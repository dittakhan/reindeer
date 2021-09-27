//
//  ReindeerStaticLibrary.m
//  ReindeerStaticLibrary
//
//  Created by Ditta on 27/09/2021.
//

#import "ReindeerStaticLibrary.h"

@implementation ReindeerStaticLibrary

void reindeerStaticLibraryTest(void) {
    NSLog(@"reindeerStaticLibraryTest");
}

void logme(const char* message, ...) {
    va_list args;
    va_start(args, message);
    NSLog(@"%@",[[NSString alloc] initWithFormat:[NSString stringWithUTF8String:message] arguments:args]);
    va_end(args);
}

@end
