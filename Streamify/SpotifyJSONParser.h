//
//  SpotifyJSONParser.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface SpotifyJSONParser : NSObject

+(User *)getUserFromJSON:(NSDictionary *)info;

+(NSArray *)getTracksFromJSON:(NSDictionary *)info;

@end
