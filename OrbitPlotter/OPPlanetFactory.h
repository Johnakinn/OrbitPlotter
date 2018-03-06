//
//  OPPlanetFactory.h
//  OrbitPlotter
//
//  Created by John Kinn on 11/3/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPPlanetFactory_h
#define OPPlanetFactory_h

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "PerspectiveHelper.h"
#import "OPPlanet.h"
#import "OPMovingCelestrial.h"
#import "OPWall.h"
#import "OPVertexCreationUtils.h"

@interface OPPlanetFactory : NSObject {
    int satId;
    int numActivePlanets;
}

@property PerspectiveHelper *perspHelper;

+ (OPPlanetFactory *)getSharedFactory;

- (OPOrbitBase *)createPlanet:(float)theX theY:(float)theY theZ:(float)theZ celestrialType:(PlanetType)celestrialType subTypeStr:(NSString *)pSubTypeStr theScale:(long)theScale angleX:(float)angleX angleY:(float)angleY;

- (OPOrbitBase *)createDefaultCelestrial:(OPOrbitBase *)thePlanet planetType:(PlanetType)pPlanetType;

//- (OPOrbitBase *)createDefaultCelestrial:(OPOrbitBase *)thePlanet planetType:(PlanetType)pPlanetType;

//- (OPPlanet *)createPlanet:(PlanetType)celestrialType subType:(PlanetSubType)subType ;
- (OPOrbitBase *)createPlanet:(PlanetType)celestrialType subTypeStr:(NSString *)pSubTypeStr;

//- (void)createTailpipeCircles:(NSMutableArray *)circleArr;

- (OPPlanet *)createNewPlanet:(CGFloat)radiusUse typeId:(PlanetType)typeId radiusMoon:(CGFloat)radiusMoon  mainPt:(OPPoint)mainPt mainOrbitOffset:(OPPoint)mainOrbitOffset rotSpeed:(CGFloat)rotSpeed angleX:(CGFloat)angleX angleY:(CGFloat)angleY theScale:(float)theScale inUse:(bool)inUse rotateAxis:(int)pRotateAxis planetId:(int)planetId perspId:(int)perspId sharedMomentum:(OPPoint)sharedMomentum vertexData:(OPVertexData *)pVertexData;

- (OPOrbitBase *)createCone;

@end

#endif /* OPPlanetFactory_h */
