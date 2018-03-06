//
//  OPMovingCelestrial.m
//  OrbitPlotter
//
//  Created by John Kinn on 11/4/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPMovingCelestrial.h"
#import "OPPlanetManager.h"

@implementation OPMovingCelestrial

@synthesize momentumSpeed;
@synthesize lastMomentumDrawTime;

//@synthesize worldStartPt;

- (id)init:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale momentumSpeed:(OPPoint)pMomentumSpeed perspHelper:(PerspectiveHelper *)pPerspHelper isStatic:(bool)pStatic perspId:(int)pPerspId textureType:(int)pTextureType  vertexData:(OPVertexData *)pVertexData {
    
    self = [super init:pOrbitsAround id:pId typeId:pTypeId pRadius:pRadius offsetPt:pOffsetPt rotateAxis:pRotateAxis worldStartPt:pWorldStartPt rotateSpeed:rotateSpeed anglePersX:anglePersX  anglePersY:anglePersY scale:pScale perspHelper:pPerspHelper isStatic:(bool)pStatic perspId:pPerspId textureType:pTextureType vertexData:pVertexData];
    if (self) {
        self.lastMomentumDrawTime = [NSDate timeIntervalSinceReferenceDate];
        self.momentumSpeed = pMomentumSpeed; //[self setRallyPtBasedOnAngles:anglePersX angleY:anglePersY perspHelper:(PerspectiveHelper *)perspHelper];   //= pMomentumSpeed;
    }
    return self;
}

- (id)init:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale momentumSpeed:(OPPoint)pMomentumSpeed perspHelper:(PerspectiveHelper *)pPerspHelper perspId:(int)pPerspId textureType:(int)pTextureType  vertexData:(OPVertexData *)pVertexData {
    
    self = [self init:pOrbitsAround id:pId typeId:pTypeId pRadius:pRadius offsetPt:pOffsetPt rotateAxis:pRotateAxis worldStartPt:pWorldStartPt rotateSpeed:rotateSpeed anglePersX:anglePersX  anglePersY:anglePersY scale:pScale perspHelper:pPerspHelper isStatic:(bool)false perspId:pPerspId textureType:pTextureType vertexData:pVertexData];
    if (self) {
        self.momentumSpeed = [self setRallyPtBasedOnAngles:anglePersX angleY:anglePersY perspHelper:(PerspectiveHelper *)perspHelper];   //pMomentumSpeed;
    }
    
    return self;
}

//- (Vertex3D *)getVertices:(PlanetType)planetType planetSubType:(int)pPlanetSubType  {
//    return (Vertex3D *)[[OPPlanetManager getSharedManager] getVertices:planetType planetSubType:pPlanetSubType];
//}

//- (GLuint)getVertexCnt:(PlanetType)planetType planetSubType:(int)pPlanetSubType  {
//   return [[OPPlanetManager getSharedManager] getVertexCnt:planetType planetSubType:(int)pPlanetSubType];
//}

- (void)reset:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale momentumSpeed:(OPPoint)pMomentumSpeed perspId:(int)pPerspId textureType:(int)pTextureType vertexData:(OPVertexData *)pVertexData {
    
    momentumSpeed = pMomentumSpeed; // [self setRallyPtBasedOnAngles:anglePersX angleY:anglePersY perspHelper:(PerspectiveHelper *)perspHelper];  // = pMomentumSpeed;
    
    [super reset:pOrbitsAround id:pId typeId:pTypeId pRadius:pRadius offsetPt:pOffsetPt rotateAxis:pRotateAxis worldStartPt:pWorldStartPt rotateSpeed:rotateSpeed anglePersX:anglePersX anglePersY:anglePersY scale:pScale isStatic:(bool)false perspId:pPerspId textureType:pTextureType vertexData:pVertexData];
}

- (void)momentumUpdate {
    
    OPPoint wStartPt = [self getWorldStartPt];
    
    OPPoint newStartPt = {self.momentumSpeed.x+wStartPt.x, self.momentumSpeed.y+wStartPt.y,
        self.momentumSpeed.z+wStartPt.z};
    
    self.worldStartPt = newStartPt;
}

- (OPPoint)setRallyPtBasedOnAngles:(float)angleX angleY:(float)angleY perspHelper:(PerspectiveHelper *)perspHelper {
    
    float sinXangle = sin(angleX);
    float cosYangle = cos (angleY);
    
    float cosXangle = cos (angleX);
    float sinYangle = sin (angleY);
    
    float sueX, sueY, sueZ;
    
    sueY = sinXangle * cosYangle;
    sueX = sinYangle;
    sueZ = cosXangle * cosYangle;
    if (![perspHelper isUp]) {
        sueX = -(sueX);
    }
//    if (fabs(sinYangle) > .4) {
//        float useXOffset;
//        if (cosXangle > 0)
//            useXOffset = 1 - cosXangle;
//        else
//            useXOffset = -1 - cosXangle;
//
//        if (sueX > 0) {
//            sueX -= fabs(useXOffset);
//        }
//        else {
//            sueX += fabs(useXOffset);
//        }
//    }
    
    //NSLog(@"%d %.2f %.2f %.2f %.2f", self.theId, sinXangle, cosYangle, cosXangle, sinYangle);
    //NSLog(@"%d %.2f %.2f %.2f %.2f %.2f", self.theId, angleX, angleY, sueX, sueY, sueZ);
    
    return (OPPoint){sueX*10, -sueY*10, sueZ*10 };
}


- (void)update {
    
    if (self.orbitsAround == nil || [self.orbitsAround isKindOfClass:[NSNull class]]) {
        if (([NSDate timeIntervalSinceReferenceDate] - self.lastMomentumDrawTime) > .1) {
            [self momentumUpdate];
            
            self.lastMomentumDrawTime = [NSDate timeIntervalSinceReferenceDate];
        }
    }
    
    [super update];
    
    //[self reckonXAnglePers:perspHelper.rotationX];
    //[self reckonYAnglePers:perspHelper.rotationY];
}

- (void)render {
    [super render];
}

@end
