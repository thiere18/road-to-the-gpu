#include <cuda_runtime.h>
#define CHANNEL 3
__global__ void colortoGrayscaleConvertion(unsigned char* outpout, unsigned char* input, int width, int height){
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if(col < width && row < height){
        int grayOffset = row * width + col;
        int rgbOffset = grayOffset * CHANNEL;
        unsigned char r = input[rgbOffset];
        unsigned char g = input[rgbOffset + 1];
        unsigned char b = input[rgbOffset + 2];
        outpout[grayOffset] = 0.21f * r + 0.71f * g + .07f * b;
    }
}