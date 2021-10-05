//
//  ReindeerView.m
//  Reindeer
//
//  Created by Ditta on 04/10/2021.
//

#import "ReindeerView.h"
#import "ReindeerRenderer.h"

@implementation ReindeerView {
    ReindeerRenderer* renderer;
}

- (id)initWithCoder:(NSCoder*)coder {
    NSLog(@"ReindeerView initWithCoder");
    self = [super initWithCoder:coder];
    [self configure];
        
    return self;
}

- (id)initWithFrame:(CGRect)rect {
    NSLog(@"ReindeerView initWithFrame");
    self = [super initWithFrame: rect];
    [self configure];

    return self;
}

- (void)awakeFromNib
{
    NSLog(@"ReindeerView awakeFromNib");
    [super awakeFromNib];
    [self configure];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    NSLog(@"*** ReindeerView drawRect ***");
//}


- (void)configure {   
    self.device = MTLCreateSystemDefaultDevice();
    
    self.clearColor = MTLClearColorMake(1.0, 0.5, 0.5, 1.0); // salmon

    renderer = [[ReindeerRenderer alloc] initWithMTKView: self];

    if(renderer) {
        // Initialize the renderer with the view size.
        [renderer mtkView: self drawableSizeWillChange: self.drawableSize];

        self.delegate = renderer;
    }
    else {
        NSLog(@"Renderer initialization failed");
        return;
    }
}

- (void)initWithImageNamed:(NSString*)name {
    NSLog(@"ReindeerView initWithImageNamed(\"%@\")", name);
    
    UIImage *image = [UIImage imageNamed:name];
    
    if (image) {
        NSLog(@"image %@ is %dx%d", name, (int)image.size.width, (int)image.size.height);
        
        MTKTextureLoader* loader = [[MTKTextureLoader alloc] initWithDevice: self.device];
        NSError *error = nil;
        self.texture = [loader newTextureWithCGImage:image.CGImage options: nil error: &error];
        if (error)
            NSLog(@"newTextureWithCGImage err: %@", [error localizedDescription]);

    }
}

@end
