//
//  TestsWithOC.m
//  YTKNetwork-SWItroFiT_Tests
//
//  Created by liqiang on 2020/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <YTKNetwork_SWItroFiT_Tests-Swift.h>

@import YTKNetwork;
@import YTKNetwork_SWItroFiT;

@interface TestsWithOC : XCTestCase

@end

@implementation TestsWithOC

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSArray *ignoredKeys = @[@"device"];
    [[SwitrofitConfig instance] setIgnoredPathArgumentsWithKeys:ignoredKeys];
    TestService *service = [TestService new];
    YTKRequest *api = [service testApiWithA:1 b:1024 c:YES d:@"string" e:nil];
    XCTAssert([[api requestUrl] isEqualToString:@"test-service/{device}/path/1/1024"]);
    XCTAssert([api.requestArgument isKindOfClass:[NSDictionary class]]);
    NSDictionary *arguments = (NSDictionary<NSString *, NSString *> *) api.requestArgument;
    XCTAssert(arguments.count == 2);
    XCTAssert([arguments[@"c"] isEqualToString:@"true"]);
    XCTAssert([arguments[@"d"] isEqualToString:@"string"]);
    TestClass *result = [api parseTestClass];
    XCTAssert(result == nil);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
