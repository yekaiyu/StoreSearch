//
//  SearchResult.m
//  StoreSearch
//
//  Created by Alan on 14-9-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult


- (NSComparisonResult) compareName:(SearchResult *)other
{
    
    return [self.name localizedStandardCompare:other.name];
}

@end
