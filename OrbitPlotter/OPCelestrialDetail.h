//
//  OPCelestrialDetail.h
//  OrbitPlotter
//
//  Created by John Kinn on 12/29/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPCelesrtialDetail_h
#define OPCelesrtialDetail_h

#import "sharedTypes.h"

@interface OPCelestrialDetail : NSObject

@property const NSString * orbitalName;
@property const PlanetType theType;
@property const float maxDistance;
@property const long minScaleFactor;
@property const long maxScaleFactor;
@property const float maxMomentum;
@property const bool isOrbital;
@property const float minNewTime;
@property const float maxActive;
@property const float chanceOfNew;
@property const LifeScopeType lifeScope;
@property const MovingCelestrialShape theFamily;
@property const TextureType textureType;
@property NSMutableArray * vertexArr;

- (id)init:(NSString *)pOrbitalName theType:(PlanetType)pTheType maxDistance:(float)pMaxDistance minScaleFactor:(long)pMinScaleFactor maxScaleFactor:(long)pMaxScaleFactor maxMomentum:(float)pMaxMomentum isOrbital:(bool)pIsOrbital minNewTime:(float)pMinNewTime maxActive:(float)pMaxActive chanceOfNew:(float)pChanceOfNew lifeScope:(LifeScopeType)pLifeScope theFamily:(MovingCelestrialShape)pTheFamily textureType:(TextureType)pTextureType;

@end


#endif /* OPCelesrtialDetail_h */
