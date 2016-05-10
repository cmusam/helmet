// adapted from @atveit on GitHub

import Cocoa // Apple's native object-oriented API for the OS X operating system
import Metal // a low-level, low-overhead hardware-accelerated graphics and compute API
import GameplayKit

@available(OSX 10.11, *)
class ViewController: MetalViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        let (_, computePipelineState, _) = setupShaderInMetalPipeline("sigmoid") // choose kernal function
        
    
        // my dot product
        func dot(A: [Float], B: [Float]) -> Float {
            var result: Float = 0.0
            for i in 0 ..< A.count {
                result += A[i] * B[i]
            }
            return result
        }
        
        // load D
        let path = NSBundle.mainBundle().pathForResource("digits", ofType:"plist")
        
        
        // parameters
        let N = 60*1000*1000 // number of Examples
        let alpha: Float = 1.0 / (1000) // step size
        
        // Clear label
        var D = [Float](count: N, repeatedValue: 0) // labels, one per example
        for i in 0 ..< N {
            D[i] = Float(i)
        }
        
        var L = [Float](count: N, repeatedValue: 0) // labels, one per example
        
    
        
        

        /****************************************
         * SEQUENTIAL
         ****************************************/
        let start_sequential = NSDate()
        
        for i in 0 ..< N {
            L[i] = 1.0 / (1.0 + exp(-D[i]))
        }
        

        // Results[i] = weight matrix for ith label
        print("Sequential time: \(NSDate().timeIntervalSinceDate(start_sequential))")
        
        
        
//
//
//        /****************************************
//         * PARALLEL
//         ****************************************/
//        
        let NUM_THREADS = 256
        
        // setup CPU arrays for output
        
        var B = [Float](count: NUM_THREADS, repeatedValue: 0.0) // output vector
    
        // create metal buffer
        let ABuffer = createMetalBuffer(D) // input metal buffer
        let BBuffer = createMetalBuffer(B) // input metal buffer
    
        
        // Create Metal Compute Command Encoder and add input and output buffers to it
        metalComputeCommandEncoder = metalCommandBuffer.computeCommandEncoder()
        metalComputeCommandEncoder.setBuffer(ABuffer, offset: 0, atIndex: 0) // N long
        metalComputeCommandEncoder.setBuffer(BBuffer, offset: 0, atIndex: 1) // N long

        
        
        // Set the shader function that Metal will use
        metalComputeCommandEncoder.setComputePipelineState(computePipelineState)
        
        // Find max number of parallel GPU threads (threadExecutionWidth) in computePipelineState
//        let threadExecutionWidth = computePipelineState.threadExecutionWidth
        let threadExecutionWidth = NUM_THREADS
        
//        print("Thread count = " + String(threadExecutionWidth)) // print number of GPU threads
        
        // Set up thread groups on GPU
        let threadsPerGroup = MTLSize(width:threadExecutionWidth,height:1,depth:1) // launch 256 threads per group
        
//        let numThreadgroups = MTLSize(width:(A.count+threadExecutionWidth)/threadExecutionWidth, height:1, depth:1)
        let numThreadgroups = MTLSize(width:1, height:1, depth:1) // launch only 1 group
        
//        print("threadsPerGroup = \(threadsPerGroup)") // 32
//        print("numThreadgroups = \(numThreadgroups)") // N / 32
        
        metalComputeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        // Finalize configuration
        metalComputeCommandEncoder.endEncoding()
        
//        print("outputVector before job is running: \(outputVector)")
        
        
        let start = NSDate() // timer
        
        
        metalCommandBuffer.commit() // Start job
        metalCommandBuffer.waitUntilCompleted() // Wait for it to finish
        
        // Get output data from Metal/GPU into Swift
        let data0 = NSData(bytesNoCopy: BBuffer.contents(), length: B.count*sizeof(Float), freeWhenDone: false)
        data0.getBytes(&B, length:B.count * sizeof(Float))
        

        
//        print("inputVector = \(inputVector)")
//        print("T0 = \(T0)")
//        print("T1 = \(T1)")
        
        
        
        
        // end time
        print("Parallel time: \(NSDate().timeIntervalSinceDate(start))")
        
        exit(0)
        
        
    }
}
