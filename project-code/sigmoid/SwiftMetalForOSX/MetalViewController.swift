

import Foundation
import Cocoa
import MetalKit
import QuartzCore

//@available(OSX 10.11, *)
@available(OSX 10.11, *)
class MetalViewController : NSViewController {
    
    var metalDevice:MTLDevice!
    var metalCommandQueue:MTLCommandQueue!
    var metalDefaultLibrary:MTLLibrary!
    var metalCommandBuffer:MTLCommandBuffer!
    var metalComputeCommandEncoder:MTLComputeCommandEncoder!
    
    
    func setupMetal() {
        // Returns an array of references to all Metal devices in the system.
        
        metalDevice = MTLCreateSystemDefaultDevice()
        print("Using device: " + String(metalDevice.name))
        
        // Queue to handle an ordered list of command buffers
        metalCommandQueue = metalDevice.newCommandQueue()
        
        // Access to Metal functions that are stored in Shaders.metal file, e.g. sigmoid()
        metalDefaultLibrary = metalDevice.newDefaultLibrary()

        // Buffer for storing encoded commands that are sent to GPU
        metalCommandBuffer = metalCommandQueue.commandBuffer()
    }
    
    
    // setup shader in metal pipeline
    func setupShaderInMetalPipeline(shaderName:String) -> (shader:MTLFunction!,
        computePipelineState:MTLComputePipelineState!,
        computePipelineErrors:NSErrorPointer!)  {
            
            let shader = metalDefaultLibrary.newFunctionWithName(shaderName)
            let computePipeLineDescriptor = MTLComputePipelineDescriptor()
            computePipeLineDescriptor.computeFunction = shader

            let computePipelineErrors: NSErrorPointer = nil
            var computePipelineState:MTLComputePipelineState? = nil
            do {
                computePipelineState = try metalDevice.newComputePipelineStateWithFunction(shader!)
            } catch {
                print("catching..")
            }
            return (shader, computePipelineState, computePipelineErrors)
    }
    
    // create metal buffer
    func createMetalBuffer( vector:[Float]) -> MTLBuffer {
        let byteLength = vector.count*sizeof(Float)
        return metalDevice.newBufferWithBytes(vector, length: byteLength, options: MTLResourceOptions.StorageModeManaged)
    }
    
    // create float numbers array
    func createFloatNumbersArray(count: Int) -> [Float] {
        return [Float](count: count, repeatedValue: 0.0)
    }

    // create float metal buffer
    func createFloatMetalBuffer( vector: [Float], let metalDevice:MTLDevice) -> MTLBuffer {
        let byteLength = vector.count*sizeof(Float) // future: MTLResourceStorageModePrivate
        return metalDevice.newBufferWithBytes(vector, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }
    
}

