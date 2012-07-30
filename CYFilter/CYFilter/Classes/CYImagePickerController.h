//
//  CYImagePickerController.h
//  CYFilter
//
//  Created by yi chen on 12-7-20.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

/*
	滤镜类型
 */
typedef enum {
	GPUIMAGE_NONE = 0,//无滤镜
    GPUIMAGE_SATURATION,
    GPUIMAGE_CONTRAST,
    GPUIMAGE_BRIGHTNESS,
    GPUIMAGE_EXPOSURE,
    GPUIMAGE_RGB,
    GPUIMAGE_MONOCHROME,
    GPUIMAGE_SHARPEN,
    GPUIMAGE_UNSHARPMASK,
    GPUIMAGE_TRANSFORM,
    GPUIMAGE_TRANSFORM3D,
    GPUIMAGE_CROP,
	GPUIMAGE_MASK,
    GPUIMAGE_GAMMA,
    GPUIMAGE_TONECURVE,
    GPUIMAGE_HAZE,
    GPUIMAGE_SEPIA,
    GPUIMAGE_COLORINVERT,
    GPUIMAGE_GRAYSCALE,
    GPUIMAGE_HISTOGRAM,
    GPUIMAGE_THRESHOLD,
    GPUIMAGE_ADAPTIVETHRESHOLD,
    GPUIMAGE_PIXELLATE,
    GPUIMAGE_POLARPIXELLATE,
    GPUIMAGE_CROSSHATCH,
    GPUIMAGE_SOBELEDGEDETECTION,
    GPUIMAGE_PREWITTEDGEDETECTION,
    GPUIMAGE_CANNYEDGEDETECTION,
    GPUIMAGE_XYGRADIENT,
    GPUIMAGE_HARRISCORNERDETECTION,
    GPUIMAGE_NOBLECORNERDETECTION,
    GPUIMAGE_SHITOMASIFEATUREDETECTION,
    GPUIMAGE_BUFFER,
    GPUIMAGE_SKETCH,
    GPUIMAGE_TOON,
    GPUIMAGE_SMOOTHTOON,
    GPUIMAGE_TILTSHIFT,
    GPUIMAGE_CGA,
    GPUIMAGE_POSTERIZE,
    GPUIMAGE_CONVOLUTION,
    GPUIMAGE_EMBOSS,
    GPUIMAGE_KUWAHARA,
    GPUIMAGE_VIGNETTE,
    GPUIMAGE_GAUSSIAN,
    GPUIMAGE_GAUSSIAN_SELECTIVE,
    GPUIMAGE_FASTBLUR,
    GPUIMAGE_BOXBLUR,
    GPUIMAGE_MEDIAN,
    GPUIMAGE_BILATERAL,
    GPUIMAGE_SWIRL,
    GPUIMAGE_BULGE,
    GPUIMAGE_PINCH,
    GPUIMAGE_SPHEREREFRACTION,
    GPUIMAGE_STRETCH,
    GPUIMAGE_DILATION,
    GPUIMAGE_EROSION,
    GPUIMAGE_OPENING,
    GPUIMAGE_CLOSING,
    GPUIMAGE_PERLINNOISE,
    GPUIMAGE_VORONI,
    GPUIMAGE_MOSAIC,
    GPUIMAGE_DISSOLVE,
    GPUIMAGE_CHROMAKEY,
    GPUIMAGE_MULTIPLY,
    GPUIMAGE_OVERLAY,
    GPUIMAGE_LIGHTEN,
    GPUIMAGE_DARKEN,
    GPUIMAGE_COLORBURN,
    GPUIMAGE_COLORDODGE,
    GPUIMAGE_SCREENBLEND,
    GPUIMAGE_DIFFERENCEBLEND,
	GPUIMAGE_SUBTRACTBLEND,
    GPUIMAGE_EXCLUSIONBLEND,
    GPUIMAGE_HARDLIGHTBLEND,
    GPUIMAGE_SOFTLIGHTBLEND,
	GPUIMAGE_DISSOLVEBLEND,
    GPUIMAGE_OPACITY,
    GPUIMAGE_CUSTOM,
    GPUIMAGE_UIELEMENT,
    GPUIMAGE_FILECONFIG,
    GPUIMAGE_FILTERGROUP,
    GPUIMAGE_NUMFILTERS,
	GPUIMAGE_GLASSSPHERE,
	GPUIMAGE_HUE,
	GPUIMAGE_LAST //最后一个标记
} GPUImageShowcaseFilterType; 

/*
	状态码
 */
typedef enum{
	
	CYImagePickerStateCapture,	//	正在实时滤镜采集，默认
	CYImagePickerStateEditing	//	采集完毕，静态编辑状态

}CYImagePickerState;

@protocol CYImagePickerControllerDelegate;

@interface CYImagePickerController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	
	id<CYImagePickerControllerDelegate> _delegate;	//	代理
	GPUImageShowcaseFilterType _filterType;			//	滤镜类型
}
@property(nonatomic)GPUImageShowcaseFilterType filterType;

//	相机的一些状态设置
@property(nonatomic) UIImagePickerControllerCameraCaptureMode cameraCaptureMode __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // default is UIImagePickerControllerCameraCaptureModePhoto
@property(nonatomic) UIImagePickerControllerCameraDevice      cameraDevice      __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // default is UIImagePickerControllerCameraDeviceRear
@property(nonatomic) UIImagePickerControllerCameraFlashMode   cameraFlashMode   __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // default is UIImagePickerControllerCameraFlashModeAuto. 

// init
- (id)initWithState:(CYImagePickerState)state editImage:(UIImage *)editImage;


+ (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)sourceType;                 // returns YES if source is available (i.e. camera present)
+ (NSArray *)availableMediaTypesForSourceType:(UIImagePickerControllerSourceType)sourceType; // returns array of available media types (i.e. kUTTypeImage)

+ (BOOL)isCameraDeviceAvailable:(UIImagePickerControllerCameraDevice)cameraDevice                   __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // returns YES if camera device is available 
+ (BOOL)isFlashAvailableForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice           __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // returns YES if camera device supports flash and torch.
+ (NSArray *)availableCaptureModesForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // returns array of NSNumbers (UIImagePickerControllerCameraCaptureMode)

@end



@protocol CYImagePickerControllerDelegate <NSObject>

@optional
// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(CYImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

- (void)imagePickerControllerDidCancel:(CYImagePickerController *)picker;

@end

