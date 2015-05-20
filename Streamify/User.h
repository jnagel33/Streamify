//
//  User.h
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface User : NSObject

@property(strong,nonatomic)NSString *username;
@property(strong,nonatomic)NSString *email;
@property(strong,nonatomic)NSString *userType;
@property(strong,nonatomic)NSString *profileImageURL;
@property(strong,nonatomic)UIImage *profileImage;
@property(strong,nonatomic)NSArray *songs;

-(instancetype)initWithUsername:(NSString *)username AndEmail:(NSString *)email WithUserType:(NSString *)userType andProfileImageURL:(NSString *)profileImageURL;


@end
