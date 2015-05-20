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

@interface PlaylistViewController () <UITableViewDataSource, UITableViewDelegate, AddSongViewControllerDelegate, SPTAudioStreamingPlaybackDelegate>

@property(weak,nonatomic)IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *songs;
@property(strong,nonatomic)SpotifyService *spotifyService;
@property(strong,nonatomic)StreamifyService *streamifyService;
@property(strong,nonatomic)SPTAudioStreamingController *player;
@property(strong,nonatomic)SPTSession *session;
@property(nonatomic)NSInteger currentRowPlaying;
@property(weak,nonatomic)IBOutlet UIImageView *thumbnailNowPlayingImageView;
@property(weak,nonatomic)IBOutlet UILabel *trackNameNowPlayingLabel;
@property(weak,nonatomic)IBOutlet UILabel *artistNameNowPlayingLabel;
@property(weak,nonatomic)IBOutlet UIView *nowPlayingView;
@property (weak,nonatomic)IBOutlet UILabel *durationLabel;
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
  
  AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
  self.session = appDelegate.session;
  [self createPlayer];
  
  self.streamifyService = [StreamifyService sharedService];
  self.spotifyService = [SpotifyService sharedService];
  
  //Remove later
  self.songs = [[NSMutableArray alloc]init];
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
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
    if (![self.player isPlaying] || self.currentRowPlaying != indexPath.row) {
      NSMutableArray *playlistQueue = [[NSMutableArray alloc]init];
      
      if ([self.player isPlaying]) {
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
        self.currentRowPlaying = indexPath.row;
      }];
    } else {
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
  [self.streamifyService removeSongFromPlaylist:self.currentPlaylist.name song:song.uri completionHandler:^(NSString *success) {
    NSLog(@"%@",success);
  }];
  if (self.currentRowPlaying == indexPath.row) {
    [self.player stop:^(NSError *error) {
      if (error != nil) {
        NSLog(@"*** Stopping playback got error: %@", error);
        return;
      }
    }];
  } else {
    if (self.songs.count > (self.currentRowPlaying + 1)) {
      NSArray *songs = [self.songs subarrayWithRange:NSMakeRange(self.currentRowPlaying + 1, self.songs.count - self.currentRowPlaying + 1)];
      [self.player queueURIs:songs clearQueue:true callback:nil];
    }
  }
  [self.songs removeObject:song];
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
  [self.streamifyService addSongToPlaylist:self.currentPlaylist.playlistID song:song.uri completionHandler:^(NSString *success) {
    NSLog(@"%@",success);
  }];
  
  [self.songs addObject:song];
  [self.tableView reloadData];
  if ([self.player isPlaying]) {
    [self.player queueURIs:@[[NSURL URLWithString:song.uri]] clearQueue:false callback:nil];
  }
  NSLog(@"%d", self.player.trackListSize);
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
        self.thumbnailNowPlayingImageView.alpha = 1;
      }];
    }
  }
}

-(void)updateCurrentTrackDuration {
  self.currentDuration = self.player.currentTrackDuration;

  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(decrementDuration) userInfo:nil repeats:true];
}

-(void)decrementDuration {
  self.currentDuration -= .01;
  [self updateTimer];
}

-(void)updateTimer {
  int minutes = floor(self.currentDuration/60);
  int seconds = trunc(self.currentDuration - minutes * 60);
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.currentDuration];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  dateFormatter.dateFormat = @"mm:ss";
  self.durationLabel.text = [dateFormatter stringFromDate:date];
//  self.durationLabel.text = [NSString stringWithFormat:@"%d:%d",minutes,seconds];
}

@end
