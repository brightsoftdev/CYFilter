//
//  CYImagePickerController.h
//  CYFilter
//
//  Created by yi chen on 12-7-20.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

typedef enum {
	GPUIMAGE_NONE,//无滤镜
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
    GPUIMAGE_OPACITY,
    GPUIMAGE_CUSTOM,
    GPUIMAGE_UIELEMENT,
    GPUIMAGE_FILECONFIG,
    GPUIMAGE_FILTERGROUP,
    GPUIMAGE_NUMFILTERS
} GPUImageShowcaseFilterType; 


@interface CYImagePickerController : UIViewController
{
	//	滤镜类型
	GPUImageShowcaseFilterType _filterType;
	NSArray *_jsonObjectArray;	//	json解析出来的对象
	
	@private
	//	用于从系统的照片库拾取照片
	UIImagePickerController *_localImagePickerController;
	
	//	UI界面
	UIButton *_turnFlashModeButton;	//	改变闪光灯状态
	UIButton *_turnCameraDeviceButton;	//	镜头切换
	UIView *_bottomBarView;			//	底部工具栏
	UIButton *_concelCaptureButton;	//	取消采集按钮
	UIButton *_startCaptureButton;  //	拍照、开始采集按钮
	UIButton *_pickFilterButton;	//	滤镜界面呼出按钮
	UIScrollView *_filterSelectScrollView;	//  滤镜效果选择列表
	
	//	滤镜处理
	NSString *_filterClassNameString;		//	滤镜效果类名

	GPUImageStillCamera *_stillCameraBack;	//	镜头相机采集后部
	GPUImageStillCamera *_stillCameraFront; //	镜头相机采集前部
	GPUImageVideoCamera *_videoCamera;		//	视频采集
    GPUImageOutput<GPUImageInput> *_filterFront;	//	滤镜源
	GPUImageOutput<GPUImageInput> *_filterBack;
    GPUImagePicture *_sourcePicture;		//	附加图片
	GPUImageView *_filterFrontView;			//	滤镜效果图
	GPUImageView *_filterBackView;			//	滤镜后摄像头View
}
@property(nonatomic)GPUImageShowcaseFilterType filterType;
@property(nonatomic,retain)NSArray *jsonObjectArray;

@property(nonatomic,retain)UIButton *turnCameraDeviceButton;
@property(nonatomic,retain)UIScrollView * filterSelectScrollView;
@property(nonatomic,retain)GPUImageOutput<GPUImageInput> *filterFront;
@property(nonatomic,retain)GPUImageOutput<GPUImageInput> *filterBack;
@property(nonatomic,retain)GPUImageView *filterFrontView;
@property(nonatomic,retain)GPUImageView *filterBackView;

//	相机的一些状态设置
@property(nonatomic) UIImagePickerControllerCameraCaptureMode cameraCaptureMode __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // default is UIImagePickerControllerCameraCaptureModePhoto
@property(nonatomic) UIImagePickerControllerCameraDevice      cameraDevice      __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // default is UIImagePickerControllerCameraDeviceRear
@property(nonatomic) UIImagePickerControllerCameraFlashMode   cameraFlashMode   __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0); // default is UIImagePickerControllerCameraFlashModeAuto. 
@property(nonatomic,copy) NSString *filterClasssNameString;
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

