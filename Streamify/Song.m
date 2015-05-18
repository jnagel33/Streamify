//
//  Song.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "Song.h"

@implementation Song

-(instancetype)initWithTrackName:(NSString *)trackName artistName:(NSString *)artistName albumName:(NSString *)albumName albumArtworkURL:(NSString *)albumArtworkURL uri:(NSString *)uri duration:(NSNumber *)duration {
  if (self == [super init]) {
    _trackName = trackName;
    _artistName = artistName;
    _albumName = albumName;
    _albumArtworkURL = albumArtworkURL;
    _uri = uri;
    _duration = duration;
  }
  return self;
}

@end
