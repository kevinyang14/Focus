//
//  ToDoItemViewController.m
//  Focus
//
//  Created by Kevin Yang on 5/31/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "ToDoItemViewController.h"
#import "BezierPathView.h"
#import "DropitBehavior.h"
#import "UIImage+ImageEffects.h"

@interface ToDoItemViewController ()<UIDynamicAnimatorDelegate>
@property (weak, nonatomic) IBOutlet UILabel *toDoListItem;
@property (weak, nonatomic) IBOutlet BezierPathView *gameView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) DropitBehavior *dropitBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;
@property (strong, nonatomic) UIView *droppingView;
@end

@implementation ToDoItemViewController

static const CGSize DROP_SIZE = {40,40};


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
    self.toDoListItem.text = self.toDoText;
    [self.animator addBehavior:self.dropitBehavior];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
}

- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        if (self.gameView) {
            _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.gameView];
            _animator.delegate = self;
        } else {
            NSLog(@"Tried to create an animator with no reference view.");
        }
    }
    return _animator;
}

- (DropitBehavior *)dropitBehavior
{
    if (!_dropitBehavior){
        _dropitBehavior = [[DropitBehavior alloc] init];
    }
    return _dropitBehavior;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    [self removeCompletedRows];
}

- (BOOL)removeCompletedRows
{
    NSMutableArray *dropsToRemove = [[NSMutableArray alloc] init];
    
    for (CGFloat y = self.gameView.bounds.size.height-DROP_SIZE.height/2; y > 0; y -= DROP_SIZE.height)
    {
        BOOL rowIsComplete = YES;
        NSMutableArray *dropsFound = [[NSMutableArray alloc] init];
        for (CGFloat x = DROP_SIZE.width/2; x <= self.gameView.bounds.size.width-DROP_SIZE.width/2; x += DROP_SIZE.width)
        {
            UIView *hitView = [self.gameView hitTest:CGPointMake(x, y) withEvent:NULL];
            if ([hitView superview] == self.gameView) {
                [dropsFound addObject:hitView];
            } else {
                rowIsComplete = NO;
                break;
            }
        }
        if (![dropsFound count]) break;
        if (rowIsComplete) [dropsToRemove addObjectsFromArray:dropsFound];
    }
    
    if ([dropsToRemove count]) {
        for (UIView *dropView in dropsToRemove) {
            [self.dropitBehavior removeItem:dropView];
        }
        [dropsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
        return YES;
    }
    
    return NO;
}


- (IBAction)tap:(UITapGestureRecognizer *)sender {
    [self drop];
}

- (void)drop
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = DROP_SIZE;
    int x = (arc4random()%(int)self.gameView.bounds.size.width)/DROP_SIZE.width;
    frame.origin.x = x * DROP_SIZE.width;
    
    UIView *ballView = [[UIView alloc] initWithFrame:frame];
    ballView.backgroundColor = [[self backgroundSensitiveColor] colorWithAlphaComponent:1];
    
    ballView.layer.cornerRadius = DROP_SIZE.width/2;
    ballView.layer.borderColor = [UIColor blackColor].CGColor;
    ballView.layer.borderWidth = 0.0;
    [self.gameView addSubview:ballView];
    
    self.droppingView = ballView;
    [self.dropitBehavior addItem:ballView];
}

- (UIColor *)backgroundSensitiveColor
{
    return [UIColor colorWithPatternImage:[[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]applyCustomLightEffect]];
}


- (UIColor *)randomColor
{
    switch (arc4random()%5) {
        case 0: return [UIColor greenColor];
        case 1: return [UIColor redColor];
        case 2: return [UIColor blueColor];
        case 3: return [UIColor purpleColor];
        case 4: return [UIColor orangeColor];
    }
    return [UIColor blackColor];
}


- (UIColor *)randomDotsColor
{
    switch (arc4random()%4) {
        case 0: return [[UIColor alloc] initWithRed:73.0/255.0 green:196.0/255.0 blue:184.0/255.0 alpha:1]; //aqua
        case 1: return [[UIColor alloc] initWithRed:255.0/255.0 green:82.0/255.0 blue:95.0/255.0 alpha:1]; //pink
        case 2: return [[UIColor alloc] initWithRed:255.0/255.0 green:124.0/255.0 blue:6.0/255.0 alpha:1]; //orange
        case 3: return [[UIColor alloc] initWithRed:114.0/255.0 green:219.0/255.0 blue:93.0/255.0 alpha:1]; //green
    }
    return [UIColor blackColor];
}

@end
