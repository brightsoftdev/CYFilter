#import "GPUImageContrastFilter.h"

NSString *const kGPUImageContrastFragmentShaderString = SHADER_STRING
( 
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float contrast;
  
 void main()
 {
	
	 lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = vec4(((textureColor.rgb   - vec3(0.5)) * contrast + textureColor.rgb  ) , textureColor.w);
 }

);


static float computeContrast(float contrastOrigin)
{
	/*
	 一、Photoshop对比度算法。可以用下面的公式来表示：
	 (1)、nRGB = RGB + (RGB - Threshold) * Contrast / 255
	 公式中，nRGB表示图像像素新的R、G、B分量，RGB表示图像像素R、G、B分量，Threshold为给定的阀值，Contrast为处理过的对比度增量。
	 Photoshop对于对比度增量，是按给定值的正负分别处理的：
	 当增量等于-255时，是图像对比度的下端极限，此时，图像RGB各分量都等于阀值，图像呈全灰色，灰度图上只有1条线，即阀值灰度；
	 当增量大于-255且小于0时，直接用上面的公式计算图像像素各分量；
	 当增量等于 255时，是图像对比度的上端极限，实际等于设置图像阀值，图像由最多八种颜色组成，灰度图上最多8条线，即红、黄、绿、青、蓝、紫及黑与白；
	 当增量大于0且小于255时，则先按下面公式(2)处理增量，然后再按上面公式(1)计算对比度：
	 (2)、nContrast = 255 * 255 / (255 - Contrast) - 255
	 公式中的nContrast为处理后的对比度增量，Contrast为给定的对比度增量。
     */
	
	float contrastFinally = contrastOrigin;
	
	if(contrastOrigin > 0  && contrastOrigin < 1.0)
	{
//		float a1 = (255.0 - contrastOrigin * 255.0) ;
//		float a2 = 255.0 * 255.0 / a1;
//		float a3 = a2 - 255.0;
//		NSLog(@"contrastOrigin = %f a1 = %f a2 = %f a3 = %f",contrastOrigin,a1,a2,a3);
//		contrastFinally = a3 / 255.0;
		
	}
	
	return contrastFinally;
	
}

@implementation GPUImageContrastFilter

@synthesize contrast = _contrast;

#pragma mark -
#pragma mark Initialization

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageContrastFragmentShaderString]))
    {
		return nil;
    }
    
    contrastUniform = [filterProgram uniformIndex:@"contrast"];
    self.contrast = 0.0; //chenyi modify from 1.0 to 0.0
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setContrast:(CGFloat)newValue;
{
//    _contrast = newValue;
	NSLog(@"contrast = %f",newValue);
	newValue = computeContrast(newValue); //先重新计算以下对比度值
	_contrast = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(contrastUniform, _contrast);
}

@end

