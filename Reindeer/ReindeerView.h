//
//  ReindeerView.h
//  Reindeer
//
//  Created by Ditta on 04/10/2021.
//

#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReindeerView : MTKView

@property (nonatomic, strong) id <MTLTexture> texture;

- (void)initWithImageNamed:(NSString*)filename;

@end

NS_ASSUME_NONNULL_END
