//
//  LoginViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginService.h"
#import "SpotifyService.h"
#import "User.h"
#import "AppDelegate.h"

const CGFloat kBufferCenterYLoginContainer = 70;
const double kAnimationDuration = 0.3;

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContainerCenterY;
@property (strong, nonatomic) SpotifyService *spotifyService;
@property (strong,nonatomic)LoginService *loginService;

@end

@implementation LoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.usernameTextField.delegate = self;
  self.passwordTextField.delegate = self;
  
  AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
  
  self.loginService = appDelegate.loginService;
  self.spotifyService = [SpotifyService sharedService];
}
- (IBAction)loginSpotifyPressed:(UIButton *)sender {
  [self.loginService loginWithSpotify:^{
    [self.spotifyService getUserProfile:^(User *user) {
      NSLog(@"%@", user.displayName);
      
      NSDictionary *userInfo = @{@"displayName": user.displayName, @"profileImageURL":user.profileImageURL};
      [[NSUserDefaults standardUserDefaults]setValue:userInfo forKey:@"currentUserData"];
      [self performSegueWithIdentifier:@"ShowMyPlaylists" sender:self];
    }];
  }];
}
- (IBAction)loginPressed:(UIButton *)sender {
  [self.spotifyService loginApp:self.usernameTextField.text AndPassword:self.passwordTextField.text completionHandler:^{
    [self performSegueWithIdentifier:@"ShowMyPlaylists" sender:self];
  }];
  
  [self performSegueWithIdentifier:@"ShowMyPlaylists" sender:self];
}
- (IBAction)createUserButtonPressed:(UIButton *)sender {
  [self.spotifyService createUser:self.usernameTextField.text AndPassword:self.passwordTextField.text completionHandler:^{
    [self performSegueWithIdentifier:@"ShowMyPlaylists" sender:self];
  }];
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
