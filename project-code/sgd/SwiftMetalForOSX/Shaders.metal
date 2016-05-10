
#include <metal_stdlib>
using namespace metal;

// doubler
kernel void doubler(const device float *A [[ buffer(0) ]],
                    const device float *B [[ buffer(1) ]],
                    const device float *P [[ buffer(2) ]],
                    device float *T0 [[ buffer(3) ]],
                    device float *T1 [[ buffer(4) ]],
                    uint id [[ thread_position_in_grid ]],
                    uint gid [[ thread_position_in_threadgroup ]], // 0 - 255
                    uint numThreads [[ threads_per_grid ]] // 256
                    )
{

    int N = 2 * 1000 * 1000; // N
    float alpha = 1.0 / (10 * 1000 * 1000); // step size
    
    int start = (N * id) / 256;
    int end = (N * (id+1)) / 256;
    end = (end > N) ? N : end;
    
    for (int iter = 0; iter < 50; iter++) {
        for (int i = start; i < end; i++) {
            float h = T0[id] * A[i] + T1[id] * B[i];
            T0[id] += alpha * (P[i] - h) * A[i];
            T1[id] += alpha * (P[i] - h) * B[i];
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