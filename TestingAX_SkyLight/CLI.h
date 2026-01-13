//
//  CLI.h
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/13/26.
//

#import <Foundation/Foundation.h>
#import "UserWindow.h"

#ifndef CLI_H
#define CLI_H

@interface Cli : NSObject

+ (void) cliLoopOn: (NSArray<UserWindow *> *)windows
        generateWindowsCompletion:(
                                   NSArray<UserWindow *>*
                                   (^)
                                   (void)
                                   )generateWindowsCompletion;


@end

#endif
