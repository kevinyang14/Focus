//
//  GraphView.m
//  Focus
//
//  Created by Kevin Yang on 6/5/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "GraphView.h"
#import <QuartzCore/QuartzCore.h>

@interface GraphView ()
@end

@implementation GraphView

#define GRAPH_WIDTH_SCALE_FACTOR 0.9
#define GRAPH_HEIGHT_SCALE_FACTOR 0.8

- (CGFloat)graphWidth { return self.bounds.size.width * GRAPH_WIDTH_SCALE_FACTOR; }
- (CGFloat)graphHeight { return self.bounds.size.height * GRAPH_HEIGHT_SCALE_FACTOR; }
- (CGFloat)graphX { return self.bounds.origin.x + (self.bounds.size.width*((1.0 - GRAPH_WIDTH_SCALE_FACTOR)/2.0)); }
- (CGFloat)graphY:(int)position { return self.bounds.origin.y + (self.bounds.size.height * (1.0/8.0) * position ); }

- (CGPoint)origin { return CGPointMake([self graphX], [self graphY:2]+[self graphHeight]*0.6); }
- (CGPoint)originDayOffset:(int)day { return CGPointMake([self graphX] + ([self graphWidth]/7 * day), [self graphY:2]+[self graphHeight]*0.6); }



- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [self drawGraph];
}


- (void)drawGraph
{
    [[self symbolColor] setStroke];
    [self setup];
    [self drawAxesAtPoint:CGPointMake([self graphX], [self graphY:2])];
    int dayCount = 0;
    for(NSNumber* numTasksThisDay in self.weekData){
        NSLog(@"numTasksThisDay: %ld", (long)[numTasksThisDay integerValue]);
        [self drawBarAtPoint:[self originDayOffset:dayCount] withNumberOfTasks:(int)[numTasksThisDay integerValue]];
        dayCount++;
    }
}

- (void)drawAxesAtPoint: (CGPoint)point
{
    UIBezierPath *axes = [[UIBezierPath alloc] init];
    axes.lineWidth = 3;
    
    [axes moveToPoint:point];
    [axes addLineToPoint:CGPointMake(point.x,
                                    point.y + [self graphHeight]*0.6)];
    [axes addLineToPoint:CGPointMake(point.x + [self graphWidth],
                                     point.y + [self graphHeight]*0.6)];
    [axes stroke];
    
}

- (void)drawBarAtPoint:(CGPoint)point withNumberOfTasks:(int)numberOfTasks
{
    UIBezierPath *bar = [[UIBezierPath alloc] init];
    
    [bar moveToPoint:point];
    [bar addLineToPoint:CGPointMake(point.x,
                                    point.y - ([self graphHeight]/17)*numberOfTasks)];
    [bar addLineToPoint:CGPointMake(point.x + [self graphWidth]/8,
                                        point.y - ([self graphHeight]/17)*numberOfTasks)];
    [bar addLineToPoint:CGPointMake(point.x + [self graphWidth]/8,
                                        point.y)];
    [bar addLineToPoint:point];
    
    CAShapeLayer *barLayer = [CAShapeLayer layer];
    barLayer.path = bar.CGPath;
    barLayer.frame=self.frame;
    barLayer.lineWidth=3;
    
    [self.layer addSublayer:barLayer];
    [self sendSublayerToBack:barLayer];
    [self drawLineAnimation:barLayer];
    barLayer.fillColor=[UIColor colorWithWhite:1 alpha:0.3].CGColor;
}

- (void)sendSublayerToBack:(CALayer *)layer {
    CALayer *superlayer = layer.superlayer;
    [layer removeFromSuperlayer];
    [superlayer insertSublayer:layer atIndex:0];
}

-(void)drawLineAnimation:(CAShapeLayer*)layer
{
    layer.strokeColor=[UIColor colorWithWhite:1 alpha:0.7].CGColor;
    CABasicAnimation *strokeAnimation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.duration=1.5;
    strokeAnimation.delegate=self;
    strokeAnimation.fromValue=[NSNumber numberWithInteger:0];
    strokeAnimation.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:strokeAnimation forKey:@"key"];
}

- (UIColor *)symbolColor
{
    return [[UIColor whiteColor] colorWithAlphaComponent:0.5];
}

-(void)resetGraph
{
    //[self.layer removeAllAnimations];
    //[self setNeedsDisplay];
}

- (void)setWeekData:(NSArray *)weekData{
    _weekData = weekData;
    [self setNeedsDisplay];
}

#pragma mark Initialization

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end
