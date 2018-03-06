//
//  OPStatsViewCtrlr.h
//  OrbitPlotter
//
//  Created by John Kinn on 11/11/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPStatsViewCtrlr_h
#define OPStatsViewCtrlr_h

#import <UIKit/UIKit.h>
#import "PerspectiveHelper.h"

@interface OPStatsViewCtrlr : UIViewController

@property PerspectiveHelper * perspHelper;

@property (strong, nonatomic) IBOutlet UILabel *shieldLabel;

@property (strong, nonatomic) IBOutlet UISlider *shieldSlider;

@property (strong, nonatomic) IBOutlet UILabel *shieldPercentLabel;

@property (strong, nonatomic) IBOutlet UILabel *heatShieldLabel;

@property (strong, nonatomic) IBOutlet UISlider *heatShieldSlider;

@property (strong, nonatomic) IBOutlet UILabel *heatShieldPctLabel;

@property (strong, nonatomic) IBOutlet UILabel *fuelLabel;

@property (strong, nonatomic) IBOutlet UISlider *fuelSlider;

@property (strong, nonatomic) IBOutlet UILabel *fuelPctLabel;


//@property (strong, nonatomic) IBOutlet UIButton *exitButton;

//@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

//@property (strong, nonatomic) IBOutlet UITextView *textView1;

//@property (strong, nonatomic) IBOutlet UITextView *textView2;

- (IBAction)exitAction:(UIButton *)sender;

@end

#endif /* OPGuideViewCtrlr_h */
