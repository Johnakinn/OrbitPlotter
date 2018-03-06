//
//  OPplanet.m
//  orbitPlotter3
//
//  Created by John Kinn on 7/30/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import "OPPlanet.h"
#import "OPMovingCelestrial.h"
#import "OPPlanetManager.h"

//@interface OPPlanet() {
    //float yBasedOnAngles;
    //float xBasedOnAngles;
    //float zBasedOnAngles;
    //long xxCount;
//}

//@end

@implementation OPPlanet

@synthesize satelliteArr;
@synthesize moonArr;

@synthesize hasSatellites;

- (id)init:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)theScale momentumSpeed:(OPPoint)pMomentumSpeed perspHelper:(PerspectiveHelper *)pPerspHelper perspId:(int)pPerspId hasSatellites:(bool)pHasSatellites  textureType:(int)pTextureType vertexData:(OPVertexData *)pVertexData {
    
    self = [super init:pOrbitsAround id:pId typeId:pTypeId pRadius:pRadius offsetPt:pOffsetPt rotateAxis:pRotateAxis worldStartPt:pWorldStartPt rotateSpeed:rotateSpeed anglePersX:anglePersX  anglePersY:anglePersY scale:theScale perspHelper:pPerspHelper isStatic:false perspId:pPerspId textureType:pTextureType vertexData:pVertexData];
    if (self) {
        
        self.hasSatellites = pHasSatellites;
        
        if (self.hasSatellites) {
            self.satelliteArr = [NSMutableArray array];
            self.moonArr = [NSMutableArray array];
        }
    }
    
    return self;
}

//- (Boolean)isVisible {
//    if (self.zEye < 0 && fabs(atanf(self.xEye/self.zEye)) < .36 && fabs(atanf(self.yEye/self.zEye)) < .62) {
        
        //float tryIt1 = fabs(atanf(self.xEye/self.zEye)); // .36
        //float tryIt2 = fabs(atanf(self.yEye/self.zEye)); // .62
        //NSLog(@"%.2f %.2f %.2f %.2f %.2f",self.xEye, self.yEye, self.zEye, tryIt1, tryIt2);
        
//
//
//
//
//        float XdivZ = self.xEye/self.zEye;
//        float YdivZ = self.yEye/self.zEye;
//
//        if (
//            (( fabs(YdivZ) < 1 ) &&
//             ( fabs(self.yEye) < 400 || fabs(YdivZ) < .8  ))
//            &&
//            (( fabs(XdivZ) < .64) && (fabs(self.xEye) < 300 ||
//                                      (fabs(self.xEye) < 430 &&  fabs(XdivZ) < .45) ||
//                                      fabs(XdivZ) < .345)
//             ))
//        {
//            return true;
            //NSLog(@"%d %.2f %.2f %.2f %.2f %.2f",theId, xEye, yEye, zEye, XdivZ, YdivZ);
 //       }
//    }
//    return false;
//}

//- (Boolean)isForwardQuadrant {
//    if ((quadrant==1 || quadrant==2 || quadrant==5 || quadrant==6))
//    //if (quadrant<5)
//        return true;
//    else
//        return false;
//}

//- (Vertex3D *)getVertices:(PlanetType)planetType planetSubType:(int)pPlanetSubType {
//    return (Vertex3D *)[[OPPlanetManager getSharedManager] getVertices:planetType planetSubType:pPlanetSubType];
//}

//- (GLuint)getVertexCnt:(PlanetType)planetType planetSubType:(int)pPlanetSubType {
//    return [[OPPlanetManager getSharedManager] getVertexCnt:planetType planetSubType:(int)pPlanetSubType];
//}

- (void)renderPlanet {
    
    [super render];
    if (hasSatellites) {
        for (OPMovingCelestrial * theSatellite in satelliteArr) {
            [theSatellite render];
        }
        for (OPPlanet * theMoon in moonArr) {
            if (theMoon.hasSatellites) {
                [theMoon renderPlanet];
            }
            else {
                [theMoon render];
            }
        }
    }
    
//    if (xxCount++ % 50 == 0 && self.theId < 10) {
//    if ([self isVisible]) {
//        float XdivZ = self.xEye/self.zEye;
//        float YdivZ = self.yEye/self.zEye;
//        float tryIt1 = atanf(XdivZ); // .36
//        float tryIt2 = atanf(YdivZ); // .62
//        //NSLog(@"%.2f %.2f %.2f %.2f %.2f",self.xEye, self.yEye, self.zEye, tryIt1, tryIt2);
//    }
//    }
}

- (void)reset:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale momentumSpeed:(OPPoint)pMomentumSpeed perspId:(int)pPerspId textureType:(int)pTextureType  vertexData:(OPVertexData *)pVertexData {
    
    [super reset:pOrbitsAround id:pId typeId:pTypeId pRadius:pRadius offsetPt:pOffsetPt rotateAxis:pRotateAxis worldStartPt:pWorldStartPt rotateSpeed:rotateSpeed anglePersX:anglePersX anglePersY:anglePersY scale:pScale isStatic:false perspId:pPerspId textureType:pTextureType vertexData:(OPVertexData *)pVertexData];
    
    //for (OPSatellite * theSatellite in satelliteArr) {
    //    [theSatellite updateToNewOrbiting];
    //}
    
    //for (OPPlanet * theMoon in moonArr) {
    //    [theMoon updateToNewOrbiting];
    //}
}

//- (void)thrustUpdateForTest:(OPPoint)thrustDist {
//
//    OPPoint newStartPt = {thrustDist.x+self.worldStartPt.x, thrustDist.y+self.worldStartPt.y,
//        -thrustDist.z+self.worldStartPt.z};
//
//    //NSLog(@"%d %.2f",self.theId, self.momentumSpeed.x);
//
//    self.worldStartPt = newStartPt;
//    //[self setPerspectiveOrigin:newPersp];
//    //self.perspectiveOrigin = newPersp;
//
//    for (OPSatellite * theSatellite in satelliteArr) {
//        //[theSatellite setPerspectiveOrigin:newPersp];
//        theSatellite.worldStartPt = newStartPt;
//    }
//
//    for (OPPlanet * theMoon in moonArr) {
//        //[theMoon setPerspectiveOrigin:newPersp];
//        theMoon.worldStartPt = newStartPt;
//    }
//}

//- (void)resetWorldStartPt {
//    self.worldStartPt = self.worldStartPtBase;
//}

//- (void)momentumUpdate {
//    
//    OPPoint wStartPt = [self getWorldStartPt];
//    
//    OPPoint newStartPt = {self.momentumSpeed.x+wStartPt.x, self.momentumSpeed.y+wStartPt.y,
//        self.momentumSpeed.z+wStartPt.z};
//    
//    //NSLog(@"%d %.2f",self.theId, self.momentumSpeed.x);
//    
//    worldStartPt = newStartPt;
//}

- (void)update {
    
    [super update];
    
    if (self.hasSatellites) {
        
        for (OPPlanet * theMoon in self.moonArr) {
            [((OPOrbitBase *)theMoon) update];
        }
        
        for (OPMovingCelestrial * theSatellite in satelliteArr) {
            [theSatellite update];
        }
    }
}

@end
