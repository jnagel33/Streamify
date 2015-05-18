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

CGFloat const kArtworkPlaylistImageHeightWidth = 75;

@interface PlaylistSongTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *albumArtworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;

@end

@implementation PlaylistSongTableViewCell

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
    UIImage *resizedImage = [ImageResizer resizeImage:artworkImage withSize:CGSizeMake(kArtworkPlaylistImageHeightWidth, kArtworkPlaylistImageHeightWidth)];
    song.albumArtwork = resizedImage;
    self.albumArtworkImageView.image = resizedImage;
  }
}

@end
