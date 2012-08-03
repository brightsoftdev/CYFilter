#import "GPUImageFilter.h"

@interface GPUImageToneCurveFilter : GPUImageFilter

// The tone curve takes in a series of control points that define the spline curve for each color component. 
// These are stored as NSValue-wrapped CGPoints in an NSArray, with normalized X and Y coordinates from 0 - 1. The defaults are (0,0), (0.5,0.5), (1,1).

//已经对改算法做了一些调整,刻度变为0-255
// The defaults are (0,0), (127.5,127.5), (255,255).

@property(readwrite, nonatomic, copy) NSArray *redControlPoints;
@property(readwrite, nonatomic, copy) NSArray *greenControlPoints;
@property(readwrite, nonatomic, copy) NSArray *blueControlPoints;

// This lets you set all three red, green, and blue tone curves at once.
- (void)setRGBControlPoints:(NSArray *)points;

// Curve calculation
- (NSArray *)getPreparedSplineCurve:(NSArray *)points;
- (NSArray *)splineCurve:(NSArray *)points;
- (NSArray *)secondDerivative:(NSArray *)cgPoints;
- (void)updateToneCurveTexture;
   
@end
