//
//  OPGuideViewCtrlr.h
//  OrbitPlotter
//
//  Created by John Kinn on 11/11/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPGuideViewCtrlr_h
#define OPGuideViewCtrlr_h

#import <UIKit/UIKit.h>

@interface OPGuideViewCtrlr : UIViewController

//@property (strong, nonatomic) IBOutlet UIButton *exitButton;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UITextView *textView1;

@property (strong, nonatomic) IBOutlet UITextView *textView2;

- (IBAction)exitAction:(UIButton *)sender;

@end

#endif /* OPGuideViewCtrlr_h */
