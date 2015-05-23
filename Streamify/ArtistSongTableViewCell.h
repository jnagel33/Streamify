//
//  ArtistSongTableViewCell.h
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Song;

@interface ArtistSongTableViewCell : UITableViewCell

-(void)configureCell:(Song *)song rowPlaying:(bool)rowPlaying;

@end
