//
//  StreamifyJSONParser.h
//  Streamify
//
//  Created by Josh Nagel on 5/19/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamifyJSONParser : NSObject

+(NSArray *)getPlaylistsFromJSON:(NSArray *)playlistInfo;

+(NSArray *)getArtistsFromJSON:(NSDictionary *)artistsInfo;

+(NSArray *)getSongsFromJSON:(NSDictionary *)songsInfo;
@end
