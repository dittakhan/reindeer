/*
Abstract:
Implementation of a platform independent renderer class, which performs Metal setup and per frame rendering
*/

#import "ReindeerRenderer.h"
#import "ShaderTypes.h"

static const uint32_t kCntQuadTexCoords = 6;
static const uint32_t kSzQuadTexCoords  = kCntQuadTexCoords * sizeof(simd::float2);

static const uint32_t kCntQuadVertices = kCntQuadTexCoords;
static const uint32_t kSzQuadVertices  = kCntQuadVertices * sizeof(simd::float4);

static const simd::float4 kQuadVertices[kCntQuadVertices] =
{
    { -1.0f,  -1.0f, 0.0f, 1.0f },
    {  1.0f,  -1.0f, 0.0f, 1.0f },
    { -1.0f,   1.0f, 0.0f, 1.0f },
    
    {  1.0f,  -1.0f, 0.0f, 1.0f },
    { -1.0f,   1.0f, 0.0f, 1.0f },
    {  1.0f,   1.0f, 0.0f, 1.0f }
};

static const simd::float2 kQuadTexCoords[kCntQuadTexCoords] =
{
    { 0.0f, 0.0f },
    { 1.0f, 0.0f },
    { 0.0f, 1.0f },
    
    { 1.0f, 0.0f },
    { 0.0f, 1.0f },
    { 1.0f, 1.0f }
};

// Main class performing the rendering
@implementation ReindeerRenderer
{
    id<MTLDevice> _device;
  
    id<MTLTexture> _texture;
    
    id<MTLRenderPipelineState> _pipelineState;

    // The command queue used to pass commands to the device
    id<MTLCommandQueue> _commmandQueue;
    
    // The vertex data
    id<MTLBuffer> _vertices;
    
    // The texture coords data
    id<MTLBuffer> _textureCoordinates;

    // The current size of the view
    vector_uint2 _viewportSize;
}


- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)view
{
    self = [super init];
    if(self)
    {
        _device = view.device;
        
        // Set up a simple MTLBuffer with vertices which include texture coordinates
        /*
        static const Vertex vertices[] =
        {
            // Pixel positions, Texture coordinates
            { {  250,  -250 },  { 1.f, 1.f } },
            { { -250,  -250 },  { 0.f, 1.f } },
            { { -250,   250 },  { 0.f, 0.f } },

            { {  250,  -250 },  { 1.f, 1.f } },
            { { -250,   250 },  { 0.f, 0.f } },
            { {  250,   250 },  { 1.f, 0.f } },
        };
         */
        
        // Create a vertex buffer, and initialize it with the quadVertices array
        _vertices = [_device newBufferWithBytes:kQuadVertices
                                         length:kSzQuadVertices
                                        options:MTLResourceOptionCPUCacheModeDefault];
        
        _textureCoordinates = [_device newBufferWithBytes:kQuadTexCoords
                                                   length:kSzQuadTexCoords
                                                  options:MTLResourceOptionCPUCacheModeDefault];
        
        // Create the render pipeline
        
        // Load the shaders from the default library
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];

        // Set up a descriptor for creating a pipeline state object
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Texturing Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm; //view.colorPixelFormat;

        NSError *error = NULL;
        _pipelineState = [_device newRenderPipelineStateWithDescriptor: pipelineStateDescriptor
                                                                 error: &error];

        NSAssert(_pipelineState, @"Failed to create pipeline state: %@", error);

        // Create the command queue
        _commmandQueue = [_device newCommandQueue];
    }

    return self;
}

- (void)loadImageNamed:(NSString *)name {
    NSLog(@"loadImageNamed(\"%@\")", name);
    
    UIImage *image = [UIImage imageNamed:name];
    
    if (image) {
        NSLog(@"image %@ is %dx%d", name, (int)image.size.width, (int)image.size.height);
        
        MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice: _device];
        NSDictionary *options = @{ MTKTextureLoaderOptionSRGB : @false, MTKTextureLoaderOptionOrigin : @true };
        NSError *error = nil;
        
        _texture = [loader newTextureWithCGImage:image.CGImage options: options error: &error];
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

/// Called whenever view changes orientation or is resized
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // Save the size of the drawable to pass to the vertex shader.
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    id<MTLCommandBuffer> commandBuffer = [_commmandQueue commandBuffer];

    // The render pass descriptor references the texture into which Metal should draw
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil) {
        // Create a render pass and immediately end encoding, causing the drawable to be cleared
        id<MTLRenderCommandEncoder> rendererCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        // Set the region of the drawable to draw into
        /*
        [rendererCommandEncoder setViewport:(MTLViewport){0.0, 0.0, (double)_viewportSize.x, (double)_viewportSize.y,
            -1.0, 1.0 }];
        */

        [rendererCommandEncoder setRenderPipelineState:_pipelineState];

        [rendererCommandEncoder setVertexBuffer:_vertices
                                         offset:0
                                        atIndex:0];

        [rendererCommandEncoder setVertexBuffer:_textureCoordinates
                                         offset:0
                                        atIndex:1];

/*        [rendererCommandEncoder setVertexBytes:&_viewportSize
                                        length:sizeof(_viewportSize)
                                       atIndex:VertexInputIndexViewportSize];
*/
        
        // Set the texture object.  The TextureIndexBaseColor enum value corresponds
        ///  to the 'colorMap' argument in the 'samplingShader' function because its
        //   texture attribute qualifier also uses TextureIndexBaseColor for its index.
        [rendererCommandEncoder setFragmentTexture:_texture
                                           atIndex:0];
        
        // Draw the triangles.
        [rendererCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                                   vertexStart:0
                                   vertexCount:6
                                 instanceCount:1];

        [rendererCommandEncoder endEncoding];

        // Schedule a present once the framebuffer is complete using the current drawable
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

@end

