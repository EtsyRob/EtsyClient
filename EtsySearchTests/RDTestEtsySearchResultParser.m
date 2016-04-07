//
//  RDTestEtsySearchResultParser.m
//  EtsySearch
//
//  Created by Robert Day on 4/6/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RDEtsySearchResultParser.h"
#import "RDEtsyClientSearchResult.h"
#import "RDEtsyClient.h"

@interface RDTestEtsySearchResultParser : XCTestCase
@end

@implementation RDTestEtsySearchResultParser

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testParseGoodData {
    NSURL *goodDataURL = [[self testDataBaseURL] URLByAppendingPathComponent:@"GoodData.json"];
    NSData *goodData = [NSData dataWithContentsOfURL:goodDataURL];
    NSURL *fakeURL = [NSURL URLWithString:@"http://fakeurl.com"];
    RDEtsyClientSearchResult *searchResult = [RDEtsySearchResultParser parseResponseData:goodData forSearchURL:fakeURL];
    
    XCTAssertNotNil(searchResult);
    XCTAssertEqual(searchResult.results.count, 25);
    XCTAssertEqual(searchResult.currentPage, 1);
    XCTAssertEqual(searchResult.nextPage, 2);
}

-(void)testParseNilData {
    NSURL *fakeURL = [NSURL URLWithString:@"http://fakeurl.com"];
    RDEtsyClientSearchResult *searchResult = [RDEtsySearchResultParser parseResponseData:nil forSearchURL:fakeURL];
    
    XCTAssertNil(searchResult);
}

-(void)testParseNilSearchURL {
    NSURL *goodDataURL = [[self testDataBaseURL] URLByAppendingPathComponent:@"GoodData.json"];
    NSData *goodData = [NSData dataWithContentsOfURL:goodDataURL];
    RDEtsyClientSearchResult *searchResult = [RDEtsySearchResultParser parseResponseData:goodData forSearchURL:nil];
    
    XCTAssertNil(searchResult);
}

-(void)testParseMalformedData {
    NSURL *fakeURL = [NSURL URLWithString:@"http://fakeurl.com"];
    NSString *fakeDataString = @"This is not json";
    NSData *fakeData = [fakeDataString dataUsingEncoding:NSUTF8StringEncoding];
    RDEtsyClientSearchResult *searchResult = [RDEtsySearchResultParser parseResponseData:fakeData forSearchURL:fakeURL];
    
    XCTAssertNil(searchResult);
}

-(void)testParseWithEmptyResults {
    NSURL *fakeURL = [NSURL URLWithString:@"http://fakeurl.com"];
    NSURL *emptyResultsURL = [[self testDataBaseURL] URLByAppendingPathComponent:@"EmptyResults.json"];
    NSData *emptyResultsData = [NSData dataWithContentsOfURL:emptyResultsURL];
    
    RDEtsyClientSearchResult *searchResult = [RDEtsySearchResultParser parseResponseData:emptyResultsData forSearchURL:fakeURL];
    
    XCTAssertNotNil(searchResult);
    XCTAssertEqual(searchResult.results.count, 0);
    XCTAssertEqual(searchResult.currentPage, 1 );
    XCTAssertEqual(searchResult.nextPage, NoNextPageValue);
    
}

- (NSURL *)testDataBaseURL {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle.bundleURL URLByAppendingPathComponent:@"TestData"];
}



@end
