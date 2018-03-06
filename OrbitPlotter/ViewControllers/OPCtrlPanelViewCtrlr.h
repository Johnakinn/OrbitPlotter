//
//  OPCtrlPanelViewCtrlr.h
//  OrbitPlotter
//
//  Created by John Kinn on 11/3/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPCtrlPanelViewCtrlr_h
#define OPCtrlPanelViewCtrlr_h

#import <UIKit/UIKit.h>
#import "PerspectiveHelper.h"
#import "GameViewController.h"

@interface OPCtrlPanelViewCtrlr : UIViewController

@property PerspectiveHelper * perspHelper;

@property GameViewController * gameViewController;

@property (strong, nonatomic) IBOutlet UISwitch *useMotionSwitch;

@property (strong, nonatomic) IBOutlet UISegmentedControl *rotateYorZ;

@property (strong, nonatomic) IBOutlet UISlider *velocitySlider;

@property (strong, nonatomic) IBOutlet UISlider *angleVelocitySlider;

@property (strong, nonatomic) IBOutlet UISegmentedControl *turnMoveSegment;

@property (strong, nonatomic) IBOutlet UISegmentedControl *thrustDirSegment;

@property (strong, nonatomic) IBOutlet UILabel *thrustLabel;

@property (strong, nonatomic) IBOutlet UILabel *turnMoveLabel;


- (IBAction)exitAction:(UIButton *)sender;

- (IBAction)thrustChange:(UISlider *)sender;

- (IBAction)angleVelocityChange:(UISlider *)sender;

- (IBAction)turnMoveChange:(UISegmentedControl *)sender;

- (IBAction)thrustDirChange:(UISegmentedControl *)sender;

- (IBAction)toggleUseMotion:(UISwitch *)sender;

- (IBAction)rotateXorYChange:(UISegmentedControl *)sender;

@end

#endif /* OPCtrlPanelViewCtrlr_h */
