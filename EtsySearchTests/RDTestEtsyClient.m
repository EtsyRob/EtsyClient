//
//  RDTestEtsyClient.m
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RDEtsyClient.h"
#import "RDEtsyClientSearchResult.h"

#define kTestTimeout 2.0
#define kAPIKey "liwecjs0c3ssk6let4p1wqt9"
@interface RDTestEtsyClient : XCTestCase
@property (nonatomic, strong) RDEtsyClient *etsyClient;
@end

//If more time allotted, this could use something like OHHTTPStubs to mock these request

@implementation RDTestEtsyClient

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _etsyClient = [[RDEtsyClient alloc] initWithApiKey:@kAPIKey];
    XCTAssertNotNil(self.etsyClient);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testGetListingsWithQueryText {
    XCTestExpectation *expection = [self expectationWithDescription:@"Client request"];
    
    [self.etsyClient getListingsWithQueryText:@"Wooden Chair" completion:^(RDEtsyClientSearchResult *searchResult) {
        
        NSArray<RDEtsySearchResultItem *> *results = searchResult.results;
        
        XCTAssertNotNil(results);
        XCTAssertEqual([results count], 25);
        
        [expection fulfill];
        
    }];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:nil];
}

- (void)testGetListingsWithNilQueryText {
    XCTestExpectation *expection = [self expectationWithDescription:@"Client request"];
    
    [self.etsyClient getListingsWithQueryText:nil completion:^(RDEtsyClientSearchResult *searchResult) {

        
        XCTAssertNil(searchResult);
    
        
        [expection fulfill];
        
    }];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:nil];
}

- (void)testGetListingsWithNonMatchingText {
    XCTestExpectation *expection = [self expectationWithDescription:@"Client request"];
    
    [self.etsyClient getListingsWithQueryText:@"DKDKKSLRANDOMTEXTDLDKAKD" completion:^(RDEtsyClientSearchResult *searchResult) {
        
        
        XCTAssertNotNil(searchResult);
        NSArray<RDEtsySearchResultItem *> *results = searchResult.results;
        XCTAssertEqual([results count], 0);
        
        
        [expection fulfill];
        
    }];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:nil];
}

- (void)testGetListingsWithSpecialCharacters {
    XCTestExpectation *expection = [self expectationWithDescription:@"Client request"];
    
    [self.etsyClient getListingsWithQueryText:@"$@(!)@($)akd" completion:^(RDEtsyClientSearchResult *searchResult) {
        
        XCTAssertNotNil(searchResult);
        [expection fulfill];
        
    }];
    [self waitForExpectationsWithTimeout:kTestTimeout handler:nil];
}


@end
