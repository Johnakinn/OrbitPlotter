//
//  OPOrbitBase.m
//  orbitPlotter3
//
//  Created by John Kinn on 8/1/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import "OPOrbitBase.h"
#import "OPPlanetManager.h"
#import "OPWall.h"
#import "OPVertexCreationUtils.h"

@interface OPOrbitBase() {
    int perspId;
    OPCelestrialDetail * theDetail;
    float oldEyeX, oldEyeY, oldEyeZ;
    float wallOldEyeX, wallOldEyeY, wallOldEyeZ;
    
    bool dontWithX, oneMoreX;
    //float udRotSpeed;
    int spiralPassX;
    
    bool dontWithY, oneMoreY;
    //float rlRotSpeed;
    int spiralPassY;
}

@end

@implementation OPOrbitBase

@synthesize lastOrbitDrawTime;
//@synthesize lastMomentumDrawTime;

@synthesize rotationDistX;
@synthesize rotationDistY;
@synthesize rotationDistZ;

@synthesize vertexArray;
@synthesize vertexBuffer;

@synthesize radius;
@synthesize theScale;

@synthesize effect;

@synthesize rotationSpeedX;
@synthesize rotationSpeedY;
@synthesize rotationSpeedZ;

@synthesize rotateAxis;

@synthesize origAnglePersX;
@synthesize origAnglePersY;
@synthesize origAnglePersZ;

@synthesize xAnglePers;
@synthesize yAnglePers;
@synthesize zAnglePers;

@synthesize offsetPt;

@synthesize orbitsAround;

@synthesize theId;

@synthesize xEye, yEye, zEye;
@synthesize wallXEye, wallYEye, wallZEye;
@synthesize xScreen, yScreen;

@synthesize typeId;

@synthesize vertexData;

@synthesize textureNum;

@synthesize worldStartPt;

- (id)init:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale perspHelper:(PerspectiveHelper *)pPerspHelper isStatic:(bool)pStatic perspId:(int)pPerspId textureType:(int)pTextureType  vertexData:(OPVertexData *)pVertexData {
    
    self = [super init];
    if (self) {
        
        self->perspHelper = pPerspHelper;
        self->theDetail = [[OPPlanetManager getSharedManager] getDetail:pTypeId];
        
        [self reset:pOrbitsAround id:pId typeId:pTypeId pRadius:pRadius offsetPt:pOffsetPt rotateAxis:pRotateAxis worldStartPt:pWorldStartPt rotateSpeed:rotateSpeed anglePersX:anglePersX anglePersY:anglePersY scale:pScale isStatic:pStatic perspId:pPerspId textureType:pTextureType vertexData:pVertexData];
        
        self.lastOrbitDrawTime = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

-(CGFloat)getXAnglePers {
    return xAnglePers;
}

-(void)reckonXAnglePers:(CGFloat)pXAnglePers {
    CGFloat theNewAngle = pXAnglePers;
    xAnglePers = theNewAngle;
}

-(CGFloat)getYAnglePers {
    return yAnglePers;
}

-(void)reckonYAnglePers:(CGFloat)pYAnglePers {
    //CGFloat theNewAngle = pYAnglePers;
    yAnglePers = pYAnglePers;
}

-(CGFloat)getZAnglePers {
    return zAnglePers;
}

-(void)reckonZAnglePers:(CGFloat)pZAnglePers {
    //CGFloat theNewAngle = pZAnglePers;
    zAnglePers = pZAnglePers;
}

- (void)setPerspId:(int)pPerspId {
    perspId = pPerspId;
}

- (int)getPerspId {
    if (orbitsAround != nil) {
        return [orbitsAround getPerspId];
    }
    return perspId;
}

- (OPPoint)getWorldStartPt {
    if (isStaticSpecial) {
        return (OPPoint){0,0,[perspHelper getBaseZCoord]};
        //return [perspHelper getBaseShipPosition];
    }
    if (orbitsAround != nil && ![orbitsAround isKindOfClass:[NSNull class]]) {
        return orbitsAround->worldStartPt;
    }
    return worldStartPt;
}

- (void)render {
    
    //bool useToTrack = false;
    
    float aspect = fabs([perspHelper screenWidth] / [perspHelper screenHeight]);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, self->theDetail.maxDistance*2);
    
    bool wantBlankTexture = false;
    bool wantFloorTexture = false;
    if ([self isKindOfClass:[OPWall class]]) {
        ((OPWall *)self)->playSound = false;

        ((OPWall *)self)->isBeingUsedForSled1 = false;
        ((OPWall *)self)->isBeingUsedForSled2 = false;
        
        if (((OPWall *)self)->isLowestInSegment) {
            wantFloorTexture = true;
        }
        
        int useTrackSegmentOffset = 10;
        if ( ((OPWall *)self).angleRotateSpeed > .04)
            useTrackSegmentOffset = 5;
        
        //NSLog(@"check %ld against %ld",((OPWall *)self)->wallSegmentNum, perspHelper.currWallSegment );
       
        if ( (((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + 5) ||
             (((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + 10)) {
            if ( ((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + useTrackSegmentOffset) {
                perspHelper.currWallFloorTrackIdx = ((OPWall *)self)->segmentFloorIdxNum;
                //NSLog(@"trackFlIdx = %ld %ld", perspHelper.currWallSegment, perspHelper.currWallFloorTrackIdx);
                //useToTrack = true;
            }
            if (((OPWall *)self)->isFloor) {
                wantBlankTexture = true;
                if (((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + 5)
                    ((OPWall *)self)->isBeingUsedForSled1 = true;
                if (((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + 10)
                    ((OPWall *)self)->isBeingUsedForSled2 = true;
            }
        }

    }
    
    GLKMatrix4 mainModelViewMatrix;
    
    if ((theDetail.textureType == NATURAL || theDetail.textureType == ARTIFICIAL)) {
        if (wantFloorTexture && !wantBlankTexture) {
            
            
            if ( ((((OPWall *)self)->wallSegmentNum == perspHelper.currWallSegment + 5))
                && ((OPWall *)self).obsticlePtr != nil
                ) {
                ((OPWall *)self)->playSound = true;
            }
            
            self.effect.texture2d0.name = perspHelper.textureFloorNum;
        }
        else if (wantBlankTexture) {
            self.effect.texture2d0.name = perspHelper.textureBlankNum;
        }
        else {
            self.effect.texture2d0.name = textureNum;
        }
//        if (wantTexture) {
//            if (useToTrack && ((OPWall *)self)->isFloor) {
//                self.effect.texture2d0.name = perspHelper.textureBlankNum;
//            }
//            else if (textureNum > 0) {
//                self.effect.texture2d0.name = textureNum;
//            }
//        }
//        else {
//            self.effect.texture2d0.name = perspHelper.textureFloorNum;
//        }
        [self.effect.texture2d0 setEnabled:true];
    }
    else {
        [self.effect.texture2d0 setEnabled:false];
    }
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    spiralPassX = 0;
    spiralPassY = 0;
    
    bool possibleSpiralX = false;
    bool possibleSpiralY = false;
    
    bool needsMoreTurnX = false;
    bool needsMoreTurnY = false;
    
    dontWithX = false;
    dontWithY = false;
    oneMoreX = false;
    oneMoreY = false;
    
    long theNumGo = 0;
 
    for (;;) {
        
        mainModelViewMatrix = GLKMatrix4Identity;
        
        // If we orbit around something else, and something else orbits around us, we need
        // to set worldStartPt, which we have been using from object we orbit around.
        //if (typeId == PLANET && orbitsAround != nil) {
        if (orbitsAround != nil && !isStaticHalo) {
            GLKMatrix4 modelViewMatrix22 = GLKMatrix4MakeTranslation(offsetPt.x, offsetPt.y, -offsetPt.z*.6);
            
            OPPoint wsp = [self getWorldStartPt];
            GLKMatrix4 modelViewMatrix24 = GLKMatrix4MakeTranslation(wsp.x, wsp.y, wsp.z);
            
            //        GLKMatrix4 modelViewMatrix23 = GLKMatrix4Rotate(modelViewMatrix24, rotationDist, (rotateAxis==ROTATE_AXIS_X), (rotateAxis==ROTATE_AXIS_Y), (rotateAxis==ROTATE_AXIS_Z));
            
            GLKMatrix4 modelViewMatrix23 = GLKMatrix4Identity;
            modelViewMatrix23 = GLKMatrix4Rotate(modelViewMatrix23, rotationDistX, 1, 0, 0);
            modelViewMatrix23 = GLKMatrix4Rotate(modelViewMatrix23, rotationDistY, 0, 1, 0);
            modelViewMatrix23 = GLKMatrix4Rotate(modelViewMatrix23, rotationDistZ, 0, 0, 1);
            
            modelViewMatrix23 = GLKMatrix4Multiply(modelViewMatrix23, modelViewMatrix24);
            
            //if (typeId == 0)
            //    NSLog(@"X: %.2f %.2f %.2f", localWorldStartPt.x, localWorldStartPt.y, localWorldStartPt.z);
            
            modelViewMatrix23 = GLKMatrix4Multiply(modelViewMatrix23, modelViewMatrix22);
            
            GLKVector4 coor2 = GLKVector4Make(0,0,0, 1);
            GLKVector4 eyeCoor2 = GLKMatrix4MultiplyVector4(modelViewMatrix23,coor2);
            
            worldStartPt = (OPPoint){eyeCoor2.x, eyeCoor2.y, eyeCoor2.z};
        }
        
        OPPoint localWorldStartPt = [self getDistanceFromShip];
        
        // Rotate around itself
        GLKMatrix4 rotateModelViewMatrix3 = GLKMatrix4Identity;
        rotateModelViewMatrix3 = GLKMatrix4Rotate(rotateModelViewMatrix3, origAnglePersZ, 0, 0, 1);
        rotateModelViewMatrix3 = GLKMatrix4Rotate(rotateModelViewMatrix3, origAnglePersX, 1, 0, 0);
        rotateModelViewMatrix3 = GLKMatrix4Rotate(rotateModelViewMatrix3, origAnglePersY, 0, 1, 0);
        
        // Start with the pivot pt
        //GLKMatrix4 pivotRotateModelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -1000);
        GLKMatrix4 pivotRotateModelViewMatrix = GLKMatrix4MakeTranslation([perspHelper getBaseXCoord],  [perspHelper getBaseYCoord], [perspHelper getBaseZCoord]);
        
        if (self.orbitsAround != nil && ![orbitsAround isKindOfClass:[NSNull class]]) {
            xAnglePers = [orbitsAround getXAnglePers];
            yAnglePers = [orbitsAround getYAnglePers];
            zAnglePers = [orbitsAround getZAnglePers];
        }
        
        //NSLog(@"A %d %.2f %.2f %.2f",theId, xAnglePers, yAnglePers, zAnglePers);
        
        // Rotate around central pivot point (the Ship) when turning due to user action.
        //if (!isStaticSpecial && orbitsAround != nil) {
        if (!isStaticSpecial) {
            pivotRotateModelViewMatrix = GLKMatrix4Rotate(pivotRotateModelViewMatrix, zAnglePers, 0, 0, 1);
            pivotRotateModelViewMatrix = GLKMatrix4Rotate(pivotRotateModelViewMatrix, xAnglePers, 1, 0, 0);
            pivotRotateModelViewMatrix = GLKMatrix4Rotate(pivotRotateModelViewMatrix, yAnglePers, 0, 1, 0);
        }
        
        // This is the point of the current object.
        GLKMatrix4 worldViewModelViewMatrix = GLKMatrix4MakeTranslation(localWorldStartPt.x, localWorldStartPt.y, localWorldStartPt.z);
        
        // now we rotate the current point around the center point.
        GLKMatrix4 worldWithPivotModelViewMatrix2 = GLKMatrix4Multiply(pivotRotateModelViewMatrix, worldViewModelViewMatrix);
        
        //GLKMatrix4 mainModelViewMatrix = worldWithPivotModelViewMatrix2;
        
        GLKMatrix4 orbitModelViewMatrix = GLKMatrix4Identity;
        if (rotateAxis != ROTATE_AXIS_NONE) { // && orbitsAround != nil) {
            //    if (rotateAxis != ROTATE_AXIS_NONE && orbitsAround != nil) {
            
            GLKMatrix4 modelViewMatrix22 = GLKMatrix4MakeTranslation(offsetPt.x, offsetPt.y, offsetPt.z);
            
            GLKMatrix4 modelViewMatrix23 = GLKMatrix4Identity;
            //GLKMatrix4 modelViewMatrix24 = GLKMatrix4Identity;
            //GLKMatrix4 modelViewMatrix25 = GLKMatrix4Identity;
            //GLKMatrix4 modelViewMatrix26 = GLKMatrix4Identity;
            if (!isNotOrbital) {
                
                //float useRotDist;
                if (rotateAxis & ROTATE_AXIS_X) {
                    modelViewMatrix23 = GLKMatrix4Rotate(worldViewModelViewMatrix, rotationDistX, 1,0,0);
                }
                else if (rotateAxis & ROTATE_AXIS_Y) {
                    modelViewMatrix23 = GLKMatrix4Rotate(worldViewModelViewMatrix, rotationDistY, 0,1,0);
                }
                else if (rotateAxis & ROTATE_AXIS_Z) {
                    modelViewMatrix23 = GLKMatrix4Rotate(worldViewModelViewMatrix, rotationDistZ, 0,0,1);
                }
                //modelViewMatrix23 = GLKMatrix4Rotate(worldViewModelViewMatrix, rotationDist, (rotateAxis==ROTATE_AXIS_X), (rotateAxis==ROTATE_AXIS_Y), (rotateAxis==ROTATE_AXIS_Z));
            }
            else {
                modelViewMatrix23 = GLKMatrix4Identity;
                modelViewMatrix23 = GLKMatrix4Multiply(modelViewMatrix23, modelViewMatrix22);
                
                //modelViewMatrix24 = GLKMatrix4Identity;
                //modelViewMatrix24 = GLKMatrix4Multiply(modelViewMatrix24, modelViewMatrix22);
                
                if (rotateAxis & ROTATE_AXIS_Z) {
                    modelViewMatrix23 = GLKMatrix4Rotate(modelViewMatrix23, rotationDistZ, 0, 0, 1);
                }
                if (rotateAxis & ROTATE_AXIS_X) {
                    modelViewMatrix23 = GLKMatrix4Rotate(modelViewMatrix23, rotationDistX, 1, 0, 0);
                }
                if (rotateAxis & ROTATE_AXIS_Y) {
                    modelViewMatrix23 = GLKMatrix4Rotate(modelViewMatrix23, rotationDistY, 0, 1, 0);
                }
                //modelViewMatrix23 = GLKMatrix4Rotate(modelViewMatrix22, rotationDist, (rotateAxis==ROTATE_AXIS_X), (rotateAxis==ROTATE_AXIS_Y), (rotateAxis==ROTATE_AXIS_Z));
            }
            orbitModelViewMatrix = GLKMatrix4Multiply(modelViewMatrix23, modelViewMatrix22);
            
            //modelViewMatrix25 = GLKMatrix4Multiply(modelViewMatrix23, modelViewMatrix22);
            //modelViewMatrix26 = GLKMatrix4Multiply(modelViewMatrix24, modelViewMatrix22);
            //orbitModelViewMatrix = GLKMatrix4Multiply(modelViewMatrix26, modelViewMatrix25);
        }
        
        //if (typeId == 0)
        //NSLog(@"%.2f %.2f %.2f", offsetPt.x, offsetPt.y, offsetPt.z);
        
        //wallMainModelViewMatrix = GLKMatrix4Multiply(mainModelViewMatrix, wallWorldWithPivotMVMatrix2);
        
        mainModelViewMatrix = GLKMatrix4Multiply(mainModelViewMatrix, worldWithPivotModelViewMatrix2);
        
        mainModelViewMatrix = GLKMatrix4Multiply(mainModelViewMatrix, orbitModelViewMatrix);
        
        mainModelViewMatrix = GLKMatrix4Multiply(mainModelViewMatrix, rotateModelViewMatrix3);
        
        if (theScale > 0) {
            mainModelViewMatrix = GLKMatrix4Scale(mainModelViewMatrix, theScale, theScale, theScale);
        }
        
        GLKVector4 coor;
        
        if (orbitsAround != nil) {
            OPPoint thePt = [self getLocalDistanceFromShip];
            coor = GLKVector4Make(thePt.x, thePt.y, thePt.z, 1);
        }
        else {
            coor = GLKVector4Make(localWorldStartPt.x, localWorldStartPt.y, localWorldStartPt.z, 1);
        }
        
        GLKVector4 eyeCoor = GLKMatrix4MultiplyVector4(worldWithPivotModelViewMatrix2, coor);
        
        oldEyeX = xEye;
        oldEyeY = yEye;
        oldEyeZ = zEye;
        
        xEye = eyeCoor.x - [perspHelper getBaseXCoord];
        yEye = eyeCoor.y - [perspHelper getBaseYCoord];
        zEye = eyeCoor.z - [perspHelper getBaseZCoord];
        
        if (useToTrack) { //} && ((OPWall *)self)->isFloor) {
            
            if (theNumGo !=  ((OPWall *)self)->segmentFloorIdxNum ) {
                theNumGo =  ((OPWall *)self)->segmentFloorIdxNum ;
                //NSLog(@"Tracking %d", ((OPWall *)self)->segmentFloorIdxNum );
            }
            
            OPPoint localWallWSP = [perspHelper getDistanceFromShip:((OPWall *)self).wallHallMiddlePt perspId:perspId];
            
            // This is the point in the center of the hall.
            GLKMatrix4 wallWorldViewMVMatrix = GLKMatrix4MakeTranslation(localWallWSP.x, localWallWSP.y, localWallWSP.z);
            
            // now we rotate the current point around the center point.
            GLKMatrix4 wallWorldWithPivotMVMatrix2 = GLKMatrix4Multiply(pivotRotateModelViewMatrix, wallWorldViewMVMatrix);
            
            GLKVector4 wallCenterCoor = GLKVector4Make(localWallWSP.x, localWallWSP.y, localWallWSP.z, 1);
            
            GLKVector4 wallEyeCoor = GLKMatrix4MultiplyVector4(wallWorldWithPivotMVMatrix2, wallCenterCoor);
            
            wallOldEyeX = wallXEye;
            wallOldEyeY = wallYEye;
            wallOldEyeZ = wallZEye;
            
            wallXEye = wallEyeCoor.x - [perspHelper getBaseXCoord];
            wallYEye = wallEyeCoor.y - [perspHelper getBaseYCoord];
            wallZEye = wallEyeCoor.z - [perspHelper getBaseZCoord];
            
            if (spiralPassX == 0) {
                //if (perspHelper.workingOnZone != ((OPWall *)self)->zoneNum) {
                //    perspHelper.zoneSetX = false;
                //    perspHelper.zoneSetY = false;
                //    perspHelper.workingOnZone = ((OPWall *)self)->zoneNum;
                //}
                perspHelper->floorRenderTot++;
                //NSLog(@"wrong: %d %d of %ld", perspHelper.wrongWayX1, perspHelper.wrongWayY, perspHelper->floorRenderTot);
            }
            
            //NSLog(@"Q %.2f %.2f %.2f %.2f", xEye, oldEyeX, yEye, oldEyeY);
            
            perspHelper->foundForwardWallObj = true;
            
            possibleSpiralX = false;
            possibleSpiralY = false;
            needsMoreTurnX = false;
            needsMoreTurnY = false;
            
            //possibleXCnt = 0;
            //possibleYCnt = 0;
            
            if (perspHelper.tryIt > 0) {
                //NSLog(@"eyeXY %.2f %.2f %.2f", xEye, yEye, zEye);
                perspHelper.tryIt--;
            }
            else {
                
                [self shapeDirection:true];
                //if (spiralPassX > 2)
                //    NSLog(@"XZ %.2f %.2f %d %d %d", wallOldEyeZ, wallZEye, dontWithX, oneMoreX, spiralPassX );
                [self shapeDirection:false];
                //if (dontWithX)
                //    NSLog(@"YZ %.2f %.2f %d %d %d", wallOldEyeZ, wallZEye, dontWithY, oneMoreY, spiralPassY );
                
                if (dontWithX && dontWithY) {
                    //NSLog(@"Z %.2f %.2f %.2f", xEye, yEye, zEye);
                    useToTrack = false;
                    break;
                }
                
            }
        }
        else {
            break;
        }
    }
    
    //if (wantBlankTexture)
    //    return;
    
    //if (spiralPassX > 2) {
    //    NSLog(@"S X %d %.2f %.2f", spiralPassX, wallXEye, wallZEye);
    //}
    
    //if (spiralPassY > 2) {
    //    NSLog(@"S Y %d %.2f %.2f", spiralPassY, wallYEye, wallZEye);
    //}
    
    self.effect.transform.modelviewMatrix = mainModelViewMatrix;
    
    int viewport[] = {0, 0, [perspHelper screenWidth], [perspHelper screenHeight]};
    
    GLKVector3 coorVec = GLKVector3Make(0, 0, 0);
    
    GLKVector3 windowVector = GLKMathProject(coorVec, mainModelViewMatrix, projectionMatrix, viewport);
    
    CGPoint p = CGPointMake(windowVector.x, windowVector.y);
    
    xScreen = p.x;
    //yScreen = perspHelper.boundsRect.size.height - p.y;
    yScreen = [perspHelper screenHeight] - p.y;
    
    // if (![self isKindOfClass:[OPWall class]] || !((OPWall *)self)->isFloor) {
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glBindVertexArrayOES(vertexArray);
    
    //if (typeId == 0)
    //    NSLog(@"w %.2f %.2f %.2f", worldStartPt.x, worldStartPt.y, worldStartPt.z);
    
    if (typeId == PLASMA) {
        glLineWidth(5);
        //glDrawArrays(GL_LINE_STRIP, 0, [self getVertexCnt:typeId planetSubType:subTypeIdx]);
        glDrawArrays(GL_LINE_STRIP, 0, vertexData.vertexCnt);
    }
    else {
        //glDrawArrays(GL_TRIANGLE_STRIP, 0, [self getVertexCnt:typeId planetSubType:subTypeIdx]);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexData.vertexCnt);
    }
    
    //if (self->theDetail.theFamily == SPHERE) {
    //    glBindVertexArrayOES(vertexArraySphere1);
    //
    //    glDrawArrays(GL_TRIANGLE_FAN, 0, [self getVertexCnt:typeId planetSubType:subTypeIdx vertexType:FAN]);
    //}
    
    glBindVertexArrayOES(0);
    
    //}
    
    return ; //mainModelViewMatrix;
}

- (void)shapeDirection:(bool)isX {
    
    float rotSpeed = 0;
    
    bool isDone = (isX ? dontWithX : dontWithY);
    
    int spiralPass = (isX ? spiralPassX : spiralPassY);
    
    if (spiralPass > 0 && wallOldEyeZ == wallZEye) {
        isDone = true;;
        if (isX) {
            dontWithX = true;
        }
        else {
            dontWithY = true;
        }
    }
    
    if ( !isDone && ( isX || dontWithX )) {
        
        float theCosZ = (cos(perspHelper.rotationZ));
        float wallEye = fabs(isX ? wallXEye : wallYEye); //*fabs(theCosZ);
        
        if (wallEye > 1) {
            
            //float eggMult = perspHelper.thrustVelocity;
            //(perspHelper.thrustVelocity*perspHelper.thrustAcceleration*perspHelper.thrustDirection) * .01;
            
            //if (eggMult <= 0) {
            //    if (isX)
            //        rotSpeed = 0;
            //}
            //else {
                
                // Maybe this should be different between x and y?
                float const useRally = 6000;
                
                //float at = ((absEye > useRally ? useRally : absEye)/useRally);
                
                //float a2 = 1 - at;
                
                //float a3 = useRally + (useRally * a2);
                
                float dd = useRally + (useRally * (1 - ((wallEye > useRally ? useRally : wallEye)/useRally)));
                
                //dd *= eggMult;
                
                //if (isX)
                    rotSpeed = wallEye/dd;
                //else
                //    rlRotSpeed = absEye/dd;
                
                //if (wallEye > (dd*100 || rotSpeed > .2))
                //    NSLog(@"Bad dd %.2f %.2f %.2f %.2f", dd, wallEye, useRally, rotSpeed);
                
                
                //NSLog(@"ud %.2f %.2f %.2f %.2f", ydd, absYeye, eggMult, udRotSpeed);
                
            //}
            
            if (spiralPass == 0) { //} && perspHelper.rlZone == TURN_NONE ) {
                if ((isX ? wallXEye : wallYEye) > 0) {
                    if (isX)
                        perspHelper.rlZone = TURN_RIGHT;
                    else
                        perspHelper.udZone = TURN_DOWN;
                }
                else {
                    if (isX)
                        perspHelper.rlZone = TURN_LEFT;
                    else
                        perspHelper.udZone = TURN_UP;
                }
                
                if (isX)
                    if (![perspHelper isUp]) {
                        perspHelper.rlZone = (perspHelper.rlZone == TURN_LEFT ? TURN_RIGHT : TURN_LEFT);
                    }
                
                if (theCosZ < 0) {
                    if (isX)
                        perspHelper.rlZone = (perspHelper.rlZone == TURN_LEFT ? TURN_RIGHT : TURN_LEFT);
                    else
                        perspHelper.udZone = perspHelper.udZone == TURN_UP ? TURN_DOWN : TURN_UP;
                }
            }
            
            //NSLog(@"Z %.2f %.2f", wallOldEyeZ, wallZEye);
            
            if (isX ? oneMoreX : oneMoreY) {
                if (isX) {
                    oneMoreX = false;
                    dontWithX = true;
                }
                else {
                    oneMoreY = false;
                    dontWithY = true;
                }
            }
            
            if (wallZEye > wallOldEyeZ  /* && rotSpeed > .01 */ && fabs(wallZEye-wallOldEyeZ) > .01) {
                
                if (isX)
                    perspHelper.rlZone = (perspHelper.rlZone == TURN_LEFT ? TURN_RIGHT : TURN_LEFT);
                else
                    perspHelper.udZone = perspHelper.udZone == TURN_UP ? TURN_DOWN : TURN_UP;
                
                if (spiralPass > 1) {
                    if (isX)
                        oneMoreX = true;
                    else
                        oneMoreY = true;
                }
            }
            else if (isX ? oneMoreX : oneMoreY) {
                //oneMore = false;
                if (isX)
                    dontWithX = true;
                else
                    dontWithY = true;
            }
            else if (fabs(wallZEye-wallOldEyeZ) < .01 && spiralPass > 0 ) {
                if (isX)
                    dontWithX = true;
                else
                    dontWithY = true;
            }
            
            //NSLog(@"w %@ %d %d %d", (isX ? @"X" : @"Y"), spiralPass, (isX ? dontWithX : dontWithY), (isX ? oneMoreX : oneMoreY));
            
            //changeX = true;
            
            if (!(isX ? dontWithX : dontWithY) || (isX ? oneMoreX : oneMoreY) ) {
                
                //[perspHelper rotateAction:(oneMoreX ? (perspHelper.rlZone == TURN_RIGHT ? TURN_LEFT : TURN_RIGHT) : perspHelper.rlZone) rotateSpeed:udRotSpeed];
                
                [perspHelper rotateAction:(isX ? perspHelper.rlZone : perspHelper.udZone) rotateSpeed:rotSpeed];
                
                [self update];
                
                if (isX)
                    spiralPassX++;
                else
                    spiralPassY++;
                
                //NSLog(@"LZ %.2f %.2f", wallOldEyeZ, wallZEye);
                
            }
        }
        else {
            if (isX) {
                dontWithX = true;
            }
            else {
                dontWithY = true;
            }
        }
    }
}

- (OPPoint)getDistanceFromShip {

    if (isStaticSpecial)
        return (OPPoint){0,0,0};
    
    return [perspHelper getDistanceFromShip:[self getWorldStartPt] perspId:perspId];
}

- (OPPoint)getLocalDistanceFromShip {
    
    if (isStaticSpecial)
        return (OPPoint){0,0,0};
    
    return [perspHelper getDistanceFromShip:worldStartPt perspId:perspId];
}

- (void)update {

    // if Orbits areound something or Rotates around itself.
    if (rotateAxis != ROTATE_AXIS_NONE && !isNotOrbital) { // && !isStaticHalo) {
    
        NSTimeInterval timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastOrbitDrawTime;
        
        if (timeSinceLastDraw > .1) {
            rotationDistX += rotationSpeedX * timeSinceLastDraw;
            rotationDistY += rotationSpeedY * timeSinceLastDraw;
            rotationDistZ += rotationSpeedZ * timeSinceLastDraw;
            lastOrbitDrawTime = [NSDate timeIntervalSinceReferenceDate];
        }
    }
    if (orbitsAround == nil) {
        [self reckonXAnglePers:perspHelper.rotationX];
        [self reckonYAnglePers:perspHelper.rotationY];
        [self reckonZAnglePers:[perspHelper getRotationZ]];
    }
}

- (bool)isSafeDistance {
    
    float mapBoundryUse = self->theDetail.maxDistance;
    
    OPPoint distanceFromShipPt = [self getDistanceFromShip];
    if (fabs(distanceFromShipPt.x) > mapBoundryUse || fabs(distanceFromShipPt.y) > mapBoundryUse || fabs(distanceFromShipPt.z) > mapBoundryUse) {
        return false;
    }
    return true;
}

- (bool)isSafeDistance2 {
    
    float mapBoundryUse = self->theDetail.maxDistance + mapBoundryFrontier;
    
    OPPoint distanceFromShipPt = [self getDistanceFromShip];
    if (fabs(distanceFromShipPt.x) > mapBoundryUse || fabs(distanceFromShipPt.y) > mapBoundryUse || fabs(distanceFromShipPt.z) > mapBoundryUse) {
        return false;
    }
    return true;
}

- (void)setNotInUse {
    inUse = false;
}

- (void)reset:(unsigned long)pId offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY textureType:(int)pTextureType {
    
    inUse = true;
    
    //passedMarker = false;

    xEye = yEye = zEye = MAX_CELESTRIAL_DISTANCE;
    wallXEye = wallYEye = wallZEye = MAX_CELESTRIAL_DISTANCE;
    
    oldEyeZ = oldEyeY = oldEyeX = 0;
    wallOldEyeX = wallOldEyeY = wallOldEyeZ = 0;
    
    yScreen = 0;
    
    self->isSelected = false;
    
    offsetPt = pOffsetPt;

    rotateAxis = pRotateAxis;
    
    //isHit = false;
    
    origAnglePersX = anglePersX;
    origAnglePersY = anglePersY;
    
    xAnglePers = 0;
    yAnglePers = 0;
    zAnglePers = 0;
    
    if (pId > 0) {
        theId = pId;
    }
    
    textureNum = pTextureType;
    
    worldStartPt = pWorldStartPt;
    
    origAnglePersZ = 0;
    
    self->isNotOrbital = false;
    
    // how far around has the rotation gotten, from 0 to 2 PI.
    float rotDist = ((float)(arc4random_uniform(100) * (float).01)) * TWOPIE;
    
    if (rotateAxis & ROTATE_AXIS_X) {
        rotationDistX = rotDist;
    } else if (rotateAxis & ROTATE_AXIS_Y) {
        rotationDistY = rotDist;
    } else if (rotateAxis & ROTATE_AXIS_Z) {
        rotationDistZ = rotDist;
    }
    
    if (![self isSafeDistance2]) {
        NSLog(@"Not safe distance... %.2f %.2f %.2f", worldStartPt.x, worldStartPt.y, worldStartPt.z);
    }
}

- (void)reset:(OPOrbitBase *)pOrbitsAround id:(unsigned long)pId typeId:(PlanetType)pTypeId pRadius:(CGFloat)pRadius offsetPt:(OPPoint)pOffsetPt rotateAxis:(int)pRotateAxis worldStartPt:(OPPoint)pWorldStartPt rotateSpeed:(CGFloat)rotateSpeed anglePersX:(CGFloat)anglePersX anglePersY:(CGFloat)anglePersY scale:(CGFloat)pScale isStatic:(bool)pStatic perspId:(int)pPerspId textureType:(int)pTextureType vertexData:(OPVertexData *)pVertexData {
    
    perspId = pPerspId;
    
    isStaticSpecial = pStatic;
    inUse = true;
    //hasBeenRendered = false;
    
    xEye = yEye = zEye = MAX_CELESTRIAL_DISTANCE;
    wallXEye = wallYEye = wallZEye = MAX_CELESTRIAL_DISTANCE;
    
    oldEyeZ = oldEyeY = oldEyeX = 0;
    wallOldEyeX = wallOldEyeY = wallOldEyeZ = 0;
    
    yScreen = 0;
    
    //theColor = 1;
    
    //subTypeId = NONE; //pSubTypeId;
    //subTypeIdx = pSubTypeIdx;
    
    //boundsRect = viewBounds;
    effect = perspHelper.effect;
    theScale = pScale;
    radius = pRadius;
    
    self->isSelected = false;
    
    offsetPt = pOffsetPt;
    rotateAxis = pRotateAxis;
    
    orbitsAround = (OPOrbitBase *)pOrbitsAround;
    
    origAnglePersX = anglePersX;
    //origAnglePersY = anglePersY;
    origAnglePersY = anglePersY;
    
    xAnglePers = 0; //anglePersX;
    yAnglePers = 0; //anglePersY;
    zAnglePers = 0;
    
    if (pId > 0) {
        theId = pId;
    }
    
    vertexData = pVertexData;
    
    textureNum = pTextureType;
    
    worldStartPt = pWorldStartPt;
    
    origAnglePersZ = 0;
    
    self->isNotOrbital = false;
    
    // how far around has the rotation gotten, from 0 to 2 PI.
    float rotDist = ((float)(arc4random_uniform(100) * (float).01)) * TWOPIE;
    
    if (rotateAxis & ROTATE_AXIS_X) {
        rotationDistX = rotDist;
        rotationSpeedX = rotateSpeed;
    } else if (rotateAxis & ROTATE_AXIS_Y) {
        rotationDistY = rotDist;
        rotationSpeedY = rotateSpeed;
    } else if (rotateAxis & ROTATE_AXIS_Z) {
        rotationDistZ = rotDist;
        rotationSpeedZ = rotateSpeed;
    }
    
    //pauseAction = false;
    typeId = pTypeId;
    
    if (![self isSafeDistance2]) {
        NSLog(@"Not safe distance... %.2f %.2f %.2f", worldStartPt.x, worldStartPt.y, worldStartPt.z);
        //NSLog(@"co %.2f %.2f %.2f",[perspHelper getShipXCoord:perspId],[perspHelper getShipYCoord:perspId],[perspHelper getShipZCoord:perspId]);
    }
}

@end
