//
//  OPOverlayView.h
//  OrbitPlotter
//
//  Created by John Kinn on 2/20/18.
//  Copyright © 2018 John Kinn. All rights reserved.
//

#ifndef OPOverlayView_h
#define OPOverlayView_h

#import <UIKit/UIKit.h>
#import "sharedTypes.h"
#import "PerspectiveHelper.h"

@interface OPOverlayView : UIView

//@property NSArray * planetArr;

@property PerspectiveHelper *persHelper;

@property Boolean needsUpd;

//@property float firedPct;

//@property NSTimeInterval timeSinceFired;

- (void)fireShot;
- (bool)isShotFired;

- (void)redrawIfNeeded;

@end


#endif /* OPOverlayView_h */
