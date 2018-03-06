//
//  OPPlanetController.m
//  OrbitPlotter
//
//  Created by John Kinn on 11/4/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/glext.h>

#import "OPPlanetController.h"
#import "OPPlanetFactory.h"
#import "OPPlanetManager.h"
#import "OPMessage.h"

//static const int COLLISION_RANGE = 8;
static const int HEAT_RANGE = 8;

@interface OPPlanetController() {
//    NSTimeInterval collisionTime;
//    NSTimeInterval heatTime;
    int xSign;
    //bool isHit;
    //bool isHeat;
    //bool isGameOver;
    bool resetOldCelestrial;
    
    Boolean isCaptured;
    
    Boolean hasAHeatWarning;
    bool checkTouch;
    
    //int chanceOfNewLower;
    //int chanceOfNewupper;
    int chanceOfNewPlanet;
    
    //NSTimeInterval lastNewPlanetTime;
    //NSTimeInterval lastNewAsteroidTime;
    
    OPOrbitBase * aPlanet;
    
    Boolean isAltPerspectiveUsed;
    
    //int localThrustVelocity;
    
    //int chosenPlanetId;
    float closestCombinedChosenDistance;
}
@end

@implementation OPPlanetController

//@synthesize planetArr1;
//@synthesize asteroidArr;

@synthesize perspHelper;
@synthesize momCircManager;

@synthesize ourShip;
@synthesize capturedShip;

//@synthesize gameContext;

static OPPlanetController * sharedPlanetController;

- (id)init {
    if (sharedPlanetController == nil) {
        self = [super init];
        if (self) {
            
            sharedPlanetController = self;
            
            [OPPlanetController reset];
            
//            for (int x=0; x<NumCelestrialLifeScopeTypes; x++) {
//                self->celestrialsArr[x] =  [NSMutableArray array];
//                self->numActiveCelestrials[x] = 0;
//            }
//
//            self->momCircManager = [[MomentumCircleManager alloc] init];
//            self->satId = 0;
//            //self->isHit = false;
//            //self->isHeat = false;
//            //self->isGameOver = false;
//
//            self->checkNearestToTouch = false;
//
//            self->closestCombinedChosenDistance = 10000;
//
//            self->thrustVelocity = 0;
//
//            self->isCaptured = false;
            
            
        }
    }
    return sharedPlanetController;
}

+ (Boolean)reset {
    
    if (sharedPlanetController == nil)
        return false;
    
    for (int x=0; x<NumCelestrialLifeScopeTypes; x++) {
        sharedPlanetController->celestrialsArr[x] =  [NSMutableArray array];
        sharedPlanetController->numActiveCelestrials[x] = 0;
    }
    if (sharedPlanetController->momCircManager == nil) {
        sharedPlanetController->momCircManager = [[MomentumCircleManager alloc] init];
    }
    sharedPlanetController->satId = 0;
    sharedPlanetController->checkNearestToTouch = false;
    sharedPlanetController->closestCombinedChosenDistance = 10000;
    //sharedPlanetController->localThrustVelocity = 0;
    sharedPlanetController->isCaptured = false;
    
    return true;
}

+ (OPPlanetController *)getSharedController {
    if (sharedPlanetController == nil) {
        sharedPlanetController = [[OPPlanetController alloc] init];
    }
    return sharedPlanetController;
}

- (void)getNearestCelestrial:(CGPoint)thePt {
    touchPoint = thePt;
    checkNearestToTouch = true;
}

- (void)addCelestrial:(int)arrIdx celestrialObj:(OPOrbitBase *)celestrialObj {
    [celestrialsArr[arrIdx] addObject:celestrialObj];
    //NSLog(@"Add %d", arrIdx);
}

- (NSUInteger)getNumCelestrials:(int)arrIdx {
    
    if (celestrialsArr[arrIdx] == nil  || [celestrialsArr[arrIdx] isKindOfClass:[NSNull class]]) {
        //|| [celestrialsArr[arrIdx] isKindOfClass:[NSMutableArray class]]) {
         return 0;
    }
    return [celestrialsArr[arrIdx] count];
}

- (OPOrbitBase *)getCelestrial:(int)celestrialTypeIdx arrIdx:(int)arrIdx {
     return [celestrialsArr[celestrialTypeIdx] objectAtIndex:arrIdx];
}

- (void)checkForTouch:(OPOrbitBase *)celestrialObject {
    
    float tryX = fabs(celestrialObject.xScreen - touchPoint.x);
    float tryY = fabs(celestrialObject.yScreen - touchPoint.y);
    
    if (tryX+tryY < closestCombinedChosenDistance && (capturedShip == nil || capturedShip.theId != celestrialObject.theId)) {
        //NSLog(@"yes %d %.2f %.2f", celestrialObject.theId, celestrialObject.xScreen, celestrialObject.yScreen);
        closestCombinedChosenDistance = tryX+tryY;
        //chosenPlanetId = celestrialObject.theId;
        capturedShip = (OPMovingCelestrial *)celestrialObject;
    }
    else {
        //NSLog(@"no  %d %.2f %.2f", celestrialObject.theId, celestrialObject.xScreen, celestrialObject.yScreen);
    }
}

- (void)repairShip:(OPOrbitBase *)celestrialObject {

    if (celestrialObject.vertexData.repairAbility == 0)
        return;
    if (celestrialObject.vertexData.repairAbility & repairBitHeat) {
        [perspHelper fixHeatDamage];
        [OPMessage addMessage:WARN_MSG_HEAT_REPAIRED];
    }
    if (celestrialObject.vertexData.repairAbility & repairBitStructure) {
        [perspHelper fixStrucctureDamage];
        [OPMessage addMessage:WARN_MSG_HIT_REPAIRED];
    }
    if (celestrialObject.vertexData.repairAbility & repairBitFuel) {
        [perspHelper boostFuel];
        [OPMessage addMessage:WARN_MSG_REFUELED];
    }
}

- (void)checkForHit:(OPOrbitBase *)celestrialObject {

    //OPPoint baseShip = [perspHelper getObserverPosition:celestrialObject.getPerspId];
    //OPPoint baseShip = [perspHelper getBaseShipPosition];
    
//    if (celestrialObject->hasBeenRendered && fabs(celestrialObject.xEye) < COLLISION_RANGE && fabs(celestrialObject.yEye) < COLLISION_RANGE && fabs(celestrialObject.zEye) < COLLISION_RANGE &&
//        fabs(baseShip.x-celestrialObject.worldStartPt.x) < 300 && fabs(baseShip.y-celestrialObject.worldStartPt.y) < 300 && fabs(baseShip.z-celestrialObject.worldStartPt.z) < 300 && !celestrialObject->isStaticSpecial) {
//        NSLog(@"Almost hit %.2f %.2f %2.f", celestrialObject.xEye, celestrialObject.yEye, celestrialObject.zEye);
//    }

    float collisionRange = celestrialObject.vertexData.collisionRange * celestrialObject.theScale;
    float heatRange = HEAT_RANGE * celestrialObject.theScale;

//    if (!gameContext.isHit && fabs(celestrialObject.xEye) < collisionRange && fabs(celestrialObject.yEye) < collisionRange && fabs(celestrialObject.zEye) < collisionRange && !celestrialObject->isStaticSpecial) {

    if (![OPMessage isErrorActive:WARN_MSG_HIT] && fabs(celestrialObject.xEye) < collisionRange && fabs(celestrialObject.yEye) < collisionRange && fabs(celestrialObject.zEye) < collisionRange && !celestrialObject->isStaticSpecial) {
        
        if (celestrialObject.vertexData.repairAbility & repairBitWorm) {
        //if (celestrialObject.typeId == SHIP_CELESTRIAL && [celestrialObject.vertexData.subTypeName isEqualToString:@"CONE1"]) {
            [perspHelper setInWormHole];
            //perspHelper.inWormHole = true;
        }
        
        if (celestrialObject->isSelected) {
            [self repairShip:celestrialObject];
        }
        else {
            NSLog(@"Heredddd");
            if (![OPMessage addMessage:WARN_MSG_HIT]) {
            [perspHelper performStructureDamage];
            NSLog(@"damage %d", perspHelper.impactShiledCapacityIdx);
            if (celestrialObject.typeId == ASTEROID || celestrialObject.typeId == SHIP_CELESTRIAL) {  // You destroyed the asteroid too.
                    celestrialObject->inUse = false;
            }
        }
        }
    }
    if (celestrialObject.typeId == STAR && fabs(celestrialObject.xEye) < heatRange && fabs(celestrialObject.yEye) < heatRange && fabs(celestrialObject.zEye) < heatRange && !celestrialObject->isStaticSpecial) {
        hasAHeatWarning = true;;
    }
}

- (void)reactivateMovingCelestrial:(OPOrbitBase *)celestrialObject {
    if (resetOldCelestrial && celestrialObject->inUse == false) {
        resetOldCelestrial = false;
        
        OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:celestrialObject.typeId];
        
        numActiveCelestrials[theDetail.lifeScope]++;
        [[OPPlanetFactory getSharedFactory] createDefaultCelestrial:celestrialObject planetType:celestrialObject.typeId];
    }
}

- (bool)isCelestrialStillInScope:(OPOrbitBase *)celestrialObject {
 
    //float mapBoundryUse = theTypeDetails[celestrialObject.typeId].maxDistance;
    
    //if (celestrialObject.typeId == PLANET) {
    //    mapBoundryUse = mapBoundryPlanet + mapBoundryFrontier;
    //}
    //else {
    //   mapBoundryUse = mapBoundryAsteroid + mapBoundryFrontier;
    //}
    
    if (celestrialObject->inUse && ![celestrialObject isSafeDistance]) {
     //   OPPoint distanceFromShipPt = [celestrialObject getDistanceFromShip];
     //   if (distanceFromShipPt.x > mapBoundryUse || distanceFromShipPt.x > mapBoundryUse || distanceFromShipPt.x > mapBoundryUse) {
            
    //} && ((fabs([perspHelper getObserverXCoord:[celestrialObject getPerspId]] - celestrialObject.worldStartPt.x) > mapBoundryUse) ||
    //                                (fabs([perspHelper getObserverYCoord:[celestrialObject getPerspId]] - celestrialObject.worldStartPt.y) > mapBoundryUse) ||
    //                                (fabs([perspHelper getObserverZCoord:[celestrialObject getPerspId]] - celestrialObject.worldStartPt.z) > mapBoundryUse))) {
        
    //if (celestrialObject->inUse && ((fabs([celestrialObject getPerspectiveOrigin].x - celestrialObject.worldStartPt.x) > mapBoundryUse) ||
    //    (fabs([celestrialObject getPerspectiveOrigin].y - celestrialObject.worldStartPt.y) > mapBoundryUse) ||
    //    (fabs([celestrialObject getPerspectiveOrigin].z - celestrialObject.worldStartPt.z) > mapBoundryUse))) {
        
@try {
        
        [(OPMovingCelestrial *)celestrialObject setNotInUse];
        
        }
        @catch(NSException *ex) {
            NSLog(@"Can't set setNotInUse");
        }
        
        OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:celestrialObject.typeId];
            
        if (numActiveCelestrials[theDetail.lifeScope]>0)
            numActiveCelestrials[theDetail.lifeScope]--;
        
        return false;
    }
    return true;
}

- (void)updatePlanets
{
    //if (gameContext.isHeat == true) {
    //if (gameContext.errorBitmap & HEAT_BIT) {
    //
    //    if (([NSDate timeIntervalSinceReferenceDate] - gameContext.heatTime) > 5) {
    //        //gameContext.isHeat = false;
    //        gameContext.errorBitmap ^= HEAT_BIT;
    //    }
    //}
    
//    if (gameContext.isHit == true) {
    if ([OPMessage isErrorActive:WARN_MSG_HIT]) {
        long rn1 = arc4random_uniform(60);
        long rn2 = arc4random_uniform(60);
        long rn3 = arc4random_uniform(60);
        
        long rnd1 = (-30 + (rn1 % 60));
        long rnd2 = (-30 + (rn2 % 60));
        long rnd3 = (-30 + (rn3 % 60));
        
        [perspHelper adjustShipCoords:rnd1 varyY:rnd2 varyZ:rnd3];
        //[perspHelper adjustYCoord:rnd2];
        //[perspHelper adjustZCoord:rnd3];
        
        [OPMessage turnErrorOff:WARN_MSG_HIT];
        //if (([NSDate timeIntervalSinceReferenceDate] - gameContext.collisionTime) > 2) {
            //gameContext.isHit = false;
        //    gameContext.errorBitmap ^= HIT_BIT;
       // }
        
    //} else if (perspHelper.isThrust || perspHelper.isPerpetualThrust || perspHelper.thrustAcceleration > 0) {
    } else if (perspHelper.currThrustType != STOPPED) {
        
        float theThrust = perspHelper.thrustVelocity*perspHelper.thrustAcceleration*perspHelper.thrustDirection;
        
        
        [perspHelper adjustShipCoords:(perspHelper.ptBasedOnAngles.x)*theThrust varyY:(perspHelper.ptBasedOnAngles.y)*theThrust varyZ:(perspHelper.ptBasedOnAngles.z)*theThrust];
        
        //[perspHelper adjustXCoord:(perspHelper.ptBasedOnAngles.x)*theThrust];
        //[perspHelper adjustYCoord:(perspHelper.ptBasedOnAngles.y)*theThrust];
        //[perspHelper adjustZCoord:(perspHelper.ptBasedOnAngles.z)*theThrust];
        
        if (perspHelper.currThrustType == SLOWING_DOWN) {
        //if (!perspHelper.isThrust && !perspHelper.isPerpetualThrust) {
            perspHelper.thrustAcceleration--;
            if (perspHelper.thrustAcceleration == 0)
                perspHelper.currThrustType = STOPPED;
        }
    }
    
    checkTouch = false;
    if (checkNearestToTouch) {
        checkTouch = true;
        //chosenPlanetId = -1;
        closestCombinedChosenDistance = 10000;
    }
    
    hasAHeatWarning = false;
    
    for (int x=0; x<NumCelestrialLifeScopeTypes; x++) {
            [self updateCelestrialType:x];
    }
 
    if (_capturedShipHalo1 != nil && _capturedShipHalo1->inUse) {
        [_capturedShipHalo1 update];
    }
    if (_capturedShipHalo2 != nil && _capturedShipHalo2->inUse) {
        [_capturedShipHalo2 update];
    }
    
    if (hasAHeatWarning) {
        [OPMessage addMessage:WARN_MSG_HEAT];
        [perspHelper performHeatDamage];
    }
    else {
        [OPMessage turnErrorOff:WARN_MSG_HEAT];
    }
    
    if (checkTouch && capturedShip != nil) {
        //NSLog(@"Nearest Touch %d", capturedShip.theId);
        checkNearestToTouch = false;
        
        isCaptured = true;
        
        if (_capturedShipHalo1 != nil) {
            if (_capturedShipHalo1.orbitsAround != nil) {
                _capturedShipHalo1.orbitsAround->isSelected = false;
            }
            _capturedShipHalo1.orbitsAround = capturedShip;
            _capturedShipHalo1.orbitsAround->isSelected = true;
            _capturedShipHalo1.theScale = capturedShip.theScale+20;
            [_capturedShipHalo1 setPerspId:[capturedShip getPerspId]];
            _capturedShipHalo1.rotationDistY = 0;
            _capturedShipHalo1->inUse = true;
        }
        if (_capturedShipHalo2 != nil) {
            _capturedShipHalo2.orbitsAround = capturedShip;
            _capturedShipHalo2.theScale = capturedShip.theScale+20;
            [_capturedShipHalo2 setPerspId:[capturedShip getPerspId]];
            _capturedShipHalo2.rotationDistY = 0;
            _capturedShipHalo2->inUse = true;
        }
        
    }
    for (OPOrbitBase * theCircle in momCircManager.circleArr) {
        [theCircle update];
        //[theCircle reckonXAnglePers:perspHelper.rotationX];
        //[theCircle reckonYAnglePers:perspHelper.rotationY];
    }
}

- (void)updateCelestrialType:(int)celestrialTypeIdx {
    
    [ourShip update];
    
    resetOldCelestrial = false;
    if (!is_debug) {
        
        for (int pTypeIdx=0; pTypeIdx<NUM_PLANET_TYPES; pTypeIdx++) {
            
            OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetailByIdx:pTypeIdx];
            
            //if (theDetail == nil) {
            //    NSLog(@"no det %d", pTypeIdx);
            //}
            
            //if (theDetail.theType == SPACE_STATION)
            //    NSLog(@"e");
            
            //NSLog(@"DEt %@ %.2f %.2f %.2f", theDetail.orbitalName, theDetail.chanceOfNew, theDetail.maxActive, theDetail.minNewTime);
            
            if (theDetail.lifeScope == celestrialTypeIdx && theDetail.chanceOfNew > 0 && numActiveCelestrials[celestrialTypeIdx] < theDetail.maxActive) {
                
                chanceOfNewPlanet = arc4random_uniform(theDetail.chanceOfNew);
                //NSLog(@"5");
                
                //if (theDetail.theType == SPACE_STATION)
                //    NSLog(@"f");
                
                //if (theDetail.theType == CONE)
                //    NSLog(@"e rand %d", chanceOfNewPlanet);
                
                if (chanceOfNewPlanet == 1 && ([NSDate timeIntervalSinceReferenceDate] - lastNewCelestrialTime[celestrialTypeIdx]) > theDetail.minNewTime) {
                    
                    //if (theDetail.theType == SPACE_STATION)
                    //    NSLog(@"g");
                    
                    if ([self getNumCelestrials:celestrialTypeIdx] < theDetail.maxActive) {
                        
                        //unsigned int theSubtypeIdx = -1;
                        
                        //if ([theDetail.orbitalName isEqualToString:@"SHIP_CELESTRIAL"]) {
                        //    theSubtypeIdx = [[OPPlanetManager getSharedManager]  getSubTypeIdx:theDetail planetSubTypeStr:@"STARBASE"];
                            //NSLog(@"1");
                        //}
                        //NSLog(@"2");
                        numActiveCelestrials[celestrialTypeIdx]++;
                        OPOrbitBase * theCelestrial = [[OPPlanetFactory getSharedFactory] createDefaultCelestrial:nil planetType:theDetail.theType];
                        [self addCelestrial:celestrialTypeIdx celestrialObj:theCelestrial];
                        //NSLog(@"R %d %d", celestrialTypeIdx, numActiveCelestrials[celestrialTypeIdx]);
                    }
                    else {
                        //NSLog(@"Resetting cele 3");
                        resetOldCelestrial = true;
                    }
                    //NSLog(@"4");
                    lastNewCelestrialTime[celestrialTypeIdx] = [NSDate timeIntervalSinceReferenceDate];
                }
            }
            //else {
            //    NSLog(@"8");
            //}
        }
    }
    
    //NSLog(@"ct: %d %@", celestrialTypeIdx,NSStringFromClass([celestrialsArr[celestrialTypeIdx] class]) );
    
    for (int x=0; x<[self getNumCelestrials:celestrialTypeIdx]; x++) {
        
        aPlanet = [celestrialsArr[celestrialTypeIdx] objectAtIndex:x];
        
        if ([self isCelestrialStillInScope:aPlanet]) {
            
            [self reactivateMovingCelestrial:aPlanet];
            
            if (!aPlanet->inUse)
                continue;
            
            if (!is_debug)
                [self checkForHit:aPlanet];
            
            if (checkNearestToTouch)
                [self checkForTouch:aPlanet];
            
            [aPlanet update];
            
            if (aPlanet.hasSatellites) {
                
                for (int x=0; x<[((OPPlanet *)aPlanet).moonArr count]; x++) {
                    
                    aPlanet = ((OPPlanet *)aPlanet).moonArr[x];
                    
                    if (!is_debug)
                    [self checkForHit:aPlanet];
                    
                    if (checkNearestToTouch)
                        [self checkForTouch:aPlanet];
                    
                }
            }
        }
    }
}

- (void)processSatellite:(OPOrbitBase *)theSatellite {
    
    GLuint vertexArr = theSatellite.vertexArray;
    glGenVertexArraysOES(1, &vertexArr);
    glBindVertexArrayOES(vertexArr);
    theSatellite.vertexArray = vertexArr;
    
    GLuint vertexBuffer = theSatellite.vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    //NSLog(@"idx %d", theSatellite.subTypeIdx);
    
    //unsigned int theLen = [[OPPlanetManager getSharedManager]  getVertexCnt:theSatellite.typeId planetSubType:theSatellite.subTypeIdx vertexType:DEFAULT_VERTEX];
    
    //NSLog(@"vtxLenAst %d", theLen);
    
//    glBufferData(GL_ARRAY_BUFFER, [[OPPlanetManager getSharedManager]  getVertexCnt:theSatellite.typeId planetSubType:theSatellite.subTypeIdx vertexType:DEFAULT_VERTEX]*12*4, [[OPPlanetManager getSharedManager]  getVertices:theSatellite.typeId planetSubType:theSatellite.subTypeIdx vertexType:DEFAULT_VERTEX], GL_STATIC_DRAW);
    
    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:theSatellite.typeId];
    
    float theSize = theSatellite.vertexData.vertexCnt;  //[[OPPlanetManager getSharedManager]  getVertexCnt:theSatellite.typeId planetSubType:theSatellite.subTypeIdx];
    
    if (theDetail.theFamily == POLYGON) {
        theSize *= (48*sizeof(GLfloat));
    }
    else {
        theSize *= sizeof(Vertex3D);
    }
    
    glBufferData(GL_ARRAY_BUFFER, theSize, theSatellite.vertexData.vertexData, GL_STATIC_DRAW);

//    glBufferData(GL_ARRAY_BUFFER, theSize, [[OPPlanetManager getSharedManager]  getVertices:theSatellite.typeId planetSubType:theSatellite.subTypeIdx], GL_STATIC_DRAW);

    
    theSatellite.vertexBuffer = vertexBuffer;
    
//    if (theDetail.theFamily == POLYGON) {
    
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(0));
    
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(12));
        
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(24));
    
    
    //if (theDetail.theFamily == POLYGON) {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(40));
    //}
    //else {
    //    glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
    //    glVertexAttribPointer(GLKVertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(40));
    //}
        
        
//    }
//    else {
//        glEnableVertexAttribArray(GLKVertexAttribPosition);
//        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(0));
//
//        glEnableVertexAttribArray(GLKVertexAttribNormal);
//        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(12));
//
//        glEnableVertexAttribArray(GLKVertexAttribColor);
//        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(24));
//    }
    
}

- (void)renderCircles {
    
    if (perspHelper.currThrustType != STOPPED && perspHelper.perspectType != WE_ARE) {
    //if ((perspHelper.isThrust || perspHelper.isPerpetualThrust) && perspHelper.perspectType != WE_ARE) {
        int circIdx=0;
        for (OPOrbitBase * theCircle in momCircManager.circleArr) {
            if ([momCircManager getCurrCircle] == circIdx++)
                [((OPOrbitBase *)theCircle) render];
        }
        [momCircManager getNextCircle];
    }
}

- (void)setupInitialCelestrials {
    
    ourShip = [[OPPlanetFactory getSharedFactory] createCone];
    
    _capturedShipHalo1 = (OPMovingCelestrial *)[[OPPlanetFactory getSharedFactory] createPlanet:PLASMA subTypeStr:@"RING1"];
    _capturedShipHalo1->isStaticHalo = true;
    _capturedShipHalo1.rotateAxis = ROTATE_AXIS_Y;
    //_capturedShipHalo1.xAnglePers = 0;
    //_capturedShipHalo1.yAnglePers = 0;
    _capturedShipHalo1.origAnglePersX = 0;
    _capturedShipHalo1.origAnglePersY = HALFPIE;
    _capturedShipHalo1.rotationDistY = 0;
    _capturedShipHalo1.rotationSpeedY = 3;
    _capturedShipHalo1.offsetPt = (OPPoint){200,0,0};
    _capturedShipHalo1->inUse = false;
    
    _capturedShipHalo2 = (OPMovingCelestrial *)[[OPPlanetFactory getSharedFactory] createPlanet:PLASMA subTypeStr:@"RING1"];
    _capturedShipHalo2->isStaticHalo = true;
    _capturedShipHalo2.rotateAxis = ROTATE_AXIS_Y;
    //_capturedShipHalo2.xAnglePers = 0;
    //_capturedShipHalo2.yAnglePers = 0;
    _capturedShipHalo2.origAnglePersX = 0;
    _capturedShipHalo2.origAnglePersY = PIE+HALFPIE;
    _capturedShipHalo2.rotationDistY = 0;
    _capturedShipHalo2.rotationSpeedY = 3;
    _capturedShipHalo2.offsetPt = (OPPoint){-200,0,0};
    _capturedShipHalo2->inUse = false;
    
    //[[OPPlanetFactory getSharedFactory] createTailpipeCircles:momCircManager.circleArr];
    
    OPOrbitBase * newPlanet;
    
    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:SHIP_CELESTRIAL];
    
    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:0 theY:0 theZ:100 celestrialType:SHIP_CELESTRIAL subTypeStr:@"CONE3" theScale:100 angleX:0 angleY:0];
               
    [self addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
    
    //newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:200 theY:-200 theZ:600 celestrialType:PLANET subTypeIdx:1 theScale:90];
    //[[OPPlanetController getSharedController] addCelestrial:PLANET celestrialObj:newPlanet];
    
    //newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:-100 theY:200 theZ:600 celestrialType:PLANET subTypeIdx:2 theScale:90];
    //[[OPPlanetController getSharedController] addCelestrial:PLANET celestrialObj:newPlanet];
    
    //newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:-100 theY:-200 theZ:600 celestrialType:PLANET subTypeIdx:3 theScale:250];
    //[[OPPlanetController getSharedController] addCelestrial:PLANET celestrialObj:newPlanet];
    
    //newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:200 theY:0 theZ:400 celestrialType:ASTEROID subTypeIdx:0 theScale:20];
    //[[OPPlanetController getSharedController] addCelestrial:TRANSITORY celestrialObj:newPlanet];
    
    //newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:-200 theY:0 theZ:400 celestrialType:ASTEROID subTypeIdx:1 theScale:20];
    //[[OPPlanetController getSharedController] addCelestrial:TRANSITORY celestrialObj:newPlanet];

    //OPCelesrtialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:WALL];
    
    //RotateAxis ax;
//    float angleX=0, angleY=0, angleZ=0;
//    float theX=0, theY=0, theZ=0;
//
//    float theScale = 200;
//    float useScale = theScale;
//    float sideWidth = theScale;
//    float halfSideWidth = sideWidth/2;
//
//    //float eVV = (theScale - sideWidth)/2;
//
//    float leftOverWidth = sideWidth / sqrtf(2);
//    float halfLeftOverWidth = halfSideWidth/2;
//    //float midXPos = (sideWidth/2)+(leftOverWidth/2);
//
//    float zInc = 200;
//
//    for (int z=0; z<150; z++) {
//    for (int x=0; x<4; x++) {
//
//
//        switch (x) {
//            case 0:
//                theX = 0;
//                theY = -halfSideWidth;
//                //theZ = 0;
//                angleX = HALFPIE;
//                angleZ = 0;
//                break;
//            case 1:
//                theX = (-halfSideWidth);
//                theY = 0;
//                //theZ = 0;
//                angleX = HALFPIE;
//                angleZ = HALFPIE;
//                break;
//            case 2:
//                theX = 0;
//                theY = halfSideWidth;
//                //theZ = 0;
//                angleX = HALFPIE;
//                angleZ = 0;
//                break;
//            case 3:
//                theX = halfSideWidth;
//                theY = 0;
//                //theZ = 0;
//                angleX = HALFPIE;
//                angleZ = HALFPIE;
//                break;
//        }
//
//
//                newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:theX theY:theY theZ:theZ celestrialType:WALL subTypeStr:@"WALL1" theScale:useScale angleX:angleX angleY:angleY];
//                newPlanet.origAnglePersZ = angleZ;
//                newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//                newPlanet.offsetPt  = (OPPoint){0,0,0};
//                if (newPlanet != nil)
//                    [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//        }
//        theZ = theZ+zInc;
//    }
    
    //RotateAxis ax;
    //
    //
    //
    //
//    float angleX=0, angleY=0, angleZ=0;
//    float theX=0, theY=0, theZ=0;
//
//    float calcZ = 0;
//
//    float theScale = 400;
//
//    float sideWidth = theScale;
//    float halfSideWidth = sideWidth/2;
//
//    //float eVV = (theScale - sideWidth)/2;
//
//    float leftOverWidth = sideWidth / sqrtf(2);
//    float halfLeftOverWidth = leftOverWidth/2;
//    //float midXPos = (sideWidth/2)+(leftOverWidth/2);
//
//    float zInc1 = theScale;
//    //float zInc2 = theScale;
//
//    //float xVV = 0;
//
//    float lowerBound = -50;
//
//    float theXBase = 0;
//
//    bool turnRight;
//
//    float xAngle = 0; // 0 to 2Pi - sin or cos goes around in a circle
//    float yAngle = 0; // 0 to 2Pi - sin or cos goes around in a circle
//    float zAngle = 0; // 0 to 2Pi - sin or cos goes around in a circle
//    float angleInc = .01;
//
//    const float turnZOffset = 0;
//    const float halfZZOffset = turnZOffset/2;
//
//    for (int z=0; z<1000; z++) {
//
//        turnRight = false;
//
//        //if (z > 100 && z < 140) {
//            if (xAngle+angleInc < TWOPIE) {
//                xAngle += angleInc;
//            }
//            else {
//                xAngle = 0;
//                break;
//            }
//
//            if (zAngle+angleInc < TWOPIE) {
//                zAngle += angleInc;
//            }
//            else {
//                zAngle = 0;
//            }
//
//
//
//
//            //theXBase += lowerBound;
//            turnRight = true;
//            //zInc1 = theScale - lowerBound;
//
//        theXBase += theScale * sinf(xAngle);
//        calcZ += theScale * cosf(xAngle);
//
//        NSLog(@"xZ: %.2f %.2f", theScale * cosf(xAngle), theScale * cosf(xAngle));
//
//    for (int x=0; x<8; x++) {
//
//        switch (x) {
//            case 0:
//                theX = theXBase;
//                theY = -halfSideWidth-leftOverWidth;
//                theZ = calcZ;
//                angleX = HALFPIE;
//                angleZ = 0;
//                break;
//            case 1:
//                theX = theXBase + (-halfSideWidth-halfLeftOverWidth);
//                theY = -halfSideWidth-halfLeftOverWidth;
//                theZ = calcZ  + (turnRight ? halfZZOffset : 0);
//                angleX = HALFPIE;
//                angleZ = PIE+HALFPIE+QPIE;
//                break;
//            case 2:
//                theX = theXBase + (-halfSideWidth-leftOverWidth);
//                theY = 0;
//                theZ = calcZ + (turnRight ? turnZOffset : 0);
//                angleX = HALFPIE;
//                angleZ = PIE+HALFPIE;
//                break;
//            case 3:
//                theX = theXBase + (-halfSideWidth-halfLeftOverWidth);
//                theY = halfSideWidth+halfLeftOverWidth;
//                theZ = calcZ + (turnRight ? halfZZOffset : 0);
//                angleX = HALFPIE;
//                angleZ = QPIE;
//                break;
//            case 4:
//                theX = theXBase;
//                theY = halfSideWidth+leftOverWidth;
//                theZ = calcZ;
//                angleX = HALFPIE;
//                angleZ = 0;
//                break;
//            case 5:
//                theX = theXBase + (halfSideWidth+halfLeftOverWidth);
//                theY = halfSideWidth+halfLeftOverWidth;
//                theZ = calcZ + (turnRight ? -halfZZOffset : 0);
//                angleX = HALFPIE;
//                angleZ = PIE+HALFPIE+QPIE;
//                break;
//            case 6:
//                theX = theXBase + (halfSideWidth+leftOverWidth);
//                theY = 0;
//                theZ = calcZ  + (turnRight ? -turnZOffset : 0);
//                angleX = HALFPIE;
//                angleZ = PIE+HALFPIE;
//                break;
//            case 7:
//                theX = theXBase + (halfSideWidth+halfLeftOverWidth);
//                theY = -halfSideWidth-halfLeftOverWidth;
//                theZ = calcZ + (turnRight ? -halfZZOffset : 0);
//                angleX = HALFPIE;
//                angleZ = QPIE;
//                break;
//            default:
//                continue;
//        }
//        newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:theX theY:theY theZ:theZ celestrialType:WALL subTypeStr:@"WALL1" theScale:theScale angleX:angleX angleY:angleY];
//        newPlanet.origAnglePersZ = angleZ;
//        newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//        newPlanet.rotationSpeed = 1;
//        newPlanet.rotationDist = 0;
//        newPlanet.offsetPt  = (OPPoint){0,0,0};
//        if (newPlanet != nil)
//            [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//    }
//        //calcZ += zInc1;
//    }
    
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:50 theY:0 theZ:-100 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:0 angleY:0];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = HALFPIE;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt  = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:0 theY:0 theZ:-50 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:0 angleY:0];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = 0;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
  
//     float angleX=0, angleY=0, angleZ=0;
//     float theX=0, theY=0, theZ=0;
//
//     float theZBase = 0;
//    float theYBase = 0;
//
//     float theScale = 100;
//
//     float sideWidth = theScale;
//     float halfSideWidth = sideWidth/2;
//
//     //float eVV = (theScale - sideWidth)/2;
//
//     float leftOverWidth = sideWidth / sqrtf(2);
//     float halfLeftOverWidth = leftOverWidth/2;
//     //float midXPos = (sideWidth/2)+(leftOverWidth/2);
//
//     //float zInc1 = theScale;
//     //float zInc2 = theScale;
//
//     //float xVV = 0;
//
//     //float lowerBound = -50;
//
//     float theXBase = 0;
//
//     bool turnRight;
//
//     float xAngle = 0; // 0 to 2Pi - sin or cos goes around in a circle
//     float yAngle = 0; // 0 to 2Pi - sin or cos goes around in a circle
//     float zAngle = 0; // 0 to 2Pi - sin or cos goes around in a circle
//     float angleInc =  0.02; //.01;
//
//     //const float turnZOffset = 0;
//     //const float halfZZOffset = turnZOffset/2;
//
//     turnRight = false;
//
//     for (int z=0; z<500; z++) { // z<500
//
//         if (z < 200) {
//             angleInc = -0.02;
//
//             if (xAngle+angleInc > 0) {
//                 xAngle += angleInc;
//             }
//             else {
//                 xAngle = TWOPIE;
//             }
//             //if (yAngle+angleInc > 0) {
//             //    yAngle += angleInc;
//             //}
//             //else {
//             //    yAngle = TWOPIE;
//             //}
//             if (zAngle+angleInc > 0) {
//                 zAngle += angleInc;
//             }
//             else {
//                 zAngle = TWOPIE;
//             }
//
//         } else if (z >= 200 && z < 400) {
//             angleInc = 0.02;
//
//             if (xAngle+angleInc < TWOPIE) {
//                 xAngle += angleInc;
//             }
//             else {
//                 xAngle = 0;
//             }
//             //if (yAngle+angleInc < TWOPIE) {
//             //    yAngle += angleInc;
//             //}
//             //else {
//             //    yAngle = 0;
//             //}
//             if (zAngle+angleInc < TWOPIE) {
//                 zAngle += angleInc;
//             }
//             else {
//                 zAngle = 0;
//             }
//         }
//         else {
//             angleInc = 0.02;
//
//             if (yAngle+angleInc < TWOPIE) {
//                 yAngle += angleInc;
//             }
//             else {
//                 yAngle = 0;
//             }
//             if (zAngle+angleInc < TWOPIE) {
//                 zAngle += angleInc;
//             }
//             else {
//                 zAngle = 0;
//             }
//         }
//
//        //theXBase += lowerBound;
//        turnRight = true;
//        //zInc1 = theScale - lowerBound;
//
//         theXBase += 20 * sinf(xAngle);
//
//         //calcZ = 0;
//         //NSLog(@"xZ: %.2f %.2f", theXBase, calcZ);
//
//     for (int x=0; x<8; x++) {
//
//         switch (x) {
//             case 0:
//                 theX = theXBase;
//                 theY = theYBase + (-halfSideWidth-leftOverWidth);
//                 theZ = theZBase;
//                 angleX = HALFPIE;
//                 angleY = 0;
//                 angleZ = 0;
//
//                 break;
//             case 1:
//                 theX = theXBase + (-halfSideWidth-halfLeftOverWidth);
//                 //NSLog(@"x1: %.2f %.2f", -(theX-theXBase), (-halfSideWidth-halfLeftOverWidth));
//                 theY = theYBase + (-halfSideWidth-halfLeftOverWidth);
//                 theZ = theZBase; //  + (turnRight ? halfZZOffset : 0);
//                 angleX = HALFPIE;
//                 angleY = 0;
//                 angleZ = PIE+HALFPIE+QPIE;
//                 break;
//             case 2:
//                 theX = theXBase + (-halfSideWidth-leftOverWidth);
//                 //NSLog(@"x3: %.2f %.2f", -(theX-theXBase), (-halfSideWidth-leftOverWidth));
//                 theY = theYBase;
//                 theZ = theZBase; // + (turnRight ? turnZOffset : 0);
//                 angleX = HALFPIE;
//                 angleY = 0;
//                 angleZ = PIE+HALFPIE;
//                 break;
//             case 3:
//                 theX = theXBase + (-halfSideWidth-halfLeftOverWidth);
//                 //NSLog(@"x3: %.2f %.2f", -(theX-theXBase), (-halfSideWidth-halfLeftOverWidth));
//                 theY = theYBase + (halfSideWidth+halfLeftOverWidth);
//                 theZ = theZBase; // + (turnRight ? halfZZOffset : 0);
//                 angleX = HALFPIE;
//                 angleY = 0;
//                 angleZ = QPIE;
//                 break;
//             case 4:
//                 theX = theXBase;
//                 //NSLog(@"x4: %.2f %.2f", -(theX-theXBase), theXBase);
//                 theY = theYBase + (halfSideWidth+leftOverWidth);
//                 theZ = theZBase;
//                 angleX = HALFPIE;
//                 angleY = 0;
//                 angleZ = 0;
//                 break;
//             case 5:
//                 theX = theXBase + (halfSideWidth+halfLeftOverWidth);
//                 theY = theYBase + (halfSideWidth+halfLeftOverWidth);
//                 theZ = theZBase; // + (turnRight ? -halfZZOffset : 0);
//                 angleX = HALFPIE;
//                 angleY = 0;
//                 angleZ = PIE+HALFPIE+QPIE;
//                 break;
//             case 6:
//                 theX = theXBase + (halfSideWidth+leftOverWidth);
//                 theY = theYBase;
//                 theZ = theZBase; //  + (turnRight ? -turnZOffset : 0);
//                 angleX = HALFPIE;
//                 angleY = 0;
//                 angleZ = PIE+HALFPIE;
//                 break;
//             case 7:
//                 theX = theXBase + (halfSideWidth+halfLeftOverWidth);
//                 theY = theYBase + (-halfSideWidth-halfLeftOverWidth);
//                 theZ = theZBase; // + (turnRight ? -halfZZOffset : 0);
//                 angleX = HALFPIE;
//                 angleY = 0;
//                 angleZ = QPIE; //  + (z == 0 ? 0 : QPIE);
//                 break;
//             default:
//                 continue;
//         }
//
//         //float rotDis = xAngle;
//
//         //NSLog(@"angles %.2f %.2f", xAngle, yAngle);
//
//         newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:theX theY:theY theZ:theZ celestrialType:WALL subTypeStr:@"WALL1" theScale:theScale angleX:angleX angleY:angleY];
//         newPlanet.origAnglePersZ = angleZ;
//         newPlanet.rotateAxis = ROTATE_AXIS_Y + ROTATE_AXIS_X;
//         newPlanet.rotationSpeedX = 1;
//         newPlanet.rotationSpeedY = 1;
//         newPlanet.rotationSpeedZ = 0;
//         newPlanet.rotationDistX = yAngle;
//         newPlanet.rotationDistY = xAngle;
//         newPlanet.rotationDistZ = 0;
//         newPlanet->isNotOrbital = true;
//         //newPlanet.offsetPt  = (OPPoint){0,0,0};
//         newPlanet.offsetPt  = (OPPoint){(theX-theXBase),theY-theYBase,(theZ-theZBase)};
//         //newPlanet.offsetPt  = (OPPoint){0,0,0};
//         if (x <= 3) {
//             newPlanet.textureNum = 3;
//         }
//         if (newPlanet != nil)
//             [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//     }
//         //calcZ += zInc1;
//         theZBase += theScale * cosf(zAngle);
//         theYBase += 20 * sinf(yAngle);
//
//        // angleY = HALFPIE;
//        //angleY += theScale * sinf(yAngle);
//     }
//
//
    
    
    
    
//
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:100 theY:0 theZ:-50 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:PIE angleY:HALFPIE];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = 0;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:150 theY:0 theZ:-100 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:PIE angleY:HALFPIE];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = HALFPIE;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt  = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:150 theY:0 theZ:-200 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:PIE angleY:HALFPIE];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = HALFPIE;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:150 theY:0 theZ:-300 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:PIE angleY:HALFPIE];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = HALFPIE;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//
//
//
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:-150 theY:0 theZ:-100 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:PIE angleY:HALFPIE];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = HALFPIE;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt  = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:-150 theY:0 theZ:-200 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:PIE angleY:HALFPIE];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = HALFPIE;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//
//    newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:-150 theY:0 theZ:-300 celestrialType:WALL subTypeStr:@"WALL1" theScale:100 angleX:PIE angleY:HALFPIE];
//    newPlanet.origAnglePersX = 0;
//    newPlanet.origAnglePersY = HALFPIE;
//    newPlanet.rotateAxis = ROTATE_AXIS_NONE;
//    newPlanet.offsetPt = (OPPoint){0,0,0};
//    //newPlanet->isStaticSpecial = true;
//    if (newPlanet != nil)
//        [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];
//
    
 //   newPlanet= [[OPPlanetFactory getSharedFactory] createPlanet:0 theY:0 theZ:1000 celestrialType:STAR subTypeStr:@"STAR1" theScale:100 angleX:0 angleY:0];
 //   [[OPPlanetController getSharedController] addCelestrial:theDetail.lifeScope celestrialObj:newPlanet];

}

- (void)renderCelestrial {
    
    if (perspHelper.perspectType == LOOKING_AT)
        [((OPOrbitBase *)ourShip) render];
    
    isAltPerspectiveUsed = false;
    
    for (int x=0; x<NumCelestrialLifeScopeTypes; x++) {
        
        for (OPOrbitBase * thePlanet in celestrialsArr[x]) {
            
            if (thePlanet->inUse) {
                
                if ([thePlanet getPerspId] != perspHelper.currPerspId && [thePlanet getPerspId] != PERSP_ID0) {
                    isAltPerspectiveUsed = true;
                }
                
                if ([thePlanet isKindOfClass:[OPPlanet class]]) {
                    [((OPPlanet *)thePlanet) renderPlanet];
                }
                else
                    [thePlanet render];
            }
        }
        //    for (OPOrbitBase * thePlanet in celestrialsArr[ASTEROID]) {
        //        if (thePlanet->inUse) {
        //
        //            if ([thePlanet getPerspId] != perspHelper.currPerspId && [thePlanet getPerspId] != PERSP_ID0) {
        //                isAltPerspectiveUsed = true;
        //            }
        //            if ([thePlanet isKindOfClass:[OPMovingCelestrial class]]) {
        //                [((OPMovingCelestrial *)thePlanet) render];
        //            }
        //        }
        //    }
    }
    
    if (_capturedShipHalo1 != nil && _capturedShipHalo1->inUse) {

        if ([_capturedShipHalo1 getPerspId] != perspHelper.currPerspId && [_capturedShipHalo1 getPerspId] != PERSP_ID0) {
            isAltPerspectiveUsed = true;
        }
        //if ([_capturedShipHalo1 isKindOfClass:[OPMovingCelestrial class]]) {
            [((OPMovingCelestrial *)_capturedShipHalo1) render];
        //}
    }
    
    if (_capturedShipHalo2 != nil && _capturedShipHalo2->inUse) {
        
        if ([_capturedShipHalo2 getPerspId] != perspHelper.currPerspId && [_capturedShipHalo2 getPerspId] != PERSP_ID0) {
            isAltPerspectiveUsed = true;
        }
        //if ([_capturedShipHalo2 isKindOfClass:[OPMovingCelestrial class]]) {
            [((OPMovingCelestrial *)_capturedShipHalo2) render];
        //}
    }
    
    if (!isAltPerspectiveUsed) {
        [perspHelper toggleCurrPersp];
    }
}

//- (bool)hadRecentHit {
//    return gameContext.isHit;
//}

//- (bool)hadRecentHeat {
    //if (gameContext.isHeat)
    //    NSLog(@"recent heat");
//    return gameContext.isHeat;
//}

//- (bool)isGameOver {
    //if (gameContext.isGameOver) {
    //    NSLog(@"What?");
    //}
//    return gameContext.isGameOver;
//}

- (void)tearDownPlanets {
    
    for (int x=0; x<NumCelestrialLifeScopeTypes; x++) {
        
        for (OPOrbitBase * thePlanet in celestrialsArr[x]) {

            if ([thePlanet isKindOfClass:[OPPlanet class]]) {
                GLuint vertexBuffer = thePlanet.vertexBuffer;
                GLuint vertexArray = thePlanet.vertexArray;
                glDeleteBuffers(1, &vertexBuffer);
                glDeleteVertexArraysOES(1, &vertexArray);
            }
        }
    }
}

@end

