/*
Abstract:
Implementation of a platform independent renderer class, which performs Metal setup and per frame rendering
*/

#import "ReindeerRenderer.h"

// Main class performing the rendering
@implementation ReindeerRenderer
{
    id<MTLDevice> device;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> commandQueue;
}


- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)view
{
    self = [super init];
    if(self)
    {
        device = view.device;

        // Create the command queue
        commandQueue = [device newCommandQueue];
    }

    return self;
}


/// Called whenever the view needs to render a frame.
- (void)drawInMTKView:(nonnull MTKView *)view
{
    // The render pass descriptor references the texture into which Metal should draw
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor == nil)
    {
        return;
    }

    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    
    // Create a render pass and immediately end encoding, causing the drawable to be cleared
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [commandEncoder endEncoding];
    
    // Get the drawable that will be presented at the end of the frame
    id<MTLDrawable> drawable = view.currentDrawable;

    // Request that the drawable texture be presented by the windowing system once drawing is done
    [commandBuffer presentDrawable:drawable];
    
    [commandBuffer commit];
}


/// Called whenever view changes orientation or is resized
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
}

@end

