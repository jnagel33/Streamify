//
//  ArtistCollectionViewCell.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ArtistCollectionViewCell.h"
#import "Artist.h"
#import "ImageService.h"
#import "ImageResizer.h"

@interface ArtistCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UILabel *artistName;

@end

@implementation ArtistCollectionViewCell

-(void)configureCell:(Artist *)artist {
  self.artistName.text = nil;
  self.artistImageView.image = nil;
  
  
  self.artistName.text = artist.name;
  self.artistImageView.layer.cornerRadius = 150 / 2;
  self.artistImageView.layer.masksToBounds = true;
  if (artist.artistImage) {
    self.artistImageView.image = artist.artistImage;
  } else {
    self.artistImageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    UIImage *artistImage = [[ImageService sharedService]getImageFromURL:artist.artistImageUrl];
    UIImage *resizedImage = [ImageResizer resizeImage:artistImage withSize:CGSizeMake(150, 150)];
    artist.artistImage = resizedImage;
    self.artistImageView.image = resizedImage;
    
    self.artistImageView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
      self.artistImageView.alpha = 1;
      self.artistImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
  }

}

@end
