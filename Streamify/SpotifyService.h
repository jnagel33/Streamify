//
//  SpotifyService.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>
@class AFHTTPRequestOperationManager;
@class AFURLSessionManager;
@class User;

@interface SpotifyService : NSObject

+(id) sharedService;

@property(strong,nonatomic) AFHTTPRequestOperationManager *operationManager;
@property(strong,nonatomic) AFURLSessionManager *sessionManager;

-(void)getUserProfile: (void (^)(User *user))completionHandler;

-(void)getTracksFromSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *tracks))completionHandler;

-(void)playUsingSession:(SPTSession *)session AndPlayer:(SPTAudioStreamingController *)player withTrack:(NSString *)trackUri;

-(void)loginApp:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(void))completionHandler;

-(void)createUser:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(void))completionHandler;

@end
