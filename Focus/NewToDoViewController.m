//
//  NewToDoViewController.m
//  Focus
//
//  Created by Kevin Yang on 5/30/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "NewToDoViewController.h"
#import "AddPhotoViewController.h"
#import "UIImage+ImageEffects.h"
#import <AVFoundation/AVFoundation.h>
#import "ToDo+Create.h"
#import "FocusDatabase.h"
#import <QuartzCore/QuartzCore.h>

@interface NewToDoViewController () <UITextFieldDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *recordOrPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) NSString *toDoText;
@property (strong, nonatomic) NSURL *audioURL;
@property BOOL didRecord;
@end

@implementation NewToDoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]applyDarkEffect]];
    
    [self setUpAudio];
    self.datePicker.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]applyLightEffect]];
//    self.datePicker.viewForBaselineLayout.layer.cornerRadius = 60;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]applyDarkEffect]];
}

#pragma mark To-Do

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.toDoText = textField.text;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Deadline

- (NSString *)getDateString:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    return [dateFormat stringFromDate:date];
}

- (NSDate *)getDate
{
    NSDate *deadline = [self.datePicker date];
    return deadline;
}

#pragma mark Audio
- (NSURL *)uniqueDocumentURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                          inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([[NSDate date] timeIntervalSince1970])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

- (void)setUpAudio
{
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    
    NSURL *outputFileURL = [self uniqueDocumentURL];
    self.audioURL = outputFileURL;

    
    // audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // audio recorder settings
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSettings error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    self.didRecord = NO;
}


- (IBAction)recordOrPause:(UIButton *)sender {
    self.didRecord = YES;
    if (self.player.playing) {
        [self.player stop];
    }
    
    if (!self.recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [self.recorder record];
        [self.recordOrPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        // Pause recording
        [self.recorder pause];
        [self.recordOrPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
}

- (IBAction)stop:(UIButton *)sender {
    [self.recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)play:(UIButton *)sender {
    if (!self.recorder.recording){
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.recordOrPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark Save

- (IBAction)doneButtonTapped:(UIButton *)sender {
    NSString *text = [self toDoText];
    NSDate *deadline = [self getDate];
    NSString *audioURL = (self.didRecord)? [self.audioURL absoluteString] : nil;
    FocusDatabase *focusdb = [FocusDatabase sharedDefaultFocusDatabase];

    //Use a block
    [ToDo toDoWithText:text
          withDeadLine:deadline
         withPhotoFile:self.photoURL
         withAudioFile:audioURL
           withUrgency:[[NSNumber alloc] initWithInt:1]
inManagedObjectContext:focusdb.managedObjectContext];
    
    //segue back to ToDoListCDTVC
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma Others

-(IBAction)addedPhoto:(UIStoryboardSegue *)segue
{
    if([segue.sourceViewController isKindOfClass:[AddPhotoViewController class]]){
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass: [AddPhotoViewController class]]){
    }
}

@end
