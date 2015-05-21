//
//  IconDetailTableViewCell.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "IconDetailTableViewCell.h"

@interface IconDetailTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation IconDetailTableViewCell

-(void)configureCell:(UIImage *)image AndDetailText:(NSString *)text {
  self.iconImageView.image = nil;
  self.detailLabel.text = nil;
  
  self.iconImageView.image = image;
  self.detailLabel.text = text;
}

@end
