//
//  SpotifyService.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "SpotifyService.h"
#import <Spotify/Spotify.h>
#import "AFNetworking.h"
#import "User.h"
#import "SpotifyJSONParser.h"

@implementation SpotifyService

+(id) sharedService {
  static SpotifyService *mySharedService = nil;
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

//-(void)playUsingSession:(SPTSession *)session withTrack:(NSString *)trackUri  {
//  
//  // Create a new player if needed
//  if (self.player == nil) {
//    self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
//  }
//  
//  [self.player loginWithSession:session callback:^(NSError *error) {
//    if (error != nil) {
//      NSLog(@"*** Logging in got error: %@", error);
//      return;
//    }
//    
//    //    NSURL *trackURI = [NSURL URLWithString:trackUri];
//    //    [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
//    //      if (error != nil) {
//    //        NSLog(@"*** Starting playback got error: %@", error);
//    //        return;
//    //      }
//    //    }];
//    //        [self.player queueURIs:@ clearQueue:<#(BOOL)#> callback:<#^(NSError *error)block#>]
//    //        [self.player que]
//  }];
//}


//-(void)searchForTracks {
//  NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"token"];
//  
//  
//  NSString *urlStr = [NSString stringWithFormat:@"https://api.spotify.com/v1/me/tracks"];
//  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//  
//  if (token) {
//    [request setValue:[NSString stringWithFormat:@"Bearer %@",token ] forHTTPHeaderField:@"Authorization"];
//  }
//  NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//    NSLog(@"%@",data);
//    
//    
//    NSDictionary *savedTracksInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSArray *tracks = savedTracksInfo[@"items"];
//    for (NSDictionary *track in tracks) {
//      NSDictionary *trackInfo = track[@"track"];
//      //          NSDictionary *album = trackInfo[@"album"];
//      //          NSString *name = album[@"name"];
//      NSString *uri = trackInfo[@"uri"];
//    }
//  }];
//  [task resume];
//}


-(void)getUserProfile: (void (^)(User *user))completionHandler {
  NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"token"];
  NSString *urlStr = [NSString stringWithFormat:@"https://api.spotify.com/v1/me"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  
  if (token) {
    [request setValue:[NSString stringWithFormat:@"Bearer %@",token ] forHTTPHeaderField:@"Authorization"];
  }
  
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([SpotifyJSONParser getUserFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}

-(void)getTracksFromSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *tracks))completionHandler {
  NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"token"];
  NSString *urlStr = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?type=track&q=%@",searchTerm];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  if (token) {
    [request setValue:[NSString stringWithFormat:@"Bearer %@",token ] forHTTPHeaderField:@"Authorization"];
  }
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        completionHandler([SpotifyJSONParser getTracksFromJSON:responseObject]);
      }];
    }
  }];
  [dataTask resume];
}

@end
