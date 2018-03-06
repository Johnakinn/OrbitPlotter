//
//  MomentumCircleManager.h
//  OrbitPlotter
//
//  Created by John Kinn on 10/29/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef MomentumCircleManager_h
#define MomentumCircleManager_h

@interface MomentumCircleManager : NSObject

//@property int numThrustCircles;

@property NSMutableArray * circleArr;

//- (void)incCircleDistance;

- (int)getNextCircle;
- (int)getCurrCircle;

- (void)setEqualizerValue:(float)pValue;

@end

#endif /* MomentumCircleManager_h */
