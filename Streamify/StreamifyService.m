//
//  StreamifyService.m
//  Streamify
//
//  Created by Josh Nagel on 5/19/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "StreamifyService.h"
#import "AFNetworking.h"
#import "User.h"
#import "Playlist.h"
#import "StreamifyJSONParser.h"
#import "Song.h"

@implementation StreamifyService

+(id)sharedService {
  static StreamifyService *mySharedService = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mySharedService = [[self alloc] init];
  });
  return mySharedService;
}

-(AFHTTPRequestOperationManager *)operationManager {
  if (_operationManager != nil) {
    return _operationManager;
  }
  _operationManager = [AFHTTPRequestOperationManager manager];
  return _operationManager;
}

-(AFURLSessionManager *)sessionManager {
  if (_sessionManager != nil) {
    return _sessionManager;
  }
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  return _sessionManager;
}

-(void)loginApp:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(User *user))completionHandler {
  NSString *urlStr = @"http://streamify-team.herokuapp.com/api/user/sign_in";
  self.operationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:urlStr]];
  self.operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
  [self.operationManager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
  [self.operationManager GET:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString *appToken = responseObject[@"token"];
    NSLog(@"Success");
    if (appToken) {
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [[NSUserDefaults standardUserDefaults]setValue:appToken forKey:@"appToken"];
        NSString *username = responseObject[@"username"];
        NSString *email = responseObject[@"email"];
        
        User *user = [[User alloc]initWithUserID:nil displayName:username AndEmail:email WithUserType:@"App" andProfileImageURL:nil];
        completionHandler(user);
      }];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
  }];
}


-(void)createUser:(NSString *)username AndPassword:(NSString *)password AndUserType:(NSString *)userType completionHandler:(void (^)(User *user))completionHandler {
  NSString *urlStr = @"http://streamify-team.herokuapp.com/api/user/create_user";
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  NSDictionary *usernamePassword = @{@"username":username, @"password":password, @"userType":userType};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:usernamePassword options:0 error:&error];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"POST";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        NSLog(@"Success");
        NSString *appToken = responseObject[@"token"];
        if (appToken) {
          [[NSUserDefaults standardUserDefaults]setValue:appToken forKey:@"appToken"];
        }
        NSString *username = responseObject[@"username"];
        NSString *email = responseObject[@"email"];
        
          User *user = [[User alloc]initWithUserID:nil displayName:username AndEmail:email WithUserType:@"App" andProfileImageURL:nil];
        completionHandler(user);
      }];
    }
  }];
  [dataTask resume];
}

-(void)checkForExistingSpotifyUser:(NSString *)username completionHandler:(void (^)(User *user))completionHandler {
  NSString *urlStr = @"http://streamify-team.herokuapp.com/api/user/spotify_user";
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  NSDictionary *usernamePassword = @{@"username":username, @"password":@"spotify", @"userType":@"spotify"};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:usernamePassword options:0 error:&error];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"POST";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        NSLog(@"Success");
        NSString *appToken = responseObject[@"token"];
        if (appToken) {
          [[NSUserDefaults standardUserDefaults]setValue:appToken forKey:@"appToken"];
        }
        NSString *username = responseObject[@"username"];
        NSString *email = responseObject[@"email"];
        
        User *user = [[User alloc]initWithUserID:nil displayName:username AndEmail:email WithUserType:@"App" andProfileImageURL:nil];
        completionHandler(user);
      }];
    }
  }];
  [dataTask resume];
}

-(void)addFavoriteSongForUser:(Song *)song completionHandler:(void (^)(NSString *success))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/user/fav"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  
  NSDictionary *playlistInfo = @{@"eat": appToken, @"favorites":song.trackID};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:playlistInfo options:0 error:&error];

  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"PUT";
  request.HTTPBody = data;
  
  NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSLog(@"Added Favorite");
  }];
  [task resume];
}

-(void)findMyFavorites: (void (^)(NSArray *songs))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *myToken = [appToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/user/fav?eat=%@",myToken];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
//  NSDictionary *info = @{@"eat":appToken};
//  NSError *error;
//  NSData *data = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
//  request.HTTPBody = data;
  
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([StreamifyJSONParser getSongsFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}


-(void)findMyPlaylists: (void (^)(NSArray *playlists))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/playlist/mine"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSDictionary *info = @{@"eat":appToken};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
  request.HTTPBody = data;
  request.HTTPMethod = @"POST";

  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([StreamifyJSONParser getPlaylistsFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}

-(void)findPlaylistsWithSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *playlists))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/playlist/search"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSDictionary *info = @{@"eat":appToken, @"searchString":searchTerm};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
  request.HTTPBody = data;
  request.HTTPMethod = @"POST";
  
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([StreamifyJSONParser getPlaylistsFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}

-(void)addPlaylist:(Playlist *)playlist completionHandler:(void (^)(NSString *playlistID))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/create_playlist"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  
  NSDictionary *playlistInfo = @{@"name":playlist.name, @"eat": appToken};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:playlistInfo options:0 error:&error];
  
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"POST";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        NSString *playlistID = responseObject[@"_id"];
        completionHandler(playlistID);
      }];
    }
  }];
  [dataTask resume];
}

-(void)fetchSongs:(NSArray *)songs completionHandler:(void (^)(NSArray *songs))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *myToken = [appToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/songs/arrayID?eat=%@",myToken];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:songs options:0 error:&error];
  
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"POST";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([StreamifyJSONParser getPlaylistSongsFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}

-(void)addSong:(Song *)song completionHandler:(void (^)(NSString *streamifyID))completionHandler {
//  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
//  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/songs"];
//  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//  
//  NSDictionary *playlistInfo = @{@"artist": song.artistName,@"name":song.trackName, @"album": song.albumName, @"album_artwork_url":song.albumArtworkURL, @"spotifyID": song.uri, @"duration":song.duration, @"eat": appToken};
//  
//  NSError *error;
//  NSData *data = [NSJSONSerialization dataWithJSONObject:playlistInfo options:0 error:&error];
//  
//  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//  request.HTTPMethod = @"POST";
//  request.HTTPBody = data;
//  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//    if (error) {
//      NSLog(@"Error: %@", error);
//    } else {
//      if (response)
//        NSLog(@"%@ %@", response, responseObject);
//      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//        NSDictionary *songInfo = responseObject;
//        NSDictionary *message = songInfo[@"msg"];
//        NSString *streamifyID = message[@"_id"];
//        completionHandler(streamifyID);
//      }];
//    }
//  }];
//  [dataTask resume];
}

-(void)addSongToPlaylist:(NSString *)playlistID song:(NSString *)streamifyID completionHandler:(void (^)(NSString *playlistID))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/playlist"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  
  NSDictionary *playlistInfo = @{@"song": streamifyID ,@"id":playlistID, @"eat": appToken};
  
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:playlistInfo options:0 error:&error];
  
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"POST";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler(@"Success");
      }];
    }
  }];
  [dataTask resume];
}

-(void)removeSongFromPlaylist:(NSString *)playlistID song:(NSString *)songID completionHandler:(void (^)(NSString *success))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/playlist"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  
  NSDictionary *playlistInfo = @{@"id":playlistID, @"song": songID, @"eat": appToken};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:playlistInfo options:0 error:&error];
  
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"DELETE";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler(@"Success");
      }];
    }
  }];
  [dataTask resume];
}

-(void)removePlaylist:(NSString *)playlistID completionHandler:(void (^)(NSString *success))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/delete_playlist"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  
  NSDictionary *playlistInfo = @{@"id":playlistID, @"eat": appToken};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:playlistInfo options:0 error:&error];
  
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPMethod = @"DELETE";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler(@"Success");
      }];
    }
  }];
  [dataTask resume];
  

}


-(void)findArtistsWithSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *artists))completionHandler {
  NSString *searchText = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *myToken = [appToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/discovery/artist/%@?eat=%@",searchText,myToken];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([StreamifyJSONParser getArtistsFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}

-(void)findArtistsWithGenreSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *artists))completionHandler {
  NSString *searchText = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *myToken = [appToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/discovery/genre/%@?eat=%@",searchText,myToken];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([StreamifyJSONParser getArtistsFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}


-(void)findArtistTopTracks:(NSString *)artistID completionHandler:(void (^)(NSArray *songs))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *myToken = [appToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/discovery/top-tracks/%@?eat=%@",artistID,myToken];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([StreamifyJSONParser getSongsFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}

-(void)findRelatedArtists:(NSString *)artistID completionHandler:(void (^)(NSArray *artists))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *myToken = [appToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/discovery/related/%@?eat=%@",artistID,myToken];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      if (response)
        NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([StreamifyJSONParser getArtistsFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}

//-(void)findVideosBySearch:(NSString *)searchTerm completionHandler:(void (^)(NSArray *artists))completionHandler {
//  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
//  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/discovery/related/%@?eat=%@",artistID,appToken];
//  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//  
//  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//    if (error) {
//      NSLog(@"Error: %@", error);
//    } else {
//      if (response)
//        NSLog(@"%@ %@", response, responseObject);
//      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//        completionHandler([StreamifyJSONParser getArtistsFromJSON:responseObject]);
//      }];
//    }
//  }];
//  [dataTask resume];
//}


@end
