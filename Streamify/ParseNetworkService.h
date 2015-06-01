//
//  ParseNetworkService.h
//  Streamify
//
//  Created by Josh Nagel on 5/29/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;
@class Playlist;
@class Song;
@class Artist;

@interface ParseNetworkService : NSObject

+(id)sharedService;

-(void)loginApp:(NSString *)username AndPassword:(NSString *)password completionHandler:(void (^)(User *user))completionHandler;

-(void)createUser:(NSString *)username AndPassword:(NSString *)password AndUserType:(NSString *)userType completionHandler:(void (^)(User *user))completionHandler;

-(void)checkForExistingSpotifyUser:(NSString *)username completionHandler:(void (^)(User *user))completionHandler;

-(void)addFavoriteSongForUser:(Song *)song completionHandler:(void (^)(NSString *success))completionHandler;

-(void)findMyFavorites: (void (^)(NSArray *songs))completionHandler;

-(void)findMyPlaylists: (void (^)(NSArray *playlists))completionHandler;

-(void)findPlaylistsWithSearchTerm:(NSString *)searchTerm completionHandler:(void (^)(NSArray *playlists))completionHandler;

-(void)addPlaylist:(Playlist *)playlist completionHandler:(void (^)(NSString *playlistID))completionHandler;

-(void)fetchSongs:(NSString *)playlistID completionHandler:(void (^)(NSArray *songs))completionHandler;

-(void)addSongsToPlaylist:(NSArray *)songs playlistID:(NSString *)playlistID completionHandler:(void (^)(NSString *playlistID))completionHandler;

-(void)removePlaylist:(NSString *)playlistID completionHandler:(void (^)(NSString *success))completionHandler;

-(void)removeSongFromPlaylist:(NSString *)playlistID song:(NSString *)songID completionHandler:(void (^)(NSString *success))completionHandler;

@end
