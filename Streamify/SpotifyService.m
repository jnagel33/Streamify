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
  NSString *searchText = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *token = [[NSUserDefaults standardUserDefaults]valueForKey:@"token"];
  NSString *urlStr = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?type=track&q=%@",searchText];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  if (token) {
    [request setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
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

-(void)loginApp:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(void))completionHandler {
  NSString *urlStr = @"http://streamify-team.herokuapp.com/api/user/sign_in";
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  NSDictionary *usernamePassword = @{@"username":username, @"password":password};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:usernamePassword options:0 error:&error];
  
  request.HTTPMethod = @"POST";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        NSLog(@"Success");
      }];
    }
  }];
  [dataTask resume];
}

-(void)createUser:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(void))completionHandler {
  NSString *urlStr = @"http://streamify-team.herokuapp.com/api/user/create_user";
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
  NSDictionary *usernamePassword = @{@"username":username, @"password":password};
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:usernamePassword options:0 error:&error];
  
  request.HTTPMethod = @"POST";
  request.HTTPBody = data;
  NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
    } else {
      NSLog(@"%@ %@", response, responseObject);
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        NSLog(@"Success");
      }];
    }
  }];
  [dataTask resume];
}


@end
