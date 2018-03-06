//
//  OPPlanetController.h
//  OrbitPlotter
//
//  Created by John Kinn on 11/4/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPPlanetController_h
#define OPPlanetController_h

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "PerspectiveHelper.h"
#import "OPPlanet.h"
#import "OPMovingCelestrial.h"
//#import "OPRing.h"
#import "MomentumCircleManager.h"

@interface OPPlanetController : NSObject {
    int satId;
    int numActiveCelestrials[NumCelestrialLifeScopeTypes];
    NSMutableArray * celestrialsArr[NumCelestrialLifeScopeTypes];
    NSTimeInterval lastNewCelestrialTime[NumCelestrialLifeScopeTypes];
   
    bool checkNearestToTouch;
    CGPoint touchPoint;
}

@property OPOrbitBase * ourShip;

@property OPMovingCelestrial * capturedShip;
@property OPMovingCelestrial * capturedShipHalo1;
@property OPMovingCelestrial * capturedShipHalo2;

@property PerspectiveHelper *perspHelper;
@property MomentumCircleManager *momCircManager;

+ (OPPlanetController *)getSharedController;
+ (Boolean)reset;

- (void)getNearestCelestrial:(CGPoint)thePt;

- (void)setupInitialCelestrials;

- (void)updatePlanets;

//- (void)processPlanet:(OPPlanet *)thePlanet;

//- (void)processSatellite:(OPOrbitBase *)theSatellite;

- (void)renderCircles;
- (void)renderCelestrial;

- (void)tearDownPlanets;

- (void)addCelestrial:(int)arrIdx celestrialObj:(OPOrbitBase *)celestrialObj;
- (NSUInteger)getNumCelestrials:(int)arrIdx;
- (OPOrbitBase *)getCelestrial:(int)celestrialTypeIdx arrIdx:(int)arrIdx;

//- (void)ressetThrustVelocity;

//- (bool)hadRecentHit;
//- (bool)hadRecentHeat;
//- (bool)isGameOver;

@end

#endif /* OPPlanetController_h */
