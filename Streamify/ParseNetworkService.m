//
//  ParseNetworkService.m
//  Streamify
//
//  Created by Josh Nagel on 5/29/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ParseNetworkService.h"
#import "User.h"
#import "Playlist.h"
#import "Song.h"
#import "Artist.h"
#import <Parse/Parse.h>

@implementation ParseNetworkService

+(id)sharedService {
  static ParseNetworkService *mySharedService = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mySharedService = [[self alloc] init];
  });
  return mySharedService;
}

-(void)loginApp:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(User *user))completionHandler {
  NSError *error;
  [PFUser logInWithUsername:username password:password error:&error];
  if (error) {
    
  } else {
    PFUser *currentUser = [PFUser currentUser];
    User *user = [[User alloc]initWithUserID:currentUser.objectId displayName:currentUser.username AndEmail:nil WithUserType:currentUser[@"userType"] andProfileImageURL:currentUser[@"profileImageURL"]];
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
      completionHandler(user);
    }];
  }
}

-(void)createUser:(NSString *)username AndPassword:(NSString *)password AndUserType:(NSString *)userType completionHandler:(void (^)(User *user))completionHandler {
  PFUser *user = [[PFUser alloc]init];
  user.username = username;
  user.password = password;
  user[@"userType"] = userType;
  [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    PFUser *currentUser = [PFUser currentUser];
    User *user = [[User alloc]initWithUserID:currentUser.objectId displayName:currentUser.username AndEmail:nil WithUserType:currentUser[@"userType"] andProfileImageURL:nil];
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
      completionHandler(user);
    }];
  }];
}

-(void)checkForExistingSpotifyUser:(NSString *)username completionHandler:(void (^)(User *user))completionHandler {
  [PFUser logInWithUsernameInBackground:username password:@"spotify" block:^(PFUser *user, NSError *error) {
    if (error) {
      PFUser *user = [[PFUser alloc]init];
      user.username = username;
      user.password = @"spotify";
      user[@"userType"] = @"spotify";
      [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFUser *currentUser = [PFUser currentUser];
        User *user = [[User alloc]initWithUserID:currentUser[@"objectId"] displayName:currentUser[@"username"] AndEmail:nil WithUserType:currentUser[@"userType"] andProfileImageURL:nil];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
          completionHandler(user);
        }];
      }];
    } else {
      PFUser *currentUser = [PFUser currentUser];
      User *user = [[User alloc]initWithUserID:currentUser.objectId displayName:currentUser.username AndEmail:nil WithUserType:currentUser[@"userType"] andProfileImageURL:currentUser[@"profileImageURL"]];
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler(user);
      }];
    }
  }];
}

-(void)addFavoriteSongForUser:(Song *)song completionHandler:(void (^)(NSString *success))completionHandler {
  
}

-(void)findMyFavorites: (void (^)(NSArray *songs))completionHandler {

}

-(void)findMyPlaylists: (void (^)(NSArray *playlists))completionHandler {
  PFQuery *query = [PFQuery queryWithClassName:@"Playlist"];
  [query whereKey:@"host" equalTo:[PFUser currentUser]];
  [query includeKey:@"Track"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *playlists, NSError *error) {
    NSMutableArray *playlistList = [[NSMutableArray alloc]init];
    for (PFObject *playlist in playlists) {
      NSMutableArray *songs = [[NSMutableArray alloc]init];
      for (PFObject *song in playlist[@"tracks"]) {
        Song *playlistSong = [[Song alloc]init];
        playlistSong.trackID = song.objectId;
        [songs addObject:playlistSong];
      }
      Playlist *myPlaylist = [[Playlist alloc]initWithID:playlist.objectId name:playlist[@"name"] host:nil dateCreated:playlist[@"dateCreated"] songs:songs];
      [playlistList addObject:myPlaylist];
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler(playlistList);
      }];
    }
  }];
}

-(void)findPlaylistsWithSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *playlists))completionHandler {
  NSString *searchText = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  PFQuery *query = [PFQuery queryWithClassName:@"Playlist"];
  [query whereKey:@"name" containsString:searchText];
  [query findObjectsInBackgroundWithBlock:^(NSArray *playlists, NSError *error) {
    NSMutableArray *playlistList = [[NSMutableArray alloc]init];
    for (PFObject *playlist in playlists) {
      Playlist *searchPlaylist = [[Playlist alloc]initWithID:playlist.objectId name:playlist[@"name"] host:nil dateCreated:playlist[@"dateCreated"] songs:nil];
      [playlistList addObject:searchPlaylist];
    }
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
      completionHandler(playlistList);
    }];
  }];
}

-(void)addPlaylist:(Playlist *)playlist completionHandler:(void (^)(NSString *playlistID))completionHandler {
  PFObject *newPlaylist = [[PFObject alloc]initWithClassName:@"Playlist"];
  newPlaylist[@"name"] = playlist.name;
  newPlaylist[@"host"] = [PFUser currentUser];
  [newPlaylist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (!error) {
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler(newPlaylist.objectId);
      }];
    }
  }];
}

-(void)fetchSongs:(NSString *)playlistID completionHandler:(void (^)(NSArray *songs))completionHandler {
  PFQuery *query = [PFQuery queryWithClassName:@"Playlist"];
  [query getObjectInBackgroundWithId:playlistID block:^(PFObject *playlist, NSError *error) {
    NSMutableArray *playlistTracks = [[NSMutableArray alloc]init];
    [PFObject fetchAllInBackground:playlist[@"tracks"] block:^(NSArray *songs, NSError *error) {
      for (PFObject *track in songs) {
        Song *song = [[Song alloc]initWithTrackID:track.objectId Name:track[@"name"] artistName:track[@"artist"] albumName:track[@"album"] albumArtworkURL:track[@"artwork_url"] uri:track[@"uri"] duration:nil streamifyID:nil];
        [playlistTracks addObject:song];
      }
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler(playlistTracks);
      }];
    }];
  }];
}

-(void)addSongsToPlaylist:(NSArray *)songs playlistID:(NSString *)playlistID completionHandler:(void (^)(NSString *playlistID))completionHandler {
  NSMutableArray *songsToAdd = [[NSMutableArray alloc]init];
  for (Song *song in songs) {
    PFObject *newSong = [[PFObject alloc]initWithClassName:@"Track"];
    newSong[@"name"] = song.trackName;
    newSong[@"artist"] = song.artistName;
    newSong[@"album"] = song.albumName;
    newSong[@"artwork_url"] = song.albumArtworkURL;
    newSong[@"uri"] = song.uri;
    newSong[@"contributor"] = [PFUser currentUser];
    [songsToAdd addObject:newSong];
  }
  PFQuery *query = [PFQuery queryWithClassName:@"Playlist"];
  [query getObjectInBackgroundWithId:playlistID block:^(PFObject *playlist, NSError *error) {
    NSLog(@"%@", playlist);
    [playlist addObjectsFromArray:songsToAdd forKey:@"tracks"];
    [PFObject saveAllInBackground:@[playlist,songsToAdd] block:^(BOOL succeeded, NSError *error) {
      if (!error) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
          completionHandler(playlistID);
        }];
      }
    }];
  }];
}

-(void)removeSongFromPlaylist:(NSString *)playlistID song:(NSString *)songID completionHandler:(void (^)(NSString *success))completionHandler {
  PFQuery *query = [PFQuery queryWithClassName:@"Playlist"];
  [query whereKey:@"objectId" equalTo:playlistID];
  [query findObjectsInBackgroundWithBlock:^(NSArray *playlists, NSError *error) {
    PFObject *playlist = [playlists firstObject];
    PFQuery *query = [PFQuery queryWithClassName:@"Track"];
    [query whereKey:@"objectId" equalTo:songID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *tracks, NSError *error) {
      PFObject *track = [tracks firstObject];
      [playlist removeObject:track forKey:@"tracks"];
      [playlist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
          completionHandler(@"Success");
        }];
      }];
    }];
  }];
}

-(void)removePlaylist:(NSString *)playlistID completionHandler:(void (^)(NSString *success))completionHandler {
  PFQuery *query = [PFQuery queryWithClassName:@"Playlist"];
  [query whereKey:@"objectId" equalTo:playlistID];
  [query findObjectsInBackgroundWithBlock:^(NSArray *playlists, NSError *error) {
    PFObject *playlist = [playlists firstObject];
    [playlist deleteEventually];
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
      completionHandler(@"Success");
    }];
  }];
}

@end
