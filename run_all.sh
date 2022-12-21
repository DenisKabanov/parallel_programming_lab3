#!/bin/bash

# последовательная версия
nvcc lab3_seq.cu -o lab3_seq.out

# 4 точки
# lab3_seq.out input/input4.txt output/output_seq_4.txt
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 
lab3_seq.out input/input4.txt output/output_seq_4.txt >> output/time_seq_4.txt 

# 8 точек
# lab3_seq.out input/input8.txt output/output_seq_8.txt
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 
lab3_seq.out input/input8.txt output/output_seq_8.txt >> output/time_seq_8.txt 

# 16 точек
# lab3_seq.out input/input16.txt output/output_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt
lab3_seq.out input/input16.txt output/output_seq_16.txt >> output/time_seq_16.txt

# 32 точки
# lab3_seq.out input/input32.txt output/output_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt
lab3_seq.out input/input32.txt output/output_seq_32.txt >> output/time_seq_32.txt

# 64 точки
# lab3_seq.out input/input64.txt output/output_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt
lab3_seq.out input/input64.txt output/output_seq_64.txt >> output/time_seq_64.txt





# параллельная версия
nvcc lab3.cu -o lab3.out

# 4 точки
# lab3.out input/input4.txt > output/output_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt
lab3.out input/input4.txt >> output/time_par_4.txt


# 8 точек
# lab3.out input/input8.txt > output/output_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt
lab3.out input/input8.txt >> output/time_par_8.txt


# 16 точек
# lab3.out input/input16.txt > output/output_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt
lab3.out input/input16.txt >> output/time_par_16.txt


# 32 точки
# lab3.out input/input32.txt > output/output_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt
lab3.out input/input32.txt >> output/time_par_32.txt

# 64 точки
# lab3.out input/input64.txt > output/output_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt
lab3.out input/input64.txt >> output/time_par_64.txt