//
//  ViewController.swift
//  HelloMetal
//
//  Created by Clay Chang on 10/6/14.
//  Copyright (c) 2014 NTU. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {

    let vertexData: [Float] = [
         0.0,  0.5, 0.0, 1.0,
        -0.5, -0.5, 0.0, 1.0,
         0.5, -0.5, 0.0, 1.0
    ];
    let colorData: [Float] = [
        1.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0
    ];
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var vertexBuffer: MTLBuffer! = nil
    var colorBuffer: MTLBuffer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = MTLPixelFormat.BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        let vertDataSize = vertexData.count * sizeofValue(vertexData[0])
        let colorDataSize = colorData.count * sizeofValue(colorData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: vertDataSize, options: MTLResourceOptions.OptionCPUCacheModeDefault)
        colorBuffer = device.newBufferWithBytes(colorData, length: colorDataSize, options: MTLResourceOptions.OptionCPUCacheModeDefault)

        let defaultLibrary = device.newDefaultLibrary()
        let vertexProgram = defaultLibrary!.newFunctionWithName("vertex_main")
        let fragmentProgram = defaultLibrary!.newFunctionWithName("fragment_main")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat
        
        var pipelineError: NSError?
        pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor, error: &pipelineError)
        if pipelineState == nil {
            println("Failed to create pipeline state, error \(pipelineError)")
        }
        
        commandQueue = device.newCommandQueue()
        
        timer = CADisplayLink(target: self, selector: Selector("gameloop"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func render() {
        var drawable = metalLayer.nextDrawable()
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.Clear
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.Store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let renderEncoderOpt = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        if let renderEncoder = renderEncoderOpt {
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            renderEncoder.setVertexBuffer(colorBuffer, offset: 0, atIndex: 1)
            renderEncoder.drawPrimitives(MTLPrimitiveType.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            renderEncoder.endEncoding()
        }
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
    
    func gameloop() {
        autoreleasepool {
            self.render();
        }
    }

}

