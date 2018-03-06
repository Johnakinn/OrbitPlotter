//
//  OPOverlayView.m
//  OrbitPlotter
//
//  Created by John Kinn on 2/20/18.
//  Copyright © 2018 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPOverlayView.h"

static const float TIME_TO_STRIKE = .5;
//static const int numConsecutiveShots = 5;

@interface OPOverlayView() {
    NSTimeInterval timeSinceFired[MAX_CONSEC_SHOTS];
    Boolean shotFired[MAX_CONSEC_SHOTS];
    //Boolean shotDetonated[numConsecutiveShots];
    
    CGContextRef context;
    
    struct CGColor * theColor1;
    struct CGColor * theColor2;
}

@end

@implementation OPOverlayView

@synthesize persHelper;

@synthesize needsUpd;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self->theColor1 = [UIColor greenColor].CGColor;
        self->theColor2 = [UIColor whiteColor].CGColor;
        self->needsUpd = false;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    context = UIGraphicsGetCurrentContext();

    float midX = [persHelper screenWidth] / 2 ;
    float midY = [persHelper screenHeight] / 2 ;
    
    //float bulletX = midX + persHelper->bulletXOffset;
    //float bulletY = midY + persHelper->bulletYOffset;
    
    float bulletX = persHelper->bulletXOffset;
    float bulletY = persHelper->bulletYOffset;
    
    if (persHelper->bulletXOffset < 0) {
        bulletX = [persHelper screenWidth] / 2 ;
    }
    
    if (persHelper->bulletYOffset < 0) {
        bulletY = [persHelper screenHeight] / 2 ;
    }
    
    float siteX1, siteX2, siteY1, siteY2;
    
    float const siteWidth = 20;
    float siteLineWd;
    
    if (persHelper.perspectType == LOOKING_AT) {
        siteLineWd = 1;
        
        siteX1 = (bulletX)-siteWidth;
        siteX2 = (bulletX)+siteWidth;
        
        siteY1 = (bulletY)-siteWidth;
        siteY2 = (bulletY)+siteWidth;
    }
    else {
        siteLineWd = .5;
        
        siteX1 = 0;
        siteX2 = [persHelper screenWidth];
        
        siteY1 = 0;
        siteY2 = [persHelper screenHeight];
        
        //NSLog(@"wh %.2f %.2f", siteX2, siteY2);
    }
    
    // Set the circle outerline-width
    CGContextSetLineWidth(context, siteLineWd);
    
    CGContextSetStrokeColorWithColor(context, theColor1);
    
    if (persHelper.perspectType == LOOKING_AT) {
        CGContextAddArc(context, (bulletX), (bulletY), siteWidth, 0, 2*PIE, false);
    }
        
    CGContextMoveToPoint(context, siteX1,  bulletY);
    CGContextAddLineToPoint(context, siteX2,  bulletY);
    
    //NSLog(@"fr1: %.2f %.2f to: %.2f %.2f",siteX1, bulletY, siteX2, bulletY);

    //CGContextDrawPath(context, kCGPathStroke);
    //CGContextStrokePath(context);
    
    // Set the circle outerline-width
    //CGContextSetLineWidth(context, 5);
    
    CGContextMoveToPoint(context, bulletX,  siteY1);
    CGContextAddLineToPoint(context, bulletX,  siteY2);
    
    //NSLog(@"fr2: %.2f %.2f to: %.2f %.2f %.2f",bulletX, siteY1, bulletX, siteY2, self.bounds.size.height);
    
    CGContextDrawPath(context, kCGPathStroke);
    CGContextStrokePath(context);

    CGContextSetFillColorWithColor(context, theColor2);
    
    for (int x=0; x<MAX_CONSEC_SHOTS; x++) {
        
        if (shotFired[x]) {
            // It detonated at the target
            float timeSinceShot = [NSDate timeIntervalSinceReferenceDate] - timeSinceFired[x];
            float pctOfTime = timeSinceShot / TIME_TO_STRIKE;
            if (timeSinceShot >= TIME_TO_STRIKE) {
                //shotDetonated[x] = true;
                shotFired[x] = false;
                if (![self isShotFired]) {
                    persHelper->bulletXOffset = -1;
                    persHelper->bulletYOffset = -1;
                    needsUpd = true;
                }
            }
            else {
                // It's heading for it's target
                
                // It gets smaller as it reaches it's target
                float shotRadius = 2 + ( 30 * (1-pctOfTime) );
                
                // Shot is fired from the outer edge and works it's way to the middle
                float shotX = (bulletX) * pctOfTime;
                float shot2X = (midX*2) - (((midX*2)-bulletX) * pctOfTime);
                
                // Shot is fired from the bottom and works it's way to the middle;
                float shotY =  (midY*2) -  (((midY*2)-bulletY) * pctOfTime);
                //((midY*2)-(bulletY) * pctOfTime);
                
                //NSLog(@"y %.2f %.2f %.2f", timeSinceShot, shotY, pctOfTime);

                CGContextAddArc(context, shotX, shotY, shotRadius, 0, 2*PIE, false);
                CGContextDrawPath(context, kCGPathFillStroke);
                CGContextStrokePath(context);
                
                CGContextAddArc(context, shot2X, shotY, shotRadius, 0, 2*PIE, true);
                CGContextDrawPath(context, kCGPathFillStroke);
                CGContextStrokePath(context);
            }
        }
    }
    
    UIGraphicsEndImageContext();
    
}

- (void)redrawIfNeeded {
    if ([self isShotFired] || needsUpd) {
        needsUpd = false;
        [self setNeedsDisplay];
    }
    return;
}

- (bool)isShotFired {
    for (int x=0; x<MAX_CONSEC_SHOTS; x++) {
        if (shotFired[x]) {
            return true;
        }
    }
    return false;
}

- (void)fireShot {
    for (int x=0; x<MAX_CONSEC_SHOTS; x++) {
        if (!shotFired[x]) {
            shotFired[x] = true;
            timeSinceFired[x] = [NSDate timeIntervalSinceReferenceDate];
            break;
        }
    }
}
    
@end
