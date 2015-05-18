//
//  AddSongViewControllerDelegate.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Song;

@protocol AddSongViewControllerDelegate <NSObject>

-(void)addSongToPlaylist:(Song *)song;

@end
