//
//  OPWormHoleController.m
//  OrbitPlotter
//
//  Created by John Kinn on 12/27/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "OPWormHoleController.h"
#import "OPPlanetFactory.h"
#import "OPPlanetManager.h"
#import "OPVertexCreationUtils.h"
#import "OPMessage.h"

static const int NUM_OBSTICLES_PER_ZONE = 25;
static const int NUM_WALLS_PER_SEGMENT = 8;

@interface OPWormHoleController() {
    int xSign;
    
    long numUpdates;

    bool resetOldCelestrial;
    
    //int shipPosWallIdx;
    
    Boolean isCaptured;

    int chanceOfnewWall;
    
    OPWall * aWall;
    OPWall * nextWall;
    
    float closestCombinedChosenDistance;
    
    float genAngleInc;
    
    PersForwardBack forwardBack;
    PersUpDown upDown;
    PersRightLeft leftRight;
    PersNorthSouth perspNorthSouth;
    
    unsigned int wallSegmentCnt;
    unsigned int wallArrIdx;
    
    float oldXDist;
    float oldYDist;
    
    // Zones from 1 to 3.  2 zones loaded at once.
    // 1 and 2/ when 1 done load 3
    // when 2 done, load 1
    // when 3 done, load 2
    unsigned int currZoneNum;
    unsigned int prevZoneNum;
    //unsigned int altZoneNum;
    unsigned int numSegmentsPerZone;
    //unsigned int numZones;
    
    unsigned long absoluteWallId;
    
    TurnDirection turnTypeNum;
    
    TurnDirection oldTurnDir;
    
    OPOrbitBase * sledPlanet1;
    OPOrbitBase * sledPlanet2;
    
    unsigned int numObsticlesInZone;
    
    int obsticleWallIdx;
}
@end

@implementation OPWormHoleController

@synthesize perspHelper;

//@synthesize xAngleTilt;
//@synthesize yAngleTilt;
//@synthesize zAngleTilt;

@synthesize wallRotationX;
@synthesize wallRotationY;
@synthesize wallOldRotationX;
@synthesize wallOldRotationY;

@synthesize wallPrevRotationX;
@synthesize wallPrevRotationY;

static OPWormHoleController * sharedWormHoldController;

- (id)init {
    if (sharedWormHoldController == nil) {
        self = [super init];
        if (self) {
            
            sharedWormHoldController = self;
            
            [OPWormHoleController reset];
        }
    }
    return sharedWormHoldController;
}

+ (Boolean)reset {
    
    if (sharedWormHoldController == nil)
        return false;
    
    //sharedWormHoldController->angleX=0;
    //sharedWormHoldController->angleY=0;
//    sharedWormHoldController->angleZ=0;
    sharedWormHoldController->theX=0;
    sharedWormHoldController->theY=0;
    sharedWormHoldController->theZ=0;
    
     //sharedWormHoldController->theZBase = 0;
     //sharedWormHoldController->theYBase = 0;
    
     sharedWormHoldController->theScale = 100;
    
     sharedWormHoldController->sideWidth = sharedWormHoldController->theScale;
     sharedWormHoldController->halfSideWidth = sharedWormHoldController->sideWidth/2;
    
    //float eVV = (theScale - sideWidth)/2;
    
     sharedWormHoldController->leftOverWidth = sharedWormHoldController->sideWidth / sqrtf(2);
     sharedWormHoldController->halfLeftOverWidth = sharedWormHoldController->leftOverWidth/2;
    
    sharedWormHoldController->angleX[0] = HALFPIE;
    sharedWormHoldController->angleY[0] = 0;
    sharedWormHoldController->angleZ[0] = 0;
    
    sharedWormHoldController->angleX[1] = HALFPIE;
    sharedWormHoldController->angleY[1] = 0;
    sharedWormHoldController->angleZ[1] = PIE+HALFPIE+QPIE;
    
    sharedWormHoldController->angleX[2] = HALFPIE;
    sharedWormHoldController->angleY[2] = 0;
    sharedWormHoldController->angleZ[2] = PIE+HALFPIE;
    
    sharedWormHoldController->angleX[3] = HALFPIE;
    sharedWormHoldController->angleY[3] = 0;
    sharedWormHoldController->angleZ[3] = QPIE;
    
    sharedWormHoldController->angleX[4] = HALFPIE;
    sharedWormHoldController->angleY[4] = 0;
    sharedWormHoldController->angleZ[4] = 0;
    
    sharedWormHoldController->angleX[5] = HALFPIE;
    sharedWormHoldController->angleY[5] = 0;
    sharedWormHoldController->angleZ[5] = PIE+HALFPIE+QPIE;
    
    sharedWormHoldController->angleX[6] = HALFPIE;
    sharedWormHoldController->angleY[6] = 0;
    sharedWormHoldController->angleZ[6] = PIE+HALFPIE;
    
    sharedWormHoldController->angleX[7] = HALFPIE;
    sharedWormHoldController->angleY[7] = 0;
    sharedWormHoldController->angleZ[7] = QPIE;
    
    sharedWormHoldController->theXBase[0] = 0;
    sharedWormHoldController->theXBase[1] = (-sharedWormHoldController->halfSideWidth-sharedWormHoldController->halfLeftOverWidth);
    sharedWormHoldController->theXBase[2] = (-sharedWormHoldController->halfSideWidth-sharedWormHoldController->leftOverWidth);
    sharedWormHoldController->theXBase[3] = (-sharedWormHoldController->halfSideWidth-sharedWormHoldController->halfLeftOverWidth);
    sharedWormHoldController->theXBase[4] = 0;
    sharedWormHoldController->theXBase[5] = (sharedWormHoldController->halfSideWidth+sharedWormHoldController->halfLeftOverWidth);
    sharedWormHoldController->theXBase[6] = (sharedWormHoldController->halfSideWidth+sharedWormHoldController->leftOverWidth);
    sharedWormHoldController->theXBase[7] = (sharedWormHoldController->halfSideWidth+sharedWormHoldController->halfLeftOverWidth);
    
    sharedWormHoldController->theYBase[0] = (-sharedWormHoldController->halfSideWidth-sharedWormHoldController->leftOverWidth);
    sharedWormHoldController->theYBase[1] = (-sharedWormHoldController->halfSideWidth-sharedWormHoldController->halfLeftOverWidth);
    sharedWormHoldController->theYBase[2] = 0;
    sharedWormHoldController->theYBase[3] = (sharedWormHoldController->halfSideWidth+sharedWormHoldController->halfLeftOverWidth);
    sharedWormHoldController->theYBase[4] = (sharedWormHoldController->halfSideWidth+sharedWormHoldController->leftOverWidth);
    sharedWormHoldController->theYBase[5] = (sharedWormHoldController->halfSideWidth+sharedWormHoldController->halfLeftOverWidth);
    sharedWormHoldController->theYBase[6] = 0;
    sharedWormHoldController->theYBase[7] = (-sharedWormHoldController->halfSideWidth-sharedWormHoldController->halfLeftOverWidth);
    
    sharedWormHoldController->forwardBack = FACING_FORWARD;
    sharedWormHoldController->upDown = FACING_UP;
    sharedWormHoldController->leftRight = FACING_RIGHT;
    sharedWormHoldController->perspNorthSouth = IN_NORTH;
    //sharedWormHoldController->turnTypeNum = TURN_NONE;
    
    sharedWormHoldController->wallSegmentCnt = 0;
    
    if (is_debug) {
        sharedWormHoldController->numSegmentsPerZone = 10;
    }
    else {
        sharedWormHoldController->numSegmentsPerZone = 40;
    }
    
    //sharedWormHoldController->numZones = 3;
    
    //sharedWormHoldController->altZoneNum = 1;
    
    sharedWormHoldController->genAngleInc = .13; //.03;
    
    return true;
}

+ (OPWormHoleController *)getSharedController {
    if (sharedWormHoldController == nil) {
        sharedWormHoldController = [[OPWormHoleController alloc] init];
    }
    return sharedWormHoldController;
}

- (void)playAudio {
    [self playSound:@"obsticle2" :@"wav"];
}

- (void)playSound :(NSString *)fName :(NSString *) ext{
    SystemSoundID audioEffect;
    NSString *path = [[NSBundle mainBundle] pathForResource : fName ofType :ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path]) {
        NSURL *pathURL = [NSURL fileURLWithPath: path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    else {
        NSLog(@"error, file not found: %@", path);
    }
}

- (void)setupInitial {
    //shipPosWallIdx = 0;
    obsticleWallIdx = 0;
    currZoneNum = 0;
    prevZoneNum = NUM_ZONES-1;
    turnTypeNum = TURN_DOWN; //TURN_NONE;
    wallRotationX = 0;
    wallRotationY = QPIE;
    OPPoint pt = [perspHelper getShipPosition:perspHelper.currPerspId];
    theXCalc = pt.x;
    theYCalc = pt.y;
    if (is_debug) {
        theZCalc = pt.z + 800;
    }
    else {
        theZCalc = pt.z - 200;
    }
    perspHelper.numWormZones = 0;
    sharedWormHoldController->wallArr = [NSMutableArray arrayWithCapacity:120];
    
    for (int x=0; x<NUM_ZONES; x++) {
        sharedWormHoldController->obsticlesArr[x] = [NSMutableArray arrayWithCapacity:NUM_OBSTICLES_PER_ZONE];
    }
    perspHelper.currWallSegment = 0;
    perspHelper.currWallZone = -1;
    
    sledPlanet1 = [[OPPlanetFactory getSharedFactory] createPlanet:0 theY:0 theZ:0 celestrialType:SHIP_CELESTRIAL subTypeStr:@"CONE2" theScale:20 angleX:0 angleY:0];
    sledPlanet1->isNotOrbital = true;
    sledPlanet1.origAnglePersZ = 0;
    sledPlanet1.rotationDistX = 0;
    sledPlanet1.rotationDistY = 0;
    sledPlanet1.rotationDistZ = 0;
    sledPlanet1.textureNum = 5;
    sledPlanet1.hasSatellites = false;
    
    sledPlanet2 = [[OPPlanetFactory getSharedFactory] createPlanet:0 theY:0 theZ:0 celestrialType:SHIP_CELESTRIAL subTypeStr:@"CONE2" theScale:20 angleX:0 angleY:0];
    //sledPlanet2 = (OPPlanet *)[[OPPlanetFactory getSharedFactory] createPlanet:0 theY:0 theZ:0 celestrialType:PLANET subTypeStr:@"PLANET1" theScale:10 angleX:0 angleY:0];
    sledPlanet2->isNotOrbital = true;
    sledPlanet2.origAnglePersZ = 0;
    sledPlanet2.rotationDistX = 0;
    sledPlanet2.rotationDistY = 0;
    sledPlanet2.rotationDistZ = 0;
    sledPlanet2.textureNum = 4;
    sledPlanet2.hasSatellites = false;
    
    [self loadNewWalls];
}

- (Boolean)isUp {
    return upDown == FACING_UP;
}

- (void)toggleNorthSouth {
    //if (wallRotationY < PIE) {
    //    wallRotationY += PIE;
    //}
    //else {
    //    wallRotationY -= PIE;
    //}
    perspNorthSouth = perspNorthSouth == IN_NORTH ? IN_SOUTH : IN_NORTH;
}

- (void)toggleForwardBack {
    forwardBack = (forwardBack == FACING_FORWARD ? FACING_BACK : FACING_FORWARD);
}

- (void)toggleUpDown {
    upDown = upDown == FACING_UP ? FACING_DOWN : FACING_UP;
}

- (void)toggleLeftRight {
    leftRight = (leftRight == FACING_LEFT ? FACING_RIGHT : FACING_LEFT);
}

- (void)bendWallRotation:(TurnDirection)direction rotateSpeed:(float)rotateSpeed {
    
    switch(direction) {
        case TURN_UP:
            if (perspNorthSouth == IN_NORTH) {
                if (wallRotationX + rotateSpeed >= PIE) {
                    wallRotationX = PIE - rotateSpeed;
                    [self toggleNorthSouth];
                }
                else {
                    wallRotationX += rotateSpeed;
                }
            }
            else {
                if (wallRotationX - rotateSpeed > 0) {
                    wallRotationX -= rotateSpeed;
                }
                else {
                    wallRotationX = 0;
                    [self toggleNorthSouth];
                }
            }
            if ((wallOldRotationX < HALFPIE && wallRotationX >= HALFPIE) ||
                (wallOldRotationX > HALFPIE && wallRotationX <= HALFPIE)) {
                [self toggleUpDown];
                [self toggleForwardBack];
            }
            break;
        case TURN_DOWN:
            if (perspNorthSouth == IN_SOUTH) {
                if (wallRotationX + rotateSpeed >= PIE) {
                    wallRotationX = PIE - rotateSpeed;
                    [self toggleNorthSouth];
                }
                else {
                    wallRotationX += rotateSpeed;
                }
            }
            else {
                if (wallRotationX - rotateSpeed > 0) {
                    wallRotationX -= rotateSpeed;
                }
                else {
                    wallRotationX = 0;
                    [self toggleNorthSouth];
                }
            }
            if ((wallOldRotationX > HALFPIE && wallRotationX <= HALFPIE) ||
                (wallOldRotationX < HALFPIE && wallRotationX >= HALFPIE)) {
                [self toggleUpDown];
                [self toggleForwardBack];
            }
            break;
        case TURN_RIGHT:
            if (wallRotationY <= rotateSpeed) {
                wallRotationY = TWOPIE - wallRotationY;
                [self toggleLeftRight];
            }
            else {
                wallRotationY -= rotateSpeed;
            }
            if ((wallOldRotationY > PIE+HALFPIE && wallRotationY <= PIE+HALFPIE) ||
                (wallOldRotationY > HALFPIE && wallRotationY <= HALFPIE)
                ) {
                [self toggleForwardBack];
            }
            break;
        case TURN_LEFT:
            if (wallRotationY + rotateSpeed >= TWOPIE) {
                wallRotationY = rotateSpeed;
                [self toggleLeftRight];
            }
            else {
                wallRotationY += rotateSpeed;
            }
            if ((wallOldRotationY < HALFPIE && wallRotationY >= HALFPIE) ||
                (wallOldRotationY < HALFPIE+PIE && wallRotationY >= HALFPIE+PIE)
                ) {
                [self toggleForwardBack];
            }
            break;
        default:
            break;
    }
    wallOldRotationX = wallRotationX;
    wallOldRotationY = wallRotationY;
}

- (void)createObsticle:(int)theZone {
    
    OPOrbitBase * newObsticle = [[OPPlanetFactory getSharedFactory] createPlanet:0 theY:0 theZ:0 celestrialType:PLASMA subTypeStr:@"RING1" theScale:25 angleX:0 angleY:0];
    newObsticle->isNotOrbital = true;
    newObsticle.origAnglePersZ = 0;
    newObsticle.rotationDistX = 0;
    newObsticle.rotationDistY = 0;
    newObsticle.rotationDistZ = 0;
    newObsticle.textureNum = 5;
    newObsticle.hasSatellites = false;
    
    [obsticlesArr[theZone] addObject:newObsticle];
}

- (void)loadNewWalls {

    //[self playAudio];
    
    OPWall *  newWall;
    //OPPlanet * newPlanet;
    
    numObsticlesInZone = 0;

    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:WALL];

    int useTexture;
    
    int numInCurrentTurn = numSegmentsPerZone-1;
    
    turnTypeNum = [OPVertexCreationUtils generateRandom:4];

    //xAngleTilt = 0;
    //zAngleTilt = 0;
    //yAngleTilt = 0;
    
    for (OPOrbitBase * theObsticle in obsticlesArr[currZoneNum]) {
        theObsticle->inUse = false;
    }
    
    for (int theIdx=0; theIdx<numSegmentsPerZone; theIdx++) {
        
        [self bendWallRotation:turnTypeNum rotateSpeed:genAngleInc];
        
        if (numInCurrentTurn == 0) {
            numInCurrentTurn = numSegmentsPerZone-1;
            genAngleInc = [OPVertexCreationUtils genNewDiv10:10];
            if (wallSegmentCnt % 2 == 0)
                genAngleInc = .1 - genAngleInc;
        }
        
        float rotX = wallRotationX;
        float rotY = wallRotationY;
        
        float yOffset = PIE+HALFPIE;
        rotY += yOffset;
        if (rotY > TWOPIE) {
            rotY = rotY - TWOPIE;
        }
  
        float pcX = sinf(rotX) * cosf(rotY);
        float pcY = sinf(rotX) * sinf(rotY);
        float pcZ = (cosf(rotX));
        
        theXCalc += theScale * pcX;
        theYCalc += theScale * pcY;
        theZCalc += theScale * pcZ;
        
        useTexture = [OPVertexCreationUtils getRandomTextureNum:theDetail perspHelper:perspHelper];

//        if (theIdx == numPerZone-1) {
//            long curInArr = [obsticlesArr[currZoneNum] count];
//            if (curInArr <= currZoneNum) {
//
//                newPlanet = (OPPlanet *)[[OPPlanetFactory getSharedFactory] createPlanet:theXCalc theY:theYCalc theZ:theZCalc celestrialType:PLANET subTypeStr:@"PLANET1" theScale:10 angleX:0 angleY:0];
//                newPlanet.rotateAxis = 0;
//                newPlanet.rotationSpeedX = 0;
//                newPlanet.rotationSpeedY = 0;
//                newPlanet.rotationSpeedZ = 0;
//                newPlanet.rotationDistZ = 0;
//                newPlanet.offsetPt  = (OPPoint){0,0,0};
//                newPlanet.theId = wallSegmentCnt;
//                newPlanet.textureNum = useTexture;
//                newPlanet.hasSatellites = false;
//
//            //if (newPlanet != nil) {
//            //    [objectsInHallArr addObject:newPlanet];
//            //}
//            }
//            else {
//                newPlanet = [obsticlesArr[currZoneNum] objectAtIndex:currZoneNum];
//                [newPlanet reset:newPlanet.theId offsetPt:(OPPoint){0,0,0} rotateAxis:0 worldStartPt:(OPPoint){theXCalc,theYCalc,theZCalc} anglePersX:0 anglePersY:0 textureType:useTexture];
//            }
//            newPlanet->isNotOrbital = true;
//            newPlanet.origAnglePersZ = 0;
//            newPlanet.rotationDistX = 0;
//            newPlanet.rotationDistY = 0;
//            newPlanet.rotationDistZ = 0;
//        }
        
        float theI = wallSegmentCnt % 3;
        //bool obsticleInSegmant = false;
        OPOrbitBase * theObsticle;
        
        bool useAsObsticle = false;
        theObsticle = nil;
        if (numObsticlesInZone < NUM_OBSTICLES_PER_ZONE) {
            unsigned int aNum = arc4random_uniform(numSegmentsPerZone);
            // if random is 1?
            if (aNum < 10) {
                useAsObsticle = true;
                //obsticleInSegmant = true;
            }
        }
        if (useAsObsticle) {
            if ([obsticlesArr[currZoneNum] count] <= numObsticlesInZone) {
                [self createObsticle:currZoneNum];
            }
            theObsticle = [obsticlesArr[currZoneNum] objectAtIndex:numObsticlesInZone++];
            theObsticle->inUse = true;
            obsticleWallIdx++;
            if (obsticleWallIdx >= NUM_WALLS_PER_SEGMENT)
                obsticleWallIdx=0;
        }
        
        for (int panelCircumfIdx=0; panelCircumfIdx<NUM_WALLS_PER_SEGMENT; panelCircumfIdx++) {
            
            theX = theXCalc + theXBase[panelCircumfIdx];
            theY = theYCalc + theYBase[panelCircumfIdx];
            theZ = theZCalc + theZBase[panelCircumfIdx];
            
            unsigned int tIdx = (currZoneNum*numSegmentsPerZone*NUM_WALLS_PER_SEGMENT)+((theIdx*NUM_WALLS_PER_SEGMENT)+panelCircumfIdx);
            
            int rotAxis = ROTATE_AXIS_X + ROTATE_AXIS_Z;
            
            if ([wallArr count] > tIdx) {
                newWall = [wallArr objectAtIndex:tIdx];
                [newWall reset:absoluteWallId offsetPt:(OPPoint){(theX-theXCalc),(theY-theYCalc),(theZ-theZCalc)} rotateAxis:rotAxis worldStartPt:(OPPoint){theX,theY,theZ} anglePersX:angleX[panelCircumfIdx] anglePersY:angleY[panelCircumfIdx] textureType:useTexture];
            }
            else {
                newWall= (OPWall *)[[OPPlanetFactory getSharedFactory] createPlanet:theX theY:theY theZ:theZ celestrialType:WALL subTypeStr:@"WALL1" theScale:theScale angleX:angleX[panelCircumfIdx] angleY:angleY[panelCircumfIdx]];
                newWall.rotateAxis = rotAxis;
                newWall.rotationSpeedX = 1;
                newWall.rotationSpeedY = 1;
                newWall.rotationSpeedZ = 1;
                newWall.offsetPt  = (OPPoint){(theX-theXCalc),theY-theYCalc,(theZ-theZCalc)};
                newWall.theId = absoluteWallId;
                newWall.textureNum = useTexture;
                if (newWall != nil)
                    [wallArr addObject:newWall];
            }
            
            newWall->wallSegmentNum = wallSegmentCnt;
            newWall->isNotOrbital = true;
            newWall.origAnglePersZ = angleZ[panelCircumfIdx];
            newWall.rotationDistX = wallRotationX;
            newWall.rotationDistY = 0;
            newWall.rotationDistZ = wallRotationY;
            
            newWall->proximityGroupNum = theI;
            newWall->zoneNum = currZoneNum;
            newWall.wallHallMiddlePt = (OPPoint){theXCalc,theYCalc,theZCalc};
            newWall.facingDirection = turnTypeNum;
            newWall.angleRotateSpeed = genAngleInc;
            newWall.rotXUse = rotX;
            newWall.rotYUse = rotY;
            
            if (panelCircumfIdx == obsticleWallIdx)
                newWall.obsticlePtr = theObsticle;
            else
                newWall.obsticlePtr = nil;

            //NSLog(@"flooridx %d %d", currZoneNum, (currZoneNum*numPerZone*NUM_WALLS_PER_SEGMENT)+((theIdx*8))+3);
            newWall->segmentFloorIdxNum = (currZoneNum*numSegmentsPerZone*NUM_WALLS_PER_SEGMENT)+((theIdx*NUM_WALLS_PER_SEGMENT))+3;
            
            if (panelCircumfIdx == 4)
                newWall->isFloor = true;
            
            absoluteWallId++;
        }
        
        wallSegmentCnt++;
        numInCurrentTurn--;
    }
    //NSLog(@"Loaded Zone: %d %@", currZoneNum, theDir);
    prevZoneNum = currZoneNum;
    currZoneNum = currZoneNum < NUM_ZONES-1 ? currZoneNum+1 : 0;
}

- (void)changeAngle:(OPWall *)theWall nextWall:(OPWall *)nextWall {
    [perspHelper setShipCoords:theWall.wallHallMiddlePt];
    
    TurnDirection turnDir = theWall.facingDirection;
    
    switch(turnDir) {
        case 0:
            perspHelper.wallRotationX = theWall.rotXUse;
            perspHelper.wallRotationY = theWall.rotYUse;
            
            break;
        case 1:
            perspHelper.wallRotationX = theWall.rotXUse;
            perspHelper.wallRotationY = theWall.rotYUse;
            break;
        case 2:
        case 3:
        case 4:
            break;
    }
    
    perspHelper.angleXRotSpeed = fabs(theWall.rotXUse - wallPrevRotationX);
    perspHelper.angleYRotSpeed = fabs(theWall.rotYUse - wallPrevRotationY);
    
    //float xCos = cosf(theWall.rotationDistX);
   
    //altZoneNum = theWall->zoneNum;
    
    wallPrevRotationX = theWall.rotXUse;
    wallPrevRotationY = theWall.rotYUse;
}

- (void)updateWalls {
    
    if ([perspHelper isPaused])
        return;
    
    if ([OPMessage isErrorActive:WARN_MSG_HIT]) {
        [OPMessage turnErrorOff:WARN_MSG_HIT];
    }
    else if (perspHelper.currThrustType != STOPPED) {
        
        float theThrust = perspHelper.thrustVelocity * perspHelper.thrustAcceleration * perspHelper.thrustDirection;
        
        int theMod = ((101-theThrust) * .01) * 10;
        //theMod *= 10;
        
        unsigned long arrIdx = (perspHelper.currWallSegment*NUM_WALLS_PER_SEGMENT) % [wallArr count];
        
        unsigned long nextArrIdx = ((perspHelper.currWallSegment+1)*NUM_WALLS_PER_SEGMENT) % [wallArr count];
        
        aWall = [wallArr objectAtIndex:arrIdx];
        
        nextWall = [wallArr objectAtIndex:nextArrIdx];
        
        if (theMod == 0 || numUpdates++ % theMod == 0) {
            
            //if ([wallArr count] > shipPosWallIdx+8)
            //    nextWall = [wallArr objectAtIndex:shipPosWallIdx+8];
            //else
            //    nextWall = [wallArr objectAtIndex:0];
            
            //[self changeAngle:aWall nextWall:nextWall];
            
            if ([perspHelper getNextWallZone] == nextWall->zoneNum) {
                //NSLog(@"Load New zone %d", perspHelper.currWallZone);
                perspHelper.currWallZone = nextWall->zoneNum;
                [self loadNewWalls];
                perspHelper.numWormZones = perspHelper.numWormZones + 1;
            }
            
//            if (loadNewZone == false && theWall->passedMarker && theWall->zoneNum == [perspHelper getNextWallZone]) {
//                perspHelper.currWallZone = theWall->zoneNum;
//                loadNewZone = true;
//            }
//
//            if ([perspHelper getNextWallZone] == zoneNum) {
//                passedMarker = true;
//            }
//
//            if (!is_debug) {
//                perspHelper.currWallSegment = perspHelper.nextWallSegment;
//
//                if (loadNewZone) {
//                    [self loadNewWalls];
//
//                }
//            }
//
//            replace shipPosWallIdx with nextWallSegment
//            perspHelper.nextWallSegment = wallSegmentNum;
            
            [perspHelper setShipCoords:aWall.wallHallMiddlePt];
            
            //altZoneNum = aWall->zoneNum;
            
            wallPrevRotationX = aWall.rotXUse;
            wallPrevRotationY = aWall.rotYUse;
            
            // Get the array idx by mod with array idx
            perspHelper.currWallSegment += 1;
            
            //NSLog(@"seg %ld", perspHelper.currWallSegment);
            
            //if ([wallArr count] <= (perspHelper.currWallSegment+1)*8) {
            //    shipPosWallIdx = 0;
            //}
            //else {
            //    shipPosWallIdx+=8;
            //}
            
        }
        else {
            // ship pos is % of dist between cur segment and next segment
            //NSLog(@"o %.2f %.2f %.2f", aWall.wallHallMiddlePt.x, aWall.wallHallMiddlePt.y, aWall.wallHallMiddlePt.z);
            //NSLog(@"x %.2f %.2f %.2f", nextWall.wallHallMiddlePt.x, nextWall.wallHallMiddlePt.y, nextWall.wallHallMiddlePt.z);
            OPPoint newWSP = (OPPoint){
                aWall.wallHallMiddlePt.x+((nextWall.wallHallMiddlePt.x-aWall.wallHallMiddlePt.x)/theMod),
                aWall.wallHallMiddlePt.y+((nextWall.wallHallMiddlePt.y-aWall.wallHallMiddlePt.y)/theMod),
                aWall.wallHallMiddlePt.z+((nextWall.wallHallMiddlePt.z-aWall.wallHallMiddlePt.z)/theMod)};
            //NSLog(@"new %.5f %.5f %.5f", newWSP.x, newWSP.y, newWSP.z);
            
            [perspHelper setShipCoords:newWSP];
            aWall.wallHallMiddlePt = newWSP;
            //OPPoint theP = [perspHelper getShipPosition:perspHelper.currPerspId];
            //NSLog(@"upd %.5f %.5f %.5f",theP.x,theP.y,theP.z);
        }

        if (perspHelper.currThrustType == SLOWING_DOWN) {
            perspHelper.thrustAcceleration--;
            if (perspHelper.thrustAcceleration == 0)
                perspHelper.currThrustType = STOPPED;
        }
    }
    
    for (int x=0; x<[wallArr count]; x++) {
        
        aWall = [wallArr objectAtIndex:x];
        
        if ([self isWallStillInScope:aWall]) {
            
            if (!aWall->inUse)
                continue;
            
            [aWall update];
            
            if (aWall.obsticlePtr != nil) {
                OPOrbitBase * theObsticle = aWall.obsticlePtr;
                
                theObsticle.worldStartPt = (OPPoint){aWall.worldStartPt.x, aWall.worldStartPt.y, aWall.worldStartPt.z};
                
                //aWall.worldStartPt;
                theObsticle.rotateAxis = aWall.rotateAxis;
                theObsticle.rotationSpeedX = aWall.rotationSpeedX;
                theObsticle.rotationSpeedY = aWall.rotationSpeedY;
                theObsticle.rotationSpeedZ = aWall.rotationSpeedZ;
                theObsticle.rotationDistX = aWall.rotationDistX;
                theObsticle.rotationDistY = aWall.rotationDistY;
                theObsticle.rotationDistZ = aWall.rotationDistZ;
                theObsticle.offsetPt = aWall.offsetPt;
            }
            
            if (aWall->isBeingUsedForSled1) {
                sledPlanet1.worldStartPt = (OPPoint){aWall.worldStartPt.x, aWall.worldStartPt.y, aWall.worldStartPt.z+60};
                
                //aWall.worldStartPt;
                sledPlanet1.rotateAxis = aWall.rotateAxis;
                sledPlanet1.rotationSpeedX = aWall.rotationSpeedX;
                sledPlanet1.rotationSpeedY = aWall.rotationSpeedY;
                sledPlanet1.rotationSpeedZ = aWall.rotationSpeedZ;
                sledPlanet1.rotationDistX = aWall.rotationDistX;
                sledPlanet1.rotationDistY = aWall.rotationDistY;
                sledPlanet1.rotationDistZ = aWall.rotationDistZ;
                sledPlanet1.offsetPt = aWall.offsetPt;
            }
            if (aWall->isBeingUsedForSled2) {
                sledPlanet2.worldStartPt = (OPPoint){aWall.worldStartPt.x, aWall.worldStartPt.y, aWall.worldStartPt.z+60};
                sledPlanet2.rotateAxis = aWall.rotateAxis;
                sledPlanet2.rotationSpeedX = aWall.rotationSpeedX;
                sledPlanet2.rotationSpeedY = aWall.rotationSpeedY;
                sledPlanet2.rotationSpeedZ = aWall.rotationSpeedZ;
                sledPlanet2.rotationDistX = aWall.rotationDistX;
                sledPlanet2.rotationDistY = aWall.rotationDistY;
                sledPlanet2.rotationDistZ = aWall.rotationDistZ;
                sledPlanet2.offsetPt = aWall.offsetPt;
            }
        }
    }
    
    [sledPlanet1 update];
    [sledPlanet2 update];
    
    for (int cZone=0; cZone<NUM_ZONES; cZone++) {
        for (int x=0; x<[obsticlesArr[cZone] count]; x++) {
        
            aWall = [obsticlesArr[cZone] objectAtIndex:x];
        
            if ([self isWallStillInScope:aWall]) {
            
                if (!aWall->inUse)
                    continue;
            
                [aWall update];
            }
        }
    }
}

- (void)renderWalls {
    
    if ([OPMessage isErrorActive:WARN_MSG_HIT]) {
        return;
    }
    
    perspHelper->wallHitTotal[0] = 0;
    perspHelper->wallHitTotal[1] = 0;
    perspHelper->wallHitTotal[2] = 0;
    
    perspHelper->wallHitDist[0] = 0;
    perspHelper->wallHitDist[1] = 0;
    perspHelper->wallHitDist[2] = 0;
    
    perspHelper->foundForwardWallObj = false;
    
    
//    if (perspHelper.currWallSegment != perspHelper.currWallSegmentAck) {
        
        unsigned long theMod = (perspHelper.currWallSegment*NUM_WALLS_PER_SEGMENT) % [wallArr count];
        
        //NSLog(@"dddddd %ld %ld", theMod, perspHelper.currWallFloorTrackIdx );
    
        OPWall * aWall = [wallArr objectAtIndex:theMod];
        //OPWall * aWall = [wallArr objectAtIndex:perspHelper.currWallFloorTrackIdx];
    
        unsigned long useTrackOffset = 10;
        if (aWall.angleRotateSpeed > .04)
            useTrackOffset = 5;
        useTrackOffset *= NUM_WALLS_PER_SEGMENT;
    
        //unsigned long theTrackIdx = perspHelper.currWallFloorTrackIdx + useTrackOffset;
        unsigned long theTrackIdx = (theMod) + useTrackOffset;
        if (theTrackIdx > [wallArr count]-1) {
            theTrackIdx =  theTrackIdx - ([wallArr count]-1);
        }
        if (theTrackIdx > [wallArr count]-1) {
            NSLog(@"calcError %ld %ld %ld", perspHelper.currWallFloorTrackIdx, useTrackOffset, [wallArr count]-1);
        }
        else {
        aWall = [wallArr objectAtIndex:theTrackIdx];
        if (aWall != nil) {
            //NSLog(@"Idx %ld", theTrackIdx);
            aWall->useToTrack = true;
            [aWall render];
        }
        }
        
//        perspHelper.currWallSegmentAck = perspHelper.currWallSegment;
//    }
        
    //if ( (((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + 5) ||
    //    (((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + 10)) {
    //    if ( ((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + useTrackOffset)
    //        useToTrack = true;
    //    if (((OPWall *)self)->isFloor) {
    
    //OPPoint theP = [perspHelper getShipPosition:perspHelper.currPerspId];
    //NSLog(@"%.5f %.5f %.5f",theP.x,theP.y,theP.z);
    
    //bool loadNewZone = false;
    int xy = 0;
    long currSegment = -10000;
    float lowestY = -100000;
    OPWall * lowestSegWall = nil;
    for (int ix = 0; ix < [wallArr count]; ix++) {
        OPWall * theWall = [wallArr objectAtIndex:ix];
        xy++;
        if (theWall->inUse) {
            
            [theWall render];
            
            if (currSegment != theWall->wallSegmentNum) {
                currSegment = theWall->wallSegmentNum;
                lowestY = -100000;
                if (lowestSegWall != nil) {
                    lowestSegWall->isLowestInSegment = true;
                    //NSLog(@"winn %.2f %ld", lowestSegWall.yScreen, lowestSegWall->wallSegmentNum);
                }
            }
            
            if (theWall.yScreen > lowestY) {
                lowestSegWall = theWall;
                //theWall->isLowestInSegment = true;
                lowestY = theWall.yScreen;
            }
            
            //NSLog(@"yScre %.2f %ld %f", theWall.yScreen, theWall->wallSegmentNum, lowestY);
            
            theWall->isLowestInSegment = false;
            
            if (theWall->playSound) {
                [self playAudio];
            }
        }
    }
    
    [sledPlanet1 render];
    [sledPlanet2 render];
    
    for (int cZone=0; cZone<NUM_ZONES; cZone++) {
        for (OPOrbitBase * theObj in obsticlesArr[cZone]) {
            if (theObj->inUse) {
                [theObj render];
            }
        }
    }
    
    perspHelper.wormHoleCurTime = [NSDate timeIntervalSinceReferenceDate] - perspHelper.wormHoleStertTime;
}

- (bool)isWallStillInScope:(OPOrbitBase *)wallObject {
    if (wallObject->inUse && ![wallObject isSafeDistance]) {
        return false;
    }
    return true;
}


@end

