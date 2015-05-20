//
//  User.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)initWithUserID:(NSString *)userID displayName:(NSString *)displayName AndEmail:(NSString *)email WithUserType:(NSString *)userType andProfileImageURL:(NSString *)profileImageURL {
  if (self == [super init]) {
    _userID = userID;
    _displayName = displayName;
    _email = email;
    _userType = userType;
    _profileImageURL = profileImageURL;
  }
  return self;
}

@end
