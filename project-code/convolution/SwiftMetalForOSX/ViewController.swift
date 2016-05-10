// adapted from @atveit on GitHub

import Cocoa // Apple's native object-oriented API for the OS X operating system
import Metal // a low-level, low-overhead hardware-accelerated graphics and compute API
import GameplayKit

@available(OSX 10.11, *)
class ViewController: MetalViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        let (_, computePipelineState, _) = setupShaderInMetalPipeline("doubler") // choose kernal function
        
    
        // parameters
        let N = 10001 // image is N x N
        let M = 5 // filter is M x M
        
        
        
        // Clear label
        var I = [Float](count: N*N, repeatedValue: 0) // image
        var O = [Float](count: N*N, repeatedValue: 0) // output
        var F = [Float](count: M*M, repeatedValue: 0) // filter
        
        // initialize input I
        for i in 0 ..< N*N {
            I[i] = Float(i)
        }
        
        // initialize filter F
        for i in 0 ..< M*M {
            F[i] = Float(i)
        }
        
       
        
        
        
        
        /****************************************
         * SEQUENTIAL
         ****************************************/
        let start_sequential = NSDate()
       
        for i in M/2 ..< N - M/2 {
            for j in M/2 ..< N - M/2 {
                for k in -M/2 ... M/2 {
                    for l in -M/2 ... M/2 {
                        // O[i][j] += ( I[i+k][j+l] ) * ( F[i][j] )
                        O[i*N+j] += I[((i+k)*N + (j+l))] * F[((k + M/2) * M + l + M/2)]
                        
                    }
                }
            }
        }
        print(O[888])
        print(O[889])
        print("Sequential time: \(NSDate().timeIntervalSinceDate(start_sequential))")
        
//        print(O)
        
        

        

        /****************************************
         * PARALLEL
         ****************************************/
        
        let NUM_THREADS = 256
        
        // setup CPU arrays for output
        var Output = [Float](count: N*N, repeatedValue: 0.0) // output vector
    
        // create metal buffer
        let IBuffer = createMetalBuffer(I) // input metal buffer
        let FBuffer = createMetalBuffer(F) // input metal buffer
        let OBuffer = createMetalBuffer(O) // input metal buffer

        
        // Create Metal Compute Command Encoder and add input and output buffers to it
        metalComputeCommandEncoder = metalCommandBuffer.computeCommandEncoder()
        metalComputeCommandEncoder.setBuffer(IBuffer, offset: 0, atIndex: 0) // N*N long
        metalComputeCommandEncoder.setBuffer(FBuffer, offset: 0, atIndex: 1) // N*N long
        metalComputeCommandEncoder.setBuffer(OBuffer, offset: 0, atIndex: 2) // M*M long
        
        
        // Set the shader function that Metal will use
        metalComputeCommandEncoder.setComputePipelineState(computePipelineState)
        
        // Find max number of parallel GPU threads (threadExecutionWidth) in computePipelineState
        let threadExecutionWidth = NUM_THREADS
        
        // Set up thread groups on GPU
        let threadsPerGroup = MTLSize(width:threadExecutionWidth,height:1,depth:1)
        let numThreadgroups = MTLSize(width:1, height:1, depth:1) // launch only 1 group
        
        metalComputeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        // Finalize configuration
        metalComputeCommandEncoder.endEncoding()
    
        
        let start_parallel = NSDate() // timer
        
        
        metalCommandBuffer.commit() // Start job
        metalCommandBuffer.waitUntilCompleted() // Wait for it to finish
        
        // Get output data from Metal/GPU into Swift
        let data0 = NSData(bytesNoCopy: OBuffer.contents(), length: Output.count*sizeof(Float), freeWhenDone: false)
        data0.getBytes(&Output, length:Output.count * sizeof(Float))
        
        
        print(Output[888])
        print(Output[889])
        
        // end time
        print("Parallel time: \(NSDate().timeIntervalSinceDate(start_parallel))")
        exit(0)
        
        
    }
}
