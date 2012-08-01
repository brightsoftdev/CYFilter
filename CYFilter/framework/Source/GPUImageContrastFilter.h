#import "GPUImageFilter.h"

/** Adjusts the contrast of the image
 */
@interface GPUImageContrastFilter : GPUImageFilter
{
    GLint contrastUniform;
}

/** Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
 */
//------>chenyi modify to thus:
/** Contrast ranges from -1.0 to 1.0 (max contrast), with 0.0 as the normal level
 */
@property(readwrite, nonatomic) CGFloat contrast; 

@end
