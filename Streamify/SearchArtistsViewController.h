//
//  SearchArtistsViewController.h
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchArtistsViewController : UIViewController

@property(nonatomic)bool isGenreSearch;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong,nonatomic)NSArray *artists;
@end
