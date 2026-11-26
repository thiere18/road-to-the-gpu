#include <chrono>
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <vector>

#define CUDA_CHECK(call) do { \
    cudaError_t e = (call); \
    if (e != cudaSuccess) { \
        printf("CUDA error %s:%d: %s\n", __FILE__, __LINE__, cudaGetErrorString(e)); \
        exit(1); \
    } \
} while(0)

template <typename T> void fill(T* input, int size) {
    for (int i = 0; i < size; i++) input[i] = (T)(i % 13) + 1;   // small values: avoids float blow-up
}

// CPU reference
template <typename T>
std::vector<T> matrixMul(const std::vector<T>& A, int M, int K, int N, const std::vector<T>& B) {
    std::vector<T> C(M * N, 0);
    for (int i = 0; i < M; i++)
        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++)
                C[i*N + j] += A[i*K + k] * B[k*N + j];
    return C;
}

template <typename T>
__global__ void matrixMulKernel(const T* A, const T* B, T* C, int M, int K, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < M && col < N) {
        T sum = 0;
        for (int k = 0; k < K; k++)
            sum += A[row*K + k] * B[k*N + col];
        C[row*N + col] = sum;
    }
}

int main() {
    int M = 1000, K = 1000, N = 2000;
    float *A, *B, *C;
    CUDA_CHECK(cudaMallocManaged(&A, M*K*sizeof(float)));
    CUDA_CHECK(cudaMallocManaged(&B, K*N*sizeof(float)));
    CUDA_CHECK(cudaMallocManaged(&C, M*N*sizeof(float)));

    fill(A, M*K);
    fill(B, K*N);

    dim3 threads(16, 16);
    dim3 blocks((N + 15)/16, (M + 15)/16);

    // warm-up
    matrixMulKernel<<<blocks, threads>>>(A, B, C, M, K, N);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    auto t0 = std::chrono::high_resolution_clock::now();
    matrixMulKernel<<<blocks, threads>>>(A, B, C, M, K, N);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    auto t1 = std::chrono::high_resolution_clock::now();
    double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();

    double gflops = 2.0 * M * N * K / (ms/1000.0) / 1e9;
    printf("GPU: %.3f ms   %.1f GFLOP/s\n", ms, gflops);

    // verify against CPU reference
    std::vector<float> hA(A, A + M*K), hB(B, B + K*N);
    auto ref = matrixMul(hA, M, K, N, hB);
    bool ok = true;
    for (int i = 0; i < M*N; i++) {
        if (fabs(C[i] - ref[i]) > 1e-2) {
            printf("MISMATCH at %d: GPU=%.3f CPU=%.3f\n", i, C[i], ref[i]);
            ok = false; break;
        }
    }
    printf("%s\n", ok ? "PASS" : "FAIL");

    cudaFree(A); cudaFree(B); cudaFree(C);
    return 0;
}