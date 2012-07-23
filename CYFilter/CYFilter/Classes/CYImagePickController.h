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
//typedef enum {
//    GPUIMAGE_SATURATION,
//    GPUIMAGE_CONTRAST,
//    GPUIMAGE_BRIGHTNESS,
//    GPUIMAGE_EXPOSURE,
//    GPUIMAGE_RGB,
//    GPUIMAGE_MONOCHROME,
//    GPUIMAGE_SHARPEN,
//    GPUIMAGE_UNSHARPMASK,
//    GPUIMAGE_TRANSFORM,
//    GPUIMAGE_TRANSFORM3D,
//    GPUIMAGE_CROP,
//	GPUIMAGE_MASK,
//    GPUIMAGE_GAMMA,
//    GPUIMAGE_TONECURVE,
//    GPUIMAGE_HAZE,
//    GPUIMAGE_SEPIA,
//    GPUIMAGE_COLORINVERT,
//    GPUIMAGE_GRAYSCALE,
//    GPUIMAGE_HISTOGRAM,
//    GPUIMAGE_THRESHOLD,
//    GPUIMAGE_ADAPTIVETHRESHOLD,
//    GPUIMAGE_PIXELLATE,
//    GPUIMAGE_POLARPIXELLATE,
//    GPUIMAGE_CROSSHATCH,
//    GPUIMAGE_SOBELEDGEDETECTION,
//    GPUIMAGE_PREWITTEDGEDETECTION,
//    GPUIMAGE_CANNYEDGEDETECTION,
//    GPUIMAGE_XYGRADIENT,
//    GPUIMAGE_HARRISCORNERDETECTION,
//    GPUIMAGE_NOBLECORNERDETECTION,
//    GPUIMAGE_SHITOMASIFEATUREDETECTION,
//    GPUIMAGE_BUFFER,
//    GPUIMAGE_SKETCH,
//    GPUIMAGE_TOON,
//    GPUIMAGE_SMOOTHTOON,
//    GPUIMAGE_TILTSHIFT,
//    GPUIMAGE_CGA,
//    GPUIMAGE_POSTERIZE,
//    GPUIMAGE_CONVOLUTION,
//    GPUIMAGE_EMBOSS,
//    GPUIMAGE_KUWAHARA,
//    GPUIMAGE_VIGNETTE,
//    GPUIMAGE_GAUSSIAN,
//    GPUIMAGE_GAUSSIAN_SELECTIVE,
//    GPUIMAGE_FASTBLUR,
//    GPUIMAGE_BOXBLUR,
//    GPUIMAGE_MEDIAN,
//    GPUIMAGE_BILATERAL,
//    GPUIMAGE_SWIRL,
//    GPUIMAGE_BULGE,
//    GPUIMAGE_PINCH,
//    GPUIMAGE_SPHEREREFRACTION,
//    GPUIMAGE_STRETCH,
//    GPUIMAGE_DILATION,
//    GPUIMAGE_EROSION,
//    GPUIMAGE_OPENING,
//    GPUIMAGE_CLOSING,
//    GPUIMAGE_PERLINNOISE,
//    GPUIMAGE_VORONI,
//    GPUIMAGE_MOSAIC,
//    GPUIMAGE_DISSOLVE,
//    GPUIMAGE_CHROMAKEY,
//    GPUIMAGE_MULTIPLY,
//    GPUIMAGE_OVERLAY,
//    GPUIMAGE_LIGHTEN,
//    GPUIMAGE_DARKEN,
//    GPUIMAGE_COLORBURN,
//    GPUIMAGE_COLORDODGE,
//    GPUIMAGE_SCREENBLEND,
//    GPUIMAGE_DIFFERENCEBLEND,
//	GPUIMAGE_SUBTRACTBLEND,
//    GPUIMAGE_EXCLUSIONBLEND,
//    GPUIMAGE_HARDLIGHTBLEND,
//    GPUIMAGE_SOFTLIGHTBLEND,
//    GPUIMAGE_OPACITY,
//    GPUIMAGE_CUSTOM,
//    GPUIMAGE_UIELEMENT,
//    GPUIMAGE_FILECONFIG,
//    GPUIMAGE_FILTERGROUP,
//    GPUIMAGE_NUMFILTERS
//} GPUImageShowcaseFilterType; 

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
