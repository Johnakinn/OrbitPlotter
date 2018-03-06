//
//  OPVertexCreationUtils.m
//  OrbitPlotter
//
//  Created by John Kinn on 12/29/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPVertexCreationUtils.h"

@implementation OPVertexCreationUtils

+ (int)produceRandomRotationAxis:(PlanetType)pPlanetType {
    
    int skipAxis = ROTATE_AXIS_NONE;
    if (pPlanetType == PLANET) {
        skipAxis = ROTATE_AXIS_Z;
    }
    if (pPlanetType == CONE)
        return ROTATE_AXIS_NONE;
    
    int retVal;
    do {
        int toChooseFrom = (skipAxis == ROTATE_AXIS_NONE ? 3 : 2);
        
        retVal = [OPVertexCreationUtils generateRandom:toChooseFrom]+1;
        
        if (skipAxis == ROTATE_AXIS_NONE) {
            break;;
        }
        
    } while (retVal == (int)skipAxis);
    
    switch(retVal) {
        case 0: return ROTATE_AXIS_NONE;
        case 1: return ROTATE_AXIS_X;
        case 2: return ROTATE_AXIS_Y;
        case 3: return ROTATE_AXIS_Z;
        default: return ROTATE_AXIS_NONE;
    }
}


// Returns 0 if no textures found else the number of textures loaded from files.
+ (int)getRandomTextureNum:(OPCelestrialDetail *)theDetail perspHelper:(PerspectiveHelper *)perspHelper {

    if (theDetail.theType == STAR)
        return STAR_TEXTURE_TYPE;
    
    //OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:typeId];
    
    int numTextures = 0;
    int lowerBound = 1;
    
    if (theDetail.textureType == NATURAL) {
        numTextures = perspHelper.numNaturalTextures;
    }
    else if (theDetail.textureType == ARTIFICIAL) {
        numTextures = perspHelper.numNaturalTextures+perspHelper.numArtificialTextures;
        lowerBound = perspHelper.numNaturalTextures;
    }
    
    if (numTextures == 0)
        return 0;
    
    return [OPVertexCreationUtils generateRandom:lowerBound upperBound:numTextures];
}


+ (OPPoint)produceRandomSatelliteDist:(float)theScale rotAxis:(int)rotAxis distFactor:(int)distFactor {
    
    int lowerBound = -theScale*distFactor;
    //int upperBound = theScale*distFactor;
    
    int rndValue1 = lowerBound + [OPVertexCreationUtils generateRandom:2*(theScale*distFactor)];
    int rndValue2 = lowerBound + [OPVertexCreationUtils generateRandom:2*(theScale*distFactor)];
    //int rndValue2 =[OPPlanetFactory generateRandom:lowerBound upperBound:upperBound];
    int rndValue3 =[OPVertexCreationUtils generateRandom:-50 upperBound:50];
    
    //int rndValue1 = lowerBound + arc4random_uniform(upperBound - lowerBound);
    //int rndValue2 = lowerBound + arc4random_uniform(upperBound - lowerBound);
    
    //int lowerBound1 = 50;
    //int upperBound1 = 80;
    //int rndRange1 = lowerBound1 + arc4random_uniform(upperBound1 - lowerBound1);
    //int rndRange1 = [OPPlanetFactory generateRandom:lowerBound upperBound:upperBound];
    
    switch((int)rotAxis) {
        case ROTATE_AXIS_X:
            //return (OPPoint){rndRange1, rndValue2+multiDist, rndValue1};
            return (OPPoint){rndValue3, rndValue2, rndValue1};
        case ROTATE_AXIS_Y:
            //return (OPPoint){rndValue1+multiDist, rndRange1, rndValue2};
            return (OPPoint){rndValue1, rndValue3, rndValue2};
        case ROTATE_AXIS_Z:
            //return (OPPoint){rndValue1+multiDist, rndValue2, rndRange1};
            return (OPPoint){rndValue1, rndValue2, rndValue3};
    }
    return (OPPoint){rndValue3, rndValue3, rndValue3};
}


+ (OPPoint)getNewMomentum:(OPCelestrialDetail *)vertexTypeDetail {
    
    //OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:typeId];
    
    float maxMomentum = vertexTypeDetail.maxMomentum;
    
    if (is_debug || maxMomentum == 0)
        return (OPPoint){0,0,0};
    
    int xMomentumRand = [OPVertexCreationUtils generateRandom:-maxMomentum upperBound:maxMomentum];
    int yMomentumRand = [OPVertexCreationUtils generateRandom:-maxMomentum upperBound:maxMomentum];
    int zMomentumRand = [OPVertexCreationUtils generateRandom:-maxMomentum upperBound:maxMomentum];
    
    //int xMomentumRand = -maxMomentum + arc4random_uniform(maxMomentum+maxMomentum);
    //int yMomentumRand = -maxMomentum + arc4random_uniform(maxMomentum+maxMomentum);
    //int zMomentumRand = -maxMomentum + arc4random_uniform(maxMomentum+maxMomentum);
    
    return (OPPoint){xMomentumRand,yMomentumRand,zMomentumRand};
}


+ (float)newSatRotateSpeed:(int)typeId {
    
    if (typeId == SHIP_CELESTRIAL)
        return HALFPIE;
    else {
        
        int lowerBound2 = 5;
        int upperBound2 = 70;
        
        int theSpeed = [OPVertexCreationUtils generateRandom:lowerBound2 upperBound:upperBound2];
        
        
        //int theSpeed = lowerBound2 + arc4random_uniform(upperBound2 - lowerBound2);
        return (float)theSpeed / 100;
    }
}

+ (int)getNewScaleFactor:(PlanetType)theType vertexDetail:(OPCelestrialDetail *)vertexDetail {
    
    return [OPVertexCreationUtils generateRandom:(unsigned int)vertexDetail.minScaleFactor upperBound:(unsigned int)(vertexDetail.maxScaleFactor)];
}

+ (int)generateRandom:(int)lowerBound upperBound:(int)upperBound {
    int retVal = lowerBound + arc4random_uniform((upperBound-lowerBound)+1);
    if (retVal < lowerBound || retVal > upperBound) {
        NSLog(@"Invalid Bounded Random;");
        return lowerBound;
    }
    return retVal;
}

+ (int)generateRandom:(int)upperBound {
    int retVal = arc4random_uniform(upperBound);
    if (retVal > upperBound || retVal < 0) {
        NSLog(@"Invalid Random;");
        return 0;
    }
    return retVal;
}

+ (float)genNewDiv10:(int)bound {
    return ((float)arc4random_uniform(bound))/(float)100.0;
}

@end
