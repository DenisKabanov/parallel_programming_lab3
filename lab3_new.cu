#include <iostream>
#include <cmath>
#include <vector>
#include <string>
#include <chrono>
#include <iomanip>
#include <fstream>
#include <cuda.h>
#include <sstream>

using namespace std;
using namespace std::chrono;

string input_path = "input/input.txt";

__device__ const double G = 6.674e-11; // гравитационная постоянная
__device__ const double dt = 0.001; // шаг по времени
__device__ const double e = 0.01; // чтобы сила не ушла в бесконечность
__device__ const double t_end = 20; // конечное время
__device__ double t = 0; // начальное время

int block_count = 1; // число блоков (thread_count выбирается динамически)

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// в предположении, что число точек делится нацело на число потоков
int points_per_thread = 1; // число точек на поток 
const int max_threads = 32; // лимит на число потоков
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

struct MatPoint { // класс для материальной точки
    double x; // координата по x
    double y; // координата по y
    double vx; // скорость по x
    double vy; // скорость по y
    double m; // масса
};

struct Direction {
    double f_x; // сила по направлению x
    double f_y; // сила по направлению y
};

MatPoint *points; // материальные точки
Direction *forces; // силы по напралениям


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
__device__ void calcForce(const MatPoint points[], Direction forces[], const int points_start_for_thread, const int points_end_for_thread) { // функция для пересчёта сил, действующих на материальную точку (на вход - вектор точек)
    for (int i = points_start_for_thread; i < points_end_for_thread; ++i) { // цикл по точкам, соответствующим потоку
        double sum_x = 0; // сумма сил, действующих на точку в направлении x
        double sum_y = 0; // сумма сил, действующих на точку в направлении y
        for (unsigned j = 0; j < blockDim.x; ++j) { // проход по всем точкам (blockDim.х - число всех потоков)
            if (i == j) { // не рассматриваем одинаковые точки
                continue;
            }
            double dist = sqrt(pow((points[j].x - points[i].x), 2) + pow((points[j].y - points[i].y), 2)); // рассчёт дистанции между точками
            sum_x += points[j].m * (points[j].x - points[i].x) / (pow(dist, 3) + e); // сила по x, действующая на точку i со стороны точки j
            sum_y += points[j].m * (points[j].y - points[i].y) / (pow(dist, 3) + e); // сила по y, действующая на точку i со стороны точки j
        }
        forces[i].f_x = G * points[i].m * sum_x; // общая сила, действующая на материальную точку i в направлении x
        forces[i].f_y = G * points[i].m * sum_y; // общая сила, действующая на материальную точку i в направлении y
    }
}
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// обновление данных точек
__device__ void simulationStep(MatPoint points[], const Direction forces[], const int points_start_for_thread, const int points_end_for_thread) {
    for (int i = points_start_for_thread; i < points_end_for_thread; ++i) { // цикл по точкам, соответствующим потоку
        points[i].vx += forces[i].f_x / points[i].m * dt; // изменяем скорость по направлению x
        points[i].vy += forces[i].f_y / points[i].m * dt; // изменяем скорость по направлению y
        points[i].x += points[i].vx * dt; // изменяем положение по x
        points[i].y += points[i].vy * dt; // изменяем положение по y
    }
}


// вывод результатов в формате "время x_1 y_1 x_2 y_2 ..."
__device__ void print_results(const double t, const MatPoint points[], const int points_per_thread) {
    printf("%.3f ", t);
    for(int i=0; i < blockDim.x * points_per_thread; ++i) // проходим по всем точкам
        printf("%f %f ", points[i].x, points[i].y);
    printf("\n");
}


__global__ void Routine(MatPoint points[], Direction forces[], const int points_per_thread){ // функция, запускаемая на девайсе
    const int points_start_for_thread = threadIdx.x * points_per_thread; // с какой точки работает поток
    const int points_end_for_thread = (threadIdx.x + 1) * points_per_thread; // по какую точку
    while (t < t_end) {
        calcForce(points, forces, points_start_for_thread, points_end_for_thread); // считаем силы, действующие на все точки
        __syncthreads(); // синхронизируемся перед обновлением данных точек
        simulationStep(points, forces, points_start_for_thread, points_end_for_thread); // обновляем данные точек
        __syncthreads(); // синхронизируемся перед следующим шагом
        if (threadIdx.x == 0) { // поток 0 выводит данные и обновляет время
            print_results(t, points, points_per_thread); // выводим результат на шаге
            t += dt; // увеличиваем время
        }
        // __syncthreads();
    }
}


int main(int argc, char* argv[]) {
    if (argc == 2) // проверка наличия аргумента (сама программа + путь для считывания файла)
        input_path = argv[1];
    // считаем число строк в файле ==> столько будет потоков
    ifstream file1(input_path);
    int thread_count = 0;
    string line;
    while (getline(file1, line))
        ++thread_count;
    file1.close();

    cudaMallocManaged(&points, thread_count * sizeof(MatPoint)); // выделение памяти под точки
    cudaMallocManaged(&forces, thread_count * sizeof(Direction)); // выделение памяти по действующие силы


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (thread_count > max_threads){ // проверка на лимит потоков
        points_per_thread = thread_count / max_threads; // изменяем число точек на поток
        thread_count = max_threads; // изменяем число потоков
    }
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


    // заполнение массивов точек и действующих сил
    ifstream file2(input_path);
    double x, y, vx, vy, m;
    int iter = 0;
    while (!file2.eof()) { // один поток - одна точка
        file2 >> x >> y >> vx >> vy >> m; // берём данные из файла
        points[iter] = {x, y, vx, vy, m}; // заполняем данные для точек
        forces[iter] = {0, 0}; // заполняем данные для точек
        iter++;
    }
    file2.close();

    auto start = high_resolution_clock::now();

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Routine<<<block_count, thread_count>>>(points, forces, points_per_thread); // вызов девайсной функции (передаём число блоков и число потоков в блоке)
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    cudaDeviceSynchronize();

    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<nanoseconds>(stop - start);
    // cout << fixed << setprecision(12) << duration.count() * 1e-9 << endl;

    cudaFree(points); // освобождение памяти
    cudaFree(forces);

    return 0;
}