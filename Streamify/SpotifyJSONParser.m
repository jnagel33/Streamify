//
//  SpotifyJSONParser.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "SpotifyJSONParser.h"
#import "User.h"
#import "Song.h"
#import "Artist.h"

@implementation SpotifyJSONParser

+(User *)getUserFromJSON:(NSDictionary *)info {
  NSString *userID = info[@"id"];
  NSString *displayName = info[@"display_name"];
  NSString *email = info[@"email"];
  NSArray *images = info[@"images"];
  NSDictionary *image = images[0];
  NSString *profileImageURL = image[@"url"];
  return [[User alloc]initWithUserID:userID displayName:displayName AndEmail:email WithUserType:@"Spotify" andProfileImageURL:profileImageURL];
}

+(NSArray *)getTracksFromJSON:(NSDictionary *)info {
  NSMutableArray *songs = [[NSMutableArray alloc]init];
  NSLog(@"%@", info);
  NSDictionary *tracksInfo = info[@"tracks"];
  NSArray *items = tracksInfo[@"items"];
  for (NSDictionary *item in items) {
    NSDictionary *album = item[@"album"];
    NSArray *albumArtworkItems = album[@"images"];
    NSMutableDictionary *albumArtworkURLItem;
    if (albumArtworkItems.count >= 2) {
      albumArtworkURLItem = albumArtworkItems[1];
    }
    NSString *albumArtworkURL = albumArtworkURLItem[@"url"];
    NSString *albumName = album[@"name"];
    NSArray *artists = item[@"artists"];
    NSDictionary *artist = artists[0];
    NSString *artistName = artist[@"name"];
//    NSNumber *duration = item[@"duration_ms"];
    NSString *trackID = item[@"id"];
    NSString *uri = item[@"uri"];
    NSString *trackName = item[@"name"];
    Song *song = [[Song alloc]initWithTrackID:trackID Name:trackName artistName:artistName albumName:albumName albumArtworkURL:albumArtworkURL uri:uri contributor:nil];
    [songs addObject:song];
  }
  return songs;
}

+(NSArray *)getSearchArtistsFromJSON:(NSDictionary *)artistsInfo {
  NSDictionary *artistsDictionary = artistsInfo[@"artists"];
  NSArray *items = artistsDictionary[@"items"];
  return [self getArtistsFromJSON:items];
}

+(NSArray *)getRelatedArtistsFromJSON:(NSDictionary *)artistsInfo {
  NSArray *artists = artistsInfo[@"artists"];
  return [self getArtistsFromJSON:artists];
}


+(NSArray *)getArtistsFromJSON:(NSArray *)artists {
  NSMutableArray *artistsList = [[NSMutableArray alloc]init];
  for (NSDictionary *artistInfo in artists) {
    NSString *artistID = artistInfo[@"id"];
    NSString *name = artistInfo[@"name"];
    NSNumber *popularity = artistInfo[@"popularity"];
    NSArray *imageURLs = artistInfo[@"images"];
    NSString *url;
    if (imageURLs.count > 1) {
      NSDictionary *imageDictionary = imageURLs[1];
      url = imageDictionary[@"url"];
    }
    Artist *artist = [[Artist alloc]initWithArtistID:artistID name:name popularity:popularity artistImageURL:url];
    
    [artistsList addObject:artist];
  }
  return artistsList;
}

+(NSArray *)getSongsFromJSON:(NSDictionary *)songsInfo {
  NSMutableArray *songs = [[NSMutableArray alloc]init];
  
  NSArray *songList = songsInfo[@"tracks"];
  for (NSDictionary *songInfo in songList) {
    NSString *uri = songInfo[@"uri"];
    NSString *songID = songInfo[@"id"];
    NSString *name = songInfo[@"name"];
    NSNumber *popularity = songInfo[@"popularity"];
    
    Song *song = [[Song alloc]init];
    song.uri = uri;
    song.trackID = songID;
    song.trackName = name;
    song.popularity = popularity;
    [songs addObject:song];
  }
  return songs;
}

@end
