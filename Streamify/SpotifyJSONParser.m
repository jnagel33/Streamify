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

@implementation SpotifyJSONParser

+(User *)getUserFromJSON:(NSDictionary *)info {
  NSString *displayName = info[@"display_name"];
  NSString *email = info[@"email"];
  return [[User alloc]initWithDisplayName:displayName AndEmail:email WithUserType:nil];
}

+(NSArray *)getTracksFromJSON:(NSDictionary *)info {
  NSMutableArray *songs = [[NSMutableArray alloc]init];
  NSLog(@"%@", info);
  NSDictionary *tracksInfo = info[@"tracks"];
  NSArray *items = tracksInfo[@"items"];
  for (NSDictionary *item in items) {
    NSDictionary *album = item[@"album"];
    NSArray *albumArtworkItems = album[@"images"];
    NSString *albumArtworkURL = albumArtworkItems[1];
    NSString *albumName = album[@"name"];
    NSArray *artists = item[@"artists"];
    NSDictionary *artist = artists[0];
    NSString *artistName = artist[@"name"];
    NSNumber *duration = item[@"duration_ms"];
    NSString *uri = item[@"uri"];
    NSString *trackName = item[@"name"];
    Song *song = [[Song alloc]initWithTrackName:trackName artistName:artistName albumName:albumName albumArtworkURL:albumArtworkURL uri:uri duration:duration];
    [songs addObject:song];
  }
  return songs;
}

@end