//
//  GraphView.h
//  Focus
//
//  Created by Kevin Yang on 6/5/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView

@property (nonatomic, strong) NSArray *weekData;
-(void)resetGraph;
- (void)drawGraph;

@end
