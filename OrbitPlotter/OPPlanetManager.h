//
//  OPPlanetManager.h
//  orbitPlotter3
//
//  Created by John Kinn on 8/24/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "sharedTypes.h"
#import "OPVertexData.h"
#import "OPOrbitBase.h"
#import "OPCelestrialDetail.h"

#ifndef orbitPlotter3_opplanetmanager_h
#define orbitPlotter3_opplanetmanager_h

#pragma once


@interface OPPlanetManager : NSObject {
}

//@property NSArray * celestrialDetailArr;
@property NSDictionary * celestrialDetailDic;

//@property NSMutableArray * orbitalArr;

+ (OPPlanetManager *)getSharedManager;

//- (void *)getVertices:(PlanetType)pType planetSubType:(int)pPlanetSubType;

//- (GLuint)getVertexCnt:(PlanetType)pType planetSubType:(int)pPlanetSubType;

- (unsigned int)getNumberSubTypes:(OPCelestrialDetail *)detail;
- (unsigned int)getNumSubTypes:(PlanetType)pType;

//- (unsigned int)getSubTypeIdx:(OPCelesrtialDetail *)detail planetSubTypeStr:(NSString *)pPlanetSubTypeStr;

- (OPVertexData *)getVertexData:(PlanetType)pType planetSubType:(int)pPlanetSubType;
- (OPVertexData *)getVertexDataFromSubtype:(PlanetType)pType planetSubType:(NSString *)pPlanetSubType;

- (OPCelestrialDetail *)getDetailByIdx:(int)theIdx;
- (OPCelestrialDetail *)getDetail:(PlanetType)typeName;

- (void)processSatellite:(OPOrbitBase *)theSatellite;

@end

#endif
