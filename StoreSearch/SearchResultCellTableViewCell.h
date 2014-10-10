//
//  SearchResultCellTableViewCell.h
//  StoreSearch
//
//  Created by Alan on 14-9-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchResult;
@interface SearchResultCellTableViewCell : UITableViewCell{

}

@property (nonatomic,weak) IBOutlet UILabel* nameLabel;
@property (nonatomic,weak) IBOutlet UILabel* artistNameLabel;
@property (nonatomic,weak) IBOutlet UIImageView* artworkImageView;

- (void)configureForSearchResult:(SearchResult *)searchResult;

@end
