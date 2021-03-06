//
//  Song.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@interface Song : NSObject

@property(strong,nonatomic)NSString *trackID;
@property(strong,nonatomic)NSString *trackName;
@property(strong,nonatomic)NSString *artistName;
@property(strong,nonatomic)NSString *albumName;
@property(strong,nonatomic)NSString *albumArtworkURL;
@property(strong,nonatomic)UIImage *albumArtwork;
@property(strong,nonatomic)NSString *uri;
@property(strong,nonatomic)User *contributor;
@property(strong,nonatomic)NSNumber *popularity;

-(instancetype)initWithTrackID:(NSString *)trackID Name:(NSString *)trackName artistName:(NSString *)artistName albumName:(NSString *)albumName albumArtworkURL:(NSString *)albumArtworkURL uri:(NSString *)uri contributor:(User *)contributor;

@end
