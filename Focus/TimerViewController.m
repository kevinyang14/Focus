//
//  TimerViewController.m
//  Focus
//
//  Created by Kevin Yang on 5/31/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "TimerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageEffects.h"

@interface TimerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (strong, nonatomic) CAShapeLayer *circleLayer;
@property NSTimeInterval time;
@property BOOL start;
@end

@implementation TimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.display.text = @"00:00";
    self.start = false;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
    [self initUIOfView];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
    if (self.start) {
        [self drawLineAnimation:self.circleLayer];
    }else{
        [self resetCircle:self.circleLayer];
    }
}

- (void)update{
    if (self.start == false) {
        return;
    }
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsedTime = currentTime - self.time;
    
    int minutes = (int)(elapsedTime / 60.0);
    int seconds = (int)(elapsedTime = elapsedTime - (minutes * 60));
    self.display.text = [NSString stringWithFormat:@"%u:%02u", minutes, seconds];
    [self performSelector:@selector(update) withObject:self afterDelay:0.1];

}

- (IBAction)startButton:(UIButton *)sender {
    if (self.start == false) {
        [self resumeLayer:self.circleLayer];
        [self resetCircle:self.circleLayer];
        [self drawLineAnimation:self.circleLayer];
        self.start = true;
        self.time = [NSDate timeIntervalSinceReferenceDate];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        [self update];
    }else{
        self.start = false;
        [sender setTitle:@"Start" forState:UIControlStateNormal];
        [self pauseLayer:self.circleLayer];
    }
}

#pragma mark Circle

-(void)initUIOfView
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    
    CGRect rect=[UIScreen mainScreen].applicationFrame;
    
    [path addArcWithCenter:CGPointMake(rect.size.width/2,rect.size.height/2-20) radius:140 startAngle:0 endAngle:2*M_PI clockwise:NO];
    self.circleLayer=[CAShapeLayer layer];
    self.circleLayer.path=path.CGPath;
    self.circleLayer.fillColor=[UIColor colorWithWhite:1 alpha:0.2].CGColor;
    self.circleLayer.strokeColor=[UIColor clearColor].CGColor;
    self.circleLayer.lineWidth=3;
    self.circleLayer.frame=self.view.frame;
    [self.view.layer addSublayer:self.circleLayer];
    [self sendSublayerToBack:self.circleLayer];
}

- (void)sendSublayerToBack:(CALayer *)layer {
    CALayer *superlayer = layer.superlayer;
    [layer removeFromSuperlayer];
    [superlayer insertSublayer:layer atIndex:0];
}

-(void)drawLineAnimation:(CALayer*)layer
{
    self.circleLayer.strokeColor=[UIColor colorWithWhite:1 alpha:0.7].CGColor;
    CABasicAnimation *strokeAnimation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.duration=30;
    strokeAnimation.delegate=self;
    strokeAnimation.fromValue=[NSNumber numberWithInteger:0];
    strokeAnimation.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:strokeAnimation forKey:@"key"];
}

-(void)resetCircle:(CAShapeLayer*)layer
{
    layer.strokeColor=[UIColor clearColor].CGColor;
    [layer removeAllAnimations];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (flag) {
        NSLog(@"Animation Stopped");
        [self drawLineAnimation:self.circleLayer];
    }
}


@end
