//
//  CYFiltersManager.m
//  CYFilter
//
//  Created by yi chen on 12-7-16.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "CYFiltersManager.h"
#import "GPUImage.h"
@implementation CYFiltersManager

@synthesize filterGroup = _filterGroup;
@synthesize keyDictionary = _keyDictionary;
static CYFiltersManager *_sharedFilterManager = nil;

- (void)dealloc{
	
	CY_RELEASE_SAFELY(countOfFilters);
	CY_RELEASE_SAFELY(_filterGroup);
	CY_RELEASE_SAFELY(_keyDictionary);
	
	[super dealloc];
}
/**
 * 滤镜管理器单例
 */
+ (id)getInstance{
    @synchronized(self){
        if (!_sharedFilterManager) {
            _sharedFilterManager = [[CYFiltersManager alloc] init];
        }    
    }
    return _sharedFilterManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
        if(_sharedFilterManager == nil) 
        {
            _sharedFilterManager = [super allocWithZone:zone];
            return _sharedFilterManager;
        }
    }
    
    return nil;
}

- (id) copyWithZone:(NSZone*)zone
{
	return self;
}

- (id) retain
{
	return self;
}

- (NSUInteger) retainCount
{
	return UINT_MAX; 
}

- (oneway void) release
{
	// do nothing
}

- (id) autorelease
{
	return self;
}

- (id)init{
	self = [super init];
	if (self) {
		_filterGroup = [[GPUImageFilterGroup alloc]init];
		_keyDictionary = [[NSMutableDictionary alloc]init];
	}
	return self;
}
/*
 *	set filter key 
 *  need a json file to check the filter type
 */
- (void)setFilter:(GPUImageOutput<GPUImageInput> *)filter forKey:(id)key{
	if (filter) {
		
		if (!countOfFilters) {
			countOfFilters = [NSNumber numberWithInt:0];
		}
		
		[_keyDictionary setObject:countOfFilters forKey:key];
		
		// add filter to group
		[self.filterGroup addFilter:filter];
		countOfFilters = [NSNumber numberWithInt:[countOfFilters intValue] + 1];
	}
}

- (GPUImageOutput<GPUImageInput> *)filterForKey:(id)key{
	NSNumber *keyIndex = [_keyDictionary objectForKey:key];
	
	return [self.filterGroup filterAtIndex:[keyIndex intValue]];
}

+ (GPUImageOutput<GPUImageInput> *)constomFilter{
	
	// return test filter of constom
	return nil;
}


- (NSNumber *)countOfFilters{

	return countOfFilters;
}


@end
