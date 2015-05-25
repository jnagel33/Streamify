//
//  PlaylistRow.m
//  Streamify
//
//  Created by Josh Nagel on 5/23/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "PlaylistRow.h"
#import <WatchKit/WatchKit.h>
#import "Playlist.h"
#import "PlaylistRow.h"

@interface PlaylistRow ()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *playlistNameLabel;

@end

@implementation PlaylistRow

-(void)configureCell:(Playlist *)playlist {
  self.playlistNameLabel.text = nil;
  self.playlistNameLabel.text = playlist.name;
}

@end
