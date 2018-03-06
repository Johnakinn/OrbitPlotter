//
//  OPOrbitBase.h
//  orbitPlotter3
//
//  Created by John Kinn on 8/1/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "sharedTypes.h"
#import "PerspectiveHelper.h"
#import "OPVertexData.h"

#import <Foundation/Foundation.h>

@interface OPOrbitBase : NSObject {
@public
    bool inUse;
    bool isStaticSpecial;
    bool isStaticHalo;
    bool isNotOrbital;
    bool isSelected;
    PerspectiveHelper *perspHelper;
    
    bool useToTrack;
}

@property GLuint vertexArray;
@property GLuint vertexBuffer;

//@property GLuint vertexArraySphere1;
//@property GLuint vertexBufferSphere1;

//@property GLuint vertexArraySphere2;
//@property GLuint vertexBufferSphere2;

//@property GLuint vertexArrayP2Strip;
//@property GLuint vertexBufferP2Strip;

@property bool hasSatellites;

@property PlanetType typeId;
//@property PlanetSubType subTypeId;

@property int textureNum;
//@property int textureType;

@property CGFloat rotationSpeedX;
@property CGFloat rotationSpeedY;
@property CGFloat rotationSpeedZ;

@property CGFloat radius;
@property CGFloat theScale;

@property OPPoint offsetPt;

//@property OPPoint worldStartPtBase;
@property OPPoint worldStartPt;

@property NSTimeInterval lastOrbitDrawTime;

@property unsigned long theId;

//@property unsigned int subTypeIdx;
@property OPVertexData * vertexData;;

//@property int perspId;

//@property int theColor;

//@property bool isHit;

//@property bool isOrbitalX;
//@property bool isOrbitalY;
//@property bool isOrbitalZ;
@property int rotateAxis;

@property CGFloat origAnglePersX;
@property CGFloat origAnglePersY;
@property CGFloat origAnglePersZ;

//@property CGFloat zAngleOrbital;
//@property CGFloat xAngleOrbital;
//@property CGFloat yAngleOrbital;

@property (nonatomic) CGFloat yAnglePers;
@property (nonatomic) CGFloat xAnglePers;
@property (nonatomic) CGFloat zAnglePers; // Only use in wormhole

//@property OPPoint pivotPt;

@property(weak) OPOrbitBase * orbitsAround;

//@property CGRect boundsRect;

@property (strong, nonatomic) GLKBaseEffect *effect;

@property CGFloat rotationDistX;
@property CGFloat rotationDistY;
@property CGFloat rotationDistZ;

@property(nonatomic) float xEye;
@property(nonatomic) float yEye;
@property(nonatomic) float zEye;

@property(nonatomic) float wallXEye;
@property(nonatomic) float wallYEye;
@property(nonatomic) float wallZEye;

@property(nonatomic) float xScreen;
@property(nonatomic) float yScreen;

//@property (nonatomic) bool pauseAction;


//@property int stripVertexCount;
//@property int fanVertexCount;

//@property GLKMatrix4 baseModelViewMatrix;

- (id)init:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale perspHelper:(PerspectiveHelper *)pPerspHelper isStatic:(bool)pStatic perspId:(int)pPerspId textureType:(int)pTextureType vertexData:(OPVertexData *)pVertexData;

- (void)reset:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale isStatic:(bool)pStatic perspId:(int)pPerspId textureType:(int)pTextureType vertexData:(OPVertexData *)pVertexData;

- (void)reset:(unsigned long)pId offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY textureType:(int)pTextureType;

//- (Vertex3D *)getStripVertices;
//- (Vertex3D *)getFanVertices;

//- (void)setPauseAction:(bool)pPauseAction;
//- (bool)getPauseAction;

//- (GLKMatrix4)render;
- (void)render;
- (void)update;

- (CGFloat)getXAnglePers;
- (void)reckonXAnglePers:(CGFloat)pXAnglePers;

//- (CGFloat)getYAnglePers;
//- (void)setYAnglePers:(CGFloat)yAnglePers;

- (CGFloat)getYAnglePers;
- (void)reckonYAnglePers:(CGFloat)pYAnglePers;

-(CGFloat)getZAnglePers;
-(void)reckonZAnglePers:(CGFloat)pZAnglePers;

//- (GLuint)getVertexCnt:(PlanetType)planetType planetSubType:(int)pPlanetSubType;

//- (void)updateToNewOrbiting;

//- (void)setPerspectiveOrigin:(OPPoint)pPerspOrigin;

//- (OPPoint)getPerspBaseOrigin;
//- (OPPoint)getPerspectiveOrigin;
- (OPPoint)getWorldStartPt;
//- (OPPoint)getPivotPt;

- (OPPoint)getDistanceFromShip;
- (bool)isSafeDistance;

- (int)getPerspId;
- (void)setPerspId:(int)pPerspId;

- (void)setNotInUse;

//- (GLuint)getPlanetTriFanVertexCnt ;
//- (GLuint)getPlanetTriStripVertexCnt;
//- (GLuint)getMoonTriFanVertexCnt ;
//- (GLuint)getMoonTriStripVertexCnt;

@end
