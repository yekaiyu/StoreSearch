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
static NSString *const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString *const LoadingCellIdentifier = @"LoadingCell";


@interface SearchUIViewController ()

@property (nonatomic,weak) IBOutlet UISearchBar* searchBar;
@property (nonatomic,weak) IBOutlet UITableView* tableView;

@end

@implementation SearchUIViewController{
    NSMutableArray* searchResults;
    
    BOOL isLoading;
    
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
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
    [self.searchBar becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoading){
        
        return 1;
        
    }else if (searchResults == nil){
    
        return 0;
        
    }else if ([searchResults count] == 0){

        return 1;
        
    }else{
        
        return [searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(isLoading){
        
        return [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
    
    }else if([searchResults count]==0){
        
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier];
        
    } else {
        
        SearchResultCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        
        SearchResult* searchResult = [searchResults objectAtIndex:indexPath.row];
    
        cell.nameLabel.text = searchResult.name;
        cell.artistNameLabel.text = searchResult.artistName;
        
        NSString* artistName = searchResult.artistName;
        
        if(artistName == nil){
            
            artistName = @"Unknown";
            
        }
        
        NSString* kind = [self kindForDisplay:searchResult.kind];
        
        cell.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName , kind];
        
        return cell;
    }
    
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([searchResults count] == 0 || isLoading){
        
        return nil;
        
    } else {
        
        return indexPath;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [searchBar resignFirstResponder];
//    
//    searchResults = [NSMutableArray arrayWithCapacity:10];
//    
//    if(![searchBar.text isEqualToString:@"yelu"]){
//        for (int i=0;i<3;i++){
//        
//            SearchResult* searchResult = [[SearchResult alloc] init];
//            searchResult.name = [NSString stringWithFormat:@"Fake Result %d for",i];
//            searchResult.artistName = searchBar.text;
//            [searchResults addObject:searchResult];
//            
//        }
//    }
//    [self.tableView reloadData];
//    
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    if([searchBar.text length] > 0){
        
        [searchBar resignFirstResponder];
        
        isLoading = YES;
        [self.tableView reloadData];
        
        searchResults = [NSMutableArray arrayWithCapacity:10];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue,^{
        
            NSURL* url = [self urlWithSearchText:searchBar.text];
        
            NSString* jsonString = [self performStoreRequestWithURL:url];
        
            if(jsonString == nil){
            
                [self showNetworkError];
                return;
            
            }

        
            NSDictionary* dictionary = [self parseJSON:jsonString];
        
            if(dictionary == nil){
            
                [self showNetworkError];
                return;
            
            }
        
            NSLog(@"Dictionary '%@'",dictionary);
        
            [self parseDictionary:dictionary];
        
            [searchResults sortUsingSelector:@selector(compareName:)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                isLoading = NO;
                [self.tableView reloadData];
                
            });
        
        });
    }
    
}

- (NSURL *)urlWithSearchText:(NSString *)searchText
{
    NSString* escaoedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200",escaoedSearchText];
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    return url;
    
}

- (NSString *)performStoreRequestWithURL:(NSURL *) url
{
    
    NSError* error;
    NSString* resultString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if(resultString == nil){
        
        NSLog(@"Download Error: %@",error);
        return nil;
        
    }
    
    return resultString;
    
}

- (NSDictionary *)parseJSON:(NSString *)jsonString
{
    
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error;
    
    id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(resultObject == nil){
        
        NSLog(@"Parse JSON error: '%@'", error);
        return nil;
        
    }
    
    if(![resultObject isKindOfClass:[NSDictionary class]]){
        
        NSLog(@"JSON Error: Expected dictionary");
        return nil;
        
    }
    
    return resultObject;
    
}

- (void)showNetworkError
{
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"There was an error reading from the iTunes Store." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
    
}

- (void)parseDictionary:(NSDictionary *)dictionary
{
    
    NSArray* array = [dictionary objectForKey:@"results"];
    
    if(array == nil ){
       
        NSLog(@"Excepted 'result' array");
        return;
        
    }
    
    for (NSDictionary* resultDict in array) {
        
        SearchResult* searchResult;
        
        NSString* wrapperType = [resultDict objectForKey:@"wrapperType"];
        
        if([wrapperType isEqualToString:@"track"]){
            
            searchResult = [self parseTrack:resultDict];
            
        } else if ([wrapperType isEqualToString:@"audiobook"]){
            
            searchResult = [self parseAudioBook:resultDict];
            
        } else if ([wrapperType isEqualToString:@"software"]){
            
            searchResult = [self parseSoftware:resultDict];
            
        } else if ([wrapperType isEqualToString:@"ebook"]){
            
            searchResult = [self parseEBook:resultDict];
            
        }
        
        if(searchResult !=nil){
            
            [searchResults addObject:searchResult];
            
        }
        
    }
    
    
}

- (SearchResult *)parseTrack:(NSDictionary *)dictionary
{
    
    SearchResult* searchResult = [[SearchResult alloc] init];
    searchResult.name = [dictionary objectForKey:@"trackName"];
    searchResult.artistName = [dictionary objectForKey:@"artistName"];
    searchResult.artworkURL60 = [dictionary objectForKey:@"artworkUrl60"];
    searchResult.artworkURL100 = [dictionary objectForKey:@"artworkUrl100"];
    searchResult.storeURL = [dictionary objectForKey:@"trackViewUrl"];
    searchResult.kind = [dictionary objectForKey:@"kind"];
    searchResult.price = [dictionary objectForKey:@"trackPrice"];
    searchResult.currency = [dictionary objectForKey:@"currency"];
    searchResult.genre = [dictionary objectForKey:@"primaryGenreName"];
    
    return searchResult;
    
}

- (SearchResult *)parseAudioBook:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    searchResult.name = [dictionary objectForKey:@"collectionName"];
    searchResult.artistName = [dictionary objectForKey:@"artistName"];
    searchResult.artworkURL60 = [dictionary objectForKey:@"artworkUrl60"];
    searchResult.artworkURL100 = [dictionary objectForKey:@"artworkUrl100"];
    searchResult.storeURL = [dictionary objectForKey:@"collectionViewUrl"];
    searchResult.kind = @"audiobook";
    searchResult.price = [dictionary objectForKey:@"collectionPrice"];
    searchResult.currency = [dictionary objectForKey:@"currency"];
    searchResult.genre = [dictionary objectForKey:@"primaryGenreName"];
    return searchResult;
}

- (SearchResult *)parseSoftware:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    searchResult.name = [dictionary objectForKey:@"trackName"];
    searchResult.artistName = [dictionary objectForKey:@"artistName"];
    searchResult.artworkURL60 = [dictionary objectForKey:@"artworkUrl60"];
    searchResult.artworkURL100 = [dictionary objectForKey:@"artworkUrl100"];
    searchResult.storeURL = [dictionary objectForKey:@"trackViewUrl"];
    searchResult.kind = [dictionary objectForKey:@"kind"];
    searchResult.price = [dictionary objectForKey:@"price"];
    searchResult.currency = [dictionary objectForKey:@"currency"];
    searchResult.genre = [dictionary objectForKey:@"primaryGenreName"];
    return searchResult;
}

- (SearchResult *)parseEBook:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    searchResult.name = [dictionary objectForKey:@"trackName"];
    searchResult.artistName = [dictionary objectForKey:@"artistName"];
    searchResult.artworkURL60 = [dictionary objectForKey:@"artworkUrl60"];
    searchResult.artworkURL100 = [dictionary objectForKey:@"artworkUrl100"];
    searchResult.storeURL = [dictionary objectForKey:@"trackViewUrl"];
    searchResult.kind = [dictionary objectForKey:@"kind"];
    searchResult.price = [dictionary objectForKey:@"price"];
    searchResult.currency = [dictionary objectForKey:@"currency"];
    searchResult.genre = [(NSArray *)[dictionary objectForKey:@"genres"] componentsJoinedByString:@", "];
    return searchResult;
}


- (NSString *)kindForDisplay:(NSString *)kind
{
    if ([kind isEqualToString:@"album"]) {
        return @"Album";
    } else if ([kind isEqualToString:@"audiobook"]) {
        return @"Audio Book";
    } else if ([kind isEqualToString:@"book"]) {
        return @"Book";
    } else if ([kind isEqualToString:@"ebook"]) {
        return @"E-Book";
    } else if ([kind isEqualToString:@"feature-movie"]) {
        return @"Movie";
    } else if ([kind isEqualToString:@"music-video"]) {
        return @"Music Video";
    } else if ([kind isEqualToString:@"podcast"]) {
        return @"Podcast";
    } else if ([kind isEqualToString:@"software"]) {
        return @"App";
    } else if ([kind isEqualToString:@"song"]) {
        return @"Song";
    } else if ([kind isEqualToString:@"tv-episode"]) {
        return @"TV Episode";
    } else {
        return kind;
    }
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
