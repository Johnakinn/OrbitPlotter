//
//  OPStatsViewCtrlr.m
//  OrbitPlotter
//
//  Created by John Kinn on 11/11/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPStatsViewCtrlr.h"

@implementation OPStatsViewCtrlr

@synthesize perspHelper;

@synthesize shieldLabel;
@synthesize shieldSlider;
@synthesize shieldPercentLabel;

@synthesize heatShieldLabel;
@synthesize heatShieldSlider;
@synthesize heatShieldPctLabel;

@synthesize fuelLabel;
@synthesize fuelSlider;
@synthesize fuelPctLabel;

- (void)viewWillAppear:(BOOL)animated {

    heatShieldPctLabel.text =
    [NSString stringWithFormat:@"%d%%", (int)(((float)((float)perspHelper.heatShieldCapacityIdx)/MAX_HEAT_SHIELD_STRENGTH)*100)];
    
    heatShieldLabel.text = @"Remaining Heat Shield Strength.";
    
    heatShieldSlider.minimumValue = 0;
    heatShieldSlider.maximumValue = MAX_HEAT_SHIELD_STRENGTH;
    [heatShieldSlider setValue:perspHelper.heatShieldCapacityIdx];
    
    shieldPercentLabel.text =
    [NSString stringWithFormat:@"%d%%", (int)(((float)((float)perspHelper.impactShiledCapacityIdx)/MAX_SHIELD_STRENGTH)*100)];
    
    shieldLabel.text = @"Remaining Shield Strength.";
    
    shieldSlider.minimumValue = 0;
    shieldSlider.maximumValue = MAX_SHIELD_STRENGTH;
    [shieldSlider setValue:perspHelper.impactShiledCapacityIdx];
    
    fuelPctLabel.text =
    [NSString stringWithFormat:@"%d%%", (int)(((float)((float)perspHelper.fuelCapacityIdx)/MAX_FUEL)*100)];
    
    fuelLabel.text = @"Remaining Fuel.";
    
    fuelSlider.minimumValue = 0;
    fuelSlider.maximumValue = MAX_FUEL;
    [fuelSlider setValue:perspHelper.fuelCapacityIdx];
}

- (IBAction)exitAction:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
