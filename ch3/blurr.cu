__global__ void blurKernel(unsigned char* in, unsigned char* out, int w, int h){
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if(col < w && row < h){
        int pixVal = 0;
        int pixels = 0;

    }
    
}