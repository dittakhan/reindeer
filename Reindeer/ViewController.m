//
//  ViewController.m
//  Reindeer
//
//  Created by Ditta on 27/09/2021.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    NSLog(@"ViewController viewDidLoad");
    [super viewDidLoad];
    
    [self.reindeerView initWithImageNamed: @"Rudolph.jpg"];
}

@end
