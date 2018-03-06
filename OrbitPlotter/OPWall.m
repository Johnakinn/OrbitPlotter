//
//  OPWall.m
//  OrbitPlotter
//
//  Created by John Kinn on 10/29/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/glext.h>
#import "OPWall.h"
#import "OPPlanetManager.h"

@interface OPWall() {
}

@end

@implementation OPWall

@synthesize wallHallMiddlePt;

@synthesize facingDirection;
@synthesize angleRotateSpeed;

@synthesize rotXUse;
@synthesize rotYUse;

@synthesize obsticlePtr;

//@synthesize isFloor;

//@synthesize secondaryTurnDir;

- (id)init:(OPOrbitBase *)pOrbitsAround  id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)theScale perspHelper:(PerspectiveHelper *)pPerspHelper isStatic:(bool)pStatic circDist:(float)circDist perspId:(int)pPerspId textureType:(int)pTextureType vertexData:(OPVertexData *)pVertexData {
    
    self = [super init:pOrbitsAround id:pId typeId:pTypeId pRadius:pRadius offsetPt:pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:pWorldStartPt rotateSpeed:rotateSpeed anglePersX:anglePersX  anglePersY:anglePersY scale:theScale  perspHelper:pPerspHelper isStatic:(bool)pStatic perspId:(int)pPerspId textureType:pTextureType vertexData:pVertexData];
    
    if (self) {
        self.rotXUse = 0;
        self.rotYUse = 0;
        self->isLowestInSegment = false;
        self->playSound = false;
        //super.mainVertexCount = NUM_SATTELITE_VERTICES;
        //self->OrigCircDist = self.circlePosition = circDist;
        //self.circlePosition = 250;
    }
    return self;
}

- (void)reset:(unsigned long)pId offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY textureType:(int)pTextureType {
    
    [super reset:pId offsetPt:pOffsetPt rotateAxis:pRotateAxis worldStartPt:pWorldStartPt anglePersX:anglePersX anglePersY:anglePersY textureType:pTextureType];
    //passedMarker = false;
    self->isLowestInSegment = false;
    self->isBeingUsedForSled1 = false;
    self->isBeingUsedForSled2 = false;
    //self->obsticleArrIdx = OBSTICLE_IDX_NONE;
}

- (void)render {
    
    [super render];
    
    float wallProximity = fabs(self.xEye) + fabs(self.yEye) + fabs(self.zEye);
    
    if (wallProximity < 450) {
        if (perspHelper->wallSegmentNum[proximityGroupNum] == wallSegmentNum || perspHelper->wallHitTotal[proximityGroupNum] == 0) {
        
            perspHelper->wallSegmentNum[proximityGroupNum] = wallSegmentNum;
            perspHelper->wallHitTotal[proximityGroupNum] += 1;
            perspHelper->wallHitDist[proximityGroupNum] += wallProximity;
            
            //if (perspHelper->wallHitTotal[proximityGroupNum] >= 3) {
                //perspHelper.lastWallHitCenter = wallHallMiddlePt;
            //    perspHelper.nextWallSegment = wallSegmentNum;
                
                //if ([perspHelper getNextWallZone] == zoneNum) {
                //    passedMarker = true;
                //}
            //}
        }
    }
}

- (void)update {
    [super update];
}

@end

