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
  NSArray *images = info[@"images"];
  NSDictionary *image = images[0];
  NSString *profileImageURL = image[@"url"];
  return [[User alloc]initWithDisplayName:displayName AndEmail:email WithUserType:@"Spotify" andProfileImageURL:profileImageURL];
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
    NSNumber *duration = item[@"duration_ms"];
    NSString *uri = item[@"uri"];
    NSString *trackName = item[@"name"];
    Song *song = [[Song alloc]initWithTrackName:trackName artistName:artistName albumName:albumName albumArtworkURL:albumArtworkURL uri:uri duration:duration];
    [songs addObject:song];
  }
  return songs;
}

@end
