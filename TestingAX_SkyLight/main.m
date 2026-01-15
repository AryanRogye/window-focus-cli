//
//  main.m
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/12/26.
//

#import <Foundation/Foundation.h>
#import "WindowFetcher.h"
#import "CLI.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSLog(@"bundle id: %@", [[NSBundle mainBundle] bundleIdentifier]);
        NSLog(@"exe path: %@", [NSBundle mainBundle].executablePath);
        
        /// start a CLI Loop
        [Cli cliLoop];
    }
    return EXIT_SUCCESS;
}
