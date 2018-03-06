//
//  GameViewController.h
//  orbitPlotter3
//
//  Created by John Kinn on 7/29/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>
#import "OPMapView.h"
#import "PerspectiveHelper.h"
#import "MomentumCircleManager.h"
#import "OPOverlayView.h"

@interface displayMsg : NSObject

@property NSString * pctWarnStr;
@property NSString * warnStr;
@property int minVal;
@property int maxVal;
@property int curVal;

@end

@interface GameViewController : GLKViewController

@property float thrustVelocity;
@property float angleChangeVelocity;

//@property (strong, nonatomic) IBOutlet UIButton *controlButton;

@property (strong, nonatomic) IBOutlet OPOverlayView *infoView;

@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) IBOutlet UILabel *levelLabel;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

@property (strong, nonatomic) IBOutlet UILabel *slideTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *fuelPctLabel;

@property (strong, nonatomic) IBOutlet UILabel *damageLabel;

@property CMMotionManager * motionManager;

@property (strong, nonatomic) IBOutlet UIButton *thrustPerpetualButton;

@property (strong, nonatomic) IBOutlet UIButton *thrustButton;

@property (strong, nonatomic) IBOutlet UIButton *controlButton;

@property (strong, nonatomic) IBOutlet UIButton *guideButton;


@property (strong, nonatomic) IBOutlet UIView *warningView;

@property (strong, nonatomic) IBOutlet UILabel *warnLabel;

@property (strong, nonatomic) IBOutlet UILabel *warnPercentLabel;

@property (strong, nonatomic) IBOutlet UISlider *warnSlider;

//@property (strong, nonatomic) IBOutlet UISlider *speedSlider;

//@property NSMutableArray * planetArr;
//@property NSMutableArray * satelliteArr;

@property PerspectiveHelper *perspHelper;

//@property PersType perspectType;

@property UIPopoverController* pop;

//@property (strong, nonatomic) IBOutlet UILabel *xAngleLabel;

//@property (strong, nonatomic) IBOutlet UILabel *yAngleLabel;

//@property (strong, nonatomic) IBOutlet UILabel *zAngleLabel;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *oneTap;

@property (strong, nonatomic) IBOutlet OPMapView *mapView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *twoTap;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPress;

//@property (strong, nonatomic) IBOutlet UILabel *xTextField;

//@property (strong, nonatomic) IBOutlet UILabel *yTextField;

//@property (strong, nonatomic) IBOutlet UILabel *zTextField;


//@property (strong, nonatomic) IBOutlet UILabel *xVelocityLebel;

//@property (strong, nonatomic) IBOutlet UILabel *yVelocityLabel;

//@property (strong, nonatomic) IBOutlet UILabel *zVelocityLabel;

- (IBAction)twoTapAction:(UITapGestureRecognizer *)sender;

- (IBAction)pinchAction:(UIPinchGestureRecognizer *)sender;

//- (IBAction)swipeRightAction:(UISwipeGestureRecognizer *)sender;

//- (IBAction)swipeLeftAction:(UISwipeGestureRecognizer *)sender;

- (IBAction)thrustPerpetualAction:(UIButton *)sender;


- (IBAction)rotateAction:(UIRotationGestureRecognizer *)sender;

- (IBAction)panAction:(UIPanGestureRecognizer *)sender;

- (IBAction)tapAction:(UITapGestureRecognizer *)sender;

- (IBAction)longPressAction:(UILongPressGestureRecognizer *)sender;

//- (IBAction)y90Action:(UIButton *)sender;

//- (IBAction)z90Aciton:(UIButton *)sender;


//- (IBAction)controlAction:(UIButton *)sender;

- (IBAction)thrustAction:(UIButton *)sender;

- (void)displayReleventInfo;


//- (IBAction)returnActionForSegue:(UIStoryboardSegue *)returnSegue;

- (void)motionControl;

- (IBAction)thrustRepeatTouch:(UIButton *)sender;

- (IBAction)resetAction:(UIButton *)sender;
//- (void)resetParial;

//- (IBAction)thrustVelocityChange:(UISlider *)sender;

@end
