//
//  LoginService.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginService : NSObject

-(void)loginWithSpotify:(void (^)(void))completionHandler;

-(void)returnFromRedirect;

@end
