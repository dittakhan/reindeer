/*
Abstract:
Implementation of a platform independent renderer class, which performs Metal setup and per frame rendering
*/

#import "ReindeerRenderer.h"

// Main class performing the rendering
@implementation ReindeerRenderer
{
    id<MTLDevice> _device;
    
    id<MTLTexture> _texture;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _commmandQueue;
}


- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)view
{
    self = [super init];
    if(self)
    {
        _device = view.device;

        // Create the command queue
        _commmandQueue = [_device newCommandQueue];
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

    id<MTLCommandBuffer> commandBuffer = [_commmandQueue commandBuffer];
    
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

- (void)loadImageNamed:(NSString *)name {
    NSLog(@"loadImageNamed(\"%@\")", name);
    
    UIImage *image = [UIImage imageNamed:name];
    
    if (image) {
        NSLog(@"image %@ is %dx%d", name, (int)image.size.width, (int)image.size.height);
        
        MTKTextureLoader* loader = [[MTKTextureLoader alloc] initWithDevice: _device];
        NSError *error = nil;
        _texture = [loader newTextureWithCGImage:image.CGImage options: nil error: &error];
        if (error)
            NSLog(@"newTextureWithCGImage err: %@", [error localizedDescription]);
        
        /*
        // Prepare the texture descriptor
        MTLTextureDescriptor* textureDescriptor = [[MTLTextureDescriptor alloc] init];
        
        // Indicate that each pixel has a blue, green, red, and alpha channel, where each channel is
        // an 8-bit unsigned normalized value (i.e. 0 maps to 0.0 and 255 maps to 1.0)
        textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        // Set the pixel dimensions of the texture
        textureDescriptor.width = image.size.width;
        textureDescriptor.height = image.size.height;
        
        // Create the texture from the device by using the descriptor
        id<MTLTexture> texture = [_device newTextureWithDescriptor:textureDescriptor];
        
        // Calculate the number of bytes per row in the image.
        NSUInteger bytesPerRow = 4 * image.size.width;
        
        MTLRegion region = {
            { 0, 0, 0 },         // MTLOrigin
            { textureDescriptor.width, textureDescriptor.height, 1 }   // MTLSize
        };
        
        // Copy the bytes from the data object into the texture
        [texture replaceRegion:region
                    mipmapLevel:0
                    withBytes:image.bytes
                    bytesPerRow:bytesPerRow];
        */
    }
}

@end

