//
//  OPWormHoldController.h
//  OrbitPlotter
//
//  Created by John Kinn on 12/27/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPWormHoldController_h
#define OPWormHoldController_h


#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "PerspectiveHelper.h"
#import "OPPlanet.h"
//#import "OPMovingCelestrial.h"
//#import "OPRing.h"
#import "OPWall.h"
#import "MomentumCircleManager.h"

static const int NUM_ZONES = 3;

@interface OPWormHoleController : NSObject {
    int numActiveWalls;
    NSMutableArray * wallArr;
    NSMutableArray * obsticlesArr[NUM_ZONES];
    
    
    
    //NSTimeInterval lastNewCelestrialTime[NumCelestrialLifeScopeTypes];
    
    //bool checkNearestToTouch;
    //CGPoint touchPoint;
    
    float angleX[8], angleY[8], angleZ[8];
    float theX, theY, theZ;
    
    float theXBase[8];
    float theYBase[8];
    float theZBase[8];
    
    float theXCalc;
    float theYCalc;
    float theZCalc;
    
    float theScale;
    
    float sideWidth;
    float halfSideWidth;
    
    //float eVV = (theScale - sideWidth)/2;
    
    float leftOverWidth;
    float halfLeftOverWidth;
    //float midXPos = (sideWidth/2)+(leftOverWidth/2);
    
    //float zInc1 = theScale;
    //float zInc2 = theScale;
    
    //float xVV = 0;
    
    //float lowerBound = -50;
    
    //bool turnRight;
    
//    float zAngle; // 0 to 2Pi - sin or cos goes around in a circle
     //.01;
}

@property CGFloat wallRotationX;
@property CGFloat wallRotationY;

@property CGFloat wallOldRotationX;
@property CGFloat wallOldRotationY;

@property CGFloat wallPrevRotationX;
@property CGFloat wallPrevRotationY;

//@property float xAngle; // 0 to 2Pi - sin or cos goes around in a circle
//@property float yAngle; // 0 to 2Pi - sin or cos goes around in a circle

//@property float xAngleTilt;
//@property float yAngleTilt;
//@property float zAngleTilt;

@property float angleInc;

@property OPOrbitBase * ourShip;

@property PerspectiveHelper *perspHelper;

@property long wallObjNum;

+ (OPWormHoleController *)getSharedController;
+ (Boolean)reset;

- (void)setupInitial;

- (void)updateWalls;
- (void)renderWalls;

@end

#endif /* OPWormHoldController_h */
