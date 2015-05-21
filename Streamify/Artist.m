//
//  Artist.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "Artist.h"

@implementation Artist

-(instancetype)initWithArtistID:(NSString *)artistID name:(NSString *)name popularity:(NSNumber *)popularity artistImageURL:(NSString *)artistImageURL {
  if (self == [super init]) {
    _artistID = artistID;
    _name = name;
    _popularity = popularity;
    _artistImageUrl = artistImageURL;
  }
  return self;
}

@end
