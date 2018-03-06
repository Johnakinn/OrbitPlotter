//
//  MomentumCircleManager.m
//  OrbitPlotter
//
//  Created by John Kinn on 10/29/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MomentumCircleManager.h"
#import "sharedTypes.h"
//#import "OPSatellite.h"
#import "OPPlanet.h"
//#import "OPRing.h"

static const float DEFAULT_EQUALIZER = 10.0;

@interface MomentumCircleManager() {
    Boolean readyForNextCircle;
    int currCircle;
    float equalizerValue;
    float curEqualizerVal;
}

@end

@implementation MomentumCircleManager

//@synthesize numThrustCircles;

@synthesize circleArr;

-(id)init {
    self = [super init];
    if (self) {
        self.circleArr = [NSMutableArray array];
        //self.numThrustCircles = 0;
        self->readyForNextCircle = true;
        self->currCircle = 0;
        self->equalizerValue = 0;
        self->curEqualizerVal = DEFAULT_EQUALIZER;
    }
    return self;
}

- (int)getNextCircle {
    if (curEqualizerVal > 0) {
        curEqualizerVal--;
    }
    else {
        curEqualizerVal = DEFAULT_EQUALIZER - fabs(equalizerValue);
    
        if (equalizerValue < 0)
            return [self getNextCircleNeg];
        else
            return [self getNextCirclePos];
    }
    return currCircle;
}

- (int)getNextCirclePos {
    if (currCircle+1 >= [self.circleArr count])
        currCircle = 0;
    else
        currCircle++;
    return currCircle;
}

- (int)getNextCircleNeg {
    if (currCircle-1 < 0)
        currCircle = (int)[self.circleArr count]-1;
    else
        currCircle--;
    return currCircle;
}

- (void)setEqualizerValue:(float)pValue {
    equalizerValue = pValue;
    curEqualizerVal = DEFAULT_EQUALIZER - fabs(equalizerValue);
}

- (int)getCurrCircle {
    return currCircle;
}

//- (void)incCircleDistance {
    
    //static const float CIRC_START_DIST = 300;
    //static const float CIRC_MAX_DIST = 400;
    
//    NSUInteger xx = [self.circleArr count];
    
//    if (xx == 0)
//        return;
    
//    return;
    
//    NSUInteger stepLen = CIRC_MAX_DIST / xx;
//    
//    bool processedOne = false;
//    for (int x=0; x<xx; x++) {
//        OPOrbitBase * thePlanet = [self.circleArr objectAtIndex:x];
//        
//        if (!thePlanet->inUse)
//            continue;
//        
//        [thePlanet update];
//        
//        int circPos = thePlanet.circlePosition;
//        
//        processedOne = true;
//        
//        if ((circPos > 0 || readyForNextCircle == true) && circPos <= CIRC_MAX_DIST) {
//            [(OPRing *)thePlanet incCircleDistance];
//            
//            if (circPos > stepLen || circPos == 0)
//                readyForNextCircle = true;
//            else
//                readyForNextCircle = false;
//            
//        }
//        else {
//            readyForNextCircle = false;
//        }
//        
//        //NSLog(@"oh %f", thePlanet.circlePosition);
//    }
//    //if (!processedOne)
//    //    readyForNextCircle = true;
//    
    
//}




@end
