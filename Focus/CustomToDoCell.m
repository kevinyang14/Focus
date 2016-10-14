//
//  MessageBubbleCell.m
//  Focus
//
//  Created by Kevin Yang on 6/1/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "CustomToDoCell.h"
#import <AVFoundation/AVFoundation.h>
#import "ImageViewController.h"
#import "ToDo.h"


@interface CustomToDoCell() <AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *urgencyButton;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *deadlineLabel;
@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation CustomToDoCell

-(void)layoutSubviews
{
    [self updateUI];
}

- (void)updateUI
{
    //update urgency button
    [self updateUrgencyImage];
    
    //update todo label
    self.textLabel.text = self.todo;
    
    //update deadline label
    NSDate *deadline = self.deadline;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    NSString *deadlineString = [dateFormat stringFromDate:deadline];
    self.deadlineLabel.text = [NSString stringWithFormat:@"Deadline: %@", deadlineString];
}

- (void)updateUrgencyImage
{
    NSString *image_name =[NSString stringWithFormat:@"Urgency%d", self.urgency];
    self.urgencyButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:image_name]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)urgencyPressed:(UIButton *)sender {
    [self updateUrgencyImage];
}

- (IBAction)audioPressed:(UIButton *)sender {
    if (self.audio_filename) {
        NSURL *outputFileURL = [NSURL URLWithString:self.audio_filename];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:outputFileURL error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }else{
        [self showAlert:@"No audio recorded!" withTitle:@"Recording"];
    }
}

- (void)showAlert:(NSString *)alertString withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: alertString
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
