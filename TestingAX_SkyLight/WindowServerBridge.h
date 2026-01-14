//
//  WindowServerBridge.h
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/13/26.
//

#ifndef WINDOW_SERVER_BRIDGE_H
#define WINDOW_SERVER_BRIDGE_H

#import <Foundation/Foundation.h>
#import "UserWindow.h"

@interface WindowServerBridge: NSObject
- (void) focusAppForUserWindow:(UserWindow*)userWindow;
@end

#endif
