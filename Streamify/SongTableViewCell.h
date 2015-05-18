//
//  SongTableViewCell.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Song;

@interface SongTableViewCell : UITableViewCell

-(void)configureCell:(Song *)song;

@end
