//
//  ViewController.m
//  Reindeer
//
//  Created by Ditta on 27/09/2021.
//

#import "ViewController.h"
#import "ReindeerRenderer.h"


@interface ViewController ()

@end

@implementation ViewController
{
    MTKView *_view;
    
    ReindeerRenderer *_renderer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _view = (MTKView *)self.view;
    
    //_view.enableSetNeedsDisplay = YES;
    
    _view.device = MTLCreateSystemDefaultDevice();
    
    _view.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
   // _view.clearColor = MTLClearColorMake(1.0, 0.5, 0.5, 1.0); // salmon

    _renderer = [[ReindeerRenderer alloc] initWithMTKView: _view];

    if(_renderer) {
        // Initialize the renderer with the view size.
        [_renderer mtkView: _view drawableSizeWillChange: _view.drawableSize];

       _view.delegate = _renderer;
    }
    else {
        NSLog(@"Renderer initialization failed");
        return;
    }
    
//    [_renderer loadImageNamed: @"Rudolph.jpg"];
    [_renderer loadImageNamed: @"Linux-Desktop.jpg"];
}

@end
