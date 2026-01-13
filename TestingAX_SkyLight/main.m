//
//  main.m
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/12/26.
//

#import <Foundation/Foundation.h>
#import "WindowFetcher.h"
#import "CLI.h"

NSArray<UserWindow *>* genUserWindows(void) {
    NSArray<UserWindow *> *windows = [WindowFetcher getWindows];
    if (!windows) {
        NSLog(@"\e[1;31mWindows Nil\e[0m");
        return nil;
    }
    
    NSLog(@"\e[1;32mGot Back: %lu Windows\e[0m", windows.count);
    return windows;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSLog(@"bundle id: %@", [[NSBundle mainBundle] bundleIdentifier]);
        NSLog(@"exe path: %@", [NSBundle mainBundle].executablePath);
        
        NSArray<UserWindow *>* windows = genUserWindows();
        if (!windows) {
            /// Warning should be covered by function above
            exit(1);
        }
        
        /// start a CLI Loop
        [Cli cliLoopOn:windows generateWindowsCompletion:^NSArray<UserWindow *>* (void) {
            return genUserWindows();
        }];
    }
    return EXIT_SUCCESS;
}
