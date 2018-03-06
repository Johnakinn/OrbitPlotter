//
//  OPMapView.m
//  orbitPlotter3
//
//  Created by John Kinn on 8/3/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

#import "OPMapView.h"
#import "OPPlanet.h"
#import "OPPlanetController.h"
#import "OPPlanetManager.h"

static const float mapViewMultFactor = 2;

@interface OPMapView() {
    //long xx;
    float mapOffsetX;
    float mapOffsetY;
    int togglePerpAngle;
    UIColor* aColorR1;
    UIColor* aColorR2;
    
    UIColor* aColorV3;
    UIColor* aColorV4;
    
    float viewCenterX;
    float viewCenterY;
    
    CGContextRef context; // = UIGraphicsGetCurrentContext();
    
    OPPoint shipPt;
    
    struct CGColor * theColor1;
    
    float toEdge;
    float circWt;
    float circLeft;
    float circTop;
    float circBottom;
    float circCenterPtLeft;
    float circCenterPtTop;
    
    CGRect aRect;
}

@end

@implementation OPMapView
@synthesize persHelper;

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        self->mapOffsetX = 10;
        self->mapOffsetY = 10;
        self->togglePerpAngle = 0;
        
        self->aColorR1 = [UIColor colorWithRed:.9 green:.4 blue:.6 alpha:1];
        self->aColorR2 = [UIColor colorWithRed:.1 green:.0 blue:.9 alpha:1];
        
        self->aColorV3 = [UIColor colorWithRed:.1 green:.9 blue:.0 alpha:1];
        self->aColorV4 = [UIColor colorWithRed:.0 green:.5 blue:.2 alpha:1];
        
        self->viewCenterX = mapOffsetX+((self.frame.size.width-mapOffsetX)/2);
        self->viewCenterY = self.frame.size.height/2;
        
        self->theColor1 = [UIColor greenColor].CGColor;
        
        self->toEdge = 5;
        self->circWt = 20;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    //float viewCenterX = mapOffsetX+((self.frame.size.width-mapOffsetX)/2);
    //float viewCenterY = self.frame.size.height/2;
    
    context = UIGraphicsGetCurrentContext();
    
    //struct CGColor * theColor1 = [UIColor greenColor].CGColor;
    
    CGContextSetFillColorWithColor(context, theColor1);

//    shipPt = [persHelper getShipPosition:persHelper.currPerspId];
    
    // TODO make sure this is working.
//    CGFloat ddX = shipPt.x/40, ddY = shipPt.y/40;
//    CGRect aRect33 = CGRectMake( viewCenterX+(ddX)-2 , viewCenterY+(ddY)-2 , 4, 4);
    
//    CGContextFillRect(context, aRect33);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    CGContextFillPath(context);
    
    CGContextMoveToPoint(context, mapOffsetX, 0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, viewCenterX , viewCenterY);
    CGContextAddLineToPoint(context, self.frame.size.width , 0);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, mapOffsetX, 0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, mapOffsetX, self.frame.size.height-mapOffsetY);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, mapOffsetX, self.frame.size.height-mapOffsetY);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height-mapOffsetY);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, mapOffsetX,  viewCenterY);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, 0,  viewCenterY);
    CGContextStrokePath(context);
    
    [self drawSkyObjects:(CGContextRef)context viewCenterX:viewCenterX viewCenterY:viewCenterY];
    
    CGContextMoveToPoint(context, viewCenterX,  viewCenterY);
    
    if ([persHelper isFacingForward])
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    else
        CGContextSetStrokeColorWithColor(context, [UIColor magentaColor].CGColor);
    
    CGContextAddLineToPoint(context, viewCenterX+(persHelper.ptBasedOnAngles2.x*(viewCenterX-mapOffsetX))-2,  viewCenterY+(persHelper.ptBasedOnAngles2.y*viewCenterY)-2);
    CGContextStrokePath(context);
    
    // ------------ Draw Context Indicator
//    float toEdge = 5;
//    float circWt = 20;
    circLeft = self.frame.size.width - (circWt+toEdge);
//    float circTop;
    circBottom = (self.frame.size.height-mapOffsetY)-toEdge;
    circCenterPtLeft = circLeft + circWt/2;
//    float circCenterPtTop;
    
//    CGRect aRect;
    
    if (self->togglePerpAngle) {
        circTop = circBottom - circWt;
        circCenterPtTop = circTop + circWt/2;
        
        aRect = CGRectMake( circLeft , circTop , circWt, circBottom-circTop);
        circCenterPtTop = circTop + circWt/2;
    }
    else {
        circTop = circBottom - (circWt / 2);
        circCenterPtTop = circTop - circWt/2;
        
        aRect = CGRectMake( circLeft , circTop , circWt, circBottom-circTop);
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddEllipseInRect(context, aRect);
    
    
    CGContextMoveToPoint(context, circCenterPtLeft,  circCenterPtTop);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, circLeft,  circTop + ((circBottom-circTop)/2));
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, circCenterPtLeft,  circCenterPtTop);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, circLeft+circWt,  circTop + ((circBottom-circTop)/2));
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, circCenterPtLeft,  circCenterPtTop);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, circCenterPtLeft,  circTop );
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, circCenterPtLeft,  circCenterPtTop);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, circCenterPtLeft,  circBottom );
    CGContextStrokePath(context);
    
    // ------------
    
    CGContextSetLineWidth(context, 2.0);
    
    CGFloat YScr = viewCenterY + (viewCenterY * sin(persHelper.rotationY));
    CGFloat XScr = viewCenterX + (viewCenterX * sin(persHelper.rotationX));
    
    CGContextMoveToPoint(context, mapOffsetX,  YScr);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, 0,  YScr);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, XScr,  self.frame.size.height-mapOffsetY);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddLineToPoint(context, XScr,  self.frame.size.height);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);

    CGContextSetLineWidth(context, 2); // .2
    
    // Set the stroke color
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    // Set the line width
    CGContextSetLineWidth(context, 1);
    
    // Set the fill color (if you are filling the circle)
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGContextMoveToPoint(context, 50, 50);

    CGPoint contextCenter = CGPointMake(60, 50);
    CGContextTranslateCTM(context, contextCenter.x, contextCenter.y);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    //[path addArcWithCenter:(CGPoint){0,0} radius:20 startAngle:0 endAngle:0 clockwise:true];
    CGContextSetLineWidth(context, 5); // set the line width
    CGContextSetRGBStrokeColor(context, 255, 255, 255, 1.0);
}

- (void)drawSkyObjects:(CGContextRef)context viewCenterX:(float)viewCenterX  viewCenterY:(float)viewCenterY {
    
    for (int y=0; y<NumCelestrialLifeScopeTypes; y++) {
        
        //for (int pTypeIdx=0; pTypeIdx<NUM_PLANET_TYPES; pTypeIdx++) {
            
        //    OPCelesrtialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetailByIdx:pTypeIdx];
        
        //OPCelesrtialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetailByIdx:y]; not right
        
        //if (theDetail == nil)
        //    break;
        
        if (y == TRANSITORY)
            continue;
        
        for (int x=0; x<[[OPPlanetController getSharedController] getNumCelestrials:y]; x++) {
        
            OPOrbitBase * aPlanet = [[OPPlanetController getSharedController] getCelestrial:y arrIdx:x];
            [self drawSkyObject:(CGContextRef)context viewCenterX:viewCenterX viewCenterY:viewCenterY aPlanet:aPlanet];
        
        }
    }
}

- (void)drawSkyObject:(CGContextRef)context viewCenterX:(float)viewCenterX  viewCenterY:(float)viewCenterY aPlanet:(OPOrbitBase *)aPlanet  {
    
    if (!aPlanet->inUse)
        return;
    
    float xCoo = 0;
    float yCoo = 0;
    
    struct CGColor * theColor = nil;
    
//    if (aPlanet.zEye > 0)
//    {
        
        if (aPlanet.typeId == STAR)
            theColor = aColorR2.CGColor;
        else if (aPlanet.typeId == SHIP_CELESTRIAL)
            theColor = aColorR1.CGColor;
        else if (aPlanet.typeId == SPACE_STATION)
            theColor = aColorV3.CGColor;
        else
            theColor = aColorV4.CGColor;
//    }
//    else {
//        if (aPlanet.typeId == STAR)
//            theColor = aColorV4.CGColor;
//        else
//            theColor = aColorV3.CGColor;
//    }
    
    CGContextSetFillColorWithColor(context, theColor);
    
    //if (aPlanet.theId > 10 && aPlanet.theId < 20) {
    //    NSLog(@"xy %.2f %.2f", aPlanet.xEye, aPlanet.yEye);
    //}
    
    xCoo =  aPlanet.xEye;
    if (self->togglePerpAngle) {
        yCoo =  -aPlanet.yEye;
    }
    else {
        yCoo =  aPlanet.zEye;
    }
    
    // *12 is good
    if (xCoo > 1 || xCoo < -1)
        xCoo /= (MAX_CELESTRIAL_DISTANCE*mapViewMultFactor); //(mapBoundry+400);
    else
        xCoo = 0.0f;
    
    if (yCoo > 1 || yCoo < -1) {
        if (self->togglePerpAngle) {
            yCoo /= (MAX_CELESTRIAL_DISTANCE*mapViewMultFactor);//(mapBoundry+400);
        }
        else {
            yCoo /= (MAX_CELESTRIAL_DISTANCE*mapViewMultFactor);
        }
    }
    else {
        yCoo = 0.0f;
    }
    
    //NSLog(@"Scr: %.2f %.2f", xCoo, yCoo);
    
    CGRect aRect = CGRectMake( viewCenterX+(xCoo*(viewCenterX-mapOffsetX))-2 , viewCenterY+(yCoo*viewCenterY)-2 , 4, 4);
    
    CGContextFillRect(context, aRect);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
}

- (void)toggleRotatePersp {
    togglePerpAngle = togglePerpAngle == 1 ? 0 : 1;
}

@end
