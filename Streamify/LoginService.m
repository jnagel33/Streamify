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

@implementation LoginService

+(void)loginWithSpotify:(void (^)(void))completionHandler {
  
  [[SPTAuth defaultInstance]setClientID:kClientID];
  [[SPTAuth defaultInstance]setRedirectURL:[NSURL URLWithString:@"streamify://callback"]];
  [[SPTAuth defaultInstance]setRequestedScopes:@[SPTAuthStreamingScope, SPTAuthUserLibraryReadScope]];
  
  NSURL *loginURL = [[SPTAuth defaultInstance]loginURL];

  [[UIApplication sharedApplication]openURL:loginURL];
  completionHandler();
}

@end
