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
#import "LoginService.h"
#import "MyPlaylistsViewController.h"
#import "SpotifyService.h"
#import "StreamifyService.h"
#import "User.h"

const CGFloat kGlobalNavigationFontSize = 17;

@interface AppDelegate ()

@property(strong,nonatomic)SpotifyService *spotifyService;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:100 * 1024 * 1024 diskCapacity:100 * 1024 * 1024 diskPath:nil];
  [NSURLCache setSharedURLCache:sharedCache];
  
  [self.window setTintColor:[StreamifyStyleKit spotifyGreen]];
  
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir" size:kGlobalNavigationFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
  [[UINavigationBar appearance] setTitleTextAttributes:attributes];
  self.loginService = [[LoginService alloc]init];
  
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSData *sessionData = [[NSUserDefaults standardUserDefaults]valueForKey:@"sessionData"];
  SPTSession *session = [NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
  
  NSComparisonResult comparison = [session.expirationDate compare:[NSDate date]];
  
  if (session && session.isValid && appToken && comparison == NSOrderedDescending) {
    self.session = session;
    self.spotifyService = [SpotifyService sharedService];
    [self.spotifyService getUserProfile:^(User *user) {
      NSLog(@"%@", user.displayName);
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
      UINavigationController *myPlaylistsNavVC = [storyboard instantiateViewControllerWithIdentifier:@"MyPlaylistsNav"];
      MyPlaylistsViewController *myPlaylistsVC = myPlaylistsNavVC.viewControllers[0];
      myPlaylistsVC.currentUser = user;
      self.window.rootViewController = myPlaylistsNavVC;
    }];
    return YES;
  } else if(appToken && !session) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *myPlaylistsNavVC = [storyboard instantiateViewControllerWithIdentifier:@"MyPlaylistsNav"];
    self.window.rootViewController = myPlaylistsNavVC;
    return YES;
  } else {
    if (session != nil) {
      
    }
    return YES;
  }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  if ([[SPTAuth defaultInstance]canHandleURL:url]) {
    [[SPTAuth defaultInstance]handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
      
      self.session = session;
      NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
      [[NSUserDefaults standardUserDefaults]setValue:sessionData forKey:@"sessionData"];
      
      [[NSUserDefaults standardUserDefaults]setValue:session.accessToken forKey:@"token"];
      [[NSUserDefaults standardUserDefaults]synchronize];
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        return;
      }
      NSLog(@"%@",session.accessToken);
      [self.loginService returnFromRedirect];

    }];
    return YES;
  }
  
  return NO;
}

-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
  UIApplication *app= [UIApplication sharedApplication];
  __block UIBackgroundTaskIdentifier task = [app beginBackgroundTaskWithName:@"test" expirationHandler:^{
    [[UIApplication sharedApplication]endBackgroundTask:task];
    task = UIBackgroundTaskInvalid;
  }];
  
  [[StreamifyService sharedService]findMyPlaylists:^(NSArray *playlists) {
    reply(@{@"playlists":playlists});
  }];
  
  [app endBackgroundTask:task];
  task = UIBackgroundTaskInvalid;
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
