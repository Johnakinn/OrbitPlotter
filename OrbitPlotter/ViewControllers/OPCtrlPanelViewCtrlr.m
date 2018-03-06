//
//  OPCtrlPanelViewCtrlr.m
//  OrbitPlotter
//
//  Created by John Kinn on 11/3/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPCtrlPanelViewCtrlr.h"

@implementation OPCtrlPanelViewCtrlr

@synthesize perspHelper;

@synthesize velocitySlider;
@synthesize angleVelocitySlider;

@synthesize turnMoveSegment;
@synthesize thrustDirSegment;

@synthesize thrustLabel;
@synthesize turnMoveLabel;

@synthesize useMotionSwitch;

@synthesize gameViewController;

@synthesize rotateYorZ;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    velocitySlider.value = perspHelper.thrustVelocity;
    angleVelocitySlider.value = perspHelper.angleChangeVelocity;
    
    thrustDirSegment.selectedSegmentIndex = perspHelper.thrustDirection == -1 ? 0 : 1;
    
    turnMoveSegment.selectedSegmentIndex = perspHelper.turnMoveId;
    
    thrustLabel.text = [NSString stringWithFormat:@"%.2f%%", perspHelper.thrustVelocity*100];
    
    turnMoveLabel.text = [NSString stringWithFormat:@"%.2f%%", perspHelper.angleChangeVelocity*100];
    
    [useMotionSwitch setOn:perspHelper.useMotion];
    
    rotateYorZ.selectedSegmentIndex = perspHelper.rotateYorZ;
    
    [super viewDidAppear:animated];
}

- (IBAction)exitAction:(UIButton *)sender {
    
    [gameViewController motionControl];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)thrustChange:(UISlider *)sender {
    perspHelper.thrustVelocity = sender.value;
    thrustLabel.text = [NSString stringWithFormat:@"%.2f%%", sender.value*100];
}

- (IBAction)angleVelocityChange:(UISlider *)sender {
    perspHelper.angleChangeVelocity = sender.value;
    turnMoveLabel.text = [NSString stringWithFormat:@"%.2f%%", sender.value*100];
}

- (IBAction)turnMoveChange:(UISegmentedControl *)sender {
    perspHelper.turnMoveId = sender.selectedSegmentIndex;
}

- (IBAction)thrustDirChange:(UISegmentedControl *)sender {
    perspHelper.thrustDirection = sender.selectedSegmentIndex == 0 ? -1 : 1;
}

- (IBAction)toggleUseMotion:(UISwitch *)sender {
    perspHelper.useMotion = sender.isOn;
}

- (IBAction)rotateXorYChange:(UISegmentedControl *)sender {
    perspHelper.rotateYorZ = sender.selectedSegmentIndex;
}
@end

