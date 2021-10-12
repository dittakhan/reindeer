/*
Abstract:
Header for a platform independent renderer class, which performs Metal setup and per frame rendering.
*/

#import <MetalKit/MetalKit.h>

@interface ReindeerRenderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMTKView:(nonnull MTKView *)view;

- (void) loadImageNamed:(nonnull NSString *)name;

@end

