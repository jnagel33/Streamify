//
//  PlaylistViewController.h
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSongViewControllerDelegate.h"
@class User;
@class Playlist;

@interface PlaylistViewController : UIViewController

@property(strong,nonatomic)User *currentUser;
@property(strong,nonatomic)Playlist *currentPlaylist;

@end
