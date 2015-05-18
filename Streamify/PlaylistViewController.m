//
//  PlaylistViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "PlaylistViewController.h"

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}
- (IBAction)addSongPressed:(UIBarButtonItem *)sender {
  [self performSegueWithIdentifier:@"SearchSongs" sender:self];
}

@end
