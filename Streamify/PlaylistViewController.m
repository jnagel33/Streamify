//
//  PlaylistViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "PlaylistViewController.h"
#import "SongTableViewCell.h"
#import "AddSongViewController.h"
#import "Song.h"
#import "SpotifyService.h"
#import "AppDelegate.h"
#import "User.h"
#import "ImageService.h"
#import "ImageResizer.h"
#import "StreamifyStyleKit.h"
#import "Playlist.h"
#import "StreamifyService.h"

@interface PlaylistViewController () <UITableViewDataSource, UITableViewDelegate, AddSongViewControllerDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate>

@property(weak,nonatomic)IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *songs;
@property(strong,nonatomic)SpotifyService *spotifyService;
@property(strong,nonatomic)StreamifyService *streamifyService;
@property(strong,nonatomic)SPTAudioStreamingController *player;
@property(strong,nonatomic)SPTSession *session;
@property(strong,nonatomic)NSIndexPath *currentRowPlaying;
@property(weak,nonatomic)IBOutlet UIImageView *thumbnailNowPlayingImageView;
@property(weak,nonatomic)IBOutlet UILabel *trackNameNowPlayingLabel;
@property(weak,nonatomic)IBOutlet UILabel *artistNameNowPlayingLabel;
@property(weak,nonatomic)IBOutlet UIView *nowPlayingView;
@property(weak,nonatomic)IBOutlet UILabel *durationLabel;
@property(weak, nonatomic)IBOutlet UIImageView *artistIconImageView;
@property(nonatomic)double currentDuration;
@property(strong,nonatomic)NSTimer *timer;

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = self.currentPlaylist.name;
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Back"
                                 style:UIBarButtonItemStylePlain
                                 target:nil
                                 action:nil];
  
  self.navigationItem.backBarButtonItem = backButton;
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.thumbnailNowPlayingImageView.image = nil;
  self.trackNameNowPlayingLabel.text = nil;
  self.artistNameNowPlayingLabel.text = nil;
  self.durationLabel.text = nil;
  self.artistNameNowPlayingLabel.textColor = [StreamifyStyleKit spotifyGreen];
  
//  AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
//  self.session = appDelegate.session;
//  if (!self.player) {
//    [self createPlayer];
//  }
//  self.player.delegate = self;
  
  self.streamifyService = [StreamifyService sharedService];
  self.spotifyService = [SpotifyService sharedService];
  
  NSMutableArray *songIDs = [[NSMutableArray alloc]init];
  for(Song *song in self.currentPlaylist.songs) {
    [songIDs addObject:song.streamifySongID];
  }
  [self.streamifyService fetchSongs:songIDs completionHandler:^(NSArray *songs) {
    self.songs = [[NSMutableArray alloc]initWithArray:songs];
    [self.tableView reloadData];
//    [self.streamifyService findMyFavorites:^(NSArray *songs) {
//      
//    }];
  }];
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
  self.session = appDelegate.session;
  if (!self.player) {
    [self createPlayer];
  }
  self.player.delegate = self;
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nowPlayingPressed:)];
  [self.nowPlayingView addGestureRecognizer:tapGestureRecognizer];
}

-(void)nowPlayingPressed:(UIGestureRecognizer *)sender {
//  [self performSegueWithIdentifier:@"ShowNowPlaying" sender:self];
}


- (IBAction)addSongPressed:(UIBarButtonItem *)sender {
  [self performSegueWithIdentifier:@"SearchSongs" sender:self];
}

-(void)createPlayer {
  self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
  [self.player loginWithSession:self.session callback:^(NSError *error) {
    if (error != nil) {
      NSLog(@"*** Logging in got error: %@", error);
      return;
    }
    self.player.playbackDelegate = self;
  }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.songs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongPlaylistCell" forIndexPath:indexPath];
  Song *song = self.songs[indexPath.row];
  [cell configureCell:song];
  
  return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 76;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.songs.count != 0) {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if ((![self.player isPlaying]) || (self.currentRowPlaying && self.currentRowPlaying != indexPath)) {
      NSMutableArray *playlistQueue = [[NSMutableArray alloc]init];
      
      if ([self.player isPlaying]) {
        [self stopTimer];
        [self.player stop:^(NSError *error) {
          if (error != nil) {
            NSLog(@"*** Stopping playback got error: %@", error);
            return;
          }
        }];
      }
      for (NSInteger i = indexPath.row; i < self.songs.count; i++) {
        Song *song = self.songs[i];
        NSURL *trackURI = [NSURL URLWithString:song.uri];
        [playlistQueue addObject:trackURI];
      }
      [self.player playURIs:playlistQueue fromIndex:0 callback:^(NSError *error) {
        if (error != nil) {
          NSLog(@"*** Starting playback got error: %@", error);
          return;
        }
        [self updateCurrentTrackDuration];
        self.currentRowPlaying = indexPath;
      }];
    } else {
      [self stopTimer];
      [self.player stop:^(NSError *error) {
        if (error != nil) {
          NSLog(@"*** Stopping playback got error: %@", error);
          return;
        }
      }];
    }
  }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  Song *song = self.songs[indexPath.row];
  [self.streamifyService removeSongFromPlaylist:self.currentPlaylist.playlistID song:song.streamifySongID completionHandler:^(NSString *success) {
    NSLog(@"%@",success);
  }];
  if (self.currentRowPlaying == indexPath) {
    [self.player stop:^(NSError *error) {
      if (error != nil) {
        NSLog(@"*** Stopping playback got error: %@", error);
        return;
      }
    }];
  } else if(![self.player isPlaying]) {
    if (self.songs.count > (self.currentRowPlaying.row + 1)) {
      NSArray *songs = [self.songs subarrayWithRange:NSMakeRange(self.currentRowPlaying.row + 1, self.songs.count - (self.currentRowPlaying.row + 1))];
      NSMutableArray *uris = [[NSMutableArray alloc]init];
      for (Song *song in songs) {
        NSURL *url = [NSURL URLWithString:song.uri];
        [uris addObject:url];
      }
      [self.player queueURIs:uris clearQueue:true callback:nil];
      [self.player stop:^(NSError *error) {
        if (error != nil) {
          NSLog(@"*** Stopping playback got error: %@", error);
          return;
        }
      }];
    }
  }
  [self.songs removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier  isEqual: @"SearchSongs"]) {
    AddSongViewController *destinationController = segue.destinationViewController;
    destinationController.delegate = self;
  }
}

-(void)addSongToPlaylist:(Song *)song {
  song.contributor = self.currentUser;
  
  
  PlaylistViewController* __weak weakSelf = self;
  
  [self.streamifyService addSong:song completionHandler:^(NSString *streamifyID) {
    song.streamifySongID = streamifyID;
    
    [weakSelf.streamifyService addSongToPlaylist:weakSelf.currentPlaylist.playlistID song:streamifyID completionHandler:^(NSString *success) {
      NSLog(@"%@",success);
    }];
  }];
  
  [self.songs addObject:song];
  [self.tableView reloadData];
  if ([self.player isPlaying]) {
    [self.player queueURIs:@[[NSURL URLWithString:song.uri]] clearQueue:false callback:nil];
  }
  NSLog(@"%d", self.player.trackListSize);
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri {
  NSLog(@"STARTED PLAYING TRACK : %@", trackUri);
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri {
  NSLog(@"%@", [trackUri relativeString]);
}

-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
  NSLog(@"%@", trackMetadata);
  [self updateCurrentTrackDuration];
  self.trackNameNowPlayingLabel.text = trackMetadata[@"SPTAudioStreamingMetadataTrackName"];
  self.artistNameNowPlayingLabel.text = trackMetadata[@"SPTAudioStreamingMetadataArtistName"];
  for (Song *song in self.songs) {
    NSString *albumName = trackMetadata[@"SPTAudioStreamingMetadataAlbumName"];
    if ([song.albumName isEqualToString:albumName]) {
      self.thumbnailNowPlayingImageView.transform = CGAffineTransformMakeScale(2, 2);
      self.thumbnailNowPlayingImageView.alpha = 0;
      UIImage *resizedImage = [ImageResizer resizeImage:song.albumArtwork withSize:CGSizeMake(50, 50)];
      self.thumbnailNowPlayingImageView.image = resizedImage;
      [UIView animateWithDuration:0.5 animations:^{
        self.thumbnailNowPlayingImageView.transform = CGAffineTransformMakeScale(1, 1);
        self.artistIconImageView.alpha = 1;
        self.thumbnailNowPlayingImageView.alpha = 1;
      }];
    }
  }
}

-(void)updateCurrentTrackDuration {
  self.currentDuration = self.player.currentTrackDuration;
  [self startTimer];
}

-(void)startTimer {
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(decrementDuration) userInfo:nil repeats:true];
//  if (!self.thumbnailNowPlayingImageView.image && [self.player isPlaying]) {
//    Song *song = self.songs[self.currentRowPlaying.row];
//    self.thumbnailNowPlayingImageView.transform = CGAffineTransformMakeScale(2, 2);
//    self.thumbnailNowPlayingImageView.alpha = 0;
//    UIImage *resizedImage = [ImageResizer resizeImage:song.albumArtwork withSize:CGSizeMake(50, 50)];
//    self.thumbnailNowPlayingImageView.image = resizedImage;
//    [UIView animateWithDuration:0.5 animations:^{
//      self.thumbnailNowPlayingImageView.transform = CGAffineTransformMakeScale(1, 1);
//      self.artistIconImageView.alpha = 1;
//      self.thumbnailNowPlayingImageView.alpha = 1;
//    }];
//
//  }
}

-(void)stopTimer {
  [self.timer invalidate];
  self.timer = nil;
}

-(void)decrementDuration {
//  self.currentDuration -= 1;
  [self updateTimer];
}

-(void)updateTimer {
//  if (self.currentDuration < 1) {
//    self.durationLabel.text = @"0:00";
//  } else {
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.currentDuration];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.player.currentPlaybackPosition];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"mm:ss";
    self.durationLabel.text = [dateFormatter stringFromDate:date];
//  }
}

@end
