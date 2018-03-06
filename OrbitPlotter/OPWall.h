//
//  OPWall.h
//  OrbitPlotter
//
//  Created by John Kinn on 10/29/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPWall_h
#define OPWall_h

#import <GLKit/GLKit.h>
#import "sharedTypes.h"
#import <Foundation/Foundation.h>
#import "OPOrbitBase.h"

static const unsigned long OBSTICLE_IDX_NONE = 10000;

@interface OPWall : OPOrbitBase {
@public
    //bool passedMarker; // For wall
    int zoneNum; // For wall
    int proximityGroupNum; // For wall
    long wallSegmentNum;
    bool isFloor;
    bool isLowestInSegment;
    bool isBeingUsedForSled1;
    bool isBeingUsedForSled2;
    int segmentFloorIdxNum;
    bool playSound;
}

@property id obsticlePtr;

@property float rotXUse; // 0 to PI
@property float rotYUse; // 0 to 2 PI

@property TurnDirection facingDirection;
//@property TurnDirection secondaryTurnDir;
@property float angleRotateSpeed;

@property OPPoint wallHallMiddlePt;

- (id)init:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)theScale  perspHelper:(PerspectiveHelper *)pPerspHelper isStatic:(bool)pStatic circDist:(float)circDist perspId:(int)pPerspId textureType:(int)pTextureType vertexData:(OPVertexData *)pVertexData;

//- (GLuint)getVertexCnt:(PlanetType)planetType planetSubType:(int)pPlanetSubType;

- (void)reset:(unsigned long)pId offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY textureType:(int)pTextureType;

@end

#endif /* OPWall_h */
