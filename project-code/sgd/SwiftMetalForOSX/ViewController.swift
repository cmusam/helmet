// adapted from @atveit

import Cocoa // Apple's native object-oriented API for the OS X operating system
import Metal // a low-level, low-overhead hardware-accelerated graphics and compute API
import GameplayKit

@available(OSX 10.11, *)
class ViewController: MetalViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        let (_, computePipelineState, _) = setupShaderInMetalPipeline("doubler") // choose kernal function
        
    
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
        let D = NSArray(contentsOfFile: path!) as! [Float]
        print("Data load completed, \(D.count) elements in total. ")
        
        // parameters
        let N = 5000 // number of Examples
        let M = 400 // number of Features
        let alpha: Float = 1.0 / (1000) // step size
        
        // Clear label
        var L = [Float](count: N, repeatedValue: 0) // labels, one per example
        
        var A = [Float](count: M*N, repeatedValue: 0)
        var B = [Float](count: M*N, repeatedValue: 0)
        
        for i in 0 ..< N * M {
            A[i] = Float(i)
            B[i] = Float(i)
        }

        /****************************************
         * SEQUENTIAL
         ****************************************/
        let start_sequential = NSDate()
         var Results = [[Float]](count: 10, repeatedValue: [])

        for label in 0 ..< 1 {
            print("Testing label \(label)")
            
            // set up labels and theta
            var T = [Float](count: M, repeatedValue: 0)
            for i in 0 ..< N { L[i] = (i / 500) == label ? 1 : 0 }
            
            for iter in 0 ..< 5  {
                for i in 0 ..< N { // over all datapoints
                    var h: Float = 0
                    for j in 0 ..< M {
                        h += T[j] * D [M*i + j]
                    }
                    for j in 0 ..< M {
                        T[j] += alpha * (L[i]-h) * D[2*i+j];
                    }
                }
                
            }
            print(T)
            Results[label] = T
        }

        // Results[i] = weight matrix for ith label
        print("Sequential time: \(NSDate().timeIntervalSinceDate(start_sequential))")
        

        var success = 0
        
        for idx in 0 ..< 5000 {
        
            var test = [Float](count: 400, repeatedValue: 0)
            for i in 0 ..< 400 {
                let val: Int = 400 * idx + i
                test[i] = D[val]
            }
            
            var maxLabel: Int = 0
            var maxVal: Float = -1
            
            for label in 0 ..< 10 {
                let prob = dot(test, B : Results[label])
                if prob > maxVal {
                    maxVal = prob
                    maxLabel = label
                }
            }
            if (maxLabel == (idx / 500)) {
                success += 1
            }
            
        }
        
        
        print(success)

        
        exit(0)


        /****************************************
         * PARALLEL
         ****************************************/
        
        let NUM_THREADS = 256
        
        // Setup CPU arrays for output
        var T0 = [Float](count: NUM_THREADS, repeatedValue: 0.0) // output vector
        var T1 = [Float](count: NUM_THREADS, repeatedValue: 0.0) // output vector
    
        // Create metal buffer
        let ABuffer = createMetalBuffer(A) // input metal buffer
        let BBuffer = createMetalBuffer(B) // output metal buffer
        let PBuffer = createMetalBuffer(B) // output metal buffer
        let T0Buffer = createMetalBuffer(T0) // output metal buffer
        let T1Buffer = createMetalBuffer(T1) // output metal buffer
 
        // Add input and output buffers to command encoder, index 0 and 1
        metalComputeCommandEncoder = metalCommandBuffer.computeCommandEncoder()
        metalComputeCommandEncoder.setBuffer(ABuffer, offset: 0, atIndex: 0)
        metalComputeCommandEncoder.setBuffer(BBuffer, offset: 0, atIndex: 1)
        metalComputeCommandEncoder.setBuffer(PBuffer, offset: 0, atIndex: 1)
        metalComputeCommandEncoder.setBuffer(T0Buffer, offset: 0, atIndex: 1)
        metalComputeCommandEncoder.setBuffer(T1Buffer, offset: 0, atIndex: 1)
        
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
        let data0 = NSData(bytesNoCopy: T0Buffer.contents(), length: T0.count*sizeof(Float), freeWhenDone: false)
        data0.getBytes(&T0, length:T0.count * sizeof(Float))
        
        let data1 = NSData(bytesNoCopy: T1Buffer.contents(), length: T1.count*sizeof(Float), freeWhenDone: false)
        data1.getBytes(&T1, length:T1.count * sizeof(Float))
        
//        print("inputVector = \(inputVector)")
//        print("T0 = \(T0)")
//        print("T1 = \(T1)")
        
        let T0avg = T0.reduce(0.0, combine: +) / Float(T0.count)
        let T1avg = T1.reduce(0.0, combine: +) / Float(T1.count)
        print("T0 = \(T0avg), T1 = \(T1avg)")
        
        
        // end time
        print("Parallel time: \(Int(100*NSDate().timeIntervalSinceDate(start_sequential)))")
        
        exit(0)
        
        
    }
}
