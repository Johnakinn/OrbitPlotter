//
//  OPplanet.h
//  orbitPlotter3
//
//  Created by John Kinn on 7/30/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "sharedTypes.h"
#import "OPOrbitBase.h"

#import <Foundation/Foundation.h>

@interface OPPlanet : OPOrbitBase {
}

@property NSMutableArray * satelliteArr;
@property NSMutableArray * moonArr;

- (id)init:(OPOrbitBase *)pOrbitsAround  id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)theScale momentumSpeed:(OPPoint)pMomentumSpeed perspHelper:(PerspectiveHelper *)pPerspHelper perspId:(int)pPerspId hasSatellites:(bool)pHasSatellites  textureType:(int)pTextureType vertexData:(OPVertexData *)pVertexData;

//- (Vertex3D *)getVertices:(PlanetType)planetType planetSubType:(int)pPlanetSubType;
//- (GLuint)getVertexCnt:(PlanetType)planetType planetSubType:(int)pPlanetSubType;

- (void)update;

- (void)reset:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale momentumSpeed:(OPPoint)pMomentumSpeed  perspId:(int)pPerspId  textureType:(int)pTextureType  vertexData:(OPVertexData *)pVertexData;

- (void)renderPlanet;

@end
