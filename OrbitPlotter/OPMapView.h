//
//  OPMapView.h
//  orbitPlotter3
//
//  Created by John Kinn on 8/3/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sharedTypes.h"
#import "PerspectiveHelper.h"

@interface OPMapView : UIView

//@property NSArray * planetArr;

@property PerspectiveHelper *persHelper;

//@property CGFloat zCoord;
//@property CGFloat xCoord;
//@property CGFloat yCoord;

//@property int theQuadrant;

//@property CGFloat xCoordFromAngles;
//@property CGFloat yCoordFromAngles;

    //@property CGFloat rotAngleX;
//@property CGFloat rotAngleY;
    //@property CGFloat rotAngleY;

//@property int orientationUpOrDown;

//@property CGFloat xPersBase, yPersBase, zPersBase;

- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)toggleOrientation;
//+ (bool)isZero:(CGFloat)f1 f2:(CGFloat)f2;

- (void)toggleRotatePersp;

@end
