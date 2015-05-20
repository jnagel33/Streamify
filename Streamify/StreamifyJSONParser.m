//
//  StreamifyJSONParser.m
//  Streamify
//
//  Created by Josh Nagel on 5/19/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "StreamifyJSONParser.h"
#import "Playlist.h"

@implementation StreamifyJSONParser

+(NSArray *)getPlaylistsFromJSON:(NSArray *)playlistInfo {
  NSMutableArray *playlists = [[NSMutableArray alloc]init];
  for (NSDictionary *playlist in playlistInfo) {
    NSString *playlistID = playlist[@"_id"];
    NSString *name = playlist[@"name"];
//    NSArray *songs = playlist[@"songs"];
    NSMutableArray *playlistSongs = [[NSMutableArray alloc]init];
//    for (NSDictionary *song in songs) {
//      
//    }
    
    Playlist *playlist = [[Playlist alloc]initWithID:playlistID name:name host:nil dateCreated:nil songs:playlistSongs];
    [playlists addObject:playlist];
  }
  
  
  return playlists;
}

@end
