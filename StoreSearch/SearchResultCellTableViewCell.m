//
//  SearchResultCellTableViewCell.m
//  StoreSearch
//
//  Created by Alan on 14-9-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SearchResultCellTableViewCell.h"

@implementation SearchResultCellTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIImage* image = [UIImage imageNamed:@"TableCellGradient"];
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:image];
    
    self.backgroundView = backgroundImageView;
    
    UIImage* selectedImage = [UIImage imageNamed:@"SelectedTableCellGradient"];
    
    UIImageView* selectedBackGroundImageView = [[UIImageView alloc] initWithImage:selectedImage];
    
    self.selectedBackgroundView = selectedBackGroundImageView;
    
}

@end
