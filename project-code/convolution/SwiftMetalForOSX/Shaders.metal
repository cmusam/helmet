

#include <metal_stdlib>
using namespace metal;

// doubler
kernel void doubler(const device float *I [[ buffer(0) ]], // input image
                    const device float *F [[ buffer(1) ]], // filter
                    device float *O [[ buffer(2) ]], // output
                    uint id [[ thread_position_in_grid ]],
                    uint gid [[ thread_position_in_threadgroup ]], // 0 - 255
                    uint numThreads [[ threads_per_grid ]] // 256
                    )
{

    int N = 1001; // N = size of input is N * N
    int M = 5; // M = size of filter is M * M
    
    
    int c = (N - M/2 - M/2) / numThreads; // number of rows per thread
    int start = M/2 + id * c;
    int end = M/2 + (id+1) * c;
    end = (end > N - M/2) ? N - M/2 : end;
    
    
//    for (int i = start; i < end; i++) {
    for (int i = M/2; i < N - M/2; i++) {
        for (int j = M/2; j < N - M/2; j++) {
            for (int k = -M/2; k <= M/2; k++) {
                for (int l = -M/2; l <= M/2; l++) {
                    // O[i][j] += ( I[i+k][j+l] ) * ( F[i][j] )
                    int x = (i+k)*N + (j+l);
                    int y = (k + M/2) * M + l + M/2;
                    O[i*N+j] += I[x] * F[y];
                }
            }
        }
    }

}


//// sigmoid
//kernel void sigmoid(const device float *inVector [[ buffer(0) ]],
//                    device float *outVector [[ buffer(1) ]],
//                    uint id [[ thread_position_in_grid ]]) {
//    // This calculates sigmoid for _one_ position (=id) in a vector per call on the GPU
//    outVector[id] = 1.0 / (1.0 + exp(-inVector[id]));
//}