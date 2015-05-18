//
//  SongTableViewCell.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "SongTableViewCell.h"
#import "Song.h"
#import "ImageService.h"
#import "ImageResizer.h"

CGFloat const kArtworkImageHeightWidth = 75;

@interface SongTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *albumArtworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;

@end

@implementation SongTableViewCell

-(void)configureCell:(Song *)song {
  self.albumArtworkImageView.image = nil;
  self.artistNameLabel.text = nil;
  self.trackNameLabel.text = nil;
  
  self.artistNameLabel.text = song.artistName;
  self.trackNameLabel.text = song.trackName;
  if (song.albumArtwork) {
    self.albumArtworkImageView.image = song.albumArtwork;
  } else {
    UIImage *artworkImage = [[ImageService sharedService]getImageFromURL:song.albumArtworkURL];
    UIImage *resizedImage = [ImageResizer resizeImage:artworkImage withSize:CGSizeMake(kArtworkImageHeightWidth, kArtworkImageHeightWidth)];
    song.albumArtwork = resizedImage;
    self.albumArtworkImageView.image = resizedImage;
  }
}

@end
