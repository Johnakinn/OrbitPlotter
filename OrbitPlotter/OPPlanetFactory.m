//
//  OPPlanetFactory.m
//  OrbitPlotter
//
//  Created by John Kinn on 11/3/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPPlanetManager.h"
#import "OPPlanetFactory.h"
//#import "OPPlanetController.h"

@implementation OPPlanetFactory

@synthesize perspHelper;
//@synthesize gameContext;

static OPPlanetFactory * sharedPlanetFactory;

static const float PlanetDistFactor = 10;
static const float MoonDistFactor = 8;

//static const float realWorldDistMult = 637;
//static const int insideMapBoundry = mapBoundry - 300;
//static const float moonDistMultFactor = 4;

//static const int DEFAULT_SPEED_X = 18;
//static const int DEFAULT_SPEED_Y = 18;
//static const int DEFAULT_SPEED_Z = 18;

//static const float maxDefaultCoordOffset = mapBoundryAsteroid/5;
static const int maxSatsInGroup = 15;
static const int maxPlanetsPerStar = 15;

static const int OurShip = 9996;
static const int SatelliteId = 9997;
//static const int DirectionCircleId = 9995;
static const int MoonId = 9998;
static const int CaptureHaloId = 9999;

- (id)init {
    if (sharedPlanetFactory == nil) {
        self = [super init];
        if (self) {
            self->satId = 0;
            self->numActivePlanets = 0;
            sharedPlanetFactory = self;
        }
    }
    return sharedPlanetFactory;
}

+ (OPPlanetFactory *)getSharedFactory {
    if (sharedPlanetFactory == nil) {
        sharedPlanetFactory = [[OPPlanetFactory alloc] init];
    }
    return sharedPlanetFactory;
}

//- (int)getNewScaleFactor:(OPCelestrialDetail *)theDetail {
    
    //OPCelesttialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:theType];
    
//    return [OPVertexCreationUtils generateRandom:(unsigned int)theDetail.minScaleFactor upperBound:(unsigned int)(theDetail.maxScaleFactor)];
//}

- (OPPoint)createNewWorldStartPt:(PlanetType)typeId perspId:(int)perspId vertexTypeDetail:(OPCelestrialDetail *)vertexTypeDetail {
    
    //OPCelesttialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:typeId];
    
    float distanceUse = vertexTypeDetail.maxDistance;
    
    float randDist = vertexTypeDetail.maxDistance/perspHelper.levelNum;
    
    if (randDist < 0)
        randDist = 0;
    
    //unsigned int distRandXandY = ((unsigned int)randDist)/5;
    //unsigned int distRandZ = ((unsigned int)randDist)/5;
    
    long floatingRand1 = [OPVertexCreationUtils generateRandom:randDist];
    long floatingRand2 = [OPVertexCreationUtils generateRandom:randDist];
    long floatingRand3 = [OPVertexCreationUtils generateRandom:randDist];
    
    if (floatingRand1 % 2 == 0)
        floatingRand1 = -floatingRand1;
    
    if (floatingRand2 % 2 == 0)
        floatingRand2 = -floatingRand2;
    
    if (floatingRand3 % 2 == 0)
        floatingRand3 = -floatingRand3;
    
    //long lowerBound = -((long)(distRand)-floatingRand);
    //long upperBound = ((long)(distRand)-floatingRand);
    
    //long rn1 = arc4random_uniform((unsigned int)(upperBound - lowerBound));
    //long rn2 = arc4random_uniform((unsigned int)(upperBound - lowerBound));
    //long rn3 = arc4random_uniform((unsigned int)(upperBound - lowerBound));
    
    //long rnd1 = (lowerBound + rn1);
    //long rnd2 = (lowerBound + rn2);
    //long rnd3 = (lowerBound + rn3);
    
    float useXCoord;
    float useYCoord;
    float useZCoord;
    
    OPPoint shipPos = [perspHelper getShipPosition:perspId];
    
    float basicX = shipPos.x - (floatingRand1/5);
    float basicY = shipPos.y - (floatingRand2/5);
    float basicZ = shipPos.z - (floatingRand3/5);
    
    if (perspHelper.currThrustType != STOPPED) {
    //if (perspHelper.isThrust || perspHelper.isPerpetualThrust) {
        
        basicX += (perspHelper.ptBasedOnAngles.x*perspHelper.thrustDirection * distanceUse);
        basicY += (perspHelper.ptBasedOnAngles.y*perspHelper.thrustDirection * distanceUse);
        basicZ += (perspHelper.ptBasedOnAngles.z*perspHelper.thrustDirection * distanceUse);
        
        OPPoint shipPos = [perspHelper getShipPosition:perspId];
        
        if (fabs(shipPos.x - basicX) > distanceUse)
        {
            if (basicX < (shipPos.x - distanceUse)) {
                basicX = (shipPos.x - distanceUse);
            }
            else if (basicX > (shipPos.x + distanceUse)) {
                basicX = (shipPos.x + distanceUse);
            }
        }
        if (fabs(shipPos.y - basicY) > distanceUse)
        {
            
            if (basicY < (shipPos.y-distanceUse)) {
                basicY = (shipPos.y-distanceUse);
            }
            else if (basicY > (shipPos.y+distanceUse)) {
                basicY = (shipPos.y+distanceUse);
            }
        }
        if (fabs(shipPos.z - basicZ) > distanceUse)
        {
            if (basicZ < (shipPos.z-distanceUse)) {
                basicZ = (shipPos.z-distanceUse);
            }
            else if (basicZ > (shipPos.z+distanceUse)) {
                basicZ = (shipPos.z+distanceUse);
            }
            
        }
    }
    else {
        basicX += floatingRand1;
        basicY += floatingRand2;
        basicZ += floatingRand3;
    }
    
    useXCoord = basicX;
    useYCoord = basicY;
    useZCoord = basicZ;
    
    return (OPPoint){useXCoord,useYCoord,useZCoord};
}

- (OPVertexData *)getRandomVertexData:(PlanetType)pPlanetType {
    unsigned long numSubTypes = [[OPPlanetManager getSharedManager] getNumSubTypes:pPlanetType];
    int planetRnd = [OPVertexCreationUtils generateRandom:(int)numSubTypes];
    
    //if (pPlanetType == SHIP_CELESTRIAL) {
    //    NSLog(@"ok: %d", planetRnd);
    //}
    
    return [[OPPlanetManager getSharedManager] getVertexData:pPlanetType planetSubType:planetRnd];
}

- (OPOrbitBase *)createPlanet:(float)theX theY:(float)theY theZ:(float)theZ celestrialType:(PlanetType)celestrialType subTypeStr:(NSString *)pSubTypeStr  theScale:(long)theScale angleX:(float)angleX angleY:(float)angleY {
    
    if (perspHelper == nil)
        return nil;
    
    OPVertexData * vertexData = [[OPPlanetManager getSharedManager] getVertexDataFromSubtype:celestrialType planetSubType:pSubTypeStr];
    
    //unsigned long numSubTypes = [[OPPlanetManager getSharedManager] getNumSubTypes:celestrialType];
    
    //if (numSubTypes <= pSubTypeIdx)
    //    return nil;
    
    //long theScale = [self getNewScaleFactor:celestrialType];
    
    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:celestrialType];
    
    OPPoint sharedMomentum = [OPVertexCreationUtils getNewMomentum:theDetail];
    
    //float rotSpeed = 0;
    //if (theTypeDetails[celestrialType].isOrbital) {
        float rotSpeed = [OPVertexCreationUtils newSatRotateSpeed:celestrialType];
    //}
    
    float rotAxis = [OPVertexCreationUtils produceRandomRotationAxis:celestrialType];
    
    OPPoint mainPt44 = (OPPoint){theX,theY,theZ};
    OPPoint mainOrbitOffset44 = (OPPoint){0,0,0};
    return [self createNewPlanet:0 typeId:celestrialType radiusMoon:(CGFloat)0 mainPt:mainPt44 mainOrbitOffset:mainOrbitOffset44 rotSpeed:rotSpeed angleX:angleX angleY:angleY theScale:theScale inUse:true rotateAxis:(int)rotAxis planetId:0 perspId:perspHelper.currPerspId sharedMomentum:sharedMomentum vertexData:vertexData];
}

- (OPOrbitBase *)createPlanet:(PlanetType)celestrialType subTypeStr:(NSString *)pSubTypeStr; {
    
    if (perspHelper == nil)
        return nil;
    
    //CGFloat radiusUse = 5371/realWorldDistMult;
    //CGFloat radiusMoon = 1736/realWorldDistMult;
    
    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:celestrialType];
    
    OPVertexData * vertexData = [[OPPlanetManager getSharedManager] getVertexDataFromSubtype:celestrialType planetSubType:pSubTypeStr];
    
    OPPoint mainPt44 = [self createNewWorldStartPt:celestrialType perspId:perspHelper.currPerspId vertexTypeDetail:theDetail];
    
    OPPoint sharedMomentum = [OPVertexCreationUtils getNewMomentum:theDetail];
    
    //OPVertexData * vertexData = [self getRandomVertexData:celestrialType];
    
    long theScale = [OPVertexCreationUtils getNewScaleFactor:celestrialType vertexDetail:theDetail];
    
    int rotAxis = [OPVertexCreationUtils produceRandomRotationAxis:celestrialType];
    
    return [self createNewPlanet:0 typeId:celestrialType radiusMoon:(CGFloat)0 mainPt:mainPt44 mainOrbitOffset:(OPPoint){0,0,0} rotSpeed:[OPVertexCreationUtils newSatRotateSpeed:celestrialType]  angleX:0 angleY:0 theScale:theScale inUse:true rotateAxis:(int)rotAxis planetId:0 perspId:perspHelper.currPerspId sharedMomentum:sharedMomentum vertexData:vertexData];
}

//- (void)createTailpipeCircles:(NSMutableArray *)circleArr {
//
//    int zCirc = -20;
//    int scaleCirc = 25; //6;
//
//    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:PLASMA];
//
//
//    for (int x=0; x<3; x++) {
//
//        int textureNum = [OPVertexCreationUtils getRandomTextureNum:theDetail perspHelper:perspHelper];
//
//        OPVertexData * vertexData = [self getRandomVertexData:PLASMA];
//
//        OPRing* usCircleDir = [[OPRing alloc] init:nil id:SatelliteId typeId:PLASMA pRadius:0 offsetPt:(OPPoint){0,0,0} rotateAxis:(int)ROTATE_AXIS_NONE worldStartPt:(OPPoint){0,0,zCirc} rotateSpeed:0 anglePersX:0 anglePersY:0 scale:scaleCirc perspHelper:perspHelper isStatic:true perspId:PERSP_ID0 textureType:textureNum vertexData:vertexData];
//        usCircleDir->inUse = true;
//        usCircleDir.theId = DirectionCircleId;
//
//        [circleArr addObject:usCircleDir];
//        //[[OPPlanetController getSharedController].momCircManager.circleArr addObject:usCircleDir];
//        [[OPPlanetManager getSharedManager] processSatellite:usCircleDir];
//
//        zCirc -= 10;
//        scaleCirc +=6;
//    }
//}

- (OPOrbitBase *)createDefaultCelestrial:(OPOrbitBase *)thePlanet planetType:(PlanetType)pPlanetType {
    
    //CGFloat radiusUse = 6371/realWorldDistMult;
    //CGFloat radiusMoon = 1736/realWorldDistMult;
    
    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:pPlanetType];
    
    long theScale = [OPVertexCreationUtils getNewScaleFactor:pPlanetType vertexDetail:theDetail];
    
    int usePerspId = perspHelper.currPerspId;;
    
    OPPoint mainOrbitOffset;
    
    OPPoint sharedMomentum = [OPVertexCreationUtils getNewMomentum:theDetail];
    
    float anglePerspX = [OPVertexCreationUtils genNewDiv10:314];
    float anglePerspY = [OPVertexCreationUtils genNewDiv10:628];
    
    OPPoint mainPt = [self createNewWorldStartPt:pPlanetType perspId:usePerspId vertexTypeDetail:theDetail];
    mainOrbitOffset = (OPPoint){0,0,0};
    
    int rotAxis = [OPVertexCreationUtils produceRandomRotationAxis:pPlanetType];
    
    if (thePlanet == nil) {
        
        OPVertexData * vertexData = [self getRandomVertexData:pPlanetType];
        
        thePlanet = [self createNewPlanet:0 typeId:pPlanetType radiusMoon:(CGFloat)0 mainPt:mainPt mainOrbitOffset:mainOrbitOffset rotSpeed:[OPVertexCreationUtils newSatRotateSpeed:pPlanetType] angleX:anglePerspX angleY:anglePerspY theScale:theScale inUse:true rotateAxis:(int)rotAxis planetId:0 perspId:usePerspId sharedMomentum:sharedMomentum vertexData:vertexData];
    }
    else {
        if (thePlanet.orbitsAround) {
            mainPt = [thePlanet getWorldStartPt];
        }
        if ([thePlanet isKindOfClass:[OPPlanet class]]) {
            
            int textureNum = [OPVertexCreationUtils getRandomTextureNum:theDetail perspHelper:perspHelper];
            OPVertexData * vertexData = [self getRandomVertexData:thePlanet.typeId];
            
            float rotateSpeed = 0;
            if (thePlanet.rotateAxis & ROTATE_AXIS_X) {
                //rotDist = thePlanet.rotationDistX;
                rotateSpeed = thePlanet.rotationSpeedX;
            } else if (thePlanet.rotateAxis & ROTATE_AXIS_Y) {
                //rotDist = thePlanet.rotationDistY;
                rotateSpeed = thePlanet.rotationSpeedY;
            } else if (thePlanet.rotateAxis & ROTATE_AXIS_Z) {
                //rotDist = thePlanet.rotationDistZ;
                rotateSpeed = thePlanet.rotationSpeedZ;
            }
            
            [(OPPlanet *)thePlanet reset:thePlanet.orbitsAround id:0 typeId:thePlanet.typeId pRadius:0 offsetPt:thePlanet.offsetPt rotateAxis:(int)thePlanet.rotateAxis worldStartPt:mainPt rotateSpeed:rotateSpeed anglePersX:anglePerspX anglePersY:anglePerspY scale:thePlanet.theScale momentumSpeed:sharedMomentum perspId:usePerspId textureType:textureNum vertexData:vertexData];
            [[OPPlanetManager getSharedManager] processSatellite:(OPPlanet *)thePlanet];
            //[[OPPlanetController getSharedController] processPlanet:(OPPlanet *)thePlanet];
            
            if (((OPPlanet *)thePlanet).hasSatellites) {
                
                OPCelestrialDetail * theMoonDetail = [[OPPlanetManager getSharedManager] getDetail:MOON];
                
                for (OPPlanet * aMoon in ((OPPlanet *)thePlanet).moonArr) {
                    
                    if (aMoon.hasSatellites) {
                        [self createDefaultCelestrial:aMoon planetType:aMoon.typeId];
                    }
                    else {
                        
                        int textureNum = [OPVertexCreationUtils getRandomTextureNum:theMoonDetail perspHelper:perspHelper];
                        OPVertexData * vertexData = [self getRandomVertexData:aMoon.typeId];
                        
                        float rotateSpeed = 0;
                        if (aMoon.rotateAxis & ROTATE_AXIS_X) {
                            //rotDist = thePlanet.rotationDistX;
                            rotateSpeed = aMoon.rotationSpeedX;
                        } else if (aMoon.rotateAxis & ROTATE_AXIS_Y) {
                            //rotDist = thePlanet.rotationDistY;
                            rotateSpeed = aMoon.rotationSpeedY;
                        } else if (aMoon.rotateAxis & ROTATE_AXIS_Z) {
                            //rotDist = thePlanet.rotationDistZ;
                            rotateSpeed = aMoon.rotationSpeedZ;
                        }
                        
                        [(OPPlanet *)aMoon reset:thePlanet id:0 typeId:aMoon.typeId pRadius:0 offsetPt:aMoon.offsetPt rotateAxis:(int)aMoon.rotateAxis worldStartPt:mainPt rotateSpeed:rotateSpeed anglePersX:aMoon.xAnglePers anglePersY:aMoon.yAnglePers scale:aMoon.theScale momentumSpeed:(OPPoint){0,0,0} perspId:usePerspId textureType:textureNum vertexData:vertexData];
                    }
                }
                
                OPCelestrialDetail * theSatDetail = [[OPPlanetManager getSharedManager] getDetail:SATELLITE];
                
                for (OPMovingCelestrial * aSat in ((OPPlanet *)thePlanet).satelliteArr) {
                    
                    int textureNum = [OPVertexCreationUtils getRandomTextureNum:theSatDetail perspHelper:perspHelper];
                    OPVertexData * vertexData = [self getRandomVertexData:SATELLITE];
                    
                    float rotateSpeed = 0;
                    if (aSat.rotateAxis & ROTATE_AXIS_X) {
                        //rotDist = thePlanet.rotationDistX;
                        rotateSpeed = aSat.rotationSpeedX;
                    } else if (aSat.rotateAxis & ROTATE_AXIS_Y) {
                        //rotDist = thePlanet.rotationDistY;
                        rotateSpeed = aSat.rotationSpeedY;
                    } else if (aSat.rotateAxis & ROTATE_AXIS_Z) {
                        //rotDist = thePlanet.rotationDistZ;
                        rotateSpeed = aSat.rotationSpeedZ;
                    }
                    
                    [(OPMovingCelestrial *)aSat reset:thePlanet id:0 typeId:aSat.typeId pRadius:0 offsetPt:aSat.offsetPt rotateAxis:(int)aSat.rotateAxis worldStartPt:mainPt rotateSpeed:rotateSpeed anglePersX:anglePerspX anglePersY:anglePerspY scale:aSat.theScale momentumSpeed:(OPPoint){0,0,0} perspId:usePerspId textureType:textureNum vertexData:vertexData];
                }
            }
        }
        else if ([thePlanet isKindOfClass:[OPMovingCelestrial class]]) {
            
            int textureNum = [OPVertexCreationUtils getRandomTextureNum:theDetail perspHelper:perspHelper];
            
            float rotateSpeed = 0;
            if (thePlanet.rotateAxis & ROTATE_AXIS_X) {
                //rotDist = thePlanet.rotationDistX;
                rotateSpeed = thePlanet.rotationSpeedX;
            } else if (thePlanet.rotateAxis & ROTATE_AXIS_Y) {
                //rotDist = thePlanet.rotationDistY;
                rotateSpeed = thePlanet.rotationSpeedY;
            } else if (thePlanet.rotateAxis & ROTATE_AXIS_Z) {
                //rotDist = thePlanet.rotationDistZ;
                rotateSpeed = thePlanet.rotationSpeedZ;
            }
            
            [(OPMovingCelestrial *)thePlanet reset:nil id:0 typeId:thePlanet.typeId pRadius:0 offsetPt:mainOrbitOffset rotateAxis:(int)rotAxis worldStartPt:mainPt rotateSpeed:rotateSpeed anglePersX:anglePerspX anglePersY:anglePerspY scale:thePlanet.theScale momentumSpeed:sharedMomentum perspId:usePerspId textureType:textureNum vertexData:thePlanet.vertexData];
            
            [[OPPlanetManager getSharedManager] processSatellite:(OPMovingCelestrial *)thePlanet];
        }
    }
    return thePlanet;
}

- (OPOrbitBase *)createCone {
    
    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:SHIP_CELESTRIAL];
    
    int textureNum = [OPVertexCreationUtils getRandomTextureNum:theDetail perspHelper:perspHelper];
    OPVertexData * vertexData = [self getRandomVertexData:SHIP_CELESTRIAL];
    
    OPOrbitBase* usConeDir = [[OPOrbitBase alloc] init:nil id:SatelliteId typeId:SHIP_CELESTRIAL pRadius:0 offsetPt:(OPPoint){0,0,0} rotateAxis:(int)ROTATE_AXIS_NONE worldStartPt:(OPPoint){0,0,0} rotateSpeed:0 anglePersX:0  anglePersY:0 scale:2 perspHelper:perspHelper isStatic:true perspId:PERSP_ID0 textureType:textureNum vertexData:vertexData];
    usConeDir->inUse = true;
    usConeDir.theId = OurShip;
    //NSLog(@"Process Cone");
    [[OPPlanetManager getSharedManager] processSatellite:usConeDir];
    
    return usConeDir;
}

- (OPOrbitBase *)createNewPlanet:(CGFloat)radiusUse typeId:(PlanetType)typeId radiusMoon:(CGFloat)radiusMoon  mainPt:(OPPoint)mainPt mainOrbitOffset:(OPPoint)mainOrbitOffset rotSpeed:(CGFloat)rotSpeed angleX:(CGFloat)angleX angleY:(CGFloat)angleY theScale:(float)theScale inUse:(bool)inUse rotateAxis:(int)pRotateAxis planetId:(int)planetId perspId:(int)perspId sharedMomentum:(OPPoint)sharedMomentum vertexData:(OPVertexData *)pVertexData {
    
    if (!inUse)
        return nil;
    
    OPOrbitBase * mainCelestrial = nil;
    
    if (planetId == 0) planetId = satId++;
    
    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:typeId];
    
    int textureNum = [OPVertexCreationUtils getRandomTextureNum:theDetail perspHelper:perspHelper];
    
    switch(typeId) {
        case PLANET:
        case STAR:
            mainCelestrial = [[OPPlanet alloc] init:nil id:planetId typeId:typeId pRadius:radiusUse offsetPt:mainOrbitOffset rotateAxis:(int)pRotateAxis worldStartPt:mainPt rotateSpeed:rotSpeed anglePersX:angleX anglePersY:angleY scale:theScale momentumSpeed:sharedMomentum perspHelper:perspHelper perspId:perspId hasSatellites:true textureType:textureNum vertexData:pVertexData];
            mainCelestrial->inUse = inUse;
            [mainCelestrial setXAnglePers:perspHelper.rotationX];
            [mainCelestrial setYAnglePers:perspHelper.rotationY];
            [[OPPlanetManager getSharedManager] processSatellite:(OPPlanet *)mainCelestrial];
            //[[OPPlanetController getSharedController] processPlanet:(OPPlanet *)mainCelestrial];
            break;
        case SATELLITE:
        case ASTEROID:
        case PLASMA:
        case SHIP_CELESTRIAL:
        case SPACE_STATION:
            mainCelestrial = [[OPMovingCelestrial alloc] init:nil id:planetId typeId:typeId  pRadius:radiusUse offsetPt:mainOrbitOffset rotateAxis:(int)pRotateAxis worldStartPt:mainPt rotateSpeed:rotSpeed anglePersX:angleX anglePersY:angleY scale:theScale momentumSpeed:sharedMomentum perspHelper:perspHelper isStatic:false perspId:perspId textureType:textureNum vertexData:pVertexData];
            mainCelestrial->inUse = inUse;
            //                [mainCelestrial setXAnglePers:perspHelper.rotationX];
            //                [mainCelestrial setYAnglePers:perspHelper.rotationY];
            //[[OPPlanetController getSharedController] addCelestrial:ASTEROID celestrialObj:mainCelestrial];
            [[OPPlanetManager getSharedManager] processSatellite:mainCelestrial];
            //processSatellite:mainCelestrial radius:radiusUse planetType:typeId planetSubType:subTypeId];
            if (typeId == PLASMA)
                mainCelestrial.theId = CaptureHaloId;
            //break;
            //processSatellite:mainCelestrial radius:radiusUse planetType:typeId planetSubType:subTypeId];
            break;
        case WALL:
            mainCelestrial = [[OPWall alloc] init:nil id:planetId typeId:typeId  pRadius:radiusUse offsetPt:mainOrbitOffset rotateAxis:(int)pRotateAxis worldStartPt:mainPt rotateSpeed:rotSpeed anglePersX:angleX anglePersY:angleY scale:theScale perspHelper:perspHelper isStatic:false perspId:perspId textureType:textureNum vertexData:pVertexData];
            mainCelestrial->inUse = inUse;
            [[OPPlanetManager getSharedManager] processSatellite:mainCelestrial];
            break;
        default:
            break;
    }
    
    if (typeId == STAR) {
        
        int numSats = [OPVertexCreationUtils generateRandom:maxPlanetsPerStar];
        
        //if (is_debug)
        //    numSats = 1;
        
        //int planetRnd;
        long planetScale;
        long offsetZ = 0;
        //float angleXX, angleYY;
        
        OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:PLANET];
        
        int rotAxis = [OPVertexCreationUtils produceRandomRotationAxis:PLANET];
        
        for (int x=0; x<numSats; x++) {
            
            //planetRnd = [self getRandomSubtypeIdx:PLANET];
            
            //OPVertexData * vertexData = [self getRandomVertexData:typeId];
            
            planetScale = [OPVertexCreationUtils getNewScaleFactor:PLANET vertexDetail:theDetail];
            
            offsetZ += theScale*PlanetDistFactor;
            
            OPPoint distancePt = (OPPoint){0,0,offsetZ};  // [self produceRandomSatelliteDist:theScale rotAxis:(RotateAxis)rotAxis multiDist:(int)offsetZ]; //(OPPoint){0,0,offsetZ};
            
            OPVertexData * satVertexData = [self getRandomVertexData:PLANET];
            
            //angleXX = ((float)(arc4random_uniform(100) * (float).01)) * TWOPIE;
            //angleYY = ((float)(arc4random_uniform(100) * (float).01)) * TWOPIE;
        
            OPPlanet * oPlanet = [self createNewPlanet:10 typeId:PLANET radiusMoon:10 mainPt:mainPt mainOrbitOffset:distancePt rotSpeed:[OPVertexCreationUtils newSatRotateSpeed:PLANET] angleX:0 angleY:0 theScale:planetScale inUse:TRUE rotateAxis:rotAxis planetId:0 perspId:perspHelper.currPerspId sharedMomentum:(OPPoint){0,0,0} vertexData:satVertexData];
            oPlanet.orbitsAround = mainCelestrial;
        
            [((OPPlanet *)mainCelestrial).moonArr addObject:oPlanet];
        }
    }
    
    if (typeId == PLANET) {
        
        OPCelestrialDetail * theMoonDetail = [[OPPlanetManager getSharedManager] getDetail:MOON];
        
        int rotAxis = [OPVertexCreationUtils produceRandomRotationAxis:MOON];
        OPPoint distancePt = [OPVertexCreationUtils produceRandomSatelliteDist:theScale rotAxis:(int)rotAxis distFactor:MoonDistFactor];
        
        //NSLog(@"axis: %d", rotAxis);
        
        long moonScaleFactor = [OPVertexCreationUtils getNewScaleFactor:MOON vertexDetail:theMoonDetail];
        
        OPVertexData * vertexData = [self getRandomVertexData:MOON];
        
        int textureNum = [OPVertexCreationUtils getRandomTextureNum:theMoonDetail perspHelper:perspHelper];
        
        OPPlanet * sat1 = [[OPPlanet alloc] init:(OPOrbitBase *)mainCelestrial id:MoonId typeId:MOON pRadius:radiusMoon offsetPt:distancePt rotateAxis:(int)rotAxis worldStartPt:mainPt rotateSpeed:[OPVertexCreationUtils newSatRotateSpeed:MOON] anglePersX:0 anglePersY:0 scale:moonScaleFactor momentumSpeed:(OPPoint){0,0,0} perspHelper:perspHelper perspId:perspId hasSatellites:false textureType:textureNum vertexData:vertexData];
        
        [[OPPlanetManager getSharedManager] processSatellite:sat1];
        //[[OPPlanetController getSharedController] processPlanet:sat1];
        [((OPPlanet *)mainCelestrial).moonArr addObject:sat1];
        
        int numSats = [OPVertexCreationUtils generateRandom:maxSatsInGroup];
        
        OPCelestrialDetail * theSatDetail = [[OPPlanetManager getSharedManager] getDetail:SATELLITE];
        
        for (int x=0; x<numSats; x++) {
            
            //unsigned long satSubTypeId = [[OPPlanetManager getSharedManager] getNumSubTypes:SATELLITE];
            
            //unsigned int satSubTypeIdx = [OPPlanetFactory generateRandom:(int)satSubTypeId];
            
            long satelliteScaleFactor = [OPVertexCreationUtils getNewScaleFactor:SATELLITE vertexDetail:theSatDetail];
            
            OPVertexData * vertexData = [self getRandomVertexData:SATELLITE];
            
            int textureNum = [OPVertexCreationUtils getRandomTextureNum:theSatDetail perspHelper:perspHelper];
            
            OPPoint distPt = [OPVertexCreationUtils produceRandomSatelliteDist:theScale rotAxis:rotAxis distFactor:MoonDistFactor];
            
            //NSLog(@"Rot: %d %.2f %.2f %.2f", rotAxis, distPt.x, distPt.y, distPt.z);
            
            OPMovingCelestrial * sat2 = [[OPMovingCelestrial alloc] init:(OPOrbitBase *)mainCelestrial id:SatelliteId typeId:SATELLITE pRadius:3 offsetPt:distPt rotateAxis:(int)rotAxis worldStartPt:mainPt rotateSpeed:[OPVertexCreationUtils newSatRotateSpeed:SATELLITE] anglePersX:0  anglePersY:0 scale:satelliteScaleFactor  momentumSpeed:(OPPoint){0,0,0} perspHelper:perspHelper isStatic:false perspId:perspId textureType:textureNum vertexData:vertexData];
            [[OPPlanetManager getSharedManager] processSatellite:sat2];
            [((OPPlanet *)mainCelestrial).satelliteArr addObject:sat2];
        }
    }
    
    return mainCelestrial;
}

@end
