//
//  CYFilterChain.h
//  CYFilter
//
//  Created by yi chen on 12-7-25.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPUImageOutput;
@protocol GPUImageInput ;

typedef enum {
	
	CYCaptureStatueLiving, //滤镜源，是实时
	CYCaptureStatuePicture //滤镜源，是图片
	
}CYCaptureStatue;

@interface CYFilterChain : NSObject

/*
	改滤镜的描述
 */
@property (nonatomic, readonly) NSString *title;

@property(nonatomic,retain)GPUImageOutput<GPUImageInput> *finallyFilter;

- (void)addFilterToChain:(id)filter;

@end
