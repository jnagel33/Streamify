//
//  PlaylistRow.h
//  Streamify
//
//  Created by Josh Nagel on 5/23/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Playlist;

@interface PlaylistRow : NSObject

-(void)configureCell:(Playlist *)playlist;

@end
