//
//  Playlist.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;

@interface Playlist : NSObject

@property(strong,nonatomic)NSString *playlistID;
@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)User *host;
@property(strong,nonatomic)NSDate *dateCreated;
@property(strong,nonatomic)NSArray *songs;

-(instancetype)initWithID:(NSString *)playlistID name:(NSString *)name host:(User *)host dateCreated:(NSDate *)date songs:(NSArray *)songs;

@end
