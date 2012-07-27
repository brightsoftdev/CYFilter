//
//  CYShowCaseFilterViewController.h
//  CYFilter
//
//  Created by yi chen on 12-7-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "CYImagePickerController.h"

@protocol CYImagePickControllerDelegate <NSObject>
@optional
// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_3_0);
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
@end


@interface CYImagePickController : UIViewController
{

	
	GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
	
    GPUImagePicture *sourcePicture;
    GPUImageUIElement *uiElementInput;
	
	GPUImageShowcaseFilterType filterType;
    __unsafe_unretained UISlider *_filterSettingsSlider;
	
	@private
	UIScrollView *_filterSelectScrollView;
	GPUImageView *filterView;
}
@property(nonatomic,retain)UIScrollView *filterSelectScrollView;
@property(nonatomic,retain)GPUImageView *filterView;

@property(readwrite, unsafe_unretained, nonatomic) UISlider *filterSettingsSlider;

@end
