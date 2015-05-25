//
//  InterfaceController.m
//  Streamify WatchKit Extension
//
//  Created by Josh Nagel on 5/22/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "InterfaceController.h"
#import "Playlist.h"
#import "PlaylistRow.h"


@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property(strong,nonatomic)NSArray *playlists;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  
  [InterfaceController openParentApplication:nil reply:^(NSDictionary *replyInfo, NSError *error) {
    self.playlists = replyInfo[@"playlists"];
    [self.table setNumberOfRows:self.playlists.count withRowType:@"PlaylistRow"];
    
    for (Playlist *playlist in self.playlists) {
      NSUInteger rowIndex = [self.playlists indexOfObject:playlist];
      Playlist *playlist = self.playlists[rowIndex];
      PlaylistRow *playlistRow = [self.table rowControllerAtIndex:rowIndex];
      [playlistRow configureCell:playlist];
    }
    
  }];
  
  
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



