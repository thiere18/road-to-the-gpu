
#include <vector>
#include <iostream>

template <typename T>
void fill(std::vector<T>& input){

    for (size_t i = 0; i < input.size(); i++)
    {
        input[i] = i + 1;
    }

}
template <typename T>
std::vector<T> matrixMul(const std::vector<T>& A, int M, int K, int N, const std::vector<T>& B) {

    if ((int)A.size() != M*K || (int)B.size() != K*N ) return {};
    std::vector<T> C(M * N);
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            T sum = 0;
            for (int k = 0; k < K; k++) {
                sum += A[i * K + k] * B[k * N + j];
            }
            C[i * N + j] = sum;
        }
    }

    return C;
}

int main(int argc, char const *argv[])
{
    int M = 1000;
    int K = 1000;
    int N = 2000;

    std::vector<float> A(M * K);
    std::vector<float> B(K * N);
    std::cout << "Filling A \n";
    fill(A);
    std::cout << "Filled A \n";
    std::cout << "Filling B \n";
    fill(B);
    std::cout << "Filled B \n";

    std::vector<float> res = matrixMul(A, M, K, N, B);

    return 0;
}
