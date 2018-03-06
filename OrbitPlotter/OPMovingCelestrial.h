//
//  OPMovingCelestrial.h
//  OrbitPlotter
//
//  Created by John Kinn on 11/4/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPMovingCelestrial_h
#define OPMovingCelestrial_h

#import <GLKit/GLKit.h>
#import "sharedTypes.h"
#import "OPOrbitBase.h"

#import <Foundation/Foundation.h>

@interface OPMovingCelestrial : OPOrbitBase {

}

@property NSTimeInterval lastMomentumDrawTime;

@property OPPoint momentumSpeed;

- (void)momentumUpdate;

- (id)init:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale momentumSpeed:(OPPoint)pMomentumSpeed perspHelper:(PerspectiveHelper *)pPerspHelper perspId:(int)pPerspId textureType:(int)pTextureType  vertexData:(OPVertexData *)pVertexData;

- (id)init:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale momentumSpeed:(OPPoint)pMomentumSpeed perspHelper:(PerspectiveHelper *)pPerspHelper isStatic:(bool)pStatic perspId:(int)pPerspId textureType:(int)pTextureType  vertexData:(OPVertexData *)pVertexData;

- (void)reset:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale momentumSpeed:(OPPoint)pMomentumSpeed perspId:(int)pPerspId textureType:(int)pTextureType  vertexData:(OPVertexData *)pVertexData;

- (void)update;
- (void)render;

@end

#endif /* OPMovingCelestrial_h */
