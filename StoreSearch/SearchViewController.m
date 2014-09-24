//
//  SearchViewController.m
//  StoreSearch
//
//  Created by Alan on 14-9-23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (nonatomic,weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic,weak) IBOutlet UITableView* tableView;

@end

@implementation SearchViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}


@end
