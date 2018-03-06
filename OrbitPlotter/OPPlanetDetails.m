//
//  OPPlanetDetails.m
//  OrbitPlotter
//
//  Created by John Kinn on 12/9/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OPPlanetDetails.h"

@implementation OPPlanetDetail

- (id)init:(NSString *)pOrbitalName theType:(PlanetType)pTheType maxDistance:(float)pMaxDistance minScaleFactor:(long)pMinScaleFactor maxScaleFactor:(long)pMaxScaleFactor maxMomentum:(float)pMaxMomentum isOrbital:(bool)pIsOrbital minNewTime:(float)pMinNewTime maxActive:(float)pMaxActive chanceOfNew:(float)pChanceOfNew lifeScope:(LifeScopeType)pLifeScope theFamily:(MovingCelestrialShape)pTheFamily {
    self = [super init];
    if (self) {
        self.orbitalName = pOrbitalName;
        self.theType = pTheType;
        self.maxDistance = pMaxDistance;
        self.minScaleFactor = pMinScaleFactor;
        self.maxScaleFactor = pMaxScaleFactor;
        self.maxMomentum = pMaxMomentum;
        self.isOrbital = pIsOrbital;
        self.minNewTime = pMinNewTime;
        self.maxActive = pMaxActive;
        self.chanceOfNew = pChanceOfNew;
        self.lifeScope = pLifeScope;
        self.theFamily = pTheFamily;
    }
    return self;
}

@end

@implementation OPPlanetDetails

@synthesize planetDetailArr;

static OPPlanetDetails * Instance;

- (id)init {
    self = [super init];
    if (self) {
        
        NSMutableArray * theArr = [NSMutableArray array];
        
        [OPPlanetDetails loadDetails:theArr];
        
        planetDetailArr = [NSArray arrayWithArray:theArr];
    }
    return self;
}

+ (OPPlanetDetails *)getSharedInstance {
    if (Instance == nil) {
        Instance = [[OPPlanetDetails alloc] init];
    }
    return Instance;
}

- (unsigned long)getNumDetails {
    return [planetDetailArr count];
}

- (OPPlanetDetail *)getDetail:(int)theIdx {
    return [planetDetailArr objectAtIndex:theIdx];
}

+ (void)loadDetails:(NSMutableArray *)theArr {
    
    NSString * theName = [NSString stringWithFormat:@"CelestrialDetails"];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:theName
                                                     ofType:@"txt"];
    
    if (path == nil)
        return;
    
    //NSLog(@"got it %@",path);
    
    // read everything from text
    NSString* fileContents =
    [NSString stringWithContentsOfFile:path
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:
                                [NSCharacterSet newlineCharacterSet]];
    
    //int xxCnt = 0;
    //int vectorCnt = 0;
    for (int xxx1=0; xxx1<[allLinedStrings count]; xxx1++) {
        
        // then break down even further
        NSString* strsInOneLine = [allLinedStrings objectAtIndex:xxx1];
        
        if ([strsInOneLine containsString:@"#"]) {
            continue;
        }
        
        // breakdow data seperated by comma
        NSArray* singleStrs = [strsInOneLine componentsSeparatedByCharactersInSet:
                               [NSCharacterSet characterSetWithCharactersInString:@","]];
        
        NSString * orbitalName = nil;
        PlanetType theType = PLANET;
        float maxDistance = 0;
        long minScaleFactor = 0;
        long maxScaleFactor = 0;
        float maxMomentum = 0;
        bool isOrbital = 0;
        float minNewTime = 0;
        float maxActive = 0;
        float chanceOfNew = 0;
        LifeScopeType lifeScope = PIVOTAL;
        MovingCelestrialShape theFamily = POLYGON;
        
        for (NSString * aStr in singleStrs) {
            
            NSArray* nameValue =
            [aStr componentsSeparatedByCharactersInSet:
             [NSCharacterSet characterSetWithCharactersInString:@":"]];
            
            if ([nameValue[0] isEqualToString:@"name"]) {
                orbitalName = [nameValue objectAtIndex:1];
                
                if ([orbitalName isEqualToString:@"PLANET"]) {
                    theType = PLANET;
                }
                else if ([orbitalName isEqualToString:@"ASTEROID"]) {
                    theType = ASTEROID;
                }
                else if ([orbitalName isEqualToString:@"SHIP_CELESTRIAL"]) {
                    theType = SHIP_CELESTRIAL;
                }
                else if ([orbitalName isEqualToString:@"MOON"]) {
                    theType = MOON;
                }
                else if ([orbitalName isEqualToString:@"SATELLITE"]) {
                    theType = SATELLITE;
                }
                else if ([orbitalName isEqualToString:@"SPACE_STATION"]) {
                    theType = SPACE_STATION;
                }
                else if ([orbitalName isEqualToString:@"PLASMA"]) {
                    theType = PLASMA;
                }
                else if ([orbitalName isEqualToString:@"STAR"]) {
                    theType = STAR;
                }
                else {
                    continue;
                }
            }
            else if ([nameValue[0] isEqualToString:@"maxDistance"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                maxDistance = [longStr intValue];
            }
            else if ([nameValue[0] isEqualToString:@"minScaleFactor"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                minScaleFactor = [longStr intValue];
            }
            else if ([nameValue[0] isEqualToString:@"maxScaleFactor"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                maxScaleFactor = [longStr intValue];
            }
            else if ([nameValue[0] isEqualToString:@"maxMomentum"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                maxMomentum = [longStr intValue];
            }
            else if ([nameValue[0] isEqualToString:@"isOrbital"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                if ([longStr isEqualToString:@"NO"]) {
                    isOrbital = NO;
                }
                else {
                    isOrbital = YES;
                }
            }
            else if ([nameValue[0] isEqualToString:@"minNewTime"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                minNewTime = [longStr intValue];
            }
            else if ([nameValue[0] isEqualToString:@"maxActive"]) {
                NSString * longVtxElementsStr = [nameValue objectAtIndex:1];
                maxActive = [longVtxElementsStr intValue];
            }
            else if ([nameValue[0] isEqualToString:@"chanceOfNew"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                chanceOfNew = [longStr intValue];
            }
            else if ([nameValue[0] isEqualToString:@"lifeScope"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                
                if ([longStr isEqualToString:@"PIVOTAL"]) {
                    lifeScope = PIVOTAL;
                }
                else if ([longStr isEqualToString:@"ABIDING"]) {
                    lifeScope = ABIDING;
                }
                else if ([longStr isEqualToString:@"TRANSITORY"]) {
                    lifeScope = TRANSITORY;
                }
                else {
                    continue;
                }
            }
            else if ([nameValue[0] isEqualToString:@"shape"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                
                if ([longStr isEqualToString:@"POLYGON"]) {
                    theFamily = POLYGON;
                }
                else if ([longStr isEqualToString:@"SPHERE"]) {
                    theFamily = SPHERE;
                }
                else if ([longStr isEqualToString:@"RING"]) {
                    theFamily = RING;
                }
                else if ([longStr isEqualToString:@"CONE"]) {
                    theFamily = CONE;
                }
                else {
                    continue;
                }
                
            }
            else {
                NSLog(@"No way %@", nameValue[0]);
            }
        }
        
        OPPlanetDetail * theDetail = [[OPPlanetDetail alloc] init:orbitalName theType:theType maxDistance:maxDistance minScaleFactor:minScaleFactor maxScaleFactor:maxScaleFactor maxMomentum:maxMomentum isOrbital:isOrbital minNewTime:minNewTime maxActive:maxActive chanceOfNew:chanceOfNew lifeScope:lifeScope theFamily:theFamily];
        
        [theArr addObject:theDetail];
    }
    
}

@end
