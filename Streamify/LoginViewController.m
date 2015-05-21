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
#import "MyPlaylistsViewController.h"
#import "StreamifyService.h"

const CGFloat kBufferCenterYLoginContainer = 70;
const double kAnimationDuration = 0.3;

@interface LoginViewController () <UITextFieldDelegate>

@property(weak, nonatomic)IBOutlet UITextField *usernameTextField;
@property(weak, nonatomic)IBOutlet UITextField *passwordTextField;
@property(weak, nonatomic)IBOutlet NSLayoutConstraint *constraintContainerCenterY;
@property(strong, nonatomic)SpotifyService *spotifyService;
@property(strong,nonatomic)LoginService *loginService;
@property(strong,nonatomic)StreamifyService *streamifyService;

@end

@implementation LoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.usernameTextField.delegate = self;
  self.passwordTextField.delegate = self;
  
  AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
  
  self.loginService = appDelegate.loginService;
  self.spotifyService = [SpotifyService sharedService];
  self.streamifyService = [StreamifyService sharedService];
}
- (IBAction)loginSpotifyPressed:(UIButton *)sender {
  [self.loginService loginWithSpotify:^{
    [self.spotifyService getUserProfile:^(User *user) {
      [self.spotifyService getUserSavedTracks:^(NSArray *songs) {
        user.songs = songs;
        NSLog(@"%@", user.displayName);
        UINavigationController *myPlaylistsNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyPlaylistsNav"];
        MyPlaylistsViewController *myPlaylistsVC = myPlaylistsNavVC.viewControllers[0];
        myPlaylistsVC.currentUser = user;
        [self.streamifyService createUser:user.userID AndPassword:@"spotify" AndUserType:@"spotify" completionHandler:^(User *user) {
          [self presentViewController:myPlaylistsNavVC animated:true completion:nil];
        }];
      }];
    }];
  }];
}
- (IBAction)loginPressed:(UIButton *)sender {
  [self.streamifyService loginApp:self.usernameTextField.text AndPassword:self.passwordTextField.text completionHandler:^(User *user) {
    UINavigationController *myPlaylistsNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyPlaylistsNav"];
    MyPlaylistsViewController *myPlaylistsVC = myPlaylistsNavVC.viewControllers[0];
    myPlaylistsVC.currentUser = user;
    [self presentViewController:myPlaylistsNavVC animated:true completion:nil];
  }];
}
- (IBAction)createUserButtonPressed:(UIButton *)sender {
  [self.streamifyService createUser:self.usernameTextField.text AndPassword:self.passwordTextField.text AndUserType:@"local" completionHandler:^(User *user) {
    UINavigationController *myPlaylistsNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyPlaylistsNav"];
    MyPlaylistsViewController *myPlaylistsVC = myPlaylistsNavVC.viewControllers[0];
    myPlaylistsVC.currentUser = user;
    [self presentViewController:myPlaylistsNavVC animated:true completion:nil];
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
