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
        
        User *user = [[User alloc]initWithUsername:username AndEmail:email WithUserType:@"App" andProfileImageURL:nil];
        completionHandler(user);
      }];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
  }];
}

-(void)createUser:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(User *user))completionHandler {
  NSString *urlStr = @"http://streamify-team.herokuapp.com/api/user/create_user";
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  NSDictionary *usernamePassword = @{@"username":@"wwwww", @"password":password};
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
        
        User *user = [[User alloc]initWithUsername:username AndEmail:email WithUserType:@"App" andProfileImageURL:nil];
        completionHandler(user);
      }];
    }
  }];
  [dataTask resume];
}

-(void)findPlaylistsWithSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *playlists))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/playlist?eat=%@&searchTerm=%@",appToken, searchTerm];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
//  NSDictionary *info = @{@"eat":appToken, @"searchTerm":searchTerm};
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
        completionHandler([StreamifyJSONParser getPlaylistsFromJSON:responseObject]);
//        NSLog(@"Success");
//        NSString *appToken = responseObject[@"token"];
//        if (appToken) {
//          [[NSUserDefaults standardUserDefaults]setValue:appToken forKey:@"appToken"];
//        }
//        NSString *username = responseObject[@"username"];
//        NSString *email = responseObject[@"email"];
//        
//        User *user = [[User alloc]initWithDisplayName:username AndEmail:email WithUserType:@"App" andProfileImageURL:nil];
//        completionHandler(user);
      }];
    }
  }];
  [dataTask resume];
}

-(void)addPlaylist:(Playlist *)playlist completionHandler:(void (^)(NSString *success))completionHandler {
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
        completionHandler(@"Success");
      }];
    }
  }];
  [dataTask resume];
}

-(void)addSongToPlaylist:(NSString *)playlistID song:(NSString *)songID completionHandler:(void (^)(NSString *success))completionHandler {
  NSString *appToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"appToken"];
  NSString *urlStr = [NSString stringWithFormat:@"http://streamify-team.herokuapp.com/api/playlist"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  
  NSDictionary *playlistInfo = @{@"id":playlistID, @"song": songID, @"eat": appToken};
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

@end
