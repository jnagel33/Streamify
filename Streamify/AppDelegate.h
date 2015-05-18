//
//  AppDelegate.h
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPTSession;
@class SPTAudioStreamingController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong)SPTSession *session;
@property(nonatomic,strong)SPTAudioStreamingController *player;

@end

