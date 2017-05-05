//
//  TableSectionConverterTestCase.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BasicPaymentProducts.h"
#import "BasicPaymentProductsConverter.h"
#import "PaymentProductsTableSection.h"
#import "PaymentProductsTableRow.h"
#import "TableSectionConverter.h"
#import "StringFormatter.h"
#import "AccountOnFile.h"

@interface TableSectionConverterTestCase : XCTestCase

@property (strong, nonatomic) BasicPaymentProductsConverter *paymentProductsConverter;
@property (strong, nonatomic) StringFormatter *stringFormatter;

@end

@implementation TableSectionConverterTestCase

- (void)setUp
{
    [super setUp];
    self.paymentProductsConverter = [[BasicPaymentProductsConverter alloc] init];
    self.stringFormatter = [[StringFormatter alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testPaymentProductsTableSectionFromAccountsOnFile
{
    NSString *paymentProductsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"paymentProducts" ofType:@"json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *paymentProductsData = [fileManager contentsAtPath:paymentProductsPath];
    NSDictionary *paymentProductsJSON = [NSJSONSerialization JSONObjectWithData:paymentProductsData options:0 error:NULL];
    BasicPaymentProducts *paymentProducts = [self.paymentProductsConverter paymentProductsFromJSON:[paymentProductsJSON objectForKey:@"paymentProducts"]];
    NSArray *accountsOnFile = [paymentProducts accountsOnFile];
    for (AccountOnFile *accountOnFile in accountsOnFile) {
        accountOnFile.stringFormatter = self.stringFormatter;
    }
    PaymentProductsTableSection *tableSection = [TableSectionConverter paymentProductsTableSectionFromAccountsOnFile:accountsOnFile paymentProducts:paymentProducts];
    PaymentProductsTableRow *row = tableSection.rows[0];
    XCTAssertTrue([row.name isEqualToString:@"**** **** **** 7988 Rob"] == YES, @"Unexpected title of table section");
}

@end
