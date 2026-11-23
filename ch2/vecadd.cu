
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cmath>

#define CUDA_CHECK(call) do { \
    cudaError_t e = (call); \
    if (e != cudaSuccess) { \
        printf("CUDA error %s:%d: %s\n", __FILE__, __LINE__, cudaGetErrorString(e)); \
        exit(1); \
    } \
} while(0)

__global__ void vecAddKernel(float* A, float* B, float* C, int n){
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if(index < n){
        C[index] = A[index] + B[index];
    }
}

void vecAdd(float* A_h, float* B_h, float* C_h, int n){
    int size = n * sizeof(float);
    float *A_d, *B_d, *C_d;
    cudaMalloc((void**)&A_d, size);
    cudaMalloc((void**)&B_d, size);
    cudaMalloc((void**)&C_d, size);

    cudaMemcpy(A_d, A_h, size, cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B_h, size, cudaMemcpyHostToDevice);

    struct timespec k0, k1;
    clock_gettime(CLOCK_MONOTONIC, &k0);
    vecAddKernel<<<(n+255)/256, 256>>>(A_d, B_d, C_d, n);
    cudaDeviceSynchronize();                 // <-- without this you time nothing
    clock_gettime(CLOCK_MONOTONIC, &k1);
    double kms = (k1.tv_sec - k0.tv_sec)*1000.0 + (k1.tv_nsec - k0.tv_nsec)/1e6;
    printf("GPU kernel only: %.3f ms\n", kms);

    cudaMemcpy(C_h, C_d, size, cudaMemcpyDeviceToHost);
    cudaFree(A_d); cudaFree(B_d); cudaFree(C_d);
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
