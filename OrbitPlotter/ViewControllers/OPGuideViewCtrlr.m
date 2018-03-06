//
//  OPGuideViewCtrlr.m
//  OrbitPlotter
//
//  Created by John Kinn on 11/11/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPGuideViewCtrlr.h"

@implementation OPGuideViewCtrlr

//@synthesize exitButton;
//@synthesize textView1;
//@synthesize textView2;
@synthesize titleLabel;

//- (void)viewWillAppear:(BOOL)animated {
    //[textView1 setBackgroundColor: [UIColor clearColor]];
    //[textView1 setTextColor: [UIColor whiteColor]];
//    [super viewWillAppear:animated];
//}

//- (void)viewDidLoad {
    
//    [super viewDidLoad];
    
    
    //[textView1 setBackgroundColor: [UIColor clearColor]];
    //[textView1 setTextColor: [UIColor whiteColor]];
    
    //NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Orbit Plotting Guide"];
    //[attributeString addAttribute:NSUnderlineStyleAttributeName
    //                        value:[NSNumber numberWithInt:1]
    //                        range:(NSRange){0,[attributeString length]}];
    
    //titleLabel.layer.backgroundColor = (__bridge CGColorRef _Nullable)(theColor);
    //titleLabel.textColor = (__bridge UIColor * _Nullable)([UIColor whiteColor].CGColor);
    
    //exitButton.layer.borderWidth = 2;
    //exitButton.layer.cornerRadius = 5;
    //exitButton.layer.borderColor = [UIColor whiteColor].CGColor;
//}

- (IBAction)exitAction:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
