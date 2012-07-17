//
//  CYUserMacroDefine.h
//  CYFilter
//
//  Created by yi chen on 12-7-16.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CY_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define CY_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }