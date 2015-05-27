//
//  PlaylistSongTableViewCell.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "PlaylistSongTableViewCell.h"
#import "ImageService.h"
#import "ImageResizer.h"
#import "Song.h"
#import "User.h"
#import "StreamifyStyleKit.h"

CGFloat const kArtworkPlaylistImageHeightWidth = 75;
CGFloat const kProfilePlaylistImageHeightWidth = 50;

@interface PlaylistSongTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *albumArtworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contributorImageView;

@end

@implementation PlaylistSongTableViewCell

-(void)configureCell:(Song *)song {
  self.albumArtworkImageView.image = nil;
  self.artistNameLabel.text = nil;
  self.trackNameLabel.text = nil;
  self.contributorImageView.image = nil;
  
  self.artistNameLabel.textColor = [StreamifyStyleKit spotifyGreen];
  
  self.artistNameLabel.text = song.artistName;
  self.trackNameLabel.text = song.trackName;
  if (song.albumArtwork) {
    self.albumArtworkImageView.image = song.albumArtwork;
  } else {
    self.albumArtworkImageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    UIImage *artworkImage = [[ImageService sharedService]getImageFromURL:song.albumArtworkURL];
    UIImage *resizedImage = [ImageResizer resizeImage:artworkImage withSize:CGSizeMake(kArtworkPlaylistImageHeightWidth, kArtworkPlaylistImageHeightWidth)];
    song.albumArtwork = resizedImage;
    self.albumArtworkImageView.image = resizedImage;
    
    self.albumArtworkImageView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
      self.albumArtworkImageView.alpha = 1;
      self.albumArtworkImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
  }
  self.contributorImageView.layer.cornerRadius = kProfilePlaylistImageHeightWidth / 2;
  self.contributorImageView.layer.masksToBounds = true;
  if (song.contributor) {
    if (song.contributor.profileImage) {
      self.contributorImageView.image = song.contributor.profileImage;
    } else {
      self.contributorImageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
      if (song.contributor.profileImageURL) {
        UIImage *profileImage = [[ImageService sharedService]getImageFromURL:song.contributor.profileImageURL];
        UIImage *resizedImage = [ImageResizer resizeImage:profileImage withSize:CGSizeMake(kProfilePlaylistImageHeightWidth, kProfilePlaylistImageHeightWidth)];
        song.contributor.profileImage = resizedImage;
        self.contributorImageView.image = resizedImage;
        self.contributorImageView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
          self.contributorImageView.alpha = 1;
          self.contributorImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
      }
    }
  }
}

@end
