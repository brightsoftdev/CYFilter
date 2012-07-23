//
//  CYImagePickerController.m
//  CYFilter
//
//  Created by yi chen on 12-7-20.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "CYImagePickerController.h"

static const NSInteger kFiltersCount = 20;
static const CGFloat kFilterSelectViewHeight = 40;
static const CGFloat kFilterSelectViewWidth  = 320;
static const CGFloat kBottomBarViewHeight = 40;
static const CGFloat kBottomBarViewWidth = 320;

@interface CYImagePickerController ()

@end

@implementation CYImagePickerController

@synthesize filterType = _filterType;
@synthesize jsonObjectArray = _jsonObjectArray;
@synthesize filterBackView = _filterBackView;
@synthesize filterFrontView  = _filterFrontView;
@synthesize filterFront = _filterFront;
@synthesize filterBack = _filterBack;
@synthesize turnCameraDeviceButton = _turnCameraDeviceButton;
@synthesize filterSelectScrollView = _filterSelectScrollView;
@synthesize filterClasssNameString = _filterClassNameString;
@synthesize cameraCaptureMode ;
@synthesize cameraFlashMode;
@synthesize cameraDevice;

- (void)dealloc{
	[super dealloc];
	CY_RELEASE_SAFELY(_jsonObjectArray);
	CY_RELEASE_SAFELY(_localImagePickerController);
	
	CY_RELEASE_SAFELY(_turnFlashModeButton);
	CY_RELEASE_SAFELY(_turnCameraDeviceButton);
	CY_RELEASE_SAFELY(_bottomBarView);
	CY_RELEASE_SAFELY(_concelCaptureButton);
	CY_RELEASE_SAFELY(_startCaptureButton);
	CY_RELEASE_SAFELY(_pickFilterButton);
	CY_RELEASE_SAFELY(_filterSelectScrollView);
	
	//	滤镜处理
	CY_RELEASE_SAFELY(_filterClassNameString);

	CY_RELEASE_SAFELY(_stillCameraBack);
	CY_RELEASE_SAFELY(_stillCameraFront);
	CY_RELEASE_SAFELY(_videoCamera);
	CY_RELEASE_SAFELY(_filterFront);
	CY_RELEASE_SAFELY(_filterBack)
	CY_RELEASE_SAFELY(_sourcePicture);
	CY_RELEASE_SAFELY(_filterFrontView);
	CY_RELEASE_SAFELY(_filterBackView);
}

+ (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)sourceType{
	
	return [UIImagePickerController isSourceTypeAvailable:sourceType];
}// returns YES if source is available (i.e. camera present)


+ (NSArray *)availableMediaTypesForSourceType:(UIImagePickerControllerSourceType)sourceType{
	
	return [UIImagePickerController availableMediaTypesForSourceType:sourceType];
}// returns array of available media types (i.e. kUTTypeImage)

+ (BOOL)isCameraDeviceAvailable:(UIImagePickerControllerCameraDevice)cameraDevice {
	
	return [UIImagePickerController isCameraDeviceAvailable:cameraDevice];
}	// returns YES if camera device is available 


+ (BOOL)isFlashAvailableForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice{

	return [UIImagePickerController isFlashAvailableForCameraDevice:cameraDevice];
} // returns YES if camera device supports flash and torch.

+ (NSArray *)availableCaptureModesForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice{
	
	return [UIImagePickerController availableCaptureModesForCameraDevice:cameraDevice];
} // returns array of NSNumbers (UIImagePickerControllerCameraCaptureMode)


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - common set filters
/*
 *	初始化滤镜的一些操作
 */
- (void)commonInitFilter{

	//默认是无闪光 后相机 拍照模式
	self.cameraCaptureMode  = UIImagePickerControllerCameraCaptureModePhoto;
	self.cameraDevice  = UIImagePickerControllerCameraDeviceRear;
	self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
	
	if (!_stillCameraBack) {
		_stillCameraBack = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
		_stillCameraBack = [[GPUImageStillCamera alloc]init];
		_stillCameraBack.outputImageOrientation = UIInterfaceOrientationPortrait;
		
//		_stillCameraBack.runBenchmark = YES;
	}
	if (!_stillCameraFront) {
		_stillCameraFront = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
		_stillCameraFront = [[GPUImageStillCamera alloc]init];
		_stillCameraFront.outputImageOrientation = UIInterfaceOrientationPortrait;
		
//		_stillCameraFront.runBenchmark = YES;
	}
	//默认是无滤镜效果
	//	self.filterType = GPUIMAGE_NONE;
	self.filterType = GPUIMAGE_SATURATION;
}

#pragma mark - view life
- (void)loadView{
	[super loadView];
	
	[[UIApplication sharedApplication]setStatusBarHidden:YES];
	self.view.backgroundColor = [UIColor blackColor];
	
	//滤镜初始化
	[self commonInitFilter];
	
	//照片预览图 前
	[self.view addSubview:self.filterFrontView];
	//照片预览图 后
	[self.view addSubview:self.filterBackView];
	
	//旋转摄像头。。。将切换按钮加到预览图上面
	[self.view addSubview:self.turnCameraDeviceButton];
	
	//选择列表
	[self.view addSubview:self.filterSelectScrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	CY_RELEASE_SAFELY(_turnFlashModeButton);
	CY_RELEASE_SAFELY(_turnCameraDeviceButton);
	CY_RELEASE_SAFELY(_bottomBarView);
	CY_RELEASE_SAFELY(_concelCaptureButton);
	CY_RELEASE_SAFELY(_startCaptureButton);
	CY_RELEASE_SAFELY(_pickFilterButton);
	CY_RELEASE_SAFELY(_filterSelectScrollView);
	
	CY_RELEASE_SAFELY(_filterFrontView);
	CY_RELEASE_SAFELY(_filterBackView);
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark view 
/*
 *	滤镜预览
 */
- (GPUImageView *)filterBackView{
	if (!_filterBackView) {
		
		UIScreen *screen = [UIScreen mainScreen];
		_filterBackView = [[GPUImageView alloc]initWithFrame:CGRectMake(0,
																	0,
																	screen.bounds.size.width, 
																	screen.bounds.size.height - kBottomBarViewHeight )];
		NSLog(@"filterView.fram = %@",_filterBackView.frame);
		_filterBackView.backgroundColor = [UIColor clearColor];
	}
	return _filterBackView;
}


- (GPUImageView *)filterFrontView{
	if (!_filterFrontView) {
		
		UIScreen *screen = [UIScreen mainScreen];
		_filterFrontView = [[GPUImageView alloc]initWithFrame:CGRectMake(0,
																		0,
																		screen.bounds.size.width, 
																		screen.bounds.size.height - kBottomBarViewHeight )];
		NSLog(@"filterView.fram = %@",_filterFrontView.frame);
		_filterFrontView.backgroundColor = [UIColor clearColor];
	}
	return _filterFrontView;

}

/*
 *	滤镜选择列表
 */
- (UIScrollView *)filterSelectScrollView{
	
	if (!_filterSelectScrollView) {
		
		NSInteger size = kFilterSelectViewHeight;
		UIScrollView *filterSelectView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 480 - size, 320, size)];
		filterSelectView.userInteractionEnabled = YES;
		filterSelectView.backgroundColor = [UIColor redColor];
		NSInteger count = kFiltersCount;
		NSInteger x = 0;
		filterSelectView.contentSize = CGSizeMake(count * size, size);
		for (int i = 0 ; i < count; i ++) {
			x = i * size;
			UIButton *oneeffect = [UIButton buttonWithType:UIButtonTypeCustom];
			[oneeffect setFrame:CGRectMake(x, 0, size, size)];
			//add filter select button to scroll view
			if (0 == i % 2) {
				[oneeffect setBackgroundColor:[UIColor blueColor]];
			}else {
				[oneeffect setBackgroundColor:[UIColor greenColor]];
			}
			[oneeffect setTitle:[NSString stringWithFormat:@"%d",i + 1] forState:UIControlStateNormal];
			oneeffect.tag = i; //编号
			[oneeffect addTarget:self action:@selector(selectFilter:) forControlEvents:UIControlEventTouchUpInside];
			[filterSelectView addSubview:oneeffect];
		}
		self.filterSelectScrollView = filterSelectView;
		CY_RELEASE_SAFELY(filterSelectView);
	}
	
	return _filterSelectScrollView;
}

- (UIButton *)turnCameraDeviceButton{
	if (!_turnCameraDeviceButton) {
		UIButton *turnCameraDeviceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		turnCameraDeviceButton.frame = CGRectMake(260, 20, 60, 35);
		turnCameraDeviceButton.backgroundColor =[UIColor clearColor];
		turnCameraDeviceButton.layer.cornerRadius = 20;
		turnCameraDeviceButton.layer.masksToBounds = YES;
		turnCameraDeviceButton.alpha = 0.5;
		[turnCameraDeviceButton setTitle:@"切换" forState:UIControlStateNormal];
	
		[turnCameraDeviceButton addTarget:self
								   action:@selector(onClickTurnCameraDeviceButton) 
						 forControlEvents:UIControlEventTouchUpInside];
		_turnCameraDeviceButton = turnCameraDeviceButton;

	}
	return _turnCameraDeviceButton;
		
}



#pragma mark - event action

/*	
	json解析出来的数组，每个元素是一个dictionary
 */
- (NSArray *)jsonObjectArray{
	if (!_jsonObjectArray) {
		NSString * filePath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"json"];  
		NSString * jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
		_jsonObjectArray = [[[[SBJsonParser alloc] init] objectWithString:jsonString] retain];
	}
	return _jsonObjectArray;
}

/*	
	滤镜选中事件
 */
- (void)selectFilter:(id)sender{
	NSInteger index = ((UIButton *)sender).tag;
	if (index < self.jsonObjectArray.count) {
		NSString *filterClassNameString = [[self.jsonObjectArray objectAtIndex:((UIButton *)sender).tag]objectForKey:@"filterAction"];
		self.filterClasssNameString = filterClassNameString; //重置类名将会重置滤镜
	}
	
}

/*
	摄像头旋转
 */
- (void)onClickTurnCameraDeviceButton{
	CATransition *transtion = [CATransition animation];
	[self.filterBackView.layer removeAllAnimations];
	transtion.duration = 0.2;
	transtion.timingFunction = UIViewAnimationCurveEaseInOut;
	transtion.type = @"oglFlip"; /* 各种动画效果*/
	//	@"cube" @"moveIn" @"reveal" @"fade"(default) @"pageCurl" @"pageUnCurl"
	//	@"suckEffect" @"rippleEffect" @"oglFlip"
	
	NSArray *subViewsArray = self.view.subviews;
	NSInteger index1 = [subViewsArray indexOfObject:self.filterFrontView];
	NSInteger index2 = [subViewsArray indexOfObject:self.filterBackView];
	
	if (UIImagePickerControllerCameraDeviceRear == self.cameraDevice) { 
		// 如果当前是后摄像头
		self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		transtion.subtype = kCATransitionFromRight;   /* 动画方向*/
		
		self.filterBackView.alpha = 0.0;
#warning 此处只好旋转一下，不知道是不是初始化的时候有问题,待查
		if ([_stillCameraFront cameraPosition] != AVCaptureDevicePositionFront) {
			[_stillCameraFront rotateCamera];
		}
		self.filterFrontView.alpha = 1.0;

		[_stillCameraBack stopCameraCapture];
		[_stillCameraFront startCameraCapture];

	}else {
		self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		transtion.subtype = kCATransitionFromLeft;
		
		self.filterFrontView.alpha = 0.0;
		self.filterBackView.alpha = 1.0;
		
		[_stillCameraFront stopCameraCapture];
		[_stillCameraBack startCameraCapture];
	}
	
	[self.view exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
	[self.filterBackView.layer removeAllAnimations];
	[self.filterFrontView.layer removeAllAnimations];
	[self.filterFrontView.layer addAnimation:transtion forKey:@"transitionFilterView"];
	[self.filterBackView.layer addAnimation:transtion forKey:@"transitionFilterView"];
}	

#pragma mark - set 
/*
	设置滤镜类型
 */
- (void)setFilterType:(GPUImageShowcaseFilterType)filterType{
	switch (filterType) {
		case GPUIMAGE_NONE:
		{
			self.filterClasssNameString = @"";
		}break;
			
		case GPUIMAGE_SATURATION:{
			self.filterClasssNameString = NSStringFromClass(GPUImageSaturationFilter.class);
		}break;
		case GPUIMAGE_SHARPEN:{
			self.filterClasssNameString = NSStringFromClass(GPUImageSharpenFilter.class) ;
		}break;
		default:{
			
		}break;
	}
	
	if (_filterType != filterType) { //与当前的type不同
		_filterType = filterType;
	}
}

/*
	重置滤镜
 */
- (void)resetFilter{
	
	Class filterClass = NSClassFromString(self.filterClasssNameString);
	NSLog(@"class name == %@",self.filterClasssNameString);
	
	if ([filterClass.class isSubclassOfClass:GPUImageFilter.class] ) {
		GPUImageOutput<GPUImageInput> *filterBack= [[filterClass alloc]init];
		self.filterBack = filterBack; //重新创建滤镜类
		CY_RELEASE_SAFELY(filterBack);
		
		GPUImageOutput<GPUImageInput> *filterFront= [[filterClass alloc]init];
		self.filterFront = filterFront; //重新创建滤镜类
		CY_RELEASE_SAFELY(filterFront);
	}
}

/*
	准备采集源
 */
- (void)prepareTarget{
	
	//	后部摄像头滤镜设置]
	[_stillCameraBack removeAllTargets];
	[_stillCameraBack addTarget:self.filterBack];
	[self.filterBack prepareForImageCapture];
	[self.filterBack removeAllTargets];
	[self.filterBack addTarget:self.filterBackView];
	
	//	前部摄像头滤镜设置
	[_stillCameraFront removeAllTargets];
	[_stillCameraFront addTarget:self.filterFront];
	[self.filterFront prepareForImageCapture];
	[self.filterFront removeAllTargets];
	[self.filterFront addTarget:self.filterFrontView];
	
	//	开始采集
	if (UIImagePickerControllerCameraDeviceRear == self.cameraDevice) { 
		[_stillCameraBack startCameraCapture];
	}else {
		[_stillCameraFront startCameraCapture];
	}
}

/*
 *	重置滤镜类名，将会使得滤镜重置
 */
- (void)setFilterClasssNameString:(NSString *)filterClasssNameString{
	
	if ([self.filterClasssNameString isEqualToString:filterClasssNameString] ||
		[filterClasssNameString isEqualToString:@""]) {
		
		return;
	}
	
	[_filterClassNameString release];
	_filterClassNameString = [filterClasssNameString copy];
	
	[self resetFilter];
	[self prepareTarget];
}
@end
