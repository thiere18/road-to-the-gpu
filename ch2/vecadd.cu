
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cmath>

__global__ void vecAddKernel(float* A, float* B, float* C, int n){
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if(index < n){
        C[index] = A[index] + B[index];
    }
}
void vecAdd(float* A_h, float* B_h, float* C_h, int n){
    int size = n * sizeof(float);
    float *A_d, *B_d, *C_d;
    cudaMalloc((void**) &A_d, size);
    cudaMalloc((void**) &B_d, size);
    cudaMalloc((void**) &C_d, size);

    cudaMemcpy(A_d, A_h, size, cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B_h, size, cudaMemcpyHostToDevice);

    vecAddKernel<<<ceil(n / 256.0), 256>>>(A_d, B_d, C_d, n);

    cudaMemcpy(C_h, C_d, size, cudaMemcpyDeviceToHost);

    cudaFree(A_d);
    cudaFree(B_d);
    cudaFree(C_d);

}

void fill(float* input, int size){
    for ( int i = 0; i < size; i++)
    {
        input[i] = i * 1.2;
    }
}
int main(int argc, char const *argv[])
{
    const int N = 1 << 20;
    float *A = (float*)malloc(N * sizeof(float));
    float *B = (float*)malloc(N * sizeof(float));
    float *C = (float*)malloc(N * sizeof(float));
    fill(A, N);
    fill(B, N);
    vecAdd(A, B, C, N);
    free(A);
    free(B);
    free(C);
    return 0;
}
