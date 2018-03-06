//
//  PerspectiveHelper.m
//  OrbitPlotter
//
//  Created by John Kinn on 10/3/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//


#import "PerspectiveHelper.h"
#import "OPPlanet.h"
//#import "OPSatellite.h"
#import "sharedTypes.h"
#import "OPMessage.h"

static const int NUM_PERSPECTIVES = 3;
static const float startPerspZ = -800;

static const int THRUST_SPEED_MULT = 100;

static const float baseAngleRotSpeed = .06;

static const int WORM_ZONES_PER_LEVEL = 40; //10;
static const int POINTS_PER_LEVEL = 1000; //5,000;
static const int FUEL_BOOST_AMOUNT = 100;

//@implementation ErrorRecord
//@end

@interface PerspectiveHelper() {
    Boolean pauseAction;
    OPPoint shipCoord[NUM_PERSPECTIVES];
    //float xCoord[NUM_PERSPECTIVES], yCoord[NUM_PERSPECTIVES], zCoord[NUM_PERSPECTIVES];
    Boolean shotFired[MAX_CONSEC_SHOTS];
}

@end

@implementation PerspectiveHelper 

@synthesize thrustDirection;

@synthesize perspectType;

@synthesize currPerspId;

@synthesize  xCoordBase, yCoordBase; //, zCoordBase;

@synthesize ptBasedOnAngles, ptBasedOnAngles2; //, ptBasedOnAngles3, ptBasedOnAngles4;

@synthesize oldRotationX, oldRotationY, oldRotationZ;

//@synthesize wallHitTotal;

//@synthesize heatShieldNum;

@synthesize persUpDown;
@synthesize persLeftRight;
@synthesize persForwardBack;
@synthesize perspNorthSouth;

@synthesize persUpDownWH;
@synthesize persLeftRightWH;
@synthesize persForwardBackWH;
@synthesize perspNorthSouthWH;

//@synthesize slowrotateSpeed;
//@synthesize fastrotateSpeed;
@synthesize angleRotateSpeed;

@synthesize currThrustType;
@synthesize thrustVelocity;
@synthesize thrustAcceleration;
@synthesize angleChangeVelocity;
@synthesize useMotion;

@synthesize effect;

@synthesize numNaturalTextures;
@synthesize numArtificialTextures;
@synthesize textureBlankNum;
@synthesize textureFloorNum;

//@synthesize lastWallHitCenter;

@synthesize wallRotationX, wallRotationY;
@synthesize wallOldRotationX, wallOldRotationY;
@synthesize currWallZone;
@synthesize currWallSegment;
@synthesize currWallSegmentAck;

@synthesize angleXRotSpeed;
@synthesize angleYRotSpeed;
@synthesize angleZRotSpeed;

@synthesize tryIt;
@synthesize possibleSpiral;
//@synthesize wrongWayX1;
//@synthesize wrongWayX2;
//@synthesize wrongWayX3;
//@synthesize wrongWayX4;
//@synthesize wrongWayY;
@synthesize workingOnZone;
//@synthesize zoneSetX;
//@synthesize zoneSetY;

@synthesize rotateYorZ;

@synthesize udZone;
@synthesize rlZone;

@synthesize heatShieldCapacityIdx;
@synthesize impactShiledCapacityIdx;
@synthesize fuelCapacityIdx;

//@synthesize collisionTime;
//@synthesize heatTime;
@synthesize levelTime;

@synthesize numUpdates;
@synthesize levelNum;

@synthesize inWormHole;
@synthesize isWormHoleReady;

//@synthesize theErrorDict;

@synthesize wormHoleStertTime;
@synthesize wormHoleCurTime;

//@synthesize tempXangle;
//@synthesize tempYangle;
//@synthesize tempXangleUse;
//@synthesize tempYangleUse;
//@synthesize turnType;

- (id)init {
    self = [super init];
    if (self) {
        [PerspectiveHelper reset:self];
    }
    
    return self;
}

+ (void)loadVarsFromFile {
    
    
    
}

+ (void)resetAngles:(PerspectiveHelper *)thePersp {
    
    thePersp.perspectType = LOOKING_AT;
    
    thePersp.persUpDown = FACING_UP;
    thePersp.persForwardBack = FACING_FORWARD;
    thePersp.persLeftRight = FACING_RIGHT;
    
    thePersp.perspNorthSouth = IN_NORTH;
    
    [thePersp setRotationX:0];
    thePersp.oldRotationX = 0;
    
    [thePersp setRotationY:0];
    thePersp.oldRotationY = 0;
    
    [thePersp setRotationZ:0];
    thePersp.oldRotationZ = 0;
    
    thePersp.ptBasedOnAngles = (OPPoint){0,0,0};
    thePersp.ptBasedOnAngles2 = (OPPoint){0,0,0};
}

+ (void)reset:(PerspectiveHelper *)thePersp {
    
    [PerspectiveHelper resetAngles:thePersp];
    
    thePersp.xCoordBase = 0.0f;
    thePersp.yCoordBase = 0.0f;
    
    thePersp.currPerspId = PERSP_ID1;
    
    thePersp.thrustVelocity = 0.5;
    thePersp.angleChangeVelocity = 0.5;

    thePersp.turnMoveId = 0;
    
    thePersp.currThrustType = STOPPED;

    thePersp.isHit = false;
    
    thePersp.thrustDirection = 1;
    
    thePersp.textureBlankNum = -1;
    thePersp.textureFloorNum = -1;
    
    thePersp.useMotion = true;
    
    thePersp->bulletXOffset = -1;
    thePersp->bulletYOffset = -1;
    
    for (int cIdx=0; cIdx<NUM_PERSPECTIVES; cIdx++) {
        thePersp->shipCoord[cIdx] = (OPPoint){0,0,0};
    }
    
    //thePersp.slowrotateSpeed = .003;
    //thePersp.fastrotateSpeed = .06;
    thePersp.angleRotateSpeed = 0; //thePersp.fastrotateSpeed;
    
    [thePersp setRallyPtBasedOnAngles];
    
    thePersp->pauseAction = false;
    
    thePersp->currWallZone = -1;
    
    thePersp->currWallSegment = 0;
    thePersp->currWallSegmentAck = -1;
    
    thePersp->floorRenderTot = 0;
    
    //thePersp.tempXangle = QPIE;
        
    //thePersp.tempXangleUse = HALFPIE;
    //thePersp.tempYangle = .3;
    //thePersp.turnType = TURN_UP;
    
    thePersp->workingOnZone = 0;
//    thePersp->zoneSetX = false;
//    thePersp->zoneSetY = false;
    
    thePersp->udZone = TURN_NONE;
    thePersp->rlZone = TURN_NONE;
    
    // GameContext /*
    
    //theInstance.isHeat = false;
    //theInstance.isHit = false;
    //thePersp.theErrorDict =  [NSMutableDictionary dictionaryWithCapacity:10];
    //theInstance.errorBitmap = 0;
    thePersp.levelTime = [NSDate timeIntervalSinceReferenceDate];
    thePersp.numUpdates = 0;
    thePersp.levelNum = 1;
    thePersp.heatShieldCapacityIdx = MAX_HEAT_SHIELD_STRENGTH; //40000;
    thePersp.impactShiledCapacityIdx = MAX_SHIELD_STRENGTH;
    thePersp.fuelCapacityIdx = MAX_FUEL;
    thePersp.inWormHole = false;
    thePersp.isWormHoleReady = false;
    
    thePersp.numWormZones = 0;
    thePersp.numPoints = 0;
    
    thePersp.currWallFloorTrackIdx = 4;
    
    // GameContext */
    
    [thePersp straighten];
}

- (float)screenWidth {
    
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
//    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
//        NSLog(@"h- %.2f", UIScreen.mainScreen.bounds.size.width);
        return UIScreen.mainScreen.bounds.size.width;
//    }
//    else {
//        NSLog(@"ht %.2f", UIScreen.mainScreen.bounds.size.height);
//        return UIScreen.mainScreen.bounds.size.height;
//   }
}

- (float)screenHeight {
    
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
//    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return UIScreen.mainScreen.bounds.size.height;
//    }
//    else {
//        return UIScreen.mainScreen.bounds.size.width;
//    }
}

- (void)set_rotationX:(CGFloat)theRotationX {
    //if ((_rotationX < PIE+HALFPIE && theRotationX >= PIE+HALFPIE) ||
    //    (_rotationX < HALFPIE && theRotationX >= HALFPIE)
    //    ) {
    //    [self toggleUpDown];
    //    [self toggleForwardBack];
    //}
    _rotationX = theRotationX;
}

- (void)set_rotationY:(CGFloat)theRotationY {
    if ((_rotationY > PIE && theRotationY <= PIE) ||
        (_rotationY < HALFPIE && theRotationY > PIE+HALFPIE)
        ) {
        [self toggleLeftRight];
    }
    if ((_rotationY > HALFPIE && theRotationY <= HALFPIE) ||
        (_rotationY > PIE+HALFPIE && theRotationY <= PIE+HALFPIE)
        ) {
        [self toggleForwardBack];
    }
    _rotationY = theRotationY;
}

- (void)setPause:(Boolean)pPause {
    pauseAction = pPause;
}

- (Boolean)isPaused {
    return pauseAction;
}

- (void)rotateAction:(TurnDirection)direction {
    angleRotateSpeed = baseAngleRotSpeed * angleChangeVelocity;
    [self rotateAction:direction rotateSpeed:angleRotateSpeed];
}

- (void)rotateAction:(TurnDirection)direction rotateSpeed:(float)rotateSpeed {
    
    if (![self isUp]) {
        if (direction == TURN_LEFT)
            direction = TURN_RIGHT;
        else if (direction == TURN_RIGHT)
            direction = TURN_LEFT;
    }
    
    //rotateSpeed = baseAngleRotSpeed * angleChangeVelocity;
    switch(direction) {
        case TURN_UP:
            if (_rotationX + rotateSpeed >= TWOPIE) {
                [self set_rotationX:(TWOPIE-_rotationX) + rotateSpeed];
                //_rotationX = (TWOPIE-_rotationX) + rotateSpeed;
            }
            else {
                [self set_rotationX:_rotationX + rotateSpeed];
                //_rotationX += rotateSpeed;
            }
            if ((oldRotationX < PIE+HALFPIE && _rotationX >= PIE+HALFPIE) ||
                (oldRotationX < HALFPIE && _rotationX >= HALFPIE)
                ) {
                [self toggleUpDown];
                [self toggleForwardBack];
            }
            break;
        case TURN_DOWN:
            if (_rotationX <= rotateSpeed) {
                [self set_rotationX:TWOPIE - (rotateSpeed - _rotationX)];
                //_rotationX = TWOPIE - _rotationX;
            }
            else {
                [self set_rotationX:_rotationX - rotateSpeed];
                //_rotationX -= rotateSpeed;
            }
            if ((oldRotationX > PIE+HALFPIE && _rotationX <= PIE+HALFPIE) ||
                (oldRotationX > HALFPIE && _rotationX <= HALFPIE)
                ) {
                [self toggleUpDown];
                [self toggleForwardBack];
            }
            break;
        case TURN_LEFT:
            if (_rotationY <= rotateSpeed) {
                _rotationY = TWOPIE - (rotateSpeed - _rotationY);
            }
            else {
                _rotationY -= rotateSpeed;
            }
            //NSLog(@"o %.2f n %.2f", oldRotationY, _rotationY);
            if ((oldRotationY > PIE && _rotationY <= PIE) ||
                (oldRotationY < HALFPIE && _rotationY > PIE+HALFPIE)
                ) {
                [self toggleLeftRight];
            }
            if ((oldRotationY > HALFPIE && _rotationY <= HALFPIE) ||
                (oldRotationY > PIE+HALFPIE && _rotationY <= PIE+HALFPIE)
                ) {
                [self toggleForwardBack];
            }
            break;
        case TURN_RIGHT:
            if (_rotationY + rotateSpeed >= TWOPIE) {
                _rotationY = (TWOPIE-_rotationY) + rotateSpeed;
            }
            else {
                _rotationY += rotateSpeed;
            }
            //NSLog(@"p %.2f n %.2f", oldRotationY, _rotationY);
            if ((oldRotationY < PIE && _rotationY >= PIE) ||
                (oldRotationY > PIE+HALFPIE && _rotationY < HALFPIE)
                ) {
                [self toggleLeftRight];
            }
            if ((oldRotationY < HALFPIE && _rotationY >= HALFPIE) ||
                (oldRotationY < PIE+HALFPIE && _rotationY >= PIE+HALFPIE)
                ) {
                [self toggleForwardBack];
            }
            break;
        case TURN_NONE:
            break;
    }
    
    if (currThrustType == PERPETUAL_THRUST) {
        [self setRallyPtBasedOnAngles];
    }
    
    oldRotationX = _rotationX;
    oldRotationY = _rotationY;
}

- (void)rotateActionUsingZ:(TurnDirection)direction rotateSpeed:(float)rotateSpeed {

    rotateSpeed = 0.2; // baseAngleRotSpeed; // * angleChangeVelocity;
    
    switch(direction) {
//        case TURN_UP:
//        case TURN_DOWN:
//            break;
        case TURN_DOWN:
        case TURN_LEFT:
            if (_rotationZ <= rotateSpeed) {
                _rotationZ = TWOPIE - _rotationZ;
            }
            else {
                _rotationZ -= rotateSpeed;
            }
            //NSLog(@"o %.2f n %.2f", oldRotationY, _rotationY);
            if ((oldRotationZ < QPIE && _rotationZ >= PIE+HALFPIE+QPIE) ||
                (oldRotationZ > PIE && _rotationZ < PIE)
                ) {
                [self toggleLeftRight];
            }
            if ((oldRotationZ > HALFPIE && _rotationZ <= HALFPIE) ||
                (oldRotationZ > PIE+HALFPIE && _rotationZ <= PIE+HALFPIE)
                ) {
                [self toggleUpDown];
                [self toggleNorthSouth];
            }
            break;
        case TURN_UP:
        case TURN_RIGHT:
            if (_rotationZ + rotateSpeed >= TWOPIE) {
                _rotationZ = (TWOPIE-_rotationZ) + rotateSpeed;
            }
            else {
                _rotationZ += rotateSpeed;
            }
            //NSLog(@"p %.2f n %.2f", oldRotationY, _rotationY);
            if ((oldRotationZ >= PIE+HALFPIE+QPIE && _rotationZ < QPIE) ||
                (oldRotationZ < PIE && _rotationZ > PIE)
                ) {
                [self toggleLeftRight];
            }
            if ((oldRotationZ < HALFPIE && _rotationZ >= HALFPIE) ||
                (oldRotationZ < PIE+HALFPIE && _rotationZ >= PIE+HALFPIE)
                ) {
                [self toggleUpDown];
                [self toggleNorthSouth];
            }
            break;
        case TURN_NONE:
            break;
    }
    
    //NSLog(@"roZ %.2f", _rotationZ);
    tryIt = 8;

    if (currThrustType == PERPETUAL_THRUST) {
        [self setRallyPtBasedOnAngles];
    }

    //oldRotationX = _rotationX;
    oldRotationZ = _rotationZ;
}

- (void)toggleNorthSouthWH {
    if (wallRotationY < PIE) {
        wallRotationY += PIE;
    }
    else {
        wallRotationY -= PIE;
    }
    perspNorthSouth = perspNorthSouth == IN_NORTH ? IN_SOUTH : IN_NORTH;
}

//- (void)rotateActionWH:(TurnDirection)direction rotateSpeed:(float)rotateSpeed {
//    
////    if (![self isUpWH]) {
////        if (direction == TURN_LEFT)
////            direction = TURN_RIGHT;
////        else if (direction == TURN_RIGHT)
////            direction = TURN_LEFT;
////    }
//    
//    //angleRotateSpeed = fastAngleRotateSpeed * angleChangeVelocity;
//    switch(direction) {
//        case TURN_UP:
//            if (perspNorthSouthWH == IN_NORTH) {
//                if (wallRotationX + rotateSpeed >= PIE) {
//                    wallRotationX = PIE - rotateSpeed;
//                    if (wallRotationY < PIE) {
//                        wallRotationY += PIE;
//                    }
//                    else {
//                        wallRotationY -= PIE;
//                    }
//                    [self toggleNorthSouthWH];
//                }
//                else {
//                    wallRotationX += rotateSpeed;
//                }
//            }
//            else {
//                if (wallRotationX - rotateSpeed > 0) {
//                    wallRotationX -= rotateSpeed;
//                }
//                else {
//                    wallRotationX = 0;
//                    
//                    if (wallRotationY < PIE) {
//                        wallRotationY += PIE;
//                    }
//                    else {
//                        wallRotationY -= PIE;
//                    }
//                    [self toggleNorthSouthWH];
//                }
//            }
//            if ((wallOldRotationX < HALFPIE && wallRotationX >= HALFPIE) ||
//                (wallOldRotationX > HALFPIE && wallRotationX <= HALFPIE)) {
//                [self toggleUpDownWH];
//                [self toggleForwardBackWH];
//            }
//            break;
//        case TURN_DOWN:
//            if (perspNorthSouthWH == IN_SOUTH) {
//                if (wallRotationX + rotateSpeed >= PIE) {
//                    wallRotationX = PIE - rotateSpeed;
//                    if (wallRotationY < PIE) {
//                        wallRotationY += PIE;
//                    }
//                    else {
//                        wallRotationY -= PIE;
//                    }
//                    [self toggleNorthSouthWH];
//                }
//                else {
//                    wallRotationX += rotateSpeed;
//                }
//            }
//            else {
//                if (wallRotationX - rotateSpeed > 0) {
//                    wallRotationX -= rotateSpeed;
//                }
//                else {
//                    wallRotationX = 0;
//                    
//                    if (wallRotationY < PIE) {
//                        wallRotationY += PIE;
//                    }
//                    else {
//                        wallRotationY -= PIE;
//                    }
//                    [self toggleNorthSouthWH];
//                }
//            }
//            if ((wallOldRotationX > HALFPIE && wallRotationX <= HALFPIE) ||
//                (wallOldRotationX < HALFPIE && wallRotationX >= HALFPIE)) {
//                [self toggleUpDownWH];
//                [self toggleForwardBackWH];
//            }
//            break;
//        case TURN_RIGHT:
//            if (wallRotationY <= rotateSpeed) {
//                wallRotationY = TWOPIE - wallRotationY;
//                [self toggleLeftRightWH];
//            }
//            else {
//                wallRotationY -= rotateSpeed;
//            }
//            if ((wallOldRotationY > PIE+HALFPIE && wallRotationY <= PIE+HALFPIE) ||
//                (wallOldRotationY > HALFPIE && wallRotationY <= HALFPIE)
//                ) {
//                [self toggleForwardBackWH];
//            }
//            break;
//        case TURN_LEFT:
//            if (wallRotationY + rotateSpeed >= TWOPIE) {
//                wallRotationY = rotateSpeed;
//                //wallRotationX += TWOPIE;
//                [self toggleLeftRightWH];
//            }
//            else {
//                wallRotationY += rotateSpeed;
//            }
//            if ((wallOldRotationY < HALFPIE && wallRotationY >= HALFPIE) ||
//                (wallOldRotationY < HALFPIE+PIE && wallRotationY >= HALFPIE+PIE)
//                ) {
//                [self toggleForwardBackWH];
//            }
//            break;
//        default:
//            break;
//    }
//    wallOldRotationX = wallRotationX;
//    wallOldRotationY = wallRotationY;
//}

- (void)straighten {
    
    [self setRotationX:0];
    oldRotationX = 0;
    
    [self setRotationY:0];
    oldRotationY = 0;
    
    [self setRotationZ:0];
    oldRotationZ = 0;
    
    persUpDown = FACING_UP;
    persForwardBack = FACING_FORWARD;
    persLeftRight = FACING_RIGHT;
    perspNorthSouth = IN_NORTH;
    
    persUpDownWH = FACING_UP;
    persForwardBackWH = FACING_FORWARD;
    persLeftRightWH = FACING_RIGHT;
    perspNorthSouthWH = IN_NORTH;
    
    [self setRallyPtBasedOnAngles];
}

- (void)setRallyPtBasedOnAngles {
    
    float sinXangle = sin(_rotationX);
    float cosYangle = cos (_rotationY);
    
    float cosXangle = cos (_rotationX);
    float sinYangle = sin (_rotationY);
    
    float sueX, sueY, sueZ;
    
    sueY = sinXangle;
    sueX = -sinYangle;
    sueZ = cosXangle * cosYangle;
    if (![self isUp]) {
        sueX = -(sueX);
    }
    if (fabs(sinYangle) > .4) {
        float useXOffset;
        if (cosXangle > 0)
            useXOffset = 1 - cosXangle;
        else
            useXOffset = -1 - cosXangle;
        
        if (sueX > 0) {
            sueX -= fabs(useXOffset);
        }
        else {
            sueX += fabs(useXOffset);
        }
    }
    
    float sueX2 = sinXangle * cosYangle;
    float sueY2 = sinXangle * sinYangle;   //(1 - fabs(sinf(rotationY)));
    float sueZ2 = (cosXangle);
    
//    float sueX2 = sinYangle;
//    float sueY2 = sinXangle * (1 - fabs(sueX2));
//    float sueZ2 = 1 - (fabs(sueX2) + fabs(sueY));
    
    //NSLog(@"sue %.2f %.2f %.2f", sueX, sueY, sueZ);
    
    ptBasedOnAngles = (OPPoint){sueX, sueY, sueZ };  // (cosX * cosY) };
    ptBasedOnAngles2 = (OPPoint){sueX2, sueY2, sueZ2 };
    //ptBasedOnAngles3 = (OPPoint){sueXFor3, sueYFor3, sueZFor3 };
}

- (Boolean)isFacingForward {
    return persForwardBack == FACING_FORWARD;
}

- (void)toggleNorthSouth {
    perspNorthSouth = perspNorthSouth == IN_NORTH ? IN_SOUTH : IN_NORTH;
}

- (void)toggleForwardBack {
    persForwardBack = persForwardBack == FACING_FORWARD ? FACING_BACK : FACING_FORWARD;
}

- (void)toggleUpDown {
    persUpDown = persUpDown == FACING_UP ? FACING_DOWN : FACING_UP;
}

- (Boolean)isFacingRight {
    return persLeftRight == FACING_RIGHT;
}

- (void)toggleLeftRight {
    persLeftRight = persLeftRight == FACING_LEFT ? FACING_RIGHT : FACING_LEFT;
}

- (Boolean)isUp {
    return persUpDown == FACING_UP;
}

- (Boolean)isNorth {
    return perspNorthSouth == IN_NORTH;
}

- (Boolean)isRight {
    return persLeftRight == FACING_RIGHT;
}

- (Boolean)isFacingForwardWH {
    return persForwardBackWH == FACING_FORWARD;
}

//- (void)toggleNorthSouthWH {
//    perspNorthSouthWH = perspNorthSouthWH == IN_NORTH ? IN_SOUTH : IN_NORTH;
//}

- (void)toggleForwardBackWH {
    persForwardBackWH = persForwardBackWH == FACING_FORWARD ? FACING_BACK : FACING_FORWARD;
}

- (void)toggleUpDownWH {
    persUpDownWH = persUpDownWH == FACING_UP ? FACING_DOWN : FACING_UP;
}

- (Boolean)isFacingRightWH {
    return persLeftRightWH == FACING_RIGHT;
}

- (void)toggleLeftRightWH {
    persLeftRightWH = persLeftRightWH == FACING_LEFT ? FACING_RIGHT : FACING_LEFT;
}

- (Boolean)isUpWH {
    return persUpDownWH == FACING_UP;
}

- (void)changePerspType {
    if (perspectType == WE_ARE) {
        perspectType = LOOKING_AT;
        //zCoordBase = startPerspZ;
    }
    else {
        perspectType = WE_ARE;
        //zCoordBase = 0;
    }
}

- (OPPoint)getShipPosition:(int)perspId {
    return shipCoord[perspId];
    //return (OPPoint){[self getShipXCoord:perspId],[self getShipYCoord:perspId],[self getShipZCoord:perspId]};
}

- (float)getBaseXCoord {
    return xCoordBase;
}
- (float)getBaseYCoord {
    return yCoordBase;
}
- (float)getBaseZCoord {
    if (perspectType == WE_ARE) {
        return 0;
    }
    else {
        return startPerspZ;
    }
    //return zCoordBase;
}

- (float)getRotationZ {
    if (inWormHole) {
        return _rotationZ;
    }
    return 0;
}

//- (float)getShipXCoord:(int)perspId {
//   return xCoord[perspId];
//}
//- (float)getShipYCoord:(int)perspId {
//    return yCoord[perspId];
//}
//- (float)getShipZCoord:(int)perspId {
//    return zCoord[perspId];
//}

//- (float)getShipXCoord {
//    return [self getShipXCoord:currPerspId];
//}
//- (float)getShipYCoord {
//    return [self getShipYCoord:currPerspId];
//}
//- (float)getShipZCoord {
//    return [self getShipZCoord:currPerspId];
//}

- (OPPoint)getDistanceFromShip:(OPPoint)worldStartPt perspId:(int)perspId {
    
    OPPoint shipPos = [self getShipPosition:perspId];
    
    return (OPPoint){shipPos.x-worldStartPt.x, shipPos.y-worldStartPt.y, shipPos.z-worldStartPt.z};
}

- (void)toggleCurrPersp {
    currPerspId = currPerspId == PERSP_ID1 ? PERSP_ID2 : PERSP_ID1;
    //for (int cIdx=0; cIdx<NUM_PERSPECTIVES; cIdx++) {
    self->shipCoord[currPerspId] = (OPPoint){0,0,0};
        //self->xCoord[currPerspId] = 0;
        //self->yCoord[currPerspId] = 0;
        //self->zCoord[currPerspId] = 0;
    //}
}

- (void)adjustXCoord:(float)varyValue {
    for (int cIdx=PERSP_ID1; cIdx<NUM_PERSPECTIVES; cIdx++) {
        self->shipCoord[cIdx] = (OPPoint){self->shipCoord[cIdx].x+varyValue,self->shipCoord[cIdx].y,self->shipCoord[cIdx].z};
        //self->xCoord[cIdx] += varyValue;
    }
}

- (void)adjustYCoord:(float)varyValue {
    for (int cIdx=PERSP_ID1; cIdx<NUM_PERSPECTIVES; cIdx++) {
        self->shipCoord[cIdx] = (OPPoint){self->shipCoord[cIdx].x,self->shipCoord[cIdx].y+varyValue,self->shipCoord[cIdx].z};
        //self->yCoord[cIdx] += varyValue;
    }
}

- (void)adjustZCoord:(float)varyValue {
    for (int cIdx=PERSP_ID1; cIdx<NUM_PERSPECTIVES; cIdx++) {
        self->shipCoord[cIdx] = (OPPoint){self->shipCoord[cIdx].x,self->shipCoord[cIdx].y,self->shipCoord[cIdx].z+varyValue};
        //self->zCoord[cIdx] += varyValue;
    }
}

- (void)adjustShipCoords:(float)varyX varyY:(float)varyY varyZ:(float)varyZ {
    for (int cIdx=PERSP_ID1; cIdx<NUM_PERSPECTIVES; cIdx++) {
        self->shipCoord[cIdx] = (OPPoint){self->shipCoord[cIdx].x+varyX,self->shipCoord[cIdx].y+varyY,self->shipCoord[cIdx].z+varyZ};
        //self->zCoord[cIdx] += varyValue;
    }
}

- (void)setShipCoords:(OPPoint)newShipCoords {
    shipCoord[currPerspId] = newShipCoords;
}

- (void)ressetThrustAcceleration {
    thrustAcceleration = THRUST_SPEED_MULT;
    //currThrustType = SLOWING_DOWN;
}

- (void)killThrustAcceleration {
    thrustAcceleration = 0;
    currThrustType = STOPPED;
}

- (void)togglePerpetualThrust {
    currThrustType = currThrustType == PERPETUAL_THRUST ? SLOWING_DOWN : PERPETUAL_THRUST;
}

- (void)toggleSoloThrust {
    currThrustType = currThrustType == SOLO_THRUST ? SLOWING_DOWN : SOLO_THRUST;
}

- (int)getNextWallZone {
    return currWallZone+1 > 2 ? 0 : currWallZone+1;
}

// Game context /*



//- (ErrorRecord *)addErrorRecord:(long)theNum shouldContinue:(Boolean)shouldContinue {
//
//    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:theNum]];
//    if (theRecord == nil) {
//        theRecord = [[ErrorRecord alloc] init];
//        theRecord.eventTime = [NSDate timeIntervalSinceReferenceDate];
//        theRecord.eventNum = theNum;
//        theRecord.eventDisplayed = false;
//        theRecord.eventActive = true;
//        theRecord.isContinuous = shouldContinue;
//        theRecord.turnOffPending = false;
//        theErrorDict[[NSNumber numberWithLong:theNum]] = theRecord;
//    }
//    return theRecord;
//}


- (bool)isGameOver {
    if (fuelCapacityIdx <= 0 || heatShieldCapacityIdx <= 0 || impactShiledCapacityIdx <= 0)
        return true;
    return false;
}

- (void)getNextLevel {
    levelNum += 1;
    levelTime = [NSDate timeIntervalSinceReferenceDate];
    numUpdates = 0;
    _numPoints += 10;
}

- (Boolean)isLevelDone {
    if (inWormHole)
        return false;
    if (numUpdates++ > POINTS_PER_LEVEL)
        return true;
    else
        return false;
}

- (Boolean)isWormDone {
    if (_numWormZones > WORM_ZONES_PER_LEVEL) {
        _numPoints += 5;
        _numWormZones = 0;
        return true;
    }
    return false;
}

- (void)performHeatDamage {
    if (heatShieldCapacityIdx > 0) {
        heatShieldCapacityIdx--;
    }
}

- (void)performStructureDamage {
    if (impactShiledCapacityIdx > 0) {
        impactShiledCapacityIdx--;
    }
}

- (void)fixHeatDamage {
    if (heatShieldCapacityIdx < MAX_HEAT_SHIELD_STRENGTH) {
        heatShieldCapacityIdx++;
    }
}

- (void)fixStrucctureDamage {
    if (impactShiledCapacityIdx < MAX_SHIELD_STRENGTH) {
        impactShiledCapacityIdx++;
    }
}

- (void)consumeFuel:(float)thrustVelocity {
    if (fuelCapacityIdx > 0) {
        fuelCapacityIdx-=(1*thrustVelocity);
    }
    else {
        fuelCapacityIdx = 0;
    }
    if (((float)((float)fuelCapacityIdx)/MAX_FUEL) < .2) {
        [OPMessage addMessage:WARN_MSG_FUELLOW];
    }
}

- (void)boostFuel {
    if (fuelCapacityIdx+FUEL_BOOST_AMOUNT < MAX_FUEL) {
        fuelCapacityIdx += FUEL_BOOST_AMOUNT;
    }
    else {
        fuelCapacityIdx = MAX_FUEL;
    }
    if (((float)((float)fuelCapacityIdx)/MAX_FUEL) > .2) {
        [OPMessage turnErrorOff:WARN_MSG_FUELLOW];
    }
}

- (int)getRemainingFuelPct {
    return (int)(((float)((float)fuelCapacityIdx)/MAX_FUEL)*100);
}

- (void)setInWormHole {
    inWormHole = true;
    wormHoleCurTime = 0;
    wormHoleStertTime = [NSDate timeIntervalSinceReferenceDate];
}

// Game context */

@end
