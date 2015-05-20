//
//  ArtistCollectionViewCell.h
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Artist;

@interface ArtistCollectionViewCell : UICollectionViewCell

-(void)configureCell:(Artist *)artist;

@end
