//
//  SignInViewController.m
//  Focus
//
//  Created by Kevin Yang on 5/31/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "SignInViewController.h"
#import "HomeViewController.h"

@interface SignInViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@end

@implementation SignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
	// Do any additional setup after loading the view.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self performSegueWithIdentifier:@"Start" sender:self];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Start"]) {
        if ([segue.destinationViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tbc = segue.destinationViewController;
            HomeViewController *hvc = [tbc.viewControllers firstObject];
            hvc.user_name = self.nameTextField.text;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
            [[NSUserDefaults standardUserDefaults] setObject:self.nameTextField.text forKey:@"user_name"];
        }
    }
}

@end
