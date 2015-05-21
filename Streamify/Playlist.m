//
//  Playlist.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist

-(instancetype)initWithID:(NSString *)playlistID name:(NSString *)name host:(User *)host dateCreated:(NSDate *)date songs:(NSArray *)songs {
  if (self == [super init]) {
    _playlistID = playlistID;
    _name = name;
    _host = host;
    _dateCreated = date;
    _songs = songs;
  }
  return self;
}

@end
