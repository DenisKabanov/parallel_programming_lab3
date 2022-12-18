#include <iostream>
#define _USE_MATH_DEFINES
#include <math.h>
#include <vector>
#include <utility>
#include <fstream>

const double G = 6.674e-11; // гравитационная постоянная
const double dt = 0.001; // шаг по времени
const double e = 0.001; // чтобы сила не ушла в бесконечность

class MatPoint { // класс для материальной точки
    public:
        double x; // координата по x
        double y; // координата по y
        double vx; // скорость по x
        double vy; // скорость по y
        double m; // масса
};

std::vector<std::pair<double, double>> calcForce(const std::vector<MatPoint>& points) { // функция для пересчёта сил, действующих на материальную точку (на вход - вектор точек)
    std::vector<std::pair<double, double>> forces(points.size()); // вектор результата подсчитанных сил для всех точек по направлению x или y
    for (unsigned i = 0; i < points.size(); i+=1) { // проходим по всем точкам
        double sum_x = 0; // сумма сил, действующих на точку в направлении x
        double sum_y = 0; // сумма сил, действующих на точку в направлении y
        for (unsigned j = 0; j < points.size(); ++j) { // проход по всем другим точкам
            if (i == j) { // не рассматриваем одинаковые точки
                continue;
            }
            //================начальный вариант
            // double dist = sqrt(pow((points[j].x - points[i].x), 2) + pow((points[j].y - points[i].y), 2)); // рассчёт дистанции между точками
            // sum_x += points[j].m * (points[j].x - points[i].x) / pow(dist, 3); // суммируем силы по направлению x
            // sum_y += points[j].m * (points[j].y - points[i].y) / pow(dist, 3); // суммируем силы по направлению y
            //----------------добавление e в знаменатель
            double dist = sqrt(pow((points[j].x - points[i].x), 2) + pow((points[j].y - points[i].y), 2));
            sum_x += points[j].m * (points[j].x - points[i].x) / (pow(dist, 3) + e);
            sum_y += points[j].m * (points[j].y - points[i].y) / (pow(dist, 3) + e);
            //================
        }
        forces[i].first = G * points[i].m * sum_x;
        forces[i].second = G * points[i].m * sum_y;
    }
    return forces;
}

// шаг прохода
void simulationStep(std::vector<MatPoint>& points, const std::vector<std::pair<double, double>>& forces) {
    for (unsigned i = 0; i < points.size(); i+=1) { // проход по всем материальным точкам
        points[i].vx += forces[i].first / points[i].m * dt; // изменяем скорость по направлению x
        points[i].vy += forces[i].second / points[i].m * dt; // изменяем скорость по направлению y
        points[i].x += points[i].vx * dt; // изменяем положение по x
        points[i].y += points[i].vy * dt; // изменяем положение по y
    }
}

void read_file(std::vector<MatPoint>& points) { // заполнение вектора точек, считывание формата "x y v_x v_y m"
    std::ifstream file("input/input.txt");
    double x, y, vx, vy, m;
    while (!file.eof()) {
        file >> x >> y >> vx >> vy >> m;
        points.push_back({x, y, vx, vy, m});
    }
}

// вывод результатов в формате "время x_1 y_1 x_2 y_2 ..."
//===============================
void print_results(std::ofstream& file, double t, const std::vector<MatPoint> points) {
    file << t << " ";
    for (const auto &point: points) {
        file << point.x << "," << point.y << ", "; 
    }
    file << "\n";
}
//-------------------------------
// void print_results(double t, const std::vector<MatPoint> points) {
//     printf("%f ", t);
//     for (const auto &point: points) {
//         printf("%f %f ", point.x, point.y);
//     }
// }
//===============================

int main() {
    std::vector<MatPoint> points; // создание объекта для хранения информации о точках
    read_file(points); // взятие данных из файла

    std::ofstream file("output/output.txt");
    file << "t\t";
    for (unsigned i = 0; i < points.size(); ++i) {
        file << "x " << i + 1 << " y " << i + 1 << "\t";
    }
    file << "\n";

    double t = 0; // начальное время
    while(t < 20) { // цикл по времени 
        auto forces = calcForce(points); // считаем силы, действующие на все точки
        simulationStep(points, forces); // делаем шаг
        print_results(file, t, points);
        // print_results(t, points); // выводим результат на шаге
        t += dt; // увеличиваем время
    }
    return 0;
}
