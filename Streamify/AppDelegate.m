//
//  AppDelegate.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "AppDelegate.h"
#import "StreamifyStyleKit.h"
#import "AFNetworking.h"
#import <Spotify/Spotify.h>
#import "SpotifyKeys.h"

const CGFloat kGlobalNavigationFontSize = 17;

@interface AppDelegate ()

@property(nonatomic,strong)SPTSession *session;
@property(nonatomic,strong)SPTAudioStreamingController *player;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [self.window setTintColor:[StreamifyStyleKit spotifyGreen]];
  
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir" size:kGlobalNavigationFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
  [[UINavigationBar appearance] setTitleTextAttributes:attributes];
  
  
  [[SPTAuth defaultInstance]setClientID:kClientID];
  [[SPTAuth defaultInstance]setRedirectURL:[NSURL URLWithString:@"streamify://callback"]];
  [[SPTAuth defaultInstance]setRequestedScopes:@[SPTAuthStreamingScope, SPTAuthUserLibraryReadScope]];
  
  NSURL *loginURL = [[SPTAuth defaultInstance]loginURL];
  
  [application performSelector:@selector(openURL:)withObject:loginURL afterDelay:0.1];
  
  
  return YES;
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  if ([[SPTAuth defaultInstance]canHandleURL:url]) {
    [[SPTAuth defaultInstance]handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
      
      [[NSUserDefaults standardUserDefaults]setValue:session.accessToken forKey:@"token"];
      [[NSUserDefaults standardUserDefaults]synchronize];
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        return;
      }
      NSLog(@"%@",session.accessToken);
      NSString *urlStr = [NSString stringWithFormat:@"https://api.spotify.com/v1/me/tracks"];
      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
      [request setValue:[NSString stringWithFormat:@"Bearer %@",session.accessToken ] forHTTPHeaderField:@"Authorization"];
      NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",data);
        
        
        NSDictionary *savedTracksInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *tracks = savedTracksInfo[@"items"];
        for (NSDictionary *track in tracks) {
          NSDictionary *trackInfo = track[@"track"];
//          NSDictionary *album = trackInfo[@"album"];
//          NSString *name = album[@"name"];
          NSString *uri = trackInfo[@"uri"];
          [self playUsingSession:session withTrack:uri];
        }
      }];
      [task resume];
      
      
      
      // Call the -playUsingSession: method to play a track
      //      [self playUsingSession:session];
    }];
    return YES;
  }
  
  return NO;
}

-(void)playUsingSession:(SPTSession *)session withTrack:(NSString *)trackUri  {
  
  // Create a new player if needed
  if (self.player == nil) {
    self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
  }
  
  [self.player loginWithSession:session callback:^(NSError *error) {
    if (error != nil) {
      NSLog(@"*** Logging in got error: %@", error);
      return;
    }
    
//    NSURL *trackURI = [NSURL URLWithString:trackUri];
//    [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
//      if (error != nil) {
//        NSLog(@"*** Starting playback got error: %@", error);
//        return;
//      }
//    }];
//        [self.player queueURIs:@ clearQueue:<#(BOOL)#> callback:<#^(NSError *error)block#>]
//        [self.player que]
  }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
