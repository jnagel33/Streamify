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
#import "ParseNetworkService.h"

@interface PlaylistViewController () <UITableViewDataSource, UITableViewDelegate, AddSongViewControllerDelegate>

@property(weak,nonatomic)IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *songs;
@property(strong,nonatomic)SpotifyService *spotifyService;
@property(strong,nonatomic)ParseNetworkService *parseService;
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
  
  AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
  self.session = appDelegate.session;
  self.player = appDelegate.player;
  
  self.parseService = [ParseNetworkService sharedService];
  self.spotifyService = [SpotifyService sharedService];
  
  [self.parseService fetchSongs:self.currentPlaylist.playlistID completionHandler:^(NSArray *songs) {
    self.songs = [[NSMutableArray alloc]initWithArray:songs];
    [self.tableView reloadData];
  }];
  
  if ([self.player isPlaying]) {
    for (Song *song in self.songs) {
      if ([self.player.currentTrackURI.description isEqualToString:song.uri]) {
        self.trackNameNowPlayingLabel.text = song.trackName;
        self.artistNameNowPlayingLabel.text = song.artistName;
        [self updateCurrentTrackDuration];
        
        // resize for playlist then resize for nowPlaying section
        UIImage *artworkImage = [[ImageService sharedService]getImageFromURL:song.albumArtworkURL];
        UIImage *resizedImage = [ImageResizer resizeImage:artworkImage withSize:CGSizeMake(75, 75)];
        song.albumArtwork = resizedImage;
        
        self.thumbnailNowPlayingImageView.transform = CGAffineTransformMakeScale(2, 2);
        self.thumbnailNowPlayingImageView.alpha = 0;
        resizedImage = [ImageResizer resizeImage:artworkImage withSize:CGSizeMake(50, 50)];
        self.thumbnailNowPlayingImageView.image = resizedImage;
        [UIView animateWithDuration:0.5 animations:^{
          self.thumbnailNowPlayingImageView.transform = CGAffineTransformMakeScale(1, 1);
          self.artistIconImageView.alpha = 1;
          self.thumbnailNowPlayingImageView.alpha = 1;
        }];
      }
    }
  }
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(trackChange:) name:@"trackChange" object:nil];
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nowPlayingPressed:)];
  [self.nowPlayingView addGestureRecognizer:tapGestureRecognizer];
}

-(void)trackChange:(NSNotification *)notification {
  self.trackNameNowPlayingLabel.text = notification.userInfo[@"track"];
  self.artistNameNowPlayingLabel.text = notification.userInfo[@"artist"];
  for (Song *song in self.songs) {
    NSString *albumName = notification.userInfo[@"album"];
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

-(void)nowPlayingPressed:(UIGestureRecognizer *)sender {
//  [self performSegueWithIdentifier:@"ShowNowPlaying" sender:self];
}


- (IBAction)addSongPressed:(UIBarButtonItem *)sender {
  [self performSegueWithIdentifier:@"SearchSongs" sender:self];
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
    NSMutableArray *playlistQueue = [[NSMutableArray alloc]init];
    if ((![self.player isPlaying]) || (self.currentRowPlaying && self.currentRowPlaying != indexPath)) {
      
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
    } else if([self.player isPlaying] && !self.currentRowPlaying) {
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
  [self.parseService removeSongFromPlaylist:self.currentPlaylist.playlistID song:song.trackID completionHandler:^(NSString *success) {
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

-(void)addSongsToPlaylist:(NSArray *)songs {
  [self.parseService addSongsToPlaylist:songs playlistID:self.currentPlaylist.playlistID completionHandler:^(NSString *playlistID) {
    NSLog(@"%@",playlistID);
  }];
  for (Song *song in songs) {
    song.contributor = self.currentUser;
    [self.songs addObject:song];
    [self.tableView reloadData];
    if ([self.player isPlaying]) {
      [self.player queueURIs:@[[NSURL URLWithString:song.uri]] clearQueue:false callback:nil];
    }
  }
}

-(void)updateCurrentTrackDuration {
  self.currentDuration = self.player.currentTrackDuration;
  [self startTimer];
}

-(void)startTimer {
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(decrementDuration) userInfo:nil repeats:true];
}

-(void)stopTimer {
  [self.timer invalidate];
  self.timer = nil;
}

-(void)decrementDuration {
  [self updateTimer];
}

-(void)updateTimer {
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.player.currentPlaybackPosition];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  dateFormatter.dateFormat = @"mm:ss";
  self.durationLabel.text = [dateFormatter stringFromDate:date];
}

@end
