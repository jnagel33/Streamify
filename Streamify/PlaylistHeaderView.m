//
//  PlaylistHeaderView.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "PlaylistHeaderView.h"
#import "StreamifyStyleKit.h"

@implementation PlaylistHeaderView

- (void)drawRect:(CGRect)rect {
  [StreamifyStyleKit drawHeaderViewWithFrame:rect];
}

@end
