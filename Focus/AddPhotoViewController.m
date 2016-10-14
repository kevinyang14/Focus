//
//  AddPhotoViewController.m
//  Focus
//
//  Created by Kevin Yang on 5/31/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "AddPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NewToDoViewController.h"


@interface AddPhotoViewController () <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;

@end

@implementation AddPhotoViewController



#pragma mark ViewControllerLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
    [super viewDidAppear:animated];
    if(![[self class] canAddPhoto]){
        [self fatalAlert:@"Sorry, this device cannot add a photo."];
    }
}

#pragma mark Properties
- (NSURL *)uniqueDocumentURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                          inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([[NSDate date] timeIntervalSince1970])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

- (NSURL *)imageURL
{
    if(!_imageURL && self.image){
        NSURL *url = [self uniqueDocumentURL];
        if (url) {
            NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
            if ([imageData writeToURL:url atomically:YES]) {
                _imageURL = url;
            }
        }
    }
    return _imageURL;
}

- (void)setImage:(UIImage *)image
{
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    self.imageURL = nil;
    self.imageView.image = image;
}

- (UIImage *)image
{
    return self.imageView.image;
}


#pragma mark Unwind

#define UNWIND_SEGUE_IDENTIFIER @"Do Add Photo"
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        if ([segue.destinationViewController isKindOfClass:[NewToDoViewController class]]) {
            NewToDoViewController *ntdvc = segue.destinationViewController;
            ntdvc.photoURL = [self.imageURL absoluteString];
            self.imageURL =nil;
        }
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        if(!self.image){
            [self alert:@"No photo taken!"];
            return NO;
        }else{
            return YES;
        }
    }else{
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

-(void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Add Photo"
                               message:msg
                              delegate:nil
                     cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
    
}

-(void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Add Photo"
                                message:msg
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

+ (BOOL)canAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return YES;
    }
    return NO;
}

#pragma mark Buttons

- (IBAction)cancel:(UIButton *)sender {
    self.image = nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self cancel:nil];
}

#pragma mark ImagePicker

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
