//
//  StreamifyJSONParser.m
//  Streamify
//
//  Created by Josh Nagel on 5/19/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "StreamifyJSONParser.h"
#import "Playlist.h"
#import "Artist.h"
#import "Song.h"


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

+(NSArray *)getArtistsFromJSON:(NSDictionary *)artistsInfo {
  NSMutableArray *artists = [[NSMutableArray alloc]init];
  
  NSArray *artistsList = artistsInfo[@"artists"];
  for (NSDictionary *artistInfo in artistsList) {
    NSString *artistID = artistInfo[@"id"];
    NSString *name = artistInfo[@"name"];
    NSNumber *popularity = artistInfo[@"popularity"];
    NSString *url = artistInfo[@"url"];
    
    Artist *artist = [[Artist alloc]initWithArtistID:artistID name:name popularity:popularity artistImageURL:url];
    
    [artists addObject:artist];
  }
  return artists;
}

+(NSArray *)getSongsFromJSON:(NSDictionary *)songsInfo {
  NSMutableArray *songs = [[NSMutableArray alloc]init];
  
  NSArray *songList = songsInfo[@"tracks"];
  for (NSDictionary *songInfo in songList) {
    NSString *songID = songInfo[@"id"];
    NSString *name = songInfo[@"name"];
    NSNumber *popularity = songInfo[@"popularity"];
    
    Song *song = [[Song alloc]init];
    song.trackID = songID;
    song.trackName = name;
    song.popularity = popularity;
    [songs addObject:song];
  }
  return songs;
}

@end
