//
//  PerspectiveHelper.h
//  OrbitPlotter
//
//  Created by John Kinn on 10/3/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef PerspectiveHelper_h
#define PerspectiveHelper_h

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>
#import "sharedTypes.h"

static const int MAX_SHIELD_STRENGTH = 20;
static const int MAX_HEAT_SHIELD_STRENGTH = 2800;
static const int MAX_FUEL = 4000;

@interface PerspectiveHelper : NSObject {
@public
    int wallHitTotal[3];
    long wallSegmentNum[3];
    bool foundForwardWallObj;
    float wallHitDist[3];
    long floorRenderTot;
    float bulletXOffset, bulletYOffset;
}

@property OPPoint ptBasedOnAngles, ptBasedOnAngles2;

//@property OPPoint lastWallHitCenter;

@property ThrustType currThrustType;

@property NSInteger turnMoveId;
@property Boolean isHit;

@property float thrustVelocity;
@property float thrustAcceleration;

@property (strong, nonatomic) GLKBaseEffect *effect;

@property PersType perspectType;
@property PersUpDown persUpDown;
@property PersForwardBack persForwardBack;
@property PersRightLeft persLeftRight;
@property PersNorthSouth perspNorthSouth;

@property PersUpDown persUpDownWH;
@property PersForwardBack persForwardBackWH;
@property PersRightLeft persLeftRightWH;
@property PersNorthSouth perspNorthSouthWH;

@property float angleChangeVelocity;
@property bool useMotion;

@property CGFloat xCoordBase, yCoordBase; //, zCoordBase;

@property CGFloat rotationX;
@property CGFloat rotationY;
@property CGFloat rotationZ;

@property CGFloat wallRotationX;
@property CGFloat wallRotationY;

@property CGFloat wallOldRotationX;
@property CGFloat wallOldRotationY;

@property int currWallZone;
@property long currWallSegment;
@property long currWallSegmentAck;
@property long currWallFloorTrackIdx;

@property CGFloat oldRotationX;
@property CGFloat oldRotationY;
@property CGFloat oldRotationZ;

//@property CGFloat slowAngleRotateSpeed;
//@property CGFloat fastAngleRotateSpeed;
@property CGFloat angleRotateSpeed;

@property CGFloat angleXRotSpeed;
@property CGFloat angleYRotSpeed;
@property CGFloat angleZRotSpeed;

//@property CGFloat tempXangle;
//@property CGFloat tempXangleUse;
//@property CGFloat tempYangle;
//@property CGFloat tempYangleUse;
//@property TurnDirection turnType;

@property int currPerspId;
@property int thrustDirection;

@property int numNaturalTextures;
@property int numArtificialTextures;
@property int textureBlankNum;
@property int textureFloorNum;

@property int tryIt; // this is temporary
@property int possibleSpiral; // This is temporary
//@property int wrongWayX1;
//@property int wrongWayX2;
//@property int wrongWayX3;
//@property int wrongWayX4;
//@property int wrongWayY;
@property int workingOnZone;
//@property Boolean zoneSetX;
//@property Boolean zoneSetY;

@property TurnDirection rlZone;
@property TurnDirection udZone;

@property NSInteger rotateYorZ; // 0=y, 1=z

// From gameContext /*

//@property NSTimeInterval collisionTime;
//@property NSTimeInterval heatTime;
@property NSTimeInterval levelTime;
@property NSTimeInterval wormHoleStertTime;
@property NSTimeInterval wormHoleCurTime;

@property int heatShieldCapacityIdx;
@property int impactShiledCapacityIdx;
@property float fuelCapacityIdx;

@property long numUpdates;
@property int levelNum;
@property long numWormZones;
@property long numPoints;

@property bool inWormHole;
@property bool isWormHoleReady;

- (int)getRemainingFuelPct;

- (bool)isGameOver;

- (void)getNextLevel;
- (Boolean)isLevelDone;
- (Boolean)isWormDone;
- (void)performHeatDamage;
- (void)performStructureDamage;
- (void)fixHeatDamage;
- (void)fixStrucctureDamage;
- (void)consumeFuel:(float)thrustVelocity;
- (void)boostFuel;

//- (ErrorRecord *)addErrorRecord:(long)theNum shouldContinue:(Boolean)shouldContinue isOn:(Boolean)isOn;
//- (bool)turnErrorOn:(long)theNum shouldContinue:(Boolean)shouldContinue;
//- (void)turnErrorOff:(long)theNum;
//- (bool)isErrorActive:(long)errNum;
//- (long)getAnyEventForDisplay;
//- (bool)getEventForDisplay:(long)theNum;

- (float)getRotationZ;

// From gameContext */

+ (void)reset:(PerspectiveHelper *)thePersp;
+ (void)resetAngles:(PerspectiveHelper *)thePersp;

- (void)toggleUpDown;
- (Boolean)isUp;
- (void)changePerspType;
- (Boolean)isFacingForward;
- (Boolean)isNorth;
- (Boolean)isRight;
//- (Boolean)isFacingRight;

- (void)setRallyPtBasedOnAngles;

- (void)rotateAction:(TurnDirection)direction;
- (void)rotateAction:(TurnDirection)direction rotateSpeed:(float)rotateSpeed;
//- (void)rotateActionWH:(TurnDirection)direction rotateSpeed:(float)rotateSpeed;
- (void)rotateActionUsingZ:(TurnDirection)direction rotateSpeed:(float)rotateSpeed;

- (void)toggleCurrPersp;

- (Boolean)isPaused;
- (void)setPause:(Boolean)pPause;

- (OPPoint)getDistanceFromShip:(OPPoint)worldStartPt perspId:(int)perspId;

//- (float)getShipXCoord:(int)perspId;
//- (float)getShipYCoord:(int)perspId;
//- (float)getShipZCoord:(int)perspId;

//- (float)getShipXCoord;
//- (float)getShipYCoord;
//- (float)getShipZCoord;

- (float)getBaseXCoord;
- (float)getBaseYCoord;
- (float)getBaseZCoord;

- (OPPoint)getShipPosition:(int)perspId;

- (void)adjustXCoord:(float)varyValue;
- (void)adjustYCoord:(float)varyValue;
- (void)adjustZCoord:(float)varyValue;
- (void)adjustShipCoords:(float)varyX varyY:(float)varyY varyZ:(float)varyZ;
- (void)setShipCoords:(OPPoint)newShipCoords;

- (float)screenWidth;
- (float)screenHeight;

- (void)ressetThrustAcceleration;
- (void)killThrustAcceleration;
- (void)togglePerpetualThrust;
- (void)toggleSoloThrust;

- (void)straighten;

- (void)set_rotationX:(CGFloat)rotationX;
- (void)set_rotationY:(CGFloat)rotationY;

- (int)getNextWallZone;

- (void)setInWormHole;

//- (void)toggleNorthSouthWH;

@end

#endif /* PerspectiveHelper_h */
