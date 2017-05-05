//
//  PaymentProductInputDataTestCase.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2016 Global Collect Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PaymentProductInputData.h"
#import "PaymentProductConverter.h"
#import "PaymentRequest.h"

@interface PaymentProductInputDataTestCase : XCTestCase

@property (nonatomic, strong) PaymentProductInputData *inputData;
@property (nonatomic, strong) PaymentProductConverter *converter;

@end

@implementation PaymentProductInputDataTestCase

- (void)setUp {
    [super setUp];

    self.inputData = [[PaymentProductInputData alloc] init];
    self.converter = [[PaymentProductConverter alloc] init];
    NSString *paymentProductPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"paymentProduct" ofType:@"json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *paymentProductData = [fileManager contentsAtPath:paymentProductPath];
    NSDictionary *paymentProductJSON = [NSJSONSerialization JSONObjectWithData:paymentProductData options:0 error:NULL];
    PaymentProduct *paymentProduct = [self.converter paymentProductFromJSON:paymentProductJSON];
    self.inputData.paymentItem = paymentProduct;
    self.inputData.accountOnFile = paymentProduct.accountsOnFile.accountsOnFile[0];
}

- (void)tearDown {

    [super tearDown];
}

- (void)testSetValue
{
    [self.inputData setValue:@"12345678" forField:@"cardNumber"];
    NSString *maskedValue = [self.inputData maskedValueForField:@"cardNumber"];
    NSString *expectedOutput = @"1234 5678 ";
    XCTAssertTrue([maskedValue isEqualToString:expectedOutput] == YES, @"Value not set correctly in payment request");
}

- (void)testValidate
{
    [self.inputData setValue:@"1" forField:@"cvv"];
    [self.inputData validate];
    XCTAssertTrue(self.inputData.errors.count == 2, @"Unexpected number of errors while validating payment request");
}

- (void)testFieldIsPartOfAccountOnFileYes
{
    XCTAssertTrue([self.inputData fieldIsPartOfAccountOnFile:@"cardNumber"] == YES, @"Card number should be part of account on file");
}

- (void)testFieldIsPartOfAccountOnFileNo
{
    XCTAssertTrue([self.inputData fieldIsPartOfAccountOnFile:@"cvv"] == NO, @"CVV should not be part of account on file");
}

- (void)testMaskedValueForField
{
    NSString *maskedValue = [self.inputData maskedValueForField:@"expiryDate"];
    XCTAssertTrue([maskedValue isEqualToString:@"08/20"] == YES, @"Masked expiry date is incorrect");
}

- (void)testMaskedValueForFieldWithCursorPosition
{
    NSInteger cursorPosition = 4;
    NSString *maskedValue = [self.inputData maskedValueForField:@"expiryDate" cursorPosition:&cursorPosition];
    XCTAssertTrue([maskedValue isEqualToString:@"08/20"] == YES, @"Masked expiry date is incorrect");
    XCTAssertTrue(cursorPosition == 5, @"Cursor position after applying mask is incorrect");
}

- (void)testUnmaskedValueForField
{
    NSString *value = [self.inputData unmaskedValueForField:@"expiryDate"];
    XCTAssertTrue([value isEqualToString:@"0820"] == YES, @"Unmasked expiry date is incorrect");
}

@end
