//
//  AddSongViewController.h
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSongViewControllerDelegate.h"

@interface AddSongViewController : UIViewController

@property (weak,nonatomic) id<AddSongViewControllerDelegate> delegate;

@end
