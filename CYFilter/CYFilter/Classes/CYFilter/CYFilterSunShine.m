//
//  CYFilterSunShine.m
//  CYFilter
//
//  Created by yi chen on 12-7-26.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "CYFilterSunShine.h"

@implementation CYFilterSunShine

- (id)init{
	if (self = [super init]) {
		GPUImageHighlightShadowFilter *highLightShadowFilter = [[GPUImageHighlightShadowFilter alloc]init];
		[highLightShadowFilter setShadows:0.7];
		[highLightShadowFilter setHighlights: 0.4];
		[self addFilterToChain:highLightShadowFilter];
	}
	
	return self;
}

- (void)dealloc{
	
	[super dealloc];
}
- (NSString *)title{
	
	return @"SunShine";
}
@end
