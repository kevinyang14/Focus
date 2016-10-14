//
//  FocusViewController.m
//  Focus
//
//  Created by Kevin Yang on 5/25/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "HomeViewController.h"
#import "VineLineDrawingView.h"
#import "FocusAppDelegate.h"

@interface HomeViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *todayTitleOrFocusQuestionLabel;
@property (weak, nonatomic) IBOutlet UILabel *actualFocusLabel;
@property (weak, nonatomic) IBOutlet UITextField *blankFocusTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *nameGreetingLabel;
@property (strong, nonatomic) IBOutlet VineLineDrawingView *background;
@property (nonatomic) int backgroundCount;
@end

@implementation HomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundCount =[[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"] intValue];
    self.user_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"];
    self.nameGreetingLabel.text = [NSString stringWithFormat:@"Good Morning, %@.", self.user_name];
    
    [self updateClockLabel];
    [self.actualFocusLabel setHidden:YES];
    [self.deleteButton setHidden:YES];
    
    [self updateBackground];
    [self setUpVineView];

    [self setUpBackgroundParallax:self.background];
}

#pragma mark Views

- (void)setUpVineView
{
    self.background.vineWidth = 5.0;
    self.background.branchSeperation = 40.0;
    self.background.leafSize = 10.0;
    self.background.branchLength = 50.0;
}

- (void)updateBackground
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
    self.background.viewForBaselineLayout.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
}

- (void)updateClockLabel
{
    NSDateFormatter *clockFormat = [[NSDateFormatter alloc] init];
    [clockFormat setDateFormat:@"hh:mm:ss"];
    self.time.text = [clockFormat stringFromDate:[NSDate date]];
    [self performSelector:@selector(updateClockLabel) withObject:self afterDelay:1.0];
}


- (IBAction)changeBackground:(UIButton *)sender {
    self.backgroundCount = (self.backgroundCount >= 6) ? 1 : self.backgroundCount+1;
    
    NSString *newBackgroundImageName = [NSString stringWithFormat:@"%d",self.backgroundCount];
    [[NSUserDefaults standardUserDefaults] setObject:newBackgroundImageName forKey:@"background_image_name"];
    [self updateBackground];
    
    FocusAppDelegate *appDelegate = (FocusAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self isAnsweredToggle:YES];
    return YES;
}

-(void)setUpBackgroundParallax: (UIView*)view
{
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [view addMotionEffect:group];
}

- (IBAction)deleteTextButton:(UIButton *)sender {
    [self isAnsweredToggle:NO];
}

-(void)isAnsweredToggle:(BOOL)isAnswered
{
    self.todayTitleOrFocusQuestionLabel.text = (isAnswered) ? @"Today":@"What is your focus today?";
    [self.blankFocusTextField setHidden:isAnswered];
    [self.actualFocusLabel setHidden:!isAnswered];
    [self.deleteButton setHidden:!isAnswered];
    if(isAnswered){
        self.actualFocusLabel.text = self.blankFocusTextField.text;
    }else{
        self.blankFocusTextField.text = @"";
    }
}


@end
