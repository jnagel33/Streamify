//
//  LoginViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "LoginViewController.h"

const CGFloat kBufferCenterYLoginContainer = 70;
const double kAnimationDuration = 0.3;

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContainerCenterY;

@end

@implementation LoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.usernameTextField.delegate = self;
  self.passwordTextField.delegate = self;
}
- (IBAction)loginFacebookPressed:(UIButton *)sender {
}
- (IBAction)loginPressed:(UIButton *)sender {
  [self performSegueWithIdentifier:@"ShowMyPlaylists" sender:self];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
  self.constraintContainerCenterY.constant += kBufferCenterYLoginContainer;
  [UIView animateWithDuration:kAnimationDuration animations:^{
    [self.view layoutIfNeeded];
  }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
  self.constraintContainerCenterY.constant -= kBufferCenterYLoginContainer;
  [UIView animateWithDuration:kAnimationDuration animations:^{
    [self.view layoutIfNeeded];
  }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  if (textField == self.usernameTextField) {
    [self.passwordTextField becomeFirstResponder];
  }
  return true;
}

@end
