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

		//亮度
		GPUImageBrightnessFilter * brightFilter = [[GPUImageBrightnessFilter alloc]init];
		[brightFilter setBrightness:4/150];
		[self addFilterToChain:brightFilter];
		[brightFilter release];		
		
		//对比度
		GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc]init];
		[contrastFilter setContrast:0.30 ];
		[self addFilterToChain:contrastFilter];
		[contrastFilter release];

		
		/*曲线调整整个风格*/
		GPUImageToneCurveFilter *toneCorveFilter = [[GPUImageToneCurveFilter alloc]init];
		
		//B通道曲线
		[toneCorveFilter setBlueControlPoints:[NSArray arrayWithObjects:
											   [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
											   [NSValue valueWithCGPoint:CGPointMake(160/255.0f, 181/255.0f)],
											   [NSValue valueWithCGPoint:CGPointMake(59/255.0f, 68/255.0f)], 
											   [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
											   nil]];
		
		//RGB通道曲线
		[toneCorveFilter setRGBControlPoints:[NSArray arrayWithObjects:
											  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
											  [NSValue valueWithCGPoint:CGPointMake(171/255.0f, 184/255.0f)], 
											  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
											  nil]];
		
		[self addFilterToChain:toneCorveFilter];
		[toneCorveFilter release];

		//单色
		GPUImageMonochromeFilter *monochromeFilter = [[ GPUImageMonochromeFilter alloc]init];
		[monochromeFilter setColorRed:255/255.0f green:174/255.0f blue:0];
		[monochromeFilter setIntensity:0.04];
		[self addFilterToChain:monochromeFilter];
		[monochromeFilter release];

		
		GPUImageOpacityFilter *opacityFilter = [[GPUImageOpacityFilter alloc]init];
		[opacityFilter setOpacity:0.04];
		[self addFilterToChain:opacityFilter];
		[opacityFilter release];
		
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
