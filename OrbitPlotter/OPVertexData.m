//
//  OPVertexData.m
//  OrbitPlotter
//
//  Created by John Kinn on 12/6/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPVertexData.h"

@implementation OPVertexData

@synthesize vertexCnt;
//@synthesize vertexAuxCnt;
@synthesize vertexData;
//@synthesize vertexDataAux;
@synthesize typeName;
@synthesize subTypeName;
@synthesize collisionRange;
@synthesize repairAbility;

- (id)init:(const int)pVertexCnt vertexData:(GLfloat *)pVertexData typeName:(NSString *)pTypeName subTypeName:(NSString *)pSubTypeName  collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility {

//- (id)init:(const int)pVertexCnt vertexAuxCnt:(const int)pVertexAuxCnt vertexData:(GLfloat *)pVertexData vertexDataAux:(GLfloat *)pVertexDataAux typeName:(NSString *)pTypeName subTypeName:(NSString *)pSubTypeName {
    self = [super init];
    if (self) {
        self.vertexCnt = pVertexCnt;
        //self.vertexAuxCnt = pVertexAuxCnt;
        self.vertexData = pVertexData;
        //self.vertexDataAux = pVertexDataAux;
        self.typeName =  [NSString stringWithString:pTypeName];
        self.subTypeName = [NSString stringWithString:pSubTypeName];
        self.collisionRange = pCollisionRange;
        self.repairAbility = pRepairAbility;
    }
    return self;
}

@end
