//
//  OPPlanetDetails.h
//  OrbitPlotter
//
//  Created by John Kinn on 12/9/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPPlanetDetails_h
#define OPPlanetDetails_h

#import <Foundation/Foundation.h>
#import "sharedTypes.h"

@interface OPPlanetDetail : NSObject

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

- (id)init:(NSString *)pOrbitalName theType:(PlanetType)pTheType maxDistance:(float)pMaxDistance minScaleFactor:(long)pMinScaleFactor maxScaleFactor:(long)pMaxScaleFactor maxMomentum:(float)pMaxMomentum isOrbital:(bool)pIsOrbital minNewTime:(float)pMinNewTime maxActive:(float)pMaxActive chanceOfNew:(float)pChanceOfNew lifeScope:(LifeScopeType)pLifeScope theFamily:(MovingCelestrialShape)pTheFamily;

@end

@interface OPPlanetDetails : NSObject

@property NSArray * planetDetailArr;

+ (OPPlanetDetails *)getSharedInstance;

- (unsigned long)getNumDetails;

- (OPPlanetDetail *)getDetail:(int)theIdx;

@end

#endif /* OPPlanetDetails_h */
