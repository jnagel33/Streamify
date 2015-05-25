//
//  StreamifyService.h
//  Streamify
//
//  Created by Josh Nagel on 5/19/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperationManager;
@class AFURLSessionManager;
@class User;
@class Playlist;
@class Song;

@interface StreamifyService : NSObject
@property(strong,nonatomic) AFHTTPRequestOperationManager *operationManager;
@property(strong,nonatomic) AFURLSessionManager *sessionManager;

+(id)sharedService;

-(void)loginApp:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(User *user))completionHandler;

-(void)createUser:(NSString *)username AndPassword:(NSString *)password AndUserType:(NSString *)userType completionHandler:(void (^)(User *user))completionHandler;

-(void)checkForExistingSpotifyUser:(NSString *)username completionHandler:(void (^)(User *user))completionHandler;

-(void)addFavoriteSongForUser:(Song *)song completionHandler:(void (^)(NSString *success))completionHandler;

-(void)findMyFavorites: (void (^)(NSArray *songs))completionHandler;

-(void)findMyPlaylists: (void (^)(NSArray *playlists))completionHandler;

-(void)findPlaylistsWithSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *playlists))completionHandler;

-(void)addPlaylist:(Playlist *)playlist completionHandler:(void (^)(NSString *success))completionHandler;

-(void)fetchSongs:(NSArray *)songs completionHandler:(void (^)(NSArray *songs))completionHandler;

-(void)addSong:(Song *)song completionHandler:(void (^)(NSString *streamifyID))completionHandler;

-(void)addSongToPlaylist:(NSString *)playlistID song:(NSString *)streamifyID completionHandler:(void (^)(NSString *playlistID))completionHandler;

-(void)removePlaylist:(NSString *)playlistID completionHandler:(void (^)(NSString *success))completionHandler;

-(void)removeSongFromPlaylist:(NSString *)playlistID song:(NSString *)songID completionHandler:(void (^)(NSString *success))completionHandler;

-(void)findArtistsWithSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *artists))completionHandler;

-(void)findArtistsWithGenreSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *artists))completionHandler;

-(void)findArtistTopTracks:(NSString *)artistID completionHandler:(void (^)(NSArray *songs))completionHandler;

-(void)findRelatedArtists:(NSString *)artistID completionHandler:(void (^)(NSArray *artists))completionHandler;

@end
