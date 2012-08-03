//
//  CYImagePickerController.m
//  CYFilter
//
//  Created by yi chen on 12-7-20.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "CYImagePickerController.h"
#import "CYFilter.h"
static const NSInteger kFiltersCount = 20;
static const CGFloat kFilterSelectViewHeight = 40;
static const CGFloat kFilterSelectViewWidth  = 320;
static const CGFloat kFilterSelectViewUpY = 440 -  kFilterSelectViewHeight;
static const CGFloat kFilterSelectViewDownY = 480 - kFilterSelectViewHeight;
static const CGFloat kBottomBarViewHeight = 40;
static const CGFloat kBottomBarViewWidth = 320;

static const NSDictionary *filterTypeDic;

@interface CYImagePickerController ()
{
	NSArray *_jsonObjectArray;				//	json解析出来的对象
	//	用于从系统的照片库拾取照片
	
	GPUImageStillCamera *_stillCameraBack;	//	镜头相机采集后部
	GPUImageVideoCamera *_videoCamera;		//	视频采集
    GPUImagePicture *_sourcePicture;		//	附加图片 混合效果
}
//	私有成员
@property(nonatomic,retain)NSArray *jsonObjectArray;
@property(nonatomic,retain)UIImagePickerController *localImagePickerController;
@property(nonatomic,retain)UIButton *turnCameraDeviceButton;
@property(nonatomic,retain)UIView *bottomBarView;
@property(nonatomic,retain)UIButton *startCaptureButton;
@property(nonatomic,retain)UIButton *pickPictureButton;
@property(nonatomic,retain)UIScrollView * filterSelectScrollView;
@property(nonatomic,retain)GPUImagePicture *editPicture;
@property(nonatomic,retain)GPUImageOutput<GPUImageInput> *filterBack;
@property(nonatomic,retain)GPUImageBrightnessFilter *originFilter;
@property(nonatomic,retain)UIImage *originImage;
@property(nonatomic,retain)GPUImageFilterPipeline *pipeline;
@property(nonatomic,retain)CYFilterChain *filterChain;
@property(nonatomic,retain)GPUImageView *filterBackView;
@property(nonatomic,copy) NSString *filterClasssNameString;
@property(nonatomic,assign)	BOOL isFilterSelectScrollViewHidden;
@property(nonatomic,assign) CYImagePickerState pickerState;		//	状态码
@end


@implementation CYImagePickerController
@synthesize pickerState = _pickerState;
@synthesize filterType = _filterType;
@synthesize localImagePickerController = _localImagePickerController;
@synthesize jsonObjectArray = _jsonObjectArray;
@synthesize editPicture = _editPicture;
@synthesize filterBackView = _filterBackView;
@synthesize filterBack = _filterBack;
@synthesize originFilter = _originFilter;
@synthesize originImage = _originImage;
@synthesize pipeline = _pipeline;
@synthesize filterChain = _filterChain;
@synthesize turnCameraDeviceButton = _turnCameraDeviceButton;
@synthesize bottomBarView = _bottomBarView;
@synthesize startCaptureButton = _startCaptureButton;
@synthesize pickPictureButton = _pickPictureButton;
@synthesize filterSelectScrollView = _filterSelectScrollView;
@synthesize filterClasssNameString = _filterClassNameString;
@synthesize cameraCaptureMode ;
@synthesize cameraFlashMode;
@synthesize cameraDevice;
@synthesize isFilterSelectScrollViewHidden = _isFilterSelectScrollViewHidden;
#pragma mark - dealloc
- (void)dealloc{
	[super dealloc];
	CY_RELEASE_SAFELY(filterTypeDic);
	CY_RELEASE_SAFELY(_jsonObjectArray);
	CY_RELEASE_SAFELY(_localImagePickerController);
	
	CY_RELEASE_SAFELY(_turnCameraDeviceButton);
	CY_RELEASE_SAFELY(_bottomBarView);
	CY_RELEASE_SAFELY(_startCaptureButton);
	CY_RELEASE_SAFELY(_pickPictureButton);
	CY_RELEASE_SAFELY(_filterSelectScrollView);
	
	//	滤镜处理
	CY_RELEASE_SAFELY(_filterClassNameString);

	CY_RELEASE_SAFELY(_stillCameraBack);
	CY_RELEASE_SAFELY(_videoCamera);
	CY_RELEASE_SAFELY(_filterBack);
	CY_RELEASE_SAFELY(_filterChain);
	CY_RELEASE_SAFELY(_originFilter);
	CY_RELEASE_SAFELY(_sourcePicture);
	CY_RELEASE_SAFELY(_editPicture);
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

#pragma mark - --- init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
		_pickerState = CYImagePickerStateCapture ;
		
		// 此处的键值对应与GPUImageShowcaseFilterType
		NSArray *keys = [NSArray arrayWithObjects:
						 @"GPUIMAGE_NONE",//无滤镜
						 @"GPUIMAGE_SATURATION",
						 @"GPUIMAGE_CONTRAST",
						 @"GPUIMAGE_BRIGHTNESS",
						 @"GPUIMAGE_EXPOSURE",
						 @"GPUIMAGE_RGB",
						 @"GPUIMAGE_MONOCHROME",
						 @"GPUIMAGE_SHARPEN",
						 @"GPUIMAGE_UNSHARPMASK",
						 @"GPUIMAGE_TRANSFORM",
						 @"GPUIMAGE_TRANSFORM3D",
						 @"GPUIMAGE_CROP",
						 @"GPUIMAGE_MASK",
						 @"GPUIMAGE_GAMMA",
						 @"GPUIMAGE_TONECURVE",
						 @"GPUIMAGE_HAZE",
						 @"GPUIMAGE_SEPIA",
						 @"GPUIMAGE_COLORINVERT",
						 @"GPUIMAGE_GRAYSCALE",
						 @"GPUIMAGE_HISTOGRAM",
						 @"GPUIMAGE_THRESHOLD",
						 @"GPUIMAGE_ADAPTIVETHRESHOLD",
						 @"GPUIMAGE_PIXELLATE",
						 @"GPUIMAGE_POLARPIXELLATE",
						 @"GPUIMAGE_CROSSHATCH",
						 @"GPUIMAGE_SOBELEDGEDETECTION",
						 @"GPUIMAGE_PREWITTEDGEDETECTION",
						 @"GPUIMAGE_CANNYEDGEDETECTION",
						 @"GPUIMAGE_XYGRADIENT",
						 @"GPUIMAGE_HARRISCORNERDETECTION",
						 @"GPUIMAGE_NOBLECORNERDETECTION",
						 @"GPUIMAGE_SHITOMASIFEATUREDETECTION",
						 @"GPUIMAGE_BUFFER",
						 @"GPUIMAGE_SKETCH",
						 @"GPUIMAGE_TOON",
						 @"GPUIMAGE_SMOOTHTOON",
						 @"GPUIMAGE_TILTSHIFT",
						 @"GPUIMAGE_CGA",
						 @"GPUIMAGE_POSTERIZE",
						 @"GPUIMAGE_CONVOLUTION",
						 @"GPUIMAGE_EMBOSS",
						 @"GPUIMAGE_KUWAHARA",
						 @"GPUIMAGE_VIGNETTE",
						 @"GPUIMAGE_GAUSSIAN",
						 @"GPUIMAGE_GAUSSIAN_SELECTIVE",
						 @"GPUIMAGE_FASTBLUR",
						 @"GPUIMAGE_BOXBLUR",
						 @"GPUIMAGE_MEDIAN",
						 @"GPUIMAGE_BILATERAL",
						 @"GPUIMAGE_SWIRL",
						 @"GPUIMAGE_BULGE",
						 @"GPUIMAGE_PINCH",
						 @"GPUIMAGE_SPHEREREFRACTION",
						 @"GPUIMAGE_STRETCH",
						 @"GPUIMAGE_DILATION",
						 @"GPUIMAGE_EROSION",
						 @"GPUIMAGE_OPENING",
						 @"GPUIMAGE_CLOSING",
						 @"GPUIMAGE_PERLINNOISE",
						 @"GPUIMAGE_VORONI",
						 @"GPUIMAGE_MOSAIC",
						 @"GPUIMAGE_DISSOLVE",
						 @"GPUIMAGE_CHROMAKEY",
						 @"GPUIMAGE_MULTIPLY",
						 @"GPUIMAGE_OVERLAY",
						 @"GPUIMAGE_LIGHTEN",
						 @"GPUIMAGE_DARKEN",
						 @"GPUIMAGE_COLORBURN",
						 @"GPUIMAGE_COLORDODGE",
						 @"GPUIMAGE_SCREENBLEND",
						 @"GPUIMAGE_DIFFERENCEBLEND",
						 @"GPUIMAGE_SUBTRACTBLEND",
						 @"GPUIMAGE_EXCLUSIONBLEND",
						 @"GPUIMAGE_HARDLIGHTBLEND",
						 @"GPUIMAGE_SOFTLIGHTBLEND",
						 @"GPUIMAGE_DISSOLVEBLEND",
						 @"GPUIMAGE_OPACITY",
						 @"GPUIMAGE_CUSTOM",
						 @"GPUIMAGE_UIELEMENT",
						 @"GPUIMAGE_FILECONFIG",
						 @"GPUIMAGE_FILTERGROUP",
						 @"GPUIMAGE_NUMFILTERS",
						 @"GPUIMAGE_GLASSSPHERE",
						 @"GPUIMAGE_HUE",
						 nil];
		
		NSMutableArray *objects = [NSMutableArray arrayWithCapacity:keys.count];
		for (int i = 0 ; i < keys.count; i ++) {
			NSNumber *keyIndex = [NSNumber numberWithInt:i];
			[objects addObject:keyIndex];
		}
		filterTypeDic = [[NSDictionary alloc]initWithObjects:objects forKeys:keys];
   
	
		///原始滤镜
		GPUImageBrightnessFilter *originFilter = [[GPUImageBrightnessFilter alloc]init];
		self.originFilter = originFilter;
		[originFilter release];

	}
    return self;
}

- (id)initWithState:(CYImagePickerState) state editImage:(UIImage *)editImage{
	if (self = [self init]) {
		_pickerState = state;
		
		if (CYImagePickerStateEditing == _pickerState   && editImage ) {
			_editPicture = [[GPUImagePicture alloc] initWithImage:editImage smoothlyScaleOutput:YES];
			
		}
	}
	
	return self;
}
#pragma mark - common init filters
/*
 *	初始化滤镜的一些操作
 */
- (void)commonInitFilter{

	//默认是无闪光 后相机 拍照模式
	self.cameraCaptureMode  = UIImagePickerControllerCameraCaptureModePhoto;
	self.cameraDevice  = UIImagePickerControllerCameraDeviceRear;
	self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
	
	if (!_stillCameraBack &&  CYImagePickerStateCapture == _pickerState ) {
		
		_stillCameraBack = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 
															  cameraPosition:AVCaptureDevicePositionBack];
		_stillCameraBack = [[GPUImageStillCamera alloc]init];
		_stillCameraBack.outputImageOrientation = UIInterfaceOrientationPortrait;
		
//		_stillCameraBack.runBenchmark = YES; //是否打印采集信息
	}
	
	self.filterClasssNameString = @"GPUImageSepiaFilter";
}

#pragma mark - view life
- (void)loadView{
	[super loadView];
	
	//隐藏状态栏
	[[UIApplication sharedApplication]setStatusBarHidden:YES];
	self.view.backgroundColor = [UIColor blackColor];
	
	//滤镜初始化
	[self commonInitFilter];

	//照片预览图 后
	[self.view addSubview:self.filterBackView];
	
	//选择列表
	[self.view addSubview:self.filterSelectScrollView];
	
	if (_pickerState == CYImagePickerStateCapture) {
		//旋转摄像头。。。将切换按钮加到预览图上面
		[self.view addSubview:self.turnCameraDeviceButton];
		//底部布局
		[self.view addSubview:self.bottomBarView];
	}
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
	CY_RELEASE_SAFELY(_turnCameraDeviceButton);
	CY_RELEASE_SAFELY(_bottomBarView);
	CY_RELEASE_SAFELY(_startCaptureButton);
	CY_RELEASE_SAFELY(_filterSelectScrollView);
	
	CY_RELEASE_SAFELY(_filterBackView);
	
	NSLog(@"@@@@@@@@@@@@@内存警告！！！！！！！！！！！！！！");
}

/*
 * 加载完毕
 */
- (void)viewDidAppear:(BOOL)animated{

	[super viewDidAppear:animated];
	//添加一个相机的动画
	CATransition *transition = [CATransition animation];
	transition.type = @"cameraIrisHollowOpen";
	transition.duration = 0.3;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:@"easeIn"];;
	[_filterBackView.layer addAnimation:transition forKey:@"open"];
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
																	-20,
																	screen.bounds.size.width, 
																	screen.bounds.size.height )];
//																	screen.bounds.size.height - kBottomBarViewHeight )];
	}
	return _filterBackView;
}



/*
 *	滤镜选择列表
 */
- (UIScrollView *)filterSelectScrollView{
	
	if (!_filterSelectScrollView) {
		_isFilterSelectScrollViewHidden = NO;
		
		CGFloat size = kFilterSelectViewHeight;
		CGFloat y = _isFilterSelectScrollViewHidden?kFilterSelectViewDownY:kFilterSelectViewUpY;
		UIScrollView *filterSelectView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, 320, size)];
		filterSelectView.userInteractionEnabled = YES;
		filterSelectView.backgroundColor = [UIColor redColor];
		
		NSInteger count =  [self.jsonObjectArray count]; // kFiltersCount;
		NSInteger x = 0;
		CGFloat buttonWidth = size * 3;
		CGFloat buttonHeight = size;
		filterSelectView.contentSize = CGSizeMake(count * buttonWidth, buttonHeight);
		for (int i = 0 ; i < count; i ++) {
			x = i * buttonWidth;
			UIButton *oneeffect = [UIButton buttonWithType:UIButtonTypeCustom];
			[oneeffect setFrame:CGRectMake(x, 0, buttonWidth, buttonHeight )];
			
			//add filter select button to scroll view
			if (0 == i % 2) {
				[oneeffect setBackgroundColor:[UIColor blueColor]];
			}else {
				[oneeffect setBackgroundColor:[UIColor greenColor]];
			}
			NSString *titile = [[self.jsonObjectArray objectAtIndex:i] objectForKey:@"filterName"];
			[oneeffect setTitle:[NSString stringWithFormat:@"%@%d",titile,i + 1] forState:UIControlStateNormal];
			oneeffect.tag = i; //编号
			[oneeffect addTarget:self action:@selector(selectFilter:) forControlEvents:UIControlEventTouchUpInside];
			[filterSelectView addSubview:oneeffect];
		}
		self.filterSelectScrollView = filterSelectView;
		CY_RELEASE_SAFELY(filterSelectView);
	}
	
	return _filterSelectScrollView;
}

/*
	切换摄像头按钮
 */
- (UIButton *)turnCameraDeviceButton{
	if (!_turnCameraDeviceButton) {
		UIButton *turnCameraDeviceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		turnCameraDeviceButton.frame = CGRectMake(260, 20, 60, 35);
		turnCameraDeviceButton.backgroundColor =[UIColor clearColor];
		turnCameraDeviceButton.layer.cornerRadius = 20;
		turnCameraDeviceButton.layer.masksToBounds = YES;
		turnCameraDeviceButton.alpha = 0.4;
		[turnCameraDeviceButton setTitle:@"切换" forState:UIControlStateNormal];
	
		[turnCameraDeviceButton addTarget:self
								   action:@selector(onClickTurnCameraDeviceButton) 
						 forControlEvents:UIControlEventTouchUpInside];
		_turnCameraDeviceButton = [turnCameraDeviceButton retain];

	}
	return _turnCameraDeviceButton;
		
}

- (UIView *)bottomBarView{
	if (!_bottomBarView) {
		UIView *bottomBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 
																	   480 - kBottomBarViewHeight,
																	   kBottomBarViewWidth, 
																	   kBottomBarViewHeight)];
		bottomBarView.backgroundColor = [UIColor grayColor];
		bottomBarView.alpha = 1;
		bottomBarView.userInteractionEnabled = YES;
		_bottomBarView = bottomBarView;
		[_bottomBarView addSubview:self.startCaptureButton];
		[_bottomBarView addSubview:self.pickPictureButton];
	}
	return _bottomBarView;
}

/*
 *	拍照按钮
 */
- (UIButton *)startCaptureButton{
	if (!_startCaptureButton) {
		UIButton *startCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[startCaptureButton setTintColor:[UIColor grayColor]];
		[startCaptureButton setTitle:@"拍照"forState:UIControlStateNormal];
		[startCaptureButton setBackgroundColor:[UIColor clearColor]];
		startCaptureButton.frame = CGRectMake((kBottomBarViewWidth - 50)/2.0,
											  (kBottomBarViewHeight - 30)/2.0,
											  50, 
											  30);
		[startCaptureButton addTarget:self 
							   action:@selector(takeOnePicture:) 
					 forControlEvents:UIControlEventTouchUpInside];
		
		_startCaptureButton = [startCaptureButton retain];
	}
	return _startCaptureButton;
}

/**
	选图按钮
 */
- (UIButton *)pickPictureButton{
	if (!_pickPictureButton) {
		UIButton *startCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[startCaptureButton setTintColor:[UIColor grayColor]];
		[startCaptureButton setTitle:@"选图"forState:UIControlStateNormal];
		[startCaptureButton setBackgroundColor:[UIColor clearColor]];
		startCaptureButton.frame = CGRectMake((kBottomBarViewWidth - 50)/2.0 - 80,
											  (kBottomBarViewHeight - 30)/2.0,
											  50, 
											  30);
		[startCaptureButton addTarget:self 
							   action:@selector(pickOnePicture:) 
					 forControlEvents:UIControlEventTouchUpInside];
		
		_pickPictureButton = startCaptureButton;
	}
	return _pickPictureButton;
}

#pragma mark - other

- (UIImagePickerController *)localImagePickerController{
	if (!_localImagePickerController) {
		_localImagePickerController = [[UIImagePickerController alloc]init];
		[_localImagePickerController setDelegate:self];
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			_localImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		}
	}
	return _localImagePickerController;
}

/*	
 *	json解析出来的数组，每个元素是一个dictionary
 */
- (NSArray *)jsonObjectArray{
	if (!_jsonObjectArray) {
		NSString * filePath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"json"];  
		NSString * jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
		_jsonObjectArray = [[[[SBJsonParser alloc] init] objectWithString:jsonString] retain];
		NSLog(@"json data == %@",[_jsonObjectArray description]);
	}
	return _jsonObjectArray;
}

/*
 *	下拉滤镜选择列表
 */
- (void)pullFilterSelectScrollViewDown{
	if (_isFilterSelectScrollViewHidden) {
		return;
	}else {
		__block typeof(self)bself = self;
		[UIView animateWithDuration:0.2 animations:^(){
			CGRect r = bself.filterSelectScrollView.frame ;
			bself.filterSelectScrollView.frame = CGRectMake(r.origin.x,
														   kFilterSelectViewDownY, 
														   r.size.width, 
														   r.size.height);
		}completion:^(BOOL finished){
			bself.isFilterSelectScrollViewHidden = YES;
		}];

	}
	
}

/*
 *	上推滤镜选择列表
 */
- (void)pushFilterSelectScrollViewUp{
	if (!_isFilterSelectScrollViewHidden) {
		return;
	}else {
		__block typeof(self)bself = self;

		[UIView animateWithDuration:0.2 animations:^(){
			CGRect r = bself.filterSelectScrollView.frame;
			bself.filterSelectScrollView.frame = CGRectMake(r.origin.x,
														   kFilterSelectViewUpY, 
														   r.size.width, 
														   r.size.height);
		}completion:^(BOOL finished){
			bself.isFilterSelectScrollViewHidden = NO;
		}];
		
	}
}

#pragma mark - event action


/*	
	滤镜选中事件
 */
- (void)selectFilter:(id)sender{
	NSInteger index = ((UIButton *)sender).tag;
	if (index < self.jsonObjectArray.count) {
		id jsonObject = [self.jsonObjectArray objectAtIndex:index];
		

		NSString *typeString = [jsonObject objectForKey:@"filterTypeEnum"];
		if (typeString) {
			self.filterType = [[filterTypeDic objectForKey:typeString]intValue];
		}
		
		NSString *filterClassNameString = [jsonObject objectForKey:@"filterAction"];
		if (filterClassNameString) {
			self.filterClasssNameString = filterClassNameString; //重置类名将会重置滤镜
		}
		
		if ([jsonObject objectForKey:@"value"]) {
			//	更新滤镜参数值
			float value = [[jsonObject objectForKey:@"value"]floatValue];
			[self updateFilterValue:value];
		}
		
	}
}

/*
	摄像头旋转
 */
- (void)onClickTurnCameraDeviceButton{
//	CATransition *transtion = [CATransition animation];
//	[self.filterBackView.layer removeAllAnimations];
//	transtion.duration = 0.2;
//	transtion.timingFunction = UIViewAnimationCurveEaseInOut;
//	transtion.type = @"oglFlip"; /* 各种动画效果*/
	//	@"cube" @"moveIn" @"reveal" @"fade"(default) @"pageCurl" @"pageUnCurl"
	//	@"suckEffect" @"rippleEffect" @"oglFlip"
	
	if (self.pickerState == CYImagePickerStateCapture) {
		[_stillCameraBack rotateCamera];
	}
	return;
}	

/*
	拍摄一张照片并记录
 */

- (void)takeOnePicture:(id)sender{
	
	if (CYImagePickerStateEditing == self.pickerState ) {
		//如果正在编辑状态 直接返回 暂时这样处理
		self.pickerState = CYImagePickerStateCapture;
		
		@autoreleasepool {
			UIImage *image = [self.filterBack imageFromCurrentlyProcessedOutput];
			NSLog(@"image width = %f height = %f",image.size.width,image.size.height);
			if (image) {
				UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
			}
			
			[self resetFilter];
			[self prepareTarget];
		}
		

		return;
	}
	
	//添加一个相机关闭的动画
	CATransition *transition = [CATransition animation];
	transition.type = @"cameraIrisHollowClose";
	transition.duration = 0.4;
	transition.timingFunction = UIViewAnimationCurveEaseInOut;
	
	__block GPUImageStillCamera *stillCamera = _stillCameraBack;
	__block UIView *filterView = _filterBackView;
	
	[_filterBackView.layer removeAllAnimations];
	[_filterBackView.layer addAnimation:transition forKey:@"close"];

	__block typeof(self) bself = self;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[stillCamera pauseCameraCapture];
		bself.startCaptureButton.hidden = YES;

		///此处获取原始照片
		GPUImageBrightnessFilter *originFilter =  [[self.pipeline filters]objectAtIndex:0];
		if (originFilter) {
			[stillCamera capturePhotoAsPNGProcessedUpToFilter:originFilter withCompletionHandler:^(NSData *processedPNG, NSError *error){
				
				[stillCamera resumeCameraCapture]; 
				bself.startCaptureButton.hidden = NO;
				[filterView.layer removeAllAnimations];
				
				UIImage *image = [[UIImage alloc]initWithData: processedPNG];
				NSLog(@"height = %f width = %f",image.size.height,image.size.height);
				
				GPUImagePicture *editPicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
				bself.editPicture = editPicture;
				[editPicture release];
								
				bself.pickerState = CYImagePickerStateEditing;
				[bself resetFilter];
				[bself prepareTarget];
				
				UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
				self.originImage = image ;
				
				[image release];
			}];
			
			dispatch_async(dispatch_get_main_queue (), ^{
				
				//等照片数据读取完之后，在主线程中更新UI，比如做照片收缩动画等操作。
				[bself pushFilterSelectScrollViewUp];
			});
		}
	});
}

/*
 *	选择一张照片
 */
- (void)pickOnePicture:(id)sender{
	
	[self presentModalViewController:self.localImagePickerController animated:NO];
}
#pragma mark - setter 

/*
 *	设置滤镜类型
 */
- (void)setFilterType:(GPUImageShowcaseFilterType)filterType{

	if (_filterType != filterType) { //与当前的type不同
		_filterType = filterType;
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

#pragma mark - filter operation

/*
 * 附加的滤镜初始化设置,不是所有的类型都需要这一步骤
 */
- (void)additionFilterInit{

	switch (_filterType) {
		case GPUIMAGE_FILTERGROUP:
		{			
			GPUImageOutput<GPUImageInput> *filter = nil;
		
			filter = self.filterBack;
			NSLog(@"filter class = %@",NSStringFromClass(self.filterBack.class ) );
			
			GPUImagePinchDistortionFilter *sepiaFilter = [[GPUImagePinchDistortionFilter alloc] init];
			[sepiaFilter prepareForImageCapture];
			[(GPUImageFilterGroup *)filter addFilter:sepiaFilter];
			
			GPUImageVignetteFilter *pixellateFilter = [[GPUImageVignetteFilter alloc] init];
			[pixellateFilter prepareForImageCapture];
			[(GPUImageFilterGroup *)filter addFilter:pixellateFilter];
			[sepiaFilter setScale: - 0.8];
			[sepiaFilter setRadius:2.0];
			[sepiaFilter addTarget:pixellateFilter];
			[(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:sepiaFilter]];
			[(GPUImageFilterGroup *)filter setTerminalFilter:pixellateFilter];
			
			CY_RELEASE_SAFELY(pixellateFilter);
			CY_RELEASE_SAFELY(sepiaFilter);
			
			[filter prepareForImageCapture];
		
		}break;
		case GPUIMAGE_DISSOLVEBLEND:{
			UIImage *inputImage = [UIImage imageNamed:@"curvies.png"];
			if (_sourcePicture) {
				CY_RELEASE_SAFELY(_sourcePicture);
			}
			_sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage ];
            [_sourcePicture processImage];      
            [_sourcePicture addTarget:self.filterBack];
		}break;
			
		case GPUIMAGE_MONOCHROME: {
			[(GPUImageMonochromeFilter *)self.filterBack setColor:(GPUVector4){0.5f, 0.5f, 0.5f, 1.f}];		
				//{0.5f, 0.3f, 1.0f, 0.0f}
		}break;
			
		case GPUIMAGE_CONVOLUTION:{ //此处卷积积分主要用于模糊，锐化，浮雕等。
			GPUImageOutput<GPUImageInput> *filter = self.filterBack;

			[(GPUImage3x3ConvolutionFilter *)filter setConvolutionKernel:(GPUMatrix3x3){
//					{-1.0f,  0.0f, 1.0f}, //设置卷积的向量
//					{-2.0f, 0.0f, 2.0f},
//					{-1.0f,  0.0f, 1.0f}
//					{-0.0f,  0.0f, 0.0f}, 
//					{-0.0f, 1.0f, 0.0f},
//					{-0.0f,  0.0f, 0.0f}
//					{-1.0f,  -1.0f, -1.0f},
//					{-1.0f, 9.0, -1.0f},
//					{-1.0f,  -1.0f, -1.0f}
				{ 0.11f,  0.11f, 0.11f},
				{ 0.11f,  0.11f, 0.11f},
				{ 0.11f,  0.11f, 0.11f}
//					{-2, -1, 0}, //卷积效果 其实就是GPUImageEmbossFilter
//					{-1, 1, 1},
//					{0, 1, 2}

			}];
			
		}break;
			
		case GPUIMAGE_RGB:{
			GPUImageOutput<GPUImageInput> *filter = self.filterBack;

			//	 RGB 保留量 (0.0 - 1.0f)
			[(GPUImageRGBFilter *)filter setRed:0.95];
			[(GPUImageRGBFilter *)filter setGreen:0.5];
			[(GPUImageRGBFilter *)filter setBlue:0.6];
			
		}break;
		default:
			break;
	}
}

/*
 *	重置滤镜
 */
- (void)resetFilter{
	Class filterClass = NSClassFromString(self.filterClasssNameString);
	NSLog(@"class name == %@",self.filterClasssNameString);
	
	if ([filterClass.class isSubclassOfClass:GPUImageFilter.class] 
			|| [filterClass.class isKindOfClass:GPUImageFilter.class]
			||	[filterClass.class isKindOfClass:GPUImageFilterGroup.class]) 
	{
		GPUImageOutput<GPUImageInput> *filterBack= [[filterClass alloc]init];
		self.filterBack = filterBack; //重新创建滤镜类
		CY_RELEASE_SAFELY(filterBack);
		
	}else if([filterClass.class isSubclassOfClass:CYFilterChain.class ]){ //自定义的滤镜
		
		CYFilterChain *filterChain = (CYFilterChain *)[[filterClass alloc]init];
		
		GPUImageOutput<GPUImageInput> *filterBack= [(filterChain).finallyFilter retain];
		self.filterBack = filterBack;
		CY_RELEASE_SAFELY(filterBack);
		
		self.filterChain = filterChain;
		CY_RELEASE_SAFELY(filterChain);
		
	}else{ //若没有指定滤镜类型，给个原始滤镜，保留原来的画质
		
		GPUImageOutput<GPUImageInput> *filterBack= [[GPUImageBrightnessFilter alloc]init];
		self.filterBack = filterBack; //重新创建滤镜类
		CY_RELEASE_SAFELY(filterBack);
	}
}

/*
 *	准备采集源
 */
- (void)prepareTarget{
	if (_pickerState == CYImagePickerStateCapture) { // 实时滤镜
		
		if (self.filterBack ) {

			//	一些特殊滤镜的附加处理,如：各种混合模式滤镜,滤镜组合时的一些初始化
			[self additionFilterInit];
			GPUImageFilterPipeline *pipeline = [[GPUImageFilterPipeline alloc]
													initWithOrderedFilters:[NSArray arrayWithObjects:self.originFilter,self.filterBack, nil]
																	 input:_stillCameraBack 
																	output:self.filterBackView];
			self.pipeline = pipeline;
			[pipeline release];
		}		
		//	开始采集
		[_stillCameraBack startCameraCapture];

	}else {
		if (self.filterBack) {
			[_editPicture removeAllTargets];
			[_editPicture addTarget:self.filterBack];
			[self additionFilterInit];
			[self.filterBack addTarget:self.filterBackView];
			
			[_editPicture processImage];
		}
		
		[_stillCameraBack removeAllTargets];
		[_stillCameraBack stopCameraCapture];
	}
}

/*
 *	更新滤镜的参数值，更新值的时候要视具体的滤镜类型而定
 *	一般情况下，只有一个参数值，附加的值需要在additionFilterInit设定
 */
- (void)updateFilterValue:(float)value{
//	switch(filterType)
//    {
//        case GPUIMAGE_SEPIA: [(GPUImageSepiaFilter *)filter setIntensity:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_PIXELLATE: [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_POLARPIXELLATE: [(GPUImagePolarPixellateFilter *)filter setPixelSize:CGSizeMake([(UISlider *)sender value], [(UISlider *)sender value])]; break;
//        case GPUIMAGE_SATURATION: [(GPUImageSaturationFilter *)filter setSaturation:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_CONTRAST: [(GPUImageContrastFilter *)filter setContrast:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_BRIGHTNESS: [(GPUImageBrightnessFilter *)filter setBrightness:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_EXPOSURE: [(GPUImageExposureFilter *)filter setExposure:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_MONOCHROME: [(GPUImageMonochromeFilter *)filter setIntensity:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_RGB: [(GPUImageRGBFilter *)filter setGreen:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_SHARPEN: [(GPUImageSharpenFilter *)filter setSharpness:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_HISTOGRAM: [(GPUImageHistogramFilter *)filter setDownsamplingFactor:round([(UISlider *)sender value])]; break;
//        case GPUIMAGE_UNSHARPMASK: [(GPUImageUnsharpMaskFilter *)filter setIntensity:[(UISlider *)sender value]]; break;
//			//        case GPUIMAGE_UNSHARPMASK: [(GPUImageUnsharpMaskFilter *)filter setBlurSize:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_GAMMA: [(GPUImageGammaFilter *)filter setGamma:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_CROSSHATCH: [(GPUImageCrosshatchFilter *)filter setCrossHatchSpacing:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_POSTERIZE: [(GPUImagePosterizeFilter *)filter setColorLevels:round([(UISlider*)sender value])]; break;
//		case GPUIMAGE_HAZE: [(GPUImageHazeFilter *)filter setDistance:[(UISlider *)sender value]]; break;
//		case GPUIMAGE_THRESHOLD: [(GPUImageLuminanceThresholdFilter *)filter setThreshold:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_ADAPTIVETHRESHOLD: [(GPUImageAdaptiveThresholdFilter *)filter setBlurSize:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_DISSOLVE: [(GPUImageDissolveBlendFilter *)filter setMix:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_CHROMAKEY: [(GPUImageChromaKeyBlendFilter *)filter setThresholdSensitivity:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_KUWAHARA: [(GPUImageKuwaharaFilter *)filter setRadius:round([(UISlider *)sender value])]; break;
//        case GPUIMAGE_SWIRL: [(GPUImageSwirlFilter *)filter setAngle:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_EMBOSS: [(GPUImageEmbossFilter *)filter setIntensity:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_CANNYEDGEDETECTION: [(GPUImageCannyEdgeDetectionFilter *)filter setBlurSize:[(UISlider*)sender value]]; break;
//			//        case GPUIMAGE_CANNYEDGEDETECTION: [(GPUImageCannyEdgeDetectionFilter *)filter setLowerThreshold:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_HARRISCORNERDETECTION: [(GPUImageHarrisCornerDetectionFilter *)filter setThreshold:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_NOBLECORNERDETECTION: [(GPUImageNobleCornerDetectionFilter *)filter setThreshold:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_SHITOMASIFEATUREDETECTION: [(GPUImageShiTomasiFeatureDetectionFilter *)filter setThreshold:[(UISlider*)sender value]]; break;
//			//        case GPUIMAGE_HARRISCORNERDETECTION: [(GPUImageHarrisCornerDetectionFilter *)filter setSensitivity:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_SMOOTHTOON: [(GPUImageSmoothToonFilter *)filter setBlurSize:[(UISlider*)sender value]]; break;
//			//        case GPUIMAGE_BULGE: [(GPUImageBulgeDistortionFilter *)filter setRadius:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_BULGE: [(GPUImageBulgeDistortionFilter *)filter setScale:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_SPHEREREFRACTION: [(GPUImageSphereRefractionFilter *)filter setRadius:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_TONECURVE: [(GPUImageToneCurveFilter *)filter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, [(UISlider *)sender value])], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]]; break;
//        case GPUIMAGE_PINCH: [(GPUImagePinchDistortionFilter *)filter setScale:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_PERLINNOISE:  [(GPUImagePerlinNoiseFilter *)filter setScale:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_MOSAIC:  [(GPUImageMosaicFilter *)filter setDisplayTileSize:CGSizeMake([(UISlider *)sender value], [(UISlider *)sender value])]; break;
//        case GPUIMAGE_VIGNETTE: [(GPUImageVignetteFilter *)filter setVignetteEnd:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_GAUSSIAN: [(GPUImageGaussianBlurFilter *)filter setBlurSize:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_BILATERAL: [(GPUImageBilateralFilter *)filter setBlurSize:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_FASTBLUR: [(GPUImageFastBlurFilter *)filter setBlurPasses:round([(UISlider*)sender value])]; break;
//			//        case GPUIMAGE_FASTBLUR: [(GPUImageFastBlurFilter *)filter setBlurSize:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_OPACITY:  [(GPUImageOpacityFilter *)filter setOpacity:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_GAUSSIAN_SELECTIVE: [(GPUImageGaussianSelectiveBlurFilter *)filter setExcludeCircleRadius:[(UISlider*)sender value]]; break;
//        case GPUIMAGE_FILTERGROUP: [(GPUImagePixellateFilter *)[(GPUImageFilterGroup *)filter filterAtIndex:1] setFractionalWidthOfAPixel:[(UISlider *)sender value]]; break;
//        case GPUIMAGE_CROP: [(GPUImageCropFilter *)filter setCropRegion:CGRectMake(0.0, 0.0, 1.0, [(UISlider*)sender value])]; break;
//        case GPUIMAGE_TRANSFORM: [(GPUImageTransformFilter *)filter setAffineTransform:CGAffineTransformMakeRotation([(UISlider*)sender value])]; break;
//        case GPUIMAGE_TRANSFORM3D:
//        {
//            CATransform3D perspectiveTransform = CATransform3DIdentity;
//            perspectiveTransform.m34 = 0.4;
//            perspectiveTransform.m33 = 0.4;
//            perspectiveTransform = CATransform3DScale(perspectiveTransform, 0.75, 0.75, 0.75);
//            perspectiveTransform = CATransform3DRotate(perspectiveTransform, [(UISlider*)sender value], 0.0, 1.0, 0.0);
//			
//            [(GPUImageTransformFilter *)filter setTransform3D:perspectiveTransform];            
//        }; break;
//        case GPUIMAGE_TILTSHIFT:
//        {
//            CGFloat midpoint = [(UISlider *)sender value];
//            [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:midpoint - 0.1];
//            [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:midpoint + 0.1];
//        }; break;
//        default: break;
//    }
	
	switch(_filterType)
	{
			case GPUIMAGE_SEPIA:{
				[(GPUImageSepiaFilter *)self.filterBack setIntensity:value];

			} break;

			case GPUIMAGE_CROSSHATCH: {
				[(GPUImageCrosshatchFilter *)self.filterBack setCrossHatchSpacing:value];

			} break;
			
			case GPUIMAGE_SWIRL: {
				[(GPUImageSwirlFilter *)self.filterBack setAngle:value];
			} break;
			
			case GPUIMAGE_EMBOSS:{
				//	漫画
				[(GPUImageEmbossFilter *)self.filterBack setIntensity:value]; 
			}break;
			
			case GPUIMAGE_PIXELLATE: {
				[(GPUImagePixellateFilter *)self.filterBack setFractionalWidthOfAPixel:value];

			} break;
			
			case GPUIMAGE_VIGNETTE: {
				[(GPUImageVignetteFilter *)self.filterBack setVignetteEnd:value];

			} break;
			
			case GPUIMAGE_GAUSSIAN: {
				[(GPUImageGaussianBlurFilter *)self.filterBack setBlurSize:value];
				
			} break;
			
			case GPUIMAGE_BULGE:{
				[(GPUImageBulgeDistortionFilter *)self.filterBack setScale:value]; 
			}break;
			
			case GPUIMAGE_SHARPEN: {
				//锐化
				[(GPUImageSharpenFilter *)self.filterBack setSharpness:value]; 
			}break;
			
			case GPUIMAGE_MONOCHROME: {
				[(GPUImageMonochromeFilter *)self.filterBack setIntensity:value]; 
			}break;
			case GPUIMAGE_GLASSSPHERE:{
				[(GPUImageGlassSphereFilter *)self.filterBack setRadius:value];
				[(GPUImageGlassSphereFilter *)self.filterBack setRefractiveIndex: 0.6];

			}break;
			default: break;
		}
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	//check mediaType
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:@"public.image"]) { 
        NSLog(@"imagePickerController Error, mediaType video");
        return;
    }
    //check image
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!image) {
        NSLog(@"imagePickerController Error, cant get Originalimage");
        return;
    }
	GPUImagePicture *editPicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
	self.editPicture = editPicture;
	[editPicture release];
	
	self.originImage = image;

	self.pickerState = CYImagePickerStateEditing;
	[self resetFilter];
	[self prepareTarget];
	
	[picker dismissModalViewControllerAnimated:NO];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[picker dismissModalViewControllerAnimated:NO];
}

@end
