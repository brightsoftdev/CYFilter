//
//  CYFilterMasic.m
//  CYFilter
//
//  Created by chen yi on 12-7-27.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "CYFilterMosaic.h"

@implementation CYFilterMosaic

- (id)init{
	
	if (self = [super init]) {
		
		GPUImageMosaicFilter *filter = [[GPUImageMosaicFilter alloc] init];
		[(GPUImageMosaicFilter *)filter setColorOn:NO];
		[filter setDisplayTileSize:CGSizeMake(0.005, 0.005)];
//		[filter setInputRotation:kGPUImageRotateRight atIndex:0];
		[self addFilterToChain:filter];
		[filter release];
	}
	
	return self;
}

- (NSString *)title{
	return @"Masic";
}
@end
