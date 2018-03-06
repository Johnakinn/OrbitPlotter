//
//  OPVertexCreationUtils.h
//  OrbitPlotter
//
//  Created by John Kinn on 12/29/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPVertexCreationUtils_h
#define OPVertexCreationUtils_h

#import "sharedTypes.h"
#import "OPCelestrialDetail.h"
#import "PerspectiveHelper.h"

@interface OPVertexCreationUtils : NSObject

+ (int)produceRandomRotationAxis:(PlanetType)pPlanetType;
+ (int)getRandomTextureNum:(OPCelestrialDetail *)theDetail perspHelper:(PerspectiveHelper *)perspHelper;
+ (OPPoint)produceRandomSatelliteDist:(float)theScale rotAxis:(int)rotAxis distFactor:(int)distFactor;
+ (OPPoint)getNewMomentum:(OPCelestrialDetail *)vertexTypeDetail;
+ (float)newSatRotateSpeed:(int)typeId;
+ (int)getNewScaleFactor:(PlanetType)theType vertexDetail:(OPCelestrialDetail *)vertexDetail;
+ (int)generateRandom:(int)lowerBound upperBound:(int)upperBound;
+ (int)generateRandom:(int)upperBound;
+ (float)genNewDiv10:(int)bound;


@end

#endif /* OPVertexCreationUtils_h */
