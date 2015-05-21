//
//  SearchPlaylistsTableViewController.h
//  Streamify
//
//  Created by Josh Nagel on 5/19/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@interface SearchPlaylistsTableViewController : UITableViewController

@property(strong,nonatomic)User *currentUser;

@end
