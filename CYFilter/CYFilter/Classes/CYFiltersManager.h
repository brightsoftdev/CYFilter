//
//  CYFiltersManager.h
//  CYFilter
//
//  Created by yi chen on 12-7-16.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageOpenGLESContext.h"

@class GPUImageFilterGroup,GPUImageOutput;


@interface CYFiltersManager : NSObject
{
	
	NSNumber *countOfFilters;
	
	@private
	GPUImageFilterGroup *_filterGroup;
	NSMutableDictionary *_keyDictionary;
}

@property(nonatomic,retain)GPUImageFilterGroup *filterGroup;
@property(nonatomic,retain)NSMutableDictionary *keyDictionary;

- (void)setFilter:(GPUImageOutput<GPUImageInput> *)filter forKey:(id)key;

- (GPUImageOutput<GPUImageInput> *)filterForKey:(id)key;

+ (GPUImageOutput<GPUImageInput> *)constomFilter;

- (NSNumber *)countOfFilters;

@end
