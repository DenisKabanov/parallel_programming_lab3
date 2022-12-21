#!/bin/bash

# последовательная версия
nvcc lab3_seq.cu -o lab3_seq.out

lab3_seq.out input/input4.txt output/output_seq_4.txt

# параллельная версия
nvcc lab3.cu -o lab3.out

lab3.out input/input4.txt > output/output_par_4.txt

lab3.out 