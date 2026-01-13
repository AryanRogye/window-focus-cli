//
//  SLPSTypes.h
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/12/26.
//

#ifndef SLPSTypes_H
#define SLPSTypes_H

#import <CoreGraphics/CoreGraphics.h>

static const char *skylightPath = "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight";
static const char *hiServicesPath = "/System/Library/Frameworks/ApplicationServices.framework/Frameworks/HIServices.framework/HIServices";

typedef CGError (*SLPSSetFrontProcessWithOptionsFn)(
                                                    ProcessSerialNumber *,
                                                    CGWindowID,
                                                    uint32_t
                                                    );

typedef CGError (*SLPSPostEventRecordToFn)(
                                           ProcessSerialNumber *,
                                           UInt8 *bytes
                                           );

typedef OSStatus (*GetProcessForPIDFn)(
                                     pid_t,
                                     ProcessSerialNumber *
                                     );

#endif
