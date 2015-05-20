//
//  Artist.h
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Artist : NSObject

@property(strong, nonatomic)NSString *artistID;
@property(strong, nonatomic)NSString *name;
@property(strong, nonatomic)NSNumber *popularity;
@property(strong,nonatomic)NSString *artistImageUrl;
@property(strong,nonatomic)UIImage *artistImage;

-(instancetype)initWithArtistID:(NSString *)artistID name:(NSString *)name popularity:(NSNumber *)popularity artistImageURL:(NSString *)artistImageURL;

@end
