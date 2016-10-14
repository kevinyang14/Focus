//
//  BezierPathView.m
//  Dropit
//
//  Created by Kevin Yang on 4/27/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "BezierPathView.h"

@implementation BezierPathView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPath:(UIBezierPath *)path
{
    _path = path;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.path stroke];
}

- (void)viewDidLoad
{
      self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
}


@end
