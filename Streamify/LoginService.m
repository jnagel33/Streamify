//
//  LoginService.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "LoginService.h"
#import <Spotify/Spotify.h>
#import "SpotifyKeys.h"
#import "AppDelegate.h"
#import "AFNetworking.h"

@interface LoginService ()

@property (nonatomic, strong) void (^completionHandler)(void);

@end


@implementation LoginService

-(void)loginWithSpotify:(void (^)(void)) completionHandler {
  
  self.completionHandler = completionHandler;
  
  [[SPTAuth defaultInstance]setClientID:kClientID];
  [[SPTAuth defaultInstance]setRedirectURL:[NSURL URLWithString:@"streamify://callback"]];
  [[SPTAuth defaultInstance]setRequestedScopes:@[SPTAuthStreamingScope, SPTAuthUserLibraryReadScope]];
  
  NSURL *loginURL = [[SPTAuth defaultInstance]loginURL];

  double delayInSeconds = 1.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [[UIApplication sharedApplication]openURL:loginURL];
  });
}

-(void)returnFromRedirect {
  [[NSOperationQueue mainQueue]addOperationWithBlock:^{
    self.completionHandler();
  }];
}



@end
