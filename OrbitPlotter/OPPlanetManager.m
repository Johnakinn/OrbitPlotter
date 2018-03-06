//
//  OPPlanetManager.m
//  orbitPlotter3
//
//  Created by John Kinn on 8/24/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

#import "OPPlanetManager.h"
#import "OPVertexData.h"

//#import "OPPlanetDetails.h"

@implementation OPPlanetManager

//@synthesize orbitalArr;

//@synthesize celestrialDetailArr;
@synthesize celestrialDetailDic;

static OPPlanetManager * sharedPlanetManager;

- (id)init {
    if (sharedPlanetManager == nil) {
        self = [super init];
        if (self) {
            sharedPlanetManager = self;
            
            //NSMutableArray * theArr = [NSMutableArray array];
            
            NSMutableDictionary * theDic = [NSMutableDictionary dictionaryWithCapacity:12];
            
            //celestrialDetailDic = [NSMutableDictionary dictionaryWithCapacity:12];
            
            [OPPlanetManager loadDetails:theDic];
            
            celestrialDetailDic = [NSDictionary dictionaryWithDictionary:theDic];
            
            //celestrialDetailArr = [NSArray arrayWithArray:(NSArray *)theArr];
            
            //[OPPlanetManager loadDetails:celestrialDetailArr];
            
            //self.orbitalArr = [NSMutableArray arrayWithCapacity:NUM_PLANET_TYPES];
            //for (int x=0; x<NUM_PLANET_TYPES; x++) {
            //    [self.orbitalArr addObject:[NSMutableArray array]];
            //}
            [self loadShapesFromDataFiles];
        }
    }
    return sharedPlanetManager;
}

+ (OPPlanetManager *)getSharedManager {
    if (sharedPlanetManager == nil) {
        sharedPlanetManager = [[OPPlanetManager alloc] init];
    }
    return sharedPlanetManager;
}

+ (void)loadDetails:(NSMutableDictionary *)theDic {
    
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
        TextureType textureType = UNSPECIFIED;
        
        int addFieldsNum = 0;
        
        for (NSString * aStr in singleStrs) {
            
            if (aStr == nil || [aStr isEqualToString:@""]) {
                continue;
            }
            
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
                else if ([orbitalName isEqualToString:@"PLASMA"]) {
                    theType = PLASMA;
                }
                else if ([orbitalName isEqualToString:@"STAR"]) {
                    theType = STAR;
                }
                else if ([orbitalName isEqualToString:@"SPACE_STATION"]) {
                    theType = SPACE_STATION;
                }
                else if ([orbitalName isEqualToString:@"WALL"]) {
                    theType = WALL;
                }
                else {
                    NSLog(@"ERROR: unloaded celestrial detail record...");
                    continue;
                }
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"maxDistance"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                if ([@"MAX_CELESTRIAL_DISTANCE" isEqualToString:longStr]) {
                    maxDistance = 100000;
                }
                else if ([@"MAX_ASTERIOD_DISTANCE" isEqualToString:longStr]) {
                    maxDistance = 16000;
                }
                else {
                    maxDistance = [longStr intValue];
                }
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"minScaleFactor"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                minScaleFactor = [longStr intValue];
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"maxScaleFactor"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                maxScaleFactor = [longStr intValue];
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"maxMomentum"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                maxMomentum = [longStr intValue];
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"isOrbital"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                if ([longStr isEqualToString:@"NO"]) {
                    isOrbital = NO;
                }
                else {
                    isOrbital = YES;
                }
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"minNewTime"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                minNewTime = [longStr intValue];
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"maxActive"]) {
                NSString * longVtxElementsStr = [nameValue objectAtIndex:1];
                maxActive = [longVtxElementsStr intValue];
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"chanceOfNew"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                chanceOfNew = [longStr intValue];
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"textureType"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                
                if ([longStr isEqualToString:@"NATURAL"]) {
                    textureType = NATURAL;
                }
                else if ([longStr isEqualToString:@"ARTIFICIAL"]) {
                    textureType = ARTIFICIAL;
                }
                // else default is already set to UNSPECIFIED...
                addFieldsNum++;
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
                addFieldsNum++;
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
                    theFamily = RING;
                }
                else {
                    continue;
                }
                addFieldsNum++;
            }
            else {
                NSLog(@"No way %@ %@", nameValue[0], orbitalName);
                break;
            }
        }
        
        if (addFieldsNum == 12) {
            //NSLog(@"Adding: %@", orbitalName);
            OPCelestrialDetail * theDetail = [[OPCelestrialDetail alloc] init:orbitalName theType:theType maxDistance:maxDistance minScaleFactor:minScaleFactor maxScaleFactor:maxScaleFactor maxMomentum:maxMomentum isOrbital:isOrbital minNewTime:minNewTime maxActive:maxActive chanceOfNew:chanceOfNew lifeScope:lifeScope theFamily:theFamily textureType:textureType];
        
            [theDic setObject:theDetail forKey:[NSNumber numberWithInt:theDetail.theType]];
            
            //[theArr addObject:theDetail];
        }
        //else {
        //    NSLog(@"Error");
        //}
    }
    
}

- (void)loadShapesFromDataFiles {
    
    int filePrdicateNum = 1;
    for (;;) {
        
        NSString * theName = [NSString stringWithFormat:@"OrbitalVertices%d",filePrdicateNum];
        
        NSString* path = [[NSBundle mainBundle] pathForResource:theName ofType:@"txt"];
        
        if (path == nil)
            break;
        
        //NSLog(@"got it %@",path);
        
        // read everything from text
        NSString* fileContents =
        [NSString stringWithContentsOfFile:path
                                  encoding:NSUTF8StringEncoding error:nil];
        
        // first, separate by new line
        NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:
         [NSCharacterSet newlineCharacterSet]];
        
        if (allLinedStrings == nil)
            continue;
        
        
        // then break down even further
        NSString* strsInOneLine = [allLinedStrings objectAtIndex:0];
        
        // breakdow data seperated by comma
        NSArray* singleStrs = [strsInOneLine componentsSeparatedByCharactersInSet:
         [NSCharacterSet characterSetWithCharactersInString:@","]];
        
        int numColorVertices = 0;
        int numVertices = 0;
        //int numVertices2 = 0;
        int numVertexElements = 0;
        int collisionRange = 10;
        int repairAbility = 0;
        //int textureNameId = 0;
        //int orbitalType = -1;
        NSString * subTypeStr1;
        //NSString * figureStr;
        MovingCelestrialShape theFamily = POLYGON;
        NSString * nameStr;
        NSString * figureStr;
        //NSString * scopeStr;
        //char * typeName = nil;
        
        OPCelestrialDetail * theDetail = nil;
        
        for (NSString * aStr in singleStrs) {
            
            NSArray* nameValue =
            [aStr componentsSeparatedByCharactersInSet:
             [NSCharacterSet characterSetWithCharactersInString:@":"]];
            
            if (nameValue == nil)
                break;
            
            //NSLog(@"Name: %@ Value: %@", nameValue[0], nameValue[1]);
            
            if ([nameValue[0] isEqualToString:@"name"]) {
                nameStr = [nameValue objectAtIndex:1];
                
                theDetail = [self getDetailFromStr:nameStr];
                
                //if ([nameStr isEqualToString:@"SHIP_CELESTRIAL"]) {
                //    NSLog(@"Here %d",theDetail.theFamily);
                //}
                
                
                if (theDetail == nil)
                    break;
                
//                for (int xx=0; xx<NUM_PLANET_TYPES; xx++) {
//
//                    [[OPPlanetDetails getSharedInstance] getDetail:xx];
//
//                    typeName = (char *)theTypeDetails[xx].orbitalName;
//
//                    if ([nameStr isEqualToString:[NSString stringWithFormat:@"%s",typeName]]) {
//                        orbitalType = xx;
//                        break;
//                    }
//                }
            }
            if ([nameValue[0] isEqualToString:@"vertices"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                numVertices = [longStr intValue];
            }
            //if ([nameValue[0] isEqualToString:@"vertices2"]) {
                //NSString * longStr = [nameValue objectAtIndex:1];
                //numVertices2 = [longStr intValue];
            //}
            if ([nameValue[0] isEqualToString:@"colorVertices"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                numColorVertices = [longStr intValue];
            }
            if ([nameValue[0] isEqualToString:@"vertexElements"]) {
                NSString * longVtxElementsStr = [nameValue objectAtIndex:1];
                numVertexElements = [longVtxElementsStr intValue];
            }
            if ([nameValue[0] isEqualToString:@"subtype"]) {
                subTypeStr1 = [nameValue objectAtIndex:1];
            }
            if ([nameValue[0] isEqualToString:@"figure"]) {
                figureStr = [nameValue objectAtIndex:1];
                
                if ([figureStr isEqualToString:@"POLYGON"]) {
                    theFamily = POLYGON;
                }
                else if ([figureStr isEqualToString:@"SPHERE"]) {
                    theFamily = SPHERE;
                }
                else if ([figureStr isEqualToString:@"RING"]) {
                    theFamily = RING;
                }
                else if ([figureStr isEqualToString:@"CONE"]) {
                    theFamily = CONE;
                }
                else {
                    continue;
                }
            }
            if ([nameValue[0] isEqualToString:@"collisionRange"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                collisionRange = [longStr intValue];
            }
            if ([nameValue[0] isEqualToString:@"repairAbility"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                repairAbility = [longStr intValue];
            }
        }
        
        if (theDetail == nil)
            break;
        
        bool useColorBuffer = false;
        GLfloat * vertexBuffer = nil;
        GLfloat * colorBuffer = nil;
        
        //GLfloat * planetColors = nil;
        
        //if ((numColorVertices*numVertexElements) > 0) {
        //    planetColors = malloc(sizeof(GLfloat)*numColorVertices*numVertexElements);
        //}
        
        GLfloat planetColors[numColorVertices*numVertexElements];
        
        //MovingCelestrialShape celestrialShape = theTypeDetails[orbitalType].theFamily;
        
        if (theFamily == POLYGON) {
        //if ([figureStr isEqualToString:@"POLYGON"]) {
            if (numVertices > 0 && numVertexElements > 0) {
                int bufSize = numVertices * numVertexElements;
                vertexBuffer = malloc(bufSize * sizeof(GLfloat));
            }
            else {
                NSLog(@"No verteces?");
                continue;
            }
            //NSLog(@"S: %@ %d %d %@", nameStr, numVertices, numVertexElements, subTypeStr1);
        }
        else {
            colorBuffer = planetColors;
            useColorBuffer = true;
            //NSLog(@"N: %@ %@ %@ %@", nameStr, figureStr, scopeStr, subTypeStr1);
        }
        
        //NSLog(@"EE %d %d", numColorVertices, numVertexElements);
        
        //char * theSubType = malloc([subTypeStr1 length]*sizeof(char));
        //theSubType = (char *)[subTypeStr UTF8String];
        
        int xxCnt = 0;
        int vectorCnt = 0;
        for (int xxx1=1; xxx1<[allLinedStrings count]; xxx1++) {
            
            // then break down even further
            NSString* dataLine =
            [allLinedStrings objectAtIndex:xxx1];
            
            if (dataLine != nil && [dataLine containsString:@"#"]) {
                continue;
            }
            
            // choose whatever input identity you have decided. in this case ;
            NSArray* dataLineElements =
            [dataLine componentsSeparatedByCharactersInSet:
             [NSCharacterSet characterSetWithCharactersInString:@","]];
            
            if ([dataLineElements count] < numVertexElements)
                continue;
            
            vectorCnt++;
            
            NSString * dataPt;
            
            for (int triCnt=0; triCnt<numVertexElements; triCnt++) {
                dataPt = [dataLineElements objectAtIndex:triCnt];
                
                if (useColorBuffer) {
                    colorBuffer[xxCnt++] = [dataPt floatValue];
                }
                else
                {
                    vertexBuffer[xxCnt++] = [dataPt floatValue];
                    //if ([subTypeStr1 isEqualToString:@"SATELLITE2"]) {
                        //NSLog(@"Num: %f", [dataPt floatValue]);
                    //}
                }
            }
        }
        
        if (vectorCnt != numVertices && vectorCnt != numColorVertices) {
            NSLog(@"Incorrect # vertices: %@ - %d : %d", subTypeStr1, vectorCnt, numVertices);
        }
        //else {
        //    NSLog(@"# vertices: %d - %d : %d", numColorVertices, vectorCnt, numVertices);
        //}
        
        if (theFamily == RING) {
            [self setupRing:1 theColors:colorBuffer numVertices:numVertices subTypeStr:subTypeStr1 detail:theDetail collisionRange:collisionRange repairAbility:repairAbility];
        }
        else if (theFamily == CONE) {
            
            if ([subTypeStr1 isEqualToString:@"CONE1"]) {
                [self setupCone1:numVertices subTypeStr:@"CONE1" detail:theDetail collisionRange:collisionRange repairAbility:repairAbility];
            }
            else if ([subTypeStr1 isEqualToString:@"CONE2"])  {
                [self setupSpheroid3:numVertices theColors:colorBuffer subTypeStr:subTypeStr1 detail:theDetail collisionRange:collisionRange repairAbility:repairAbility];
            }
            else {
                [self setupCone:numVertices theColors:colorBuffer subTypeStr:subTypeStr1 detail:theDetail collisionRange:collisionRange repairAbility:repairAbility];
            }
            
            //[self setupCone:1 theColors:colorBuffer numVertices:numVertices subTypeStr:subTypeStr1 detail:theDetail];
        }
        else if (theFamily == SPHERE) {
            //PlanetType theType = PLANET;
            //if ([nameStr isEqualToString:@"STAR"]) {
            //    theType = STAR;
            //} else if ([nameStr isEqualToString:@"MOON"]) {
            //    theType = MOON;
            //}
            
            [self setupSpheroid2:numVertices theColors:colorBuffer subTypeStr:subTypeStr1 detail:theDetail collisionRange:collisionRange repairAbility:repairAbility];
            
            //[self getSolidSphere:1 detail:theDetail theColors:colorBuffer numVertices:numVertices numVertices2:numVertices2 subTypeStr:subTypeStr1 textureId:textureNameId];
        }
        else {
            
            OPVertexData * vertexData = [[OPVertexData alloc] init:numVertices vertexData:(GLfloat *)vertexBuffer typeName:nameStr subTypeName:subTypeStr1 collisionRange:collisionRange repairAbility:repairAbility];
            
            //VertexStruct vertextStructData = {numVertices,0,(GLfloat *)vertexBuffer,nil,(char *)typeName, theSubType};
            
            //NSLog(@"SubType %d %@", numVertices, subTypeStr1);
        
            //NSMutableArray * theArr = [orbitalArr objectAtIndex:orbitalType];
        
            [theDetail.vertexArr addObject:vertexData];
            //[theDetail.vertexDic setObject:vertexData forKey:nameStr];
            
            //[theArr addObject:[NSValue valueWithBytes:&vertextStructData objCType:@encode(VertexStruct)]];
            
            //[theArr addObject:vertexData];
        }
            
        filePrdicateNum++;
    }
}

- (OPCelestrialDetail *)getDetailByIdx:(int)theIdx {
    
    //NSArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:celestrialTypeIdx];
    
    NSArray *keys = [celestrialDetailDic allKeys];
    
    if (keys == nil)
        return nil;
    
    if ([keys count] <= theIdx)
        return nil;
    
    return [celestrialDetailDic objectForKey:keys[theIdx]];
    
    //return [celestrialDetailArr objectAtIndex:theIdx];
}

- (OPCelestrialDetail *)getDetailFromStr:(NSString *)typeNameStr {
    
    NSArray *keys = [celestrialDetailDic allValues];
    
    for (OPCelestrialDetail * aDetail in keys) {
        if ([aDetail.orbitalName isEqualToString:typeNameStr]) {
            return aDetail;
        }
    }
    return nil;
}

- (OPCelestrialDetail *)getDetail:(PlanetType)typeName {
    return [celestrialDetailDic objectForKey:[NSNumber numberWithInt:typeName]];
}

- (unsigned int)getNumSubTypes:(PlanetType)pType {

    OPCelestrialDetail * theDetail = [celestrialDetailDic objectForKey:[NSNumber numberWithInt:pType]];
    if (theDetail == nil)
        return 0;
    return [self getNumberSubTypes:theDetail];    
}

- (unsigned int)getNumberSubTypes:(OPCelestrialDetail *)detail {
    
    NSArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:celestrialTypeIdx];
    
    if (theArr == nil)
        return 0;
    
    return (unsigned int)[theArr count];
}

//- (void *)getVertices:(PlanetType)pType planetSubType:(int)pPlanetSubType {
//
//    NSMutableArray * theArr;
//    //NSValue * theValue;
//    //VertexStruct p;
//    OPVertexData * vertexData;
//    unsigned int numSubTypes = 0;
//
//    //theArr = [orbitalArr objectAtIndex:planetType];
//    OPCelesrtialDetail * detail = [celestrialDetailDic objectForKey:[NSNumber numberWithInt:pType]];
//    numSubTypes = [self getNumberSubTypes:detail];
//    theArr = detail.vertexArr;
//
//    if (theArr != nil && numSubTypes >= pPlanetSubType+1) {
//
//        vertexData = [theArr objectAtIndex:pPlanetSubType];
//
//        //[theValue getValue:&p];
//
//        //if (vertexType == FAN) {
//            //return (void *)p.vertexDataAux;
//        //    return vertexData.vertexDataAux;
//        //}
//        //else {
//            //NSLog(@"Getting vertext Ptr %s", p.subType);
//            //return (void *)p.vertexData;
//            return vertexData.vertexData;
//        //}
//    }
//
//    NSLog(@"This is a problem vertex !!!!");
//    return nil;
//}

- (OPVertexData *)getVertexDataFromSubtype:(PlanetType)pType planetSubType:(NSString *)pPlanetSubType {
    NSArray * theArr;
    
    OPCelestrialDetail * detail = [celestrialDetailDic objectForKey:[NSNumber numberWithInt:pType]];
    unsigned int numSubTypes = [self getNumberSubTypes:detail];
    
    if (numSubTypes <= 0)
        return nil;
    
    theArr = detail.vertexArr;
    
    OPVertexData * theData = nil;
    for (int x=0; x<numSubTypes; x++) {
        theData = detail.vertexArr[x];
        if ([theData.subTypeName isEqualToString:pPlanetSubType]) {
            return [theArr objectAtIndex:x];
        }
    }
    return nil;
}

- (OPVertexData *)getVertexData:(PlanetType)pType planetSubType:(int)pPlanetSubType {
    NSArray * theArr;
    
    OPCelestrialDetail * detail = [celestrialDetailDic objectForKey:[NSNumber numberWithInt:pType]];
    unsigned int numSubTypes = [self getNumberSubTypes:detail];
    theArr = detail.vertexArr;
    
    if (theArr != nil && numSubTypes >= pPlanetSubType+1) {
        return [theArr objectAtIndex:pPlanetSubType];
    }
    return nil;
}

//- (GLuint)getVertexCnt:(PlanetType)pType planetSubType:(int)pPlanetSubType {
//
//    NSArray * theArr;
//    //NSValue * theValue;
//    //VertexStruct p;
//    OPVertexData * vertexData;
//    unsigned int numSubTypes = 0;
//
//    OPCelesrtialDetail * detail = [celestrialDetailDic objectForKey:[NSNumber numberWithInt:pType]];
//    numSubTypes = [self getNumberSubTypes:detail];
//    theArr = detail.vertexArr;
//
//    if (theArr != nil && numSubTypes >= pPlanetSubType+1) {
//
//        vertexData = [theArr objectAtIndex:pPlanetSubType];
//
//        //[theValue getValue:&p];
//
//        //if (vertexType == FAN) {
//            //NSLog(@"Getting AuxVtx cnt %s %d", p.subType, p.vertexAuxCnt);
//            //return p.vertexAuxCnt;
//        //    return vertexData.vertexAuxCnt;
//        //}
//        //else {
//            //NSLog(@"Getting vertext cnt %s %d", p.subType, p.vertexCnt);
//            //return p.vertexCnt;
//            return vertexData.vertexCnt;
//        //}
//    }
//    NSLog(@"This is a problem vertex cnt!!!!");
//    return 0;
//}

//- (unsigned int)getSubTypeIdx:(OPCelesrtialDetail *)detail planetSubTypeStr:(NSString *)pPlanetSubTypeStr {
//    
//    NSMutableArray * theArr;
//    //NSValue * theValue;
//    //VertexStruct p;
//    OPVertexData * vertexData;
//    unsigned int numSubTypes = 0;
//    
//    //theArr = [orbitalArr objectAtIndex:planetType];
//    numSubTypes = [self getNumberSubTypes:detail];
//    theArr = detail.vertexArr;
//    
//    for (int x=0; x<numSubTypes; x++) {
//        
//        vertexData = [theArr objectAtIndex:x];
//        
//        //[theValue getValue:&p];
//        
//        //if (strcmp([pPlanetSubTypeStr UTF8String], p.subTypeName)==0)
//        
//        if ([vertexData.subTypeName isEqualToString:pPlanetSubTypeStr])
//            return x;
//    }
//    NSLog(@"This is a problem vertex cnt!!!!");
//    return 0;
//}

- (void)setupCone1:(int)numVertices subTypeStr:(NSString *)subTypeStr detail:(OPCelestrialDetail *)detail collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {
    
    int numBands = 8;
    int numVer = 12;
    int numVertsPVert = 6;
    
    Vertex3D * coneVertices = malloc((numVer) * (numBands-1) * numVertsPVert * sizeof(Vertex3D));
    
    //NSLog(@"cone %d", (numVer) * (numBands-1) * numVertsPVert);
    
    NSMutableArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:CONE];
    
    OPVertexData * vertexData = [[OPVertexData alloc] init:(numVer * (numBands-1) * numVertsPVert) vertexData:(GLfloat *)coneVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr collisionRange:pCollisionRange repairAbility:pRepairAbility];
    
    [theArr addObject:vertexData];
    
    float stepAroundCircle = (TWOPIE / numVer);
    
    float stepHalfCircle = (M_PI / (numBands));
    
    float ack = 1/(float)numBands;
    
    float iUse = 0;
    
    int x=0;
    
    float okHold[3];
    
    float widthOffset = 1;
    
    float yUse = ack;
    
    for (int y=1; y<numBands; y++) {
        
        okHold[0] = ( (cos(stepHalfCircle * (yUse))));
        okHold[1] =  ( (cos(stepHalfCircle * (yUse+ack))));
        okHold[2] =  ( (cos(stepHalfCircle * (yUse-ack))));
        
        //okHold[0] = ((numBands * cos(stepHalfCircle * (y))));
        //okHold[1] =  ((numBands * cos(stepHalfCircle * (y+1))));
        //okHold[2] =  ((numBands * cos(stepHalfCircle * (y-1))));
        
        for(int i=0; i < (numVer); i++) {
            
            if (y % 2 == 0) {
                iUse = (i);
            }
            else {
                iUse = (i)+1;
            }
            
            //NSLog(@"v:%d %.2f %.2f",i,yUse, (yUse * cos(iUse * stepAroundCircle)));
            
            //coneVertices[x].x = coneVertices[x+3].x = (y * cos(iUse * stepAroundCircle));
            //coneVertices[x].y = coneVertices[x+3].y = (y * sin(iUse * stepAroundCircle));
            coneVertices[x].x = coneVertices[x+3].x = (yUse * cos(iUse * stepAroundCircle));
            coneVertices[x].y = coneVertices[x+3].y = (yUse * sin(iUse * stepAroundCircle));
            coneVertices[x].z = coneVertices[x+3].z = okHold[0]*widthOffset;
            
            coneVertices[x].textX = coneVertices[x+3].textX = 0;
            coneVertices[x].textY = coneVertices[x+3].textY = 0;
            
            if (y == numBands-1) {
                coneVertices[x+1].x = (0 * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = (0 * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1]*widthOffset;
            }
            else {
                coneVertices[x+1].x = ((yUse+stepHalfCircle) * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = ((yUse+stepHalfCircle) * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1]*widthOffset;
            }
            
            coneVertices[x+1].textX = 1;
            coneVertices[x+1].textY = 0;
            
            coneVertices[x+2].x = coneVertices[x+5].x = (yUse * cos((iUse+2) * stepAroundCircle));
            coneVertices[x+2].y = coneVertices[x+5].y = (yUse * sin((iUse+2) * stepAroundCircle));
            coneVertices[x+2].z = coneVertices[x+5].z = okHold[0]*widthOffset;
            
            //coneVertices[x+2].x = coneVertices[x+5].x = (y * cos((iUse+2) * stepAroundCircle));
            //coneVertices[x+2].y = coneVertices[x+5].y = (y * sin((iUse+2) * stepAroundCircle));
            //coneVertices[x+2].z = coneVertices[x+5].z = okHold[0];
            
            coneVertices[x+2].textX = coneVertices[x+5].textX = 1;
            coneVertices[x+2].textY = coneVertices[x+5].textY = 1;
            
            coneVertices[x+4].x = ((yUse-stepHalfCircle) * cos((iUse+1) * stepAroundCircle));
            coneVertices[x+4].y = ((yUse-stepHalfCircle) * sin((iUse+1) * stepAroundCircle));
            coneVertices[x+4].z = okHold[2]*widthOffset;
            
            //coneVertices[x+4].x = ((y-1)  * cos((iUse+1) * stepAroundCircle));
            //coneVertices[x+4].y = ((y-1)  * sin((iUse+1) * stepAroundCircle));
            //coneVertices[x+4].z = okHold[2];
            
            coneVertices[x+4].textX = 0;
            coneVertices[x+4].textY = 1;
            
            for (int xx=0; xx<numVertsPVert; xx++) {
                
                if (i % 2 == 0) {
                    coneVertices[x+xx].r = 1.0; //.4;
                    coneVertices[x+xx].g = 1.0; //.5;
                    coneVertices[x+xx].b = 1.0; //.6;
                    coneVertices[x+xx].alpha = 1;
                    coneVertices[x+xx].normX = 0; //aVec.x;
                    coneVertices[x+xx].normY = 1; //aVec.y;
                    coneVertices[x+xx].normZ = 0; //aVec.z;
                }
                else {
                    coneVertices[x+xx].r = 1.0; //.4;
                    coneVertices[x+xx].g = 1.0; //.5;
                    coneVertices[x+xx].b = 1.0; //.6;
                    coneVertices[x+xx].alpha = 1;
                    coneVertices[x+xx].normX = 1; //aVec.x;
                    coneVertices[x+xx].normY = 0; //aVec.y;
                    coneVertices[x+xx].normZ = 0; //aVec.z;
                }
            }
            x+=numVertsPVert;
        }
        yUse+=ack;
    }
}


- (void)setupFlower:(int)numVertices subTypeStr:(NSString *)subTypeStr detail:(OPCelestrialDetail *)detail collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {
    
    int numBands = 8;
    int numVer = 12;
    int numVertsPVert = 6;
    
    Vertex3D * coneVertices = malloc((numVer) * (numBands-1) * numVertsPVert * sizeof(Vertex3D));
    
    //NSLog(@"cone %d", (numVer) * (numBands-1) * numVertsPVert);
    
    NSMutableArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:CONE];
    
    OPVertexData * vertexData = [[OPVertexData alloc] init:(numVer * (numBands-1) * numVertsPVert) vertexData:(GLfloat *)coneVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr collisionRange:pCollisionRange repairAbility:pRepairAbility];
    
    [theArr addObject:vertexData];
    
    float stepAroundCircle = (TWOPIE / numVer);
    
    float stepHalfCircle = (M_PI / (numBands));
    
    float ack = 1/(float)numBands;
    
    float iUse = 0;
    
    int x=0;
    
    float okHold[3];
    
    float widthOffset = 1;
    
    float yUse = 0;
    
    for (int y=1; y<numBands; y++) {
    
        okHold[0] = (yUse * (cos(stepHalfCircle * (y))));
        okHold[1] =  (yUse * (cos(stepHalfCircle * (y+1))));
        okHold[2] =  (yUse * (cos(stepHalfCircle * (y-1))));
        
        //okHold[0] = ((numBands * cos(stepHalfCircle * (y))));
        //okHold[1] =  ((numBands * cos(stepHalfCircle * (y+1))));
        //okHold[2] =  ((numBands * cos(stepHalfCircle * (y-1))));
        
        for(int i=0; i < (numVer); i++) {
            
            if (y % 2 == 0) {
                iUse = (i);
            }
            else {
                iUse = (i)+1;
            }
            
            //NSLog(@"v:%d %.2f %.2f",i,yUse, (yUse * cos(iUse * stepAroundCircle)));
            
            //coneVertices[x].x = coneVertices[x+3].x = (y * cos(iUse * stepAroundCircle));
            //coneVertices[x].y = coneVertices[x+3].y = (y * sin(iUse * stepAroundCircle));
            coneVertices[x].x = coneVertices[x+3].x = (yUse * cos(iUse * stepAroundCircle));
            coneVertices[x].y = coneVertices[x+3].y = (yUse * sin(iUse * stepAroundCircle));
            coneVertices[x].z = coneVertices[x+3].z = okHold[0]*widthOffset;
            
            coneVertices[x].textX = coneVertices[x+3].textX = 0;
            coneVertices[x].textY = coneVertices[x+3].textY = 0;
            
            if (y == numBands-1) {
                coneVertices[x+1].x = (0 * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = (0 * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1]*widthOffset;
            }
            else {

                coneVertices[x+1].x = ((yUse+stepHalfCircle) * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = ((yUse+stepHalfCircle) * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1]*widthOffset;
                
                //coneVertices[x+1].x = ((y+1) * cos((iUse+1) * stepAroundCircle));
                //coneVertices[x+1].y = ((y+1) * sin((iUse+1) * stepAroundCircle));
                //coneVertices[x+1].z = okHold[1];
                
            }
                
            coneVertices[x+1].textX = 1;
            coneVertices[x+1].textY = 0;
            
            coneVertices[x+2].x = coneVertices[x+5].x = (yUse * cos((iUse+2) * stepAroundCircle));
            coneVertices[x+2].y = coneVertices[x+5].y = (yUse * sin((iUse+2) * stepAroundCircle));
            coneVertices[x+2].z = coneVertices[x+5].z = okHold[0]*widthOffset;
            
            //coneVertices[x+2].x = coneVertices[x+5].x = (y * cos((iUse+2) * stepAroundCircle));
            //coneVertices[x+2].y = coneVertices[x+5].y = (y * sin((iUse+2) * stepAroundCircle));
            //coneVertices[x+2].z = coneVertices[x+5].z = okHold[0];
            
            coneVertices[x+2].textX = coneVertices[x+5].textX = 1;
            coneVertices[x+2].textY = coneVertices[x+5].textY = 1;

            coneVertices[x+4].x = ((yUse-stepHalfCircle) * cos((iUse+1) * stepAroundCircle));
            coneVertices[x+4].y = ((yUse-stepHalfCircle) * sin((iUse+1) * stepAroundCircle));
            coneVertices[x+4].z = okHold[2]*widthOffset;
            
            //coneVertices[x+4].x = ((y-1)  * cos((iUse+1) * stepAroundCircle));
            //coneVertices[x+4].y = ((y-1)  * sin((iUse+1) * stepAroundCircle));
            //coneVertices[x+4].z = okHold[2];
            
            coneVertices[x+4].textX = 0;
            coneVertices[x+4].textY = 1;
            
            for (int xx=0; xx<numVertsPVert; xx++) {
                
                if (i % 2 == 0) {
                    coneVertices[x+xx].r = 1.0; //.4;
                    coneVertices[x+xx].g = 1.0; //.5;
                    coneVertices[x+xx].b = 1.0; //.6;
                    coneVertices[x+xx].alpha = 1;
                    coneVertices[x+xx].normX = 0; //aVec.x;
                    coneVertices[x+xx].normY = 1; //aVec.y;
                    coneVertices[x+xx].normZ = 0; //aVec.z;
                }
                else {
                    coneVertices[x+xx].r = 1.0; //.4;
                    coneVertices[x+xx].g = 1.0; //.5;
                    coneVertices[x+xx].b = 1.0; //.6;
                    coneVertices[x+xx].alpha = 1;
                    coneVertices[x+xx].normX = 1; //aVec.x;
                    coneVertices[x+xx].normY = 0; //aVec.y;
                    coneVertices[x+xx].normZ = 0; //aVec.z;
                }
            }
            x+=numVertsPVert;
        }
        yUse+=ack;
    }
}

- (void)setupXTree:(int)numVertices subTypeStr:(NSString *)subTypeStr detail:(OPCelestrialDetail *)detail collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {
    
    int numBands = 8;
    int numVer = 12;
    int numVertsPVert = 6;
    
    Vertex3D * coneVertices = malloc((numVer) * (numBands-1) * numVertsPVert * sizeof(Vertex3D));
    
    //NSLog(@"cone %d", (numVer) * (numBands-1) * numVertsPVert);
    
    NSMutableArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:CONE];
    
    OPVertexData * vertexData = [[OPVertexData alloc] init:(numVer * (numBands-1) * numVertsPVert) vertexData:(GLfloat *)coneVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr collisionRange:pCollisionRange repairAbility:pRepairAbility];
    
    [theArr addObject:vertexData];
    
    float stepAroundCircle = (TWOPIE / numVer);
    
    float stepHalfCircle = (M_PI / (numBands));
    
    float ack = 1/(float)numBands;
    
    float iUse = 0;
    
    int x=0;
    
    float okHold[3];
    
    float widthOffset = 1;
    
    float yUse = 0;
    
    for (int y=1; y<numBands; y++) {
        
        okHold[0] = ((cos(stepHalfCircle * (y))));
        okHold[1] =  ((cos(stepHalfCircle * (y+1))));
        okHold[2] =  ((cos(stepHalfCircle * (y-1))));
        
        //okHold[0] = ((numBands * cos(stepHalfCircle * (y))));
        //okHold[1] =  ((numBands * cos(stepHalfCircle * (y+1))));
        //okHold[2] =  ((numBands * cos(stepHalfCircle * (y-1))));
        
        for(int i=0; i < (numVer); i++) {
            
            if (y % 2 == 0) {
                iUse = (i);
            }
            else {
                iUse = (i)+1;
            }
            
            //NSLog(@"v:%d %.2f %.2f",i,yUse, (yUse * cos(iUse * stepAroundCircle)));
            
            //coneVertices[x].x = coneVertices[x+3].x = (y * cos(iUse * stepAroundCircle));
            //coneVertices[x].y = coneVertices[x+3].y = (y * sin(iUse * stepAroundCircle));
            coneVertices[x].x = coneVertices[x+3].x = (yUse * cos(iUse * stepAroundCircle));
            coneVertices[x].y = coneVertices[x+3].y = (yUse * sin(iUse * stepAroundCircle));
            coneVertices[x].z = coneVertices[x+3].z = okHold[0]*widthOffset;
            
            coneVertices[x].textX = coneVertices[x+3].textX = 0;
            coneVertices[x].textY = coneVertices[x+3].textY = 0;
            
            if (y == numBands-1) {
                coneVertices[x+1].x = (0 * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = (0 * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1]*widthOffset;
            }
            else {
                
                coneVertices[x+1].x = ((yUse+stepHalfCircle) * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = ((yUse+stepHalfCircle) * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1]*widthOffset;
                
                //coneVertices[x+1].x = ((y+1) * cos((iUse+1) * stepAroundCircle));
                //coneVertices[x+1].y = ((y+1) * sin((iUse+1) * stepAroundCircle));
                //coneVertices[x+1].z = okHold[1];
                
            }
            
            coneVertices[x+1].textX = 1;
            coneVertices[x+1].textY = 0;
            
            coneVertices[x+2].x = coneVertices[x+5].x = (yUse * cos((iUse+2) * stepAroundCircle));
            coneVertices[x+2].y = coneVertices[x+5].y = (yUse * sin((iUse+2) * stepAroundCircle));
            coneVertices[x+2].z = coneVertices[x+5].z = okHold[0]*widthOffset;
            
            //coneVertices[x+2].x = coneVertices[x+5].x = (y * cos((iUse+2) * stepAroundCircle));
            //coneVertices[x+2].y = coneVertices[x+5].y = (y * sin((iUse+2) * stepAroundCircle));
            //coneVertices[x+2].z = coneVertices[x+5].z = okHold[0];
            
            coneVertices[x+2].textX = coneVertices[x+5].textX = 1;
            coneVertices[x+2].textY = coneVertices[x+5].textY = 1;
            
            coneVertices[x+4].x = ((yUse-stepHalfCircle) * cos((iUse+1) * stepAroundCircle));
            coneVertices[x+4].y = ((yUse-stepHalfCircle) * sin((iUse+1) * stepAroundCircle));
            coneVertices[x+4].z = okHold[2]*widthOffset;
            
            //coneVertices[x+4].x = ((y-1)  * cos((iUse+1) * stepAroundCircle));
            //coneVertices[x+4].y = ((y-1)  * sin((iUse+1) * stepAroundCircle));
            //coneVertices[x+4].z = okHold[2];
            
            coneVertices[x+4].textX = 0;
            coneVertices[x+4].textY = 1;
            
            for (int xx=0; xx<numVertsPVert; xx++) {
                
                if (i % 2 == 0) {
                    coneVertices[x+xx].r = 1.0; //.4;
                    coneVertices[x+xx].g = 1.0; //.5;
                    coneVertices[x+xx].b = 1.0; //.6;
                    coneVertices[x+xx].alpha = 1;
                    coneVertices[x+xx].normX = 0; //aVec.x;
                    coneVertices[x+xx].normY = 1; //aVec.y;
                    coneVertices[x+xx].normZ = 0; //aVec.z;
                }
                else {
                    coneVertices[x+xx].r = 1.0; //.4;
                    coneVertices[x+xx].g = 1.0; //.5;
                    coneVertices[x+xx].b = 1.0; //.6;
                    coneVertices[x+xx].alpha = 1;
                    coneVertices[x+xx].normX = 1; //aVec.x;
                    coneVertices[x+xx].normY = 0; //aVec.y;
                    coneVertices[x+xx].normZ = 0; //aVec.z;
                }
            }
            x+=numVertsPVert;
        }
        yUse+=ack;
    }
}

- (void)setupSpheroid2:(int)numVertices theColors:(GLfloat[])theColors subTypeStr:(NSString *)subTypeStr detail:(OPCelestrialDetail *)detail collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {
    
    int numBands = 12;
    int numVer = 18;
    int numVertsPVert = 6;
    
    Vertex3D * coneVertices = malloc((numVer) * (numBands-1) * numVertsPVert * sizeof(Vertex3D));
    
    //NSLog(@"cone %d", (numVer) * (numBands-1) * numVertsPVert);
    
    NSMutableArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:CONE];
    
    OPVertexData * vertexData = [[OPVertexData alloc] init:(numVer * (numBands-1) * numVertsPVert) vertexData:(GLfloat *)coneVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr collisionRange:pCollisionRange repairAbility:pRepairAbility];
    
    [theArr addObject:vertexData];
    
    float stepAroundCircle = (TWOPIE / numVer);
    
    float stepHalfCircle = (M_PI / (numBands));
    
    float iUse = 0;
    
    int x=0;
    
    float okHold[5];
    
    float okWidth[5];

    for (int y=1; y<numBands; y++) {
        
        okWidth[0] = (( sin(stepHalfCircle * (y))));
        okWidth[2] =  (( sin(stepHalfCircle * (y+1))));
        okWidth[4] =  (( sin(stepHalfCircle * (y-1))));
        
        okHold[0] = (( cos(stepHalfCircle * (y))));
        okHold[2] =  (( cos(stepHalfCircle * (y+1))));
        okHold[4] =  (( cos(stepHalfCircle * (y-1))));

        for(int i=0; i < (numVer); i++) {

            if (y % 2 == 0) {
                iUse = (i);
            }
            else {
                iUse = (i)+1;
            }
        
            coneVertices[x].x = coneVertices[x+3].x = (okWidth[0] * cos(iUse * stepAroundCircle));
            coneVertices[x].y = coneVertices[x+3].y = (okWidth[0] * sin(iUse * stepAroundCircle));
            coneVertices[x].z = coneVertices[x+3].z = okHold[0];
            
            coneVertices[x].textX = coneVertices[x+3].textX = 0;
            coneVertices[x].textY = coneVertices[x+3].textY = 0;

            coneVertices[x+1].x = (okWidth[2] * cos((iUse+1) * stepAroundCircle));
            coneVertices[x+1].y = (okWidth[2] * sin((iUse+1) * stepAroundCircle));
            coneVertices[x+1].z = okHold[2];
            
            coneVertices[x+1].textX = 1;
            coneVertices[x+1].textY = 0;
            
            coneVertices[x+2].x = coneVertices[x+5].x = (okWidth[0]  * cos((iUse+2) * stepAroundCircle));
            coneVertices[x+2].y = coneVertices[x+5].y = (okWidth[0]  * sin((iUse+2) * stepAroundCircle));
            coneVertices[x+2].z = coneVertices[x+5].z = okHold[0];
            
            coneVertices[x+2].textX = coneVertices[x+5].textX = 1;
            coneVertices[x+2].textY = coneVertices[x+5].textY = 1;
            
            coneVertices[x+4].x = (okWidth[4]  * cos((iUse+1) * stepAroundCircle));
            coneVertices[x+4].y = (okWidth[4]  * sin((iUse+1) * stepAroundCircle));
            coneVertices[x+4].z = okHold[4];
            
            coneVertices[x+4].textX = 0;
            coneVertices[x+4].textY = 1;

            for (int xx=0; xx<numVertsPVert; xx++) {
                
                if (i % 2 == 0) {
                    coneVertices[x+xx].r = theColors[0]; //.4;
                    coneVertices[x+xx].g = theColors[1]; //.5;
                    coneVertices[x+xx].b = theColors[2]; //1.0; //.6;
                    coneVertices[x+xx].alpha = theColors[3];
                    coneVertices[x+xx].normX = 0; //aVec.x;
                    coneVertices[x+xx].normY = 1; //aVec.y;
                    coneVertices[x+xx].normZ = 0; //aVec.z;
                }
                else {
                    coneVertices[x+xx].r = theColors[4]; //.4;
                    coneVertices[x+xx].g = theColors[5]; //.5;
                    coneVertices[x+xx].b = theColors[6]; //.6;
                    coneVertices[x+xx].alpha = theColors[7];
                    coneVertices[x+xx].normX = 1; //aVec.x;
                    coneVertices[x+xx].normY = 0; //aVec.y;
                    coneVertices[x+xx].normZ = 0; //aVec.z;
                }
            }
            x+=numVertsPVert;
        }
    }
}

- (void)setupSpheroid3:(int)numVertices theColors:(GLfloat[])theColors subTypeStr:(NSString *)subTypeStr detail:(OPCelestrialDetail *)detail collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {
    
    int numBands = 12;
    int numVer = 18;
    int numVertsPVert = 6;
    
    Vertex3D * coneVertices = malloc((numVer) * (numBands-1) * (numVertsPVert*2) * sizeof(Vertex3D));
    
    //NSLog(@"cone size %d", ((numVer) * (numBands-1) * (numVertsPVert*2) ) );
    
    //NSLog(@"cone %d", (numVer) * (numBands-1) * numVertsPVert);
    
    NSMutableArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:CONE];
    
    OPVertexData * vertexData = [[OPVertexData alloc] init:(numVer * (numBands-1) * numVertsPVert*2) vertexData:(GLfloat *)coneVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr collisionRange:pCollisionRange repairAbility:pRepairAbility];
    
    [theArr addObject:vertexData];
    
    float stepAroundCircle = (TWOPIE / numVer);
    
    float stepHalfCircle = (M_PI / (numBands));
    
    float iUse = 0;
    
    int x1=0;
    
    int x=0;
    
    float okHold[3];
    
    float okWidth[3];
    
    float okUse[3];
    
    for (int y=1; y<numBands; y++) {
        
//        okWidth[0] = ((numBands * sin(stepHalfCircle * (y))));
//        okWidth[1] =  ((numBands * sin(stepHalfCircle * (y+1))));
//        okWidth[2] =  ((numBands * sin(stepHalfCircle * (y-1))));
        
//        okUse[0] = ((numBands * cos(stepHalfCircle * (y))));
//        okUse[1] =  ((numBands * cos(stepHalfCircle * (y+1))));
//        okUse[2] =  ((numBands * cos(stepHalfCircle * (y-1))));
        
        okWidth[0] = ((  sin(stepHalfCircle * (y))));
        okWidth[1] =  (( sin(stepHalfCircle * (y+1))));
        okWidth[2] =  (( sin(stepHalfCircle * (y-1))));
        
        okUse[0] = (( cos(stepHalfCircle * (y))));
        okUse[1] =  (( cos(stepHalfCircle * (y+1))));
        okUse[2] =  (( cos(stepHalfCircle * (y-1))));
        
        for(int i=0; i < (numVer); i++) {
            
            if (y % 2 == 0) {
                iUse = (i);
            }
            else {
                iUse = (i)+1;
            }
            
            //int hoV = 0;
            
            for (int vxx=0; vxx<2; vxx++) {
                
                if (vxx == 1) {
                    //hoV = -(numBands);
                    x=x1+((numBands-1)*numVer*numVertsPVert);
                    for (int pp=0; pp<3; pp++) {
                        okHold[pp] = (okUse[pp]*1.5);
                    }
                    //NSLog(@"X: %d %.2f %.2f",x, okHold[0], (okWidth[0] * cos(iUse * stepAroundCircle)));
                }
                else {
                    x=x1;
                    for (int pp=0; pp<3; pp++) {
                        okHold[pp] = (2.5) + (okUse[pp]/4);
                    }
                    //NSLog(@"Z: %d %.2f %.2f",x, okHold[0], (okWidth[0] * cos(iUse * stepAroundCircle)));
                }
                
                coneVertices[x].x = coneVertices[x+3].x = (okWidth[0] * cos(iUse * stepAroundCircle));
                coneVertices[x].y = coneVertices[x+3].y = (okWidth[0] * sin(iUse * stepAroundCircle));
                coneVertices[x].z = coneVertices[x+3].z = okHold[0];
                
                coneVertices[x].textX = coneVertices[x+3].textX = 0;
                coneVertices[x].textY = coneVertices[x+3].textY = 0;
                
                coneVertices[x+1].x = (okWidth[1] * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = (okWidth[1] * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1];
                
                coneVertices[x+1].textX = 1;
                coneVertices[x+1].textY = 0;
                
                coneVertices[x+2].x = coneVertices[x+5].x = (okWidth[1]  * cos((iUse+2) * stepAroundCircle));
                coneVertices[x+2].y = coneVertices[x+5].y = (okWidth[1]  * sin((iUse+2) * stepAroundCircle));
                coneVertices[x+2].z = coneVertices[x+5].z = okHold[1];
                
                coneVertices[x+2].textX = coneVertices[x+5].textX = 1;
                coneVertices[x+2].textY = coneVertices[x+5].textY = 1;
                
                coneVertices[x+4].x = (okWidth[2]  * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+4].y = (okWidth[2]  * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+4].z = okHold[2];
                
                coneVertices[x+4].textX = 0;
                coneVertices[x+4].textY = 1;
                
                for (int xx=0; xx<numVertsPVert; xx++) {
                    
                    if (i % 2 == 0) {
                        coneVertices[x+xx].r = theColors[0]; //.4;
                        coneVertices[x+xx].g = theColors[1]; //.5;
                        coneVertices[x+xx].b = theColors[2]; //1.0; //.6;
                        coneVertices[x+xx].alpha = theColors[3];
                        coneVertices[x+xx].normX = 0; //aVec.x;
                        coneVertices[x+xx].normY = 1; //aVec.y;
                        coneVertices[x+xx].normZ = 0; //aVec.z;
                    }
                    else {
                        coneVertices[x+xx].r = theColors[4]; //.4;
                        coneVertices[x+xx].g = theColors[5]; //.5;
                        coneVertices[x+xx].b = theColors[6]; //.6;
                        coneVertices[x+xx].alpha = theColors[7];
                        coneVertices[x+xx].normX = 1; //aVec.x;
                        coneVertices[x+xx].normY = 0; //aVec.y;
                        coneVertices[x+xx].normZ = 0; //aVec.z;
                    }
                }
                
            }
            x1+=numVertsPVert;
        }
    }
}

//- (void)setupSpheroid:(int)numVertices subTypeStr:(NSString *)subTypeStr detail:(OPCelesrtialDetail *)detail  textureId:(unsigned int)pTextureId {
//
//    //NSLog(@"cone Len %lu", CONE_VERTECES * sizeof(Vertex3D) );
//
//    int numBands = 20;
//    int numVer = 24;
//    int numVertsPVert = 18;
//
//    Vertex3D * coneVertices = malloc(numVer * (numBands-1) * numVertsPVert * sizeof(Vertex3D));
//
//    NSLog(@"cone %d", numVer * (numBands-1) * numVertsPVert);
//
//    //VertexStruct vertextStructData = {numVertices,0,(GLfloat *)coneVertices,nil, "CONE", subTypeStr};
//
//    NSMutableArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:CONE];
//
//    //[theArr addObject:[NSValue valueWithBytes:&vertextStructData objCType:@encode(VertexStruct)]];
//
//    OPVertexData * vertexData = [[OPVertexData alloc] init:(numVer * (numBands-1) * numVertsPVert) vertexAuxCnt:0 vertexData:(GLfloat *)coneVertices vertexDataAux:nil typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr textureId:pTextureId];
//
//    [theArr addObject:vertexData];
//
//    float stepAroundCircle = (TWOPIE / numVer);
//
//    //    float startHalfCircle = 0;
//    float stepHalfCircle = (M_PI / (numBands*2));
//
//    //NSLog(@"fh: %.2d", (numBands*2));
//    //for (int x=0; x<numBands; x++) {
//    //    NSLog(@"ff %.2f %.2f %.2f", x*(M_PI/(numBands*2)), sin(((x*2)*stepHalfCircle)+startHalfCircle), cos(((x*2)*stepHalfCircle)+startHalfCircle) );
//    //}
//
//    //float baseStep = 1;
//
//    //float widthFactor = (numBands*2);
//
//    //float oldRadius;
//    //float curRadius = 0;
//    //float nextRadius = widthFactor;
//
//    float iUse = 0;
//
//    float widthJump = 0;
//
//    //float colorRed = 0;
//
//    int cnt = 0;
//
//    int x=0;
//
//    //    float radIncFactor = 0;
//    //    float haldRadIncFactorOld = 0;
//    //    float haldRadIncFactorNext = 0;
//
//    //    float spikeHeight = 7;
//
//    float okHold[5];
//
//    float okWidth[5];
//
//    //for (int y=1; y<3; y++) {
//    for (int y=1; y<numBands; y++) {
//
//        widthJump = y * stepHalfCircle;
//
//        cnt++;
//
//        okWidth[0] = ((numBands * sin(stepHalfCircle * (y*2))));
//        //NSLog(@"ew %.2f", okWidth[0]);
//        okWidth[1] = (numBands * sin(stepHalfCircle * ((y*2)+1)));
//        //NSLog(@"ew %.2f", okWidth[1]);
//        okWidth[2] =  ((numBands * sin(stepHalfCircle * ((y*2)+2))));
//        //NSLog(@"ew %.2f", okWidth[2]);
//        okWidth[3] =  ((numBands * sin(stepHalfCircle * ((y*2)-1))));
//        //NSLog(@"ew %.2f", okWidth[3]);
//        okWidth[4] =  ((numBands * sin(stepHalfCircle * ((y*2)-2))));
//        //NSLog(@"ew %.2f", okWidth[4]);
//
//
//        okHold[0] = ((numBands * cos(stepHalfCircle * (y*2))));
//        //        NSLog(@"ello1 %.2f", okHold[0]);
//        okHold[1] = (numBands * cos(stepHalfCircle * ((y*2)+1)));
//        //        NSLog(@"ello2 %.2f", okHold[1]);
//        okHold[2] =  ((numBands * cos(stepHalfCircle * ((y*2)+2))));
//        //        NSLog(@"ello3 %.2f", okHold[2]);
//        okHold[3] =  ((numBands * cos(stepHalfCircle * ((y*2)-1))));
//        //        NSLog(@"ello4 %.2f", okHold[3]);
//        okHold[4] =  ((numBands * cos(stepHalfCircle * ((y*2)-2))));
//        //        NSLog(@"ello5 %.2f", okHold[4]);
//        //if (okHold[0] < 0) okHold[0] = 0;
//        //if (okHold[1] < 0) okHold[1] = 0;
//        //if (okHold[2] < 0) okHold[2] = 0;
//        //if (okHold[3] < 0) okHold[3] = 0;
//        //if (okHold[4] < 0) okHold[4] = 0;
//
//        //radIncFactor = baseStep;
//        //        radIncFactor = (y < numBands/2 ? widthFactor : -widthFactor);
//        //        haldRadIncFactorNext = (radIncFactor/2)+spikeHeight;
//
//        //        oldRadius = curRadius;
//        //        curRadius = nextRadius;
//        //        nextRadius = curRadius + radIncFactor;
//
//        //        haldRadIncFactorOld = (oldRadius != nextRadius) ? haldRadIncFactorNext : -haldRadIncFactorNext;
//
//        //NSLog(@"fac: %.2f %.2f", curRadius, widthJump);
//        //NSLog(@"olh: %.2f %.2f", haldRadIncFactorOld, haldRadIncFactorNext);
//
//        //for (int i=4; i<6; i++) {
//
//        //float theZIncFactor = 10;
//        //float theZbase = (stepHalfCircle*(y*2))*theZIncFactor;
//
//        for(int i=0; i < (numVer/2); i++) {
//
//            iUse = i;
//            if (y % 2 == 0) {
//                iUse = (i*2);
//            }
//            else {
//                iUse = (i*2)+1;
//            }
//
//            //coneVertices[x].x = coneVertices[x+8].x = (curRadius * cos(iUse * stepAroundCircle));
//            //coneVertices[x].y = coneVertices[x+8].y = (curRadius * sin(iUse * stepAroundCircle));
//            //coneVertices[x].z = coneVertices[x+8].z = widthJump;
//
//            coneVertices[x].x = coneVertices[x+8].x = (okWidth[0] * cos(iUse * stepAroundCircle));
//            coneVertices[x].y = coneVertices[x+8].y = (okWidth[0] * sin(iUse * stepAroundCircle));
//            coneVertices[x].z = okHold[0];
//
//
//
//            //            NSLog(@"V %.2f %.2f %.2f", coneVertices[x].x, coneVertices[x].y, coneVertices[x].z);
//
//            [self setVertex:coneVertices[x]];
//            [self setVertex:coneVertices[x+8]];
//
//            // Middle
//            //coneVertices[x+1].x = coneVertices[x+4].x = coneVertices[x+7].x = ((curRadius+haldRadIncFactorNext) * cos((iUse+1) * stepAroundCircle));
//            //coneVertices[x+1].y = coneVertices[x+4].y = coneVertices[x+7].y = ((curRadius+haldRadIncFactorNext) * sin((iUse+1) * stepAroundCircle));
//
//            coneVertices[x+1].x = coneVertices[x+4].x = coneVertices[x+7].x = (okWidth[1]  * cos((iUse+1) * stepAroundCircle));
//            coneVertices[x+1].y = coneVertices[x+4].y = coneVertices[x+7].y = (okWidth[1]  * sin((iUse+1) * stepAroundCircle));
//            //coneVertices[x+1].z =coneVertices[x+4].z = coneVertices[x+7].z =  widthJump+(widthFactor/2);
//            coneVertices[x+1].z = coneVertices[x+4].z = coneVertices[x+7].z = okHold[1];
//
//            //            NSLog(@"V1 %.2f %.2f %.2f", coneVertices[x+1].x, coneVertices[x+1].y, coneVertices[x+1].z);
//
//            [self setVertex:coneVertices[x+1]];
//            [self setVertex:coneVertices[x+4]];
//            [self setVertex:coneVertices[x+7]];
//
//            //okHold =  ((numBands * sin(stepHalfCircle * ((y*2)+2))));
//
//            //NSLog(@"ello3 %.2f", okHold);
//
//            coneVertices[x+2].x = coneVertices[x+3].x = (okWidth[2]  * cos((iUse+1) * stepAroundCircle));
//            coneVertices[x+2].y = coneVertices[x+3].y = (okWidth[2]  * sin((iUse+1) * stepAroundCircle));
//
//            //coneVertices[x+2].x = coneVertices[x+3].x = (nextRadius * cos((iUse+1) * stepAroundCircle));
//            //coneVertices[x+2].y = coneVertices[x+3].y = (nextRadius * sin((iUse+1) * stepAroundCircle));
//            //coneVertices[x+2].z = coneVertices[x+3].z = widthJump+widthFactor;
//
//            coneVertices[x+2].z = coneVertices[x+3].z = okHold[2];
//
//            //            NSLog(@"V2 %.2f %.2f %.2f", coneVertices[x+2].x, coneVertices[x+2].y, coneVertices[x+2].z);
//
//            [self setVertex:coneVertices[x+2]];
//            [self setVertex:coneVertices[x+3]];
//
//            //coneVertices[x+5].x = coneVertices[x+6].x = (curRadius * cos((iUse+2) * stepAroundCircle));
//            //coneVertices[x+5].y = coneVertices[x+6].y = (curRadius * sin((iUse+2) * stepAroundCircle));
//
//            coneVertices[x+5].x = coneVertices[x+6].x = (okWidth[0]  * cos((iUse+2) * stepAroundCircle));
//            coneVertices[x+5].y = coneVertices[x+6].y = (okWidth[0]  * sin((iUse+2) * stepAroundCircle));
//            //coneVertices[x+5].z = coneVertices[x+6].z = widthJump;
//            coneVertices[x+5].z = coneVertices[x+6].z = okHold[0];
//
//            //            NSLog(@"V3 %.2f %.2f %.2f", coneVertices[x+5].x, coneVertices[x+5].y, coneVertices[x+5].z);
//
//            //NSLog(@"V0 %.2f %.2f %.2f", coneVertices[x].x, coneVertices[x].y, coneVertices[x].z);
//            //NSLog(@"V1 %.2f %.2f %.2f", coneVertices[x+1].x, coneVertices[x+1].y, coneVertices[x+1].z);
//            //NSLog(@"V2 %.2f %.2f %.2f", coneVertices[x+2].x, coneVertices[x+2].y, coneVertices[x+2].z);
//            //NSLog(@"V3 %.2f %.2f %.2f", coneVertices[x+3].x, coneVertices[x+3].y, coneVertices[x+3].z);
//            //NSLog(@"V4 %.2f %.2f %.2f", coneVertices[x+4].x, coneVertices[x+4].y, coneVertices[x+4].z);
//            //NSLog(@"V5 %.2f %.2f %.2f", coneVertices[x+5].x, coneVertices[x+5].y, coneVertices[x+5].z);
//
//            [self setVertex:coneVertices[x+5]];
//            [self setVertex:coneVertices[x+6]];
//
//            // -------------------------------------------------
//
//            //coneVertices[x+9].x = coneVertices[x+17].x = (curRadius * cos((iUse) * stepAroundCircle));
//            //coneVertices[x+9].y = coneVertices[x+17].y = (curRadius * sin((iUse) * stepAroundCircle));
//            coneVertices[x+9].x = coneVertices[x+17].x = (okWidth[0]  * cos((iUse) * stepAroundCircle));
//            coneVertices[x+9].y = coneVertices[x+17].y = (okWidth[0]  * sin((iUse) * stepAroundCircle));
//            //coneVertices[x+9].z = coneVertices[x+17].z = widthJump;
//            coneVertices[x+9].z = coneVertices[x+17].z = okHold[0];
//
//            //            NSLog(@"V4 %.2f %.2f %.2f", coneVertices[x+9].x, coneVertices[x+9].y, coneVertices[x+9].z);
//
//            [self setVertex:coneVertices[x+9]];
//            [self setVertex:coneVertices[x+17]];
//
//            // Middle
//            //coneVertices[x+10].x = coneVertices[x+13].x = coneVertices[x+16].x = ((curRadius-haldRadIncFactorOld) * cos((iUse+1) * stepAroundCircle));
//            //coneVertices[x+10].y = coneVertices[x+13].y = coneVertices[x+16].y = ((curRadius-haldRadIncFactorOld) * sin((iUse+1) * stepAroundCircle));
//
//
//            coneVertices[x+10].x = coneVertices[x+13].x = coneVertices[x+16].x = (okWidth[3] * cos((iUse+1) * stepAroundCircle));
//            coneVertices[x+10].y = coneVertices[x+13].y = coneVertices[x+16].y = (okWidth[3] * sin((iUse+1) * stepAroundCircle));
//
//            //coneVertices[x+10].z =coneVertices[x+13].z = coneVertices[x+16].z =  widthJump-(widthFactor/2);
//            coneVertices[x+10].z = okHold[3];
//
//            //            NSLog(@"V5 %.2f %.2f %.2f", coneVertices[x+10].x, coneVertices[x+10].y, coneVertices[x+10].z);
//
//            [self setVertex:coneVertices[x+10]];
//            [self setVertex:coneVertices[x+13]];
//            [self setVertex:coneVertices[x+16]];
//
//            //coneVertices[x+11].x = coneVertices[x+12].x = (oldRadius * cos((iUse+1) * stepAroundCircle));
//            //coneVertices[x+11].y = coneVertices[x+12].y = (oldRadius * sin((iUse+1) * stepAroundCircle));
//
//            coneVertices[x+11].x = coneVertices[x+12].x = (okWidth[4]  * cos((iUse+1) * stepAroundCircle));
//            coneVertices[x+11].y = coneVertices[x+12].y = (okWidth[4]  * sin((iUse+1) * stepAroundCircle));
//
//            //coneVertices[x+11].z = coneVertices[x+12].z = widthJump-widthFactor;
//            coneVertices[x+11].z = coneVertices[x+12].z = okHold[4];
//
//            //            NSLog(@"V6 %.2f %.2f %.2f", coneVertices[x+11].x, coneVertices[x+11].y, coneVertices[x+11].z);
//
//            [self setVertex:coneVertices[x+11]];
//            [self setVertex:coneVertices[x+12]];
//
//            //coneVertices[x+14].x = coneVertices[x+15].x = (curRadius * cos((iUse+2) * stepAroundCircle));
//            //coneVertices[x+14].y = coneVertices[x+15].y = (curRadius * sin((iUse+2) * stepAroundCircle));
//
//            coneVertices[x+14].x = coneVertices[x+15].x = (okWidth[0]  * cos((iUse+2) * stepAroundCircle));
//            coneVertices[x+14].y = coneVertices[x+15].y = (okWidth[0]  * sin((iUse+2) * stepAroundCircle));
//            //coneVertices[x+14].z = coneVertices[x+15].z = widthJump;
//            coneVertices[x+14].z = coneVertices[x+15].z = okHold[0];
//
//            //            NSLog(@"V7 %.2f %.2f %.2f", coneVertices[x+14].x, coneVertices[x+14].y, coneVertices[x+14].z);
//
//            [self setVertex:coneVertices[x+14]];
//            [self setVertex:coneVertices[x+15]];
//
//            for (int xx=0; xx<numVertsPVert; xx++) {
//
//                //coneVertices[x+xx].r = 0; //.4;
//                //coneVertices[x+xx].g = 0; //.5;
//                //coneVertices[x+xx].b = 1; //.6;
//                //coneVertices[x+xx].alpha = 1;
//
//                //GLKVector3 aVec = GLKVector3Make(coneVertices[x+xx].x, coneVertices[x+xx].y, coneVertices[x+xx].z);
//
//                //aVec = GLKVector3Normalize(aVec);
//
//                //if (xx < numVertsPVert/2) {
//                //coneVertices[x+xx].x = 0;
//                //coneVertices[x+xx].y = 0;
//                //coneVertices[x+xx].z = 0;
//                //}
//
//                if (i % 2 == 0) {
//                    coneVertices[x+xx].r = 0.2; //.4;
//                    coneVertices[x+xx].g = 0.2; //.5;
//                    coneVertices[x+xx].b = 0.2; //.6;
//                    coneVertices[x+xx].alpha = 1;
//                    coneVertices[x+xx].normX = 0; //aVec.x;
//                    coneVertices[x+xx].normY = 1; //aVec.y;
//                    coneVertices[x+xx].normZ = 0; //aVec.z;
//                }
//                else {
//                    coneVertices[x+xx].r = 0.81; //.4;
//                    coneVertices[x+xx].g = 0.81; //.5;
//                    coneVertices[x+xx].b = 0.81; //.6;
//                    coneVertices[x+xx].alpha = 1;
//                    coneVertices[x+xx].normX = 1; //aVec.x;
//                    coneVertices[x+xx].normY = 0; //aVec.y;
//                    coneVertices[x+xx].normZ = 0; //aVec.z;
//                }
//            }
//
//            x+=numVertsPVert;
//        }
//        //oldRadius = curRadius;
//        //NSLog(@"rad %f %f %f", curRadius, nextRadius, oldRadius);
//    }
//    //NSLog(@"coneCnt %d", cnt*6);
//}

- (void)setupRing:(float)theRadius theColors:(GLfloat[])theColors numVertices:(int)numVertices subTypeStr:(NSString *)subTypeStr detail:(OPCelestrialDetail *)detail collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {
    
    Vertex3D * circleVertices = malloc(numVertices * sizeof(Vertex3D));
    
    //NSLog(@"circleSize %lu %lu", numVertices * sizeof(Vertex3D), sizeof(Vertex3D));
    
    //VertexStruct vertextStructData = {numVertices,0,(GLfloat *)circleVertices,nil, "RING", subTypeStr};
    
    NSMutableArray * theArr = detail.vertexArr; //[orbitalArr objectAtIndex:RING];
    
    //[theArr addObject:[NSValue valueWithBytes:&vertextStructData objCType:@encode(VertexStruct)]];
    
    OPVertexData * vertexData = [[OPVertexData alloc] init:numVertices vertexData:(GLfloat *)circleVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr collisionRange:pCollisionRange repairAbility:pRepairAbility];
    
    [theArr addObject:vertexData];
    
    for(int i=0; i < numVertices; i++) {
        circleVertices[i].x = (theRadius * cos(i *  (TWOPIE / (numVertices-1))));
        circleVertices[i].y = (theRadius * sin(i *  (TWOPIE / (numVertices-1))));
        circleVertices[i].z = theRadius;

        circleVertices[i].r = theColors[0];
        circleVertices[i].g = theColors[1];
        circleVertices[i].b = theColors[2];
        circleVertices[i].alpha = theColors[3];
        
        GLKVector3 aVec = GLKVector3Make(circleVertices[i].x, circleVertices[i].y, circleVertices[i].z);
        
        aVec = GLKVector3Normalize(aVec);
        
        circleVertices[i].normX = aVec.x;
        circleVertices[i].normY = aVec.y;
        circleVertices[i].normZ = aVec.z;
    }
}

- (void)setupCone:(int)numVertices theColors:(GLfloat[])theColors subTypeStr:(NSString *)subTypeStr detail:(OPCelestrialDetail *)detail collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {
    
    int numBands = 12;
    int numVer = 18;
    int numVertsPVert = 6;
    
    Vertex3D * coneVertices = malloc((numVer) * (numBands-1) * (numVertsPVert) * sizeof(Vertex3D));
    
    //NSLog(@"cone size %d", ((numVer) * (numBands-1) * (numVertsPVert*2) ) );
    
    //NSLog(@"cone %d", (numVer) * (numBands-1) * numVertsPVert);
    
    NSMutableArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:CONE];
    
    OPVertexData * vertexData = [[OPVertexData alloc] init:(numVer * (numBands-1) * numVertsPVert) vertexData:(GLfloat *)coneVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr collisionRange:pCollisionRange repairAbility:pRepairAbility];
    
    [theArr addObject:vertexData];
    
    float stepAroundCircle = (TWOPIE / numVer);
    float stepHalfCircle = (M_PI / numBands);
    float iUse = 0;
    
    int x1=0;
    int x=0;
    
    float okHold[3];
    float okWidth[3];
    float okUse[3];
    
    for (int y=1; y<numBands/2; y++) {
        
        //okWidth[0] = sin(stepHalfCircle * (y));
        //okWidth[1] = sin(stepHalfCircle * (y+1));
        //okWidth[2] = sin(stepHalfCircle * (y-1));
        
        okWidth[0] = (stepHalfCircle * (y));
        okWidth[1] = (stepHalfCircle * (y+1));
        okWidth[2] = (stepHalfCircle * (y-1));
        
        //okUse[0] = cos(stepHalfCircle * (y));
        //okUse[1] = cos(stepHalfCircle * (y+1));
        //okUse[2] = cos(stepHalfCircle * (y-1));
        
        okUse[0] = (stepHalfCircle * (y));
        okUse[1] = (stepHalfCircle * (y+1));
        okUse[2] = (stepHalfCircle * (y-1));
        
        for(int i=0; i < numVer; i++) {
            
            if (y % 2 == 0) {
                iUse = i;
            }
            else {
                iUse = i+1;
            }
            
            //int vxx=1;
            //if (vxx == 1) {
            //for (int vxx=0; vxx<2; vxx++) {
                
                //if (vxx == 1) {
                    x=x1; //+((numBands-1)*numVer*numVertsPVert);
                    for (int pp=0; pp<3; pp++) {
                        okHold[pp] = (okUse[pp]*1.5);
                    }
                //}
                
                coneVertices[x].x = coneVertices[x+3].x = (okWidth[0] * cos(iUse * stepAroundCircle));
                coneVertices[x].y = coneVertices[x+3].y = (okWidth[0] * sin(iUse * stepAroundCircle));
                coneVertices[x].z = coneVertices[x+3].z = okHold[0];
                
                coneVertices[x].textX = coneVertices[x+3].textX = 0;
                coneVertices[x].textY = coneVertices[x+3].textY = 0;
                
                coneVertices[x+1].x = (okWidth[1] * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = (okWidth[1] * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1];
                
                coneVertices[x+1].textX = 1;
                coneVertices[x+1].textY = 0;
                
                coneVertices[x+2].x = coneVertices[x+5].x = (okWidth[1]  * cos((iUse+2) * stepAroundCircle));
                coneVertices[x+2].y = coneVertices[x+5].y = (okWidth[1]  * sin((iUse+2) * stepAroundCircle));
                coneVertices[x+2].z = coneVertices[x+5].z = okHold[1];
                
                coneVertices[x+2].textX = coneVertices[x+5].textX = 1;
                coneVertices[x+2].textY = coneVertices[x+5].textY = 1;
                
                coneVertices[x+4].x = (okWidth[2]  * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+4].y = (okWidth[2]  * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+4].z = okHold[2];
                
                coneVertices[x+4].textX = 0;
                coneVertices[x+4].textY = 1;
                
                for (int xx=0; xx<numVertsPVert; xx++) {
                    if (i % 2 == 0) {
                        coneVertices[x+xx].r = theColors[0];
                        coneVertices[x+xx].g = theColors[1];
                        coneVertices[x+xx].b = theColors[2];
                        coneVertices[x+xx].alpha = theColors[3];
                        coneVertices[x+xx].normX = 0;
                        coneVertices[x+xx].normY = 1;
                        coneVertices[x+xx].normZ = 0;
                    }
                    else {
                        coneVertices[x+xx].r = theColors[4];
                        coneVertices[x+xx].g = theColors[5];
                        coneVertices[x+xx].b = theColors[6];
                        coneVertices[x+xx].alpha = theColors[7];
                        coneVertices[x+xx].normX = 1;
                        coneVertices[x+xx].normY = 0;
                        coneVertices[x+xx].normZ = 0;
                    }
                }
                
            //}
            x1 += numVertsPVert;
        }
    }
}

- (void)setupEgg:(int)numVertices theColors:(GLfloat[])theColors subTypeStr:(NSString *)subTypeStr detail:(OPCelestrialDetail *)detail collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {
    
    int numBands = 12;
    int numVer = 18;
    int numVertsPVert = 6;
    
    int useSize = numVer * (numBands-1) * numVertsPVert;
    
    Vertex3D * coneVertices = malloc(useSize * sizeof(Vertex3D));
    
    //NSLog(@"cone size %d", ((numVer) * (numBands-1) * (numVertsPVert*2) ) );
    
    //NSLog(@"cone %d", (numVer) * (numBands-1) * numVertsPVert);
    
    NSMutableArray * theArr = detail.vertexArr;  //[orbitalArr objectAtIndex:CONE];
    
    OPVertexData * vertexData = [[OPVertexData alloc] init:useSize vertexData:(GLfloat *)coneVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr collisionRange:pCollisionRange repairAbility:pRepairAbility];
    
    [theArr addObject:vertexData];
    
    float stepAroundCircle = (TWOPIE / numVer);
    float stepHalfCircle = (M_PI / numBands);
    float iUse = 0;
    
    int x1=0;
    int x=0;
    
    float okHold[3];
    float okWidth[3];
    float okUse[3];
    
    for (int y=1; y<numBands; y++) {
        
        okWidth[0] =   sin(stepHalfCircle * (y));
        okWidth[1] =   sin(stepHalfCircle * (y+1));
        okWidth[2] =   sin(stepHalfCircle * (y-1));
        
        okUse[0] =  cos(stepHalfCircle * (y));
        okUse[1] =  cos(stepHalfCircle * (y+1));
        okUse[2] =  cos(stepHalfCircle * (y-1));
        
        for(int i=0; i < numVer; i++) {
            
            if (y % 2 == 0) {
                iUse = i;
            }
            else {
                iUse = i+1;
            }
            
            int vxx=1;
            if (vxx == 1) {
            //for (int vxx=0; vxx<2; vxx++) {
                
                //if (vxx == 1) {
                x=x1; //+((numBands-1)*numVer*numVertsPVert);
                    for (int pp=0; pp<3; pp++) {
                        okHold[pp] = (okUse[pp]*1.5);
                    }
                    //NSLog(@"X: %d %.2f %.2f",x, okHold[0], (okWidth[0] * cos(iUse * stepAroundCircle)));
                //}
                
                coneVertices[x].x = coneVertices[x+3].x = (okWidth[0] * cos(iUse * stepAroundCircle));
                coneVertices[x].y = coneVertices[x+3].y = (okWidth[0] * sin(iUse * stepAroundCircle));
                coneVertices[x].z = coneVertices[x+3].z = okHold[0];
                
                coneVertices[x].textX = coneVertices[x+3].textX = 0;
                coneVertices[x].textY = coneVertices[x+3].textY = 0;
                
                coneVertices[x+1].x = (okWidth[1] * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+1].y = (okWidth[1] * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+1].z = okHold[1];
                
                coneVertices[x+1].textX = 1;
                coneVertices[x+1].textY = 0;
                
                coneVertices[x+2].x = coneVertices[x+5].x = (okWidth[1]  * cos((iUse+2) * stepAroundCircle));
                coneVertices[x+2].y = coneVertices[x+5].y = (okWidth[1]  * sin((iUse+2) * stepAroundCircle));
                coneVertices[x+2].z = coneVertices[x+5].z = okHold[1];
                
                coneVertices[x+2].textX = coneVertices[x+5].textX = 1;
                coneVertices[x+2].textY = coneVertices[x+5].textY = 1;
                
                coneVertices[x+4].x = (okWidth[2]  * cos((iUse+1) * stepAroundCircle));
                coneVertices[x+4].y = (okWidth[2]  * sin((iUse+1) * stepAroundCircle));
                coneVertices[x+4].z = okHold[2];
                
                coneVertices[x+4].textX = 0;
                coneVertices[x+4].textY = 1;
                
                for (int xx=0; xx<numVertsPVert; xx++) {
                    if (i % 2 == 0) {
                        coneVertices[x+xx].r = theColors[0];
                        coneVertices[x+xx].g = theColors[1];
                        coneVertices[x+xx].b = theColors[2];
                        coneVertices[x+xx].alpha = theColors[3];
                        coneVertices[x+xx].normX = 0;
                        coneVertices[x+xx].normY = 1;
                        coneVertices[x+xx].normZ = 0;
                    }
                    else {
                        coneVertices[x+xx].r = theColors[4];
                        coneVertices[x+xx].g = theColors[5];
                        coneVertices[x+xx].b = theColors[6];
                        coneVertices[x+xx].alpha = theColors[7];
                        coneVertices[x+xx].normX = 1;
                        coneVertices[x+xx].normY = 0;
                        coneVertices[x+xx].normZ = 0;
                    }
                }
                
            }
            x1+=numVertsPVert;
        }
    }
}



//- (void)getSolidSphere:(float)theRadius  detail:(OPCelesrtialDetail *)detail theColors:(GLfloat[])theColors numVertices:(int)numVertices numVertices2:(int)numVertices2 subTypeStr:(NSString *)subTypeStr textureId:(unsigned int)pTextureId
//{
//    Vertex3D * stripVertices = malloc(((numVertices + 1) * 2 * numVertices2) * sizeof(Vertex3D));
//    Vertex3D * fanVertices = malloc((numVertices+2) * sizeof(Vertex3D));
//
//    NSLog(@"Sphere1 %d", ((numVertices + 1) * 2 * numVertices2) );
//    NSLog(@"Sphere2 %d", (numVertices+2) );
//    //NSLog(@"SphereV %d %d", numVertices, numVertices2);
//
//    OPVertexData * vertexData = [[OPVertexData alloc] init:(numVertices + 1) * 2 * numVertices2 vertexAuxCnt:numVertices+2 vertexData:(GLfloat *)stripVertices vertexDataAux:(GLfloat *)fanVertices typeName:(NSString *)detail.orbitalName subTypeName:subTypeStr textureId:pTextureId];
//
//    //VertexStruct vertextStructData = {(numVertices + 1) * 2 * numVertices2,numVertices+2,(GLfloat *)stripVertices,(GLfloat *)fanVertices, (char *)theTypeDetails[planetType].orbitalName,subTypeStr};
//
//    NSMutableArray * theArr =  detail.vertexArr; //[orbitalArr objectAtIndex:planetType];
//
//    //[theArr addObject:[NSValue valueWithBytes:&vertextStructData objCType:@encode(VertexStruct)]];
//
//    [theArr addObject:vertexData];
//
//    GLfloat rho, drho, theta, dtheta, rhopdrho;
//    GLfloat x, y, z;
//    drho = M_PI / (GLfloat) numVertices2;
//    dtheta = (2.0 * M_PI) / (GLfloat) numVertices;
//
//    fanVertices[0].x = 0;
//    fanVertices[0].y = 0;
//    fanVertices[0].z =  theRadius;
//
//    fanVertices[0].r = theColors[0];
//    fanVertices[0].g = theColors[1];
//    fanVertices[0].b = theColors[2];
//    fanVertices[0].alpha = 1;
//
//    GLKVector3 aVec = GLKVector3Make(fanVertices[0].x, fanVertices[0].y, fanVertices[0].z);
//
//    aVec = GLKVector3Normalize(aVec);
//
//    fanVertices[0].normX = aVec.x;
//    fanVertices[0].normY = aVec.y;
//    fanVertices[0].normZ = aVec.z;
//
//    int counter = 1;
//
//    float theRed=0, theGreen=0, theBlue=0;
//
//    z = cos(drho);
//    for (int j = 0; j <= numVertices; j++)
//    {
//        theta = (j == numVertices) ? 0.0 : j * dtheta;
//
//        x = (-sin(theta) * sin(drho));
//        y = (cos(theta) * sin(drho));
//
//        fanVertices[counter].x = x * theRadius;
//        fanVertices[counter].y = y * theRadius;
//        fanVertices[counter].z = z * theRadius;
//
//        GLKVector3 aVec = GLKVector3Make(fanVertices[counter].x, fanVertices[counter].y, fanVertices[counter].z);
//
//        aVec = GLKVector3Normalize(aVec);
//
//        if (j % 10 == 0 || j % 10 == 1) {
//            theRed =    theColors[3];
//            theGreen = theColors[4];
//            theBlue = theColors[5];
//        }
//        else {
//
//            theRed = theColors[6];
//            theGreen = theColors[7];
//            theBlue = theColors[8];
//        }
//
//        fanVertices[counter].r = theRed;
//        fanVertices[counter].g = theGreen;
//        fanVertices[counter].b = theBlue;
//        fanVertices[counter].alpha = 1;
//
//        fanVertices[counter].normX = aVec.x;
//        fanVertices[counter].normY = aVec.y;
//        fanVertices[counter].normZ = aVec.z;
//
//        counter++;
//    }
//
//    counter = 0;
//    for (int i = 0; i < numVertices2; i++) {
//        rho = i * drho;
//        rhopdrho = rho + drho;
//
//        for (int j = 0; j <= numVertices; j++)
//        {
//            theta = (j == numVertices) ? 0.0 : j * dtheta;
//            x = (-sin(theta) * sin(drho));
//            y = (cos(theta) * sin(drho));
//            z = cos(drho);
//
//            stripVertices[counter].x = x * theRadius;
//            stripVertices[counter].y = y * theRadius;
//            stripVertices[counter].z = z * theRadius;
//
//            if (j % 10 == 0 || j % 10 == 1) {
//                theRed = theColors[9];
//                theGreen = theColors[10];
//                theBlue = theColors[11];
//            }
//            else {
//                theRed = theColors[12];
//                theGreen = theColors[13];
//                theBlue = theColors[14];
//            }
//            stripVertices[counter].r = theRed;
//            stripVertices[counter].g = theGreen;
//            stripVertices[counter].b = theBlue;
//            stripVertices[counter].alpha = 1;
//
//            GLKVector3 aVec = GLKVector3Make(stripVertices[counter].x, stripVertices[counter].y, stripVertices[counter].z);
//
//            aVec = GLKVector3Normalize(aVec);
//
//            stripVertices[counter].normX = aVec.x;
//            stripVertices[counter].normY = aVec.y;
//            stripVertices[counter].normZ = aVec.z;
//
//            counter++;
//
//            x = (-sin(theta) * sin(rhopdrho));
//            y = (cos(theta) * sin(rhopdrho));
//            z = cos(rhopdrho);
//
//            //NSLog(@"KKKK: %f %f %f %f %f %f", x, y, z, theta, rho, drho);
//            //NSLog(@"KKKK: %f", z);
//
//            stripVertices[counter].x = x * theRadius;
//            stripVertices[counter].y = y * theRadius;
//            stripVertices[counter].z = z * theRadius;
//
//            if (j % 10 == 0 || j % 10 == 1) {
//
//                theRed = theColors[15];
//                theGreen = theColors[16];
//                theBlue = theColors[17];
//            }
//            else {
//
//                theRed = theColors[18];
//                theGreen = theColors[19];
//                theBlue = theColors[20];
//            }
//
//            stripVertices[counter].r = theRed;
//            stripVertices[counter].g = theGreen;
//            stripVertices[counter].b = theBlue;
//            stripVertices[counter].alpha = 1;
//
//            aVec = GLKVector3Make(stripVertices[counter].x, stripVertices[counter].y, stripVertices[counter].z);
//
//            aVec = GLKVector3Normalize(aVec);
//
//            stripVertices[counter].normX = aVec.x;
//            stripVertices[counter].normY = aVec.y;
//            stripVertices[counter].normZ = aVec.z;
//
//            counter++;
//        }
//    }
//    //NSLog(@"Counter %d", counter);
//}

- (void)processSatellite:(OPOrbitBase *)theSatellite {
    
    GLuint vertexArr = theSatellite.vertexArray;
    glGenVertexArraysOES(1, &vertexArr);
    glBindVertexArrayOES(vertexArr);
    theSatellite.vertexArray = vertexArr;
    
    GLuint vertexBuffer = theSatellite.vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    OPCelestrialDetail * theDetail = [[OPPlanetManager getSharedManager] getDetail:theSatellite.typeId];
    
    float theSize = theSatellite.vertexData.vertexCnt;
    
    if (theDetail.theFamily == POLYGON) {
        theSize *= (48*sizeof(GLfloat));
    }
    else {
        theSize *= sizeof(Vertex3D);
    }
    
    glBufferData(GL_ARRAY_BUFFER, theSize, theSatellite.vertexData.vertexData, GL_STATIC_DRAW);
    
    theSatellite.vertexBuffer = vertexBuffer;
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(12));
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(24));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 48, BUFFER_OFFSET(40));
}

@end
