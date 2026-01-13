//
//  WindowServerBridge.m
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/13/26.
//

#import "WindowServerBridge.h"
#import "SLPSTypes.h"
#import <dlfcn.h>

@interface WindowServerBridge()
@property (nonatomic, nullable) void* handle;
@property (nonatomic, nullable) SLPSSetFrontProcessWithOptionsFn setFrontProcessWithOptions;
@property (nonatomic, nullable) SLPSPostEventRecordToFn postEventRecordTo;
@end

@implementation WindowServerBridge

- (void) focusAppForWindowID:(UInt32)windowID pid:(pid_t)pid {
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.handle = NULL;
        self.setFrontProcessWithOptions = NULL;
        self.postEventRecordTo = NULL;
        [self openHandle];
    }
    return self;
}

- (void) openHandle {
    self.handle = dlopen(skylightPath, RTLD_LAZY);
    if (!self.handle) {
        NSLog(@"\e[1;31mHandle is Null\e[0m");
        exit(1);
    }
    NSLog(@"✅ Handle is Ready");
}

- (void) setSLPSSetFrontProcessWithOptions {
    NSLog(@"Attempting SLPSSetFrontProcessWithOptions");
    void* sym = dlsym(self.handle, "SLPSSetFrontProcessWithOptions");
    if (!sym) {
        NSLog(@"Attempting _SLPSSetFrontProcessWithOptions");
        sym = dlsym(self.handle, "_SLPSSetFrontProcessWithOptions");
        if (!sym) {
            NSLog(@"\e[1;31mdlsym Cant be Found: %s\e[0m", dlerror());
            exit(1);
        } else {
            NSLog(@"✅ _SLPSSetFrontProcessWithOptions Success");
        }
    } else {
        NSLog(@"✅ SLPSSetFrontProcessWithOptions Success");
    }
    
    self.setFrontProcessWithOptions = sym;
}

- (void) setSLPSPostEventRecordTo {
    NSLog(@"Attempting SLPSPostEventRecordTo");
    void *sym = dlsym(self.handle, "SLPSPostEventRecordTo");
    if (!sym) {
        NSLog(@"Attempting _SLPSPostEventRecordTo");
        sym = dlsym(self.handle, "_SLPSPostEventRecordTo");
        if (!sym) {
            NSLog(@"\e[1;31mdlsym Cant be Found: %s\e[0m", dlerror());
            exit(1);
        } else {
            NSLog(@"✅ _SLPSPostEventRecordTo Success");
        }
    } else {
        NSLog(@"✅ SLPSPostEventRecordTo Success");
    }
    
    self.postEventRecordTo = sym;
}

@end
