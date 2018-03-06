//
//  OPCelesrtialDetail.m
//  OrbitPlotter
//
//  Created by John Kinn on 12/29/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPCelestrialDetail.h"

@implementation OPCelestrialDetail

- (id)init:(NSString *)pOrbitalName theType:(PlanetType)pTheType maxDistance:(float)pMaxDistance minScaleFactor:(long)pMinScaleFactor maxScaleFactor:(long)pMaxScaleFactor maxMomentum:(float)pMaxMomentum isOrbital:(bool)pIsOrbital minNewTime:(float)pMinNewTime maxActive:(float)pMaxActive chanceOfNew:(float)pChanceOfNew lifeScope:(LifeScopeType)pLifeScope theFamily:(MovingCelestrialShape)pTheFamily textureType:(TextureType)pTextureType {
    self = [super init];
    if (self) {
        self.orbitalName = pOrbitalName;
        self.theType = pTheType;
        self.maxDistance = pMaxDistance;
        self.minScaleFactor = pMinScaleFactor;
        self.maxScaleFactor = pMaxScaleFactor;
        self.maxMomentum = pMaxMomentum;
        self.isOrbital = pIsOrbital;
        self.minNewTime = pMinNewTime;
        self.maxActive = pMaxActive;
        self.chanceOfNew = pChanceOfNew;
        self.lifeScope = pLifeScope;
        self.theFamily = pTheFamily;
        self.textureType = pTextureType;
        self.vertexArr = [NSMutableArray array];
        //self.vertexDic = [NSMutableDictionary dictionary];
    }
    return self;
}

@end
