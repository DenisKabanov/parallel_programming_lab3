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

__device__ void calcForce(const MatPoint points[], Direction forces[]) { // функция для пересчёта сил, действующих на материальную точку (на вход - вектор точек)
    double sum_x = 0; // сумма сил, действующих на точку в направлении x
    double sum_y = 0; // сумма сил, действующих на точку в направлении y
    for (unsigned i = 0; i < blockDim.x; ++i) { // проход по всем точкам
        if (threadIdx.x == i) { // не рассматриваем одинаковые точки
            continue;
        }
        double dist = sqrt(pow((points[i].x - points[threadIdx.x].x), 2) + pow((points[i].y - points[threadIdx.x].y), 2)); // рассчёт дистанции между точками
        sum_x += points[i].m * (points[i].x - points[threadIdx.x].x) / (pow(dist, 3) + e); // сила по x, действующая на точку, рассматриваемую потоком threadIdx.x со стороны точки i
        sum_y += points[i].m * (points[i].y - points[threadIdx.x].y) / (pow(dist, 3) + e); // сила по y, действующая на точку, рассматриваемую потоком threadIdx.x со стороны точки i
    }
    forces[threadIdx.x].f_x = G * points[threadIdx.x].m * sum_x; // общая сила, действующая на материальную точку threadIdx.x в направлении x
    forces[threadIdx.x].f_y = G * points[threadIdx.x].m * sum_y; // общая сила, действующая на материальную точку threadIdx.x в направлении y
}

// обновление данных точек
__device__ void simulationStep(MatPoint points[], const Direction forces[]) {
    points[threadIdx.x].vx += forces[threadIdx.x].f_x / points[threadIdx.x].m * dt; // изменяем скорость по направлению x
    points[threadIdx.x].vy += forces[threadIdx.x].f_y / points[threadIdx.x].m * dt; // изменяем скорость по направлению y
    points[threadIdx.x].x += points[threadIdx.x].vx * dt; // изменяем положение по x
    points[threadIdx.x].y += points[threadIdx.x].vy * dt; // изменяем положение по y
}

// вывод результатов в формате "время x_1 y_1 x_2 y_2 ..."
//===============================
// __device__ void print_results(double t, const MatPoint points[], string output_path="output/output") {
//     ofstream file(output_path + to_string(threadIdx.x) + ".txt", ios::app);
//     file << t << " " << points[threadIdx.x].x << " " << points[threadIdx.x].y << endl; 
//     file.close();
// }
//-------------------------------
// __device__ void print_results(double t, const MatPoint points[]) {
//     printf("%.3f %f %f\n", t, points[threadIdx.x].x, points[threadIdx.x].y);
// }
//-------------------------------
__device__ void print_results(const double t, const MatPoint points[]) {
    printf("%.3f ", t);
    for(int i=0; i<blockDim.x; ++i)
        printf("%f %f ", points[i].x, points[i].y);
    printf("\n");
}
//===============================


__global__ void Routine(MatPoint points[], Direction forces[]){ // функция, запускаемая на девайсе
    // printf("%f %f %f %f %f\n", points[threadIdx.x].x, points[threadIdx.x].y, points[threadIdx.x].vx, points[threadIdx.x].vy, points[ithreadIdx.x].m);
    while (t < t_end) {
        calcForce(points, forces); // считаем силы, действующие на все точки
        __syncthreads(); // синхронизируемся перед обновлением данных точек
        simulationStep(points, forces); // обновляем данные точек
        __syncthreads(); // синхронизируемся перед следующим шагом
        if (threadIdx.x == 0) { // поток 0 выводит данные и собновляет время
            print_results(t, points); // выводим результат на шаге
            t += dt; // увеличиваем время
        }
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

    Routine<<<block_count, thread_count>>>(points, forces); // вызов девайсной функции (передаём число блоков и число потоков в блоке)
    cudaDeviceSynchronize();

    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<nanoseconds>(stop - start);
    // cout << fixed << setprecision(12) << duration.count() * 1e-9 << endl;

    cudaFree(points); // освобождение памяти
    cudaFree(forces);

    return 0;
}