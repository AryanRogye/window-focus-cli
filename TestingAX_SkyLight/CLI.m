//
//  CLI.m
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/13/26.
//

#import "CLI.h"
#import "WindowServerBridge.h"
#import "WindowFetcher.h"

@implementation Cli

+ (NSUInteger) calcLongestBundle:(NSArray<UserWindow *> *) windows {
    NSUInteger longestBundle = 0;
    for (UserWindow *win in windows) {
        NSString *bundle = win.bundleIdentifier ?: @"<no bundle>";
        if (bundle.length > longestBundle) {
            longestBundle = bundle.length;
        }
    }
    return longestBundle;
}

+ (void) cliLoop {
    WindowServerBridge *bridge = [[WindowServerBridge alloc] init];
    NSArray<UserWindow *> *windows = [WindowFetcher getWindowsWithBridge:bridge];
    
    while(true) {
        
        NSLog(@"Pick a Window");
        
        NSUInteger longestBundle = [Cli calcLongestBundle:windows];
        
        NSString *fmt = [NSString stringWithFormat:@"%%2d | %%d | %%lu | %%-%lu@ | %%@",
                         longestBundle];
        
        /// Display Windows
        for (int i = 0; i < windows.count; i++) {
            UserWindow *win = windows[i];
            NSString *bundle = win.bundleIdentifier ?: @"<no bundle>";
            
            NSLog(@"%@", [NSString stringWithFormat:fmt,
                          (int)i,
                          win.pid,
                          win.window.windowID,
                          bundle,
                          win.title ?: @"<no title>"]);
            
        }
        
        printf("> ");
        
        char input;
        int retStr = scanf(" %c", &input);
        
        if (retStr != 1) {
            NSLog(@"\e[1;31mWrong Input\e[0m");
            exit(1);
        }
        
        input = tolower(input);
        
        /// Handle Input
        if (input == 'q') {
            NSLog(@"\e[1;32mExiting\e[0m");
            exit(1);
        }
        if (input < '0' || input >= '0' + (windows.count)) {
            NSLog(@"\e[1;31mIndex Out of Range Try Again\e[0m");
            continue;
        }
        int inputNum = input - '0';
        
        UserWindow *window = windows[inputNum];
        NSLog(@"\e[1;32mUsing Title %@\e[0m", window.title);
        NSLog(@"\e[1;32mUsing Pid   %d\e[0m", window.pid);
        NSLog(@"\e[1;32mElement Exists: %s\e[0m", window.element != NULL ? "true" : "false");
        
        /// Ask to Focus
        printf("Focus? (y or n) > ");
        char focus;
        scanf(" %c", &focus);
        focus = tolower(focus);
        
        if (focus == 'y') {
            [bridge focusAppForUserWindow:window];
            
        } else {
            NSLog(@"\e[1;31mSkipping\e[0m");
        }
        
        windows = [WindowFetcher getWindowsWithBridge:bridge];
    }
}

@end
