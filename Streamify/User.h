//
//  User.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(strong,nonatomic)NSString *displayName;
@property(strong,nonatomic)NSString *email;
@property(strong,nonatomic)NSString *userType;

-(instancetype)initWithDisplayName:(NSString *)displayName AndEmail:(NSString *)email WithUserType:(NSString *)userType;


@end
