//
//  User.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)initWithDisplayName:(NSString *)displayName AndEmail:(NSString *)email WithUserType:(NSString *)userType {
  if (self == [super init]) {
    _displayName = displayName;
    _email = email;
    _userType = userType;
  }
  return self;
}

@end
