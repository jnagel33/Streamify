//
//  ArtistViewController.h
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Artist;

@interface ArtistViewController : UIViewController

@property(strong,nonatomic)Artist *selectedArtist;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property(strong,nonatomic)NSIndexPath *selectedIndexPath;

@end
