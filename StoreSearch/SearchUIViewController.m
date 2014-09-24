//
//  SearchUIViewController.m
//  StoreSearch
//
//  Created by Alan on 14-9-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SearchUIViewController.h"
#import "SearchResult.h"
#import "SearchResultCellTableViewCell.h"

static NSString *const SearchResultCellIdentifier = @"SearchResultCell";

@interface SearchUIViewController ()

@property (nonatomic,weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic,weak) IBOutlet UITableView* tableView;

@end

@implementation SearchUIViewController{
    NSMutableArray* searchResults;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib* cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    self.tableView.rowHeight = 80;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchResults == nil){
    
        return 0;
        
    }else if ([searchResults count] == 0){

        return 1;
        
    }else{
        
        return [searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SearchResultCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
    
    
    if([searchResults count]==0){
        
        cell.nameLabel.text =@"(Nothing found)";
        
        cell.artistNameLabel.text = @"";
        
    } else {
    
        SearchResult* searchResult = [searchResults objectAtIndex:indexPath.row];
    
        cell.nameLabel.text = searchResult.name;
        cell.artistNameLabel.text = searchResult.artistName;
        
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    searchResults = [NSMutableArray arrayWithCapacity:10];
    
    if(![searchBar.text isEqualToString:@"justin bieber"]){
        for (int i=0;i<3;i++){
        
            SearchResult* searchResult = [[SearchResult alloc] init];
            searchResult.name = [NSString stringWithFormat:@"Fake Result %d for",i];
            searchResult.artistName = searchBar.text;
            [searchResults addObject:searchResult];
            
        }
    }
    [self.tableView reloadData];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
