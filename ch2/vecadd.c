#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void vecAdd(float* A, float* B , float* C, int n){
    for (int i = 0; i < n; i++)
    {
        C[i] = A[i] + B[i];
    }
}

void fill(float* input, int size){
    for ( int i = 0; i < size; i++)
    {
        input[i] = i * 1.0;
    }
}
int main(int argc, char const *argv[])
{
    const int N = 1 << 25;
    float *A = (float*)malloc(N * sizeof(float));
    float *B = (float*)malloc(N * sizeof(float));
    float *C = (float*)malloc(N * sizeof(float));
    fill(A, N);
    fill(B, N);
    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    vecAdd(A, B, C, N);
    clock_gettime(CLOCK_MONOTONIC, &t1);
    double ms = (t1.tv_sec - t0.tv_sec)*1000.0 + (t1.tv_nsec - t0.tv_nsec)/1e6;
    printf("CPU: %.3f ms\n", ms);
    vecAdd(A, B, C, N);
    bool ok = true;
    for (int i = 0; i < N; i++) {
        if (C[i] != A[i] + B[i]) {
            printf("Mismatch at %d: got %f, expected %f\n", i, C[i], A[i] + B[i]);
            ok = false;
            break;
        }
    }
    if (ok) printf("PASS\n");

    free(A);
    free(B);
    free(C);
    return 0;
}
