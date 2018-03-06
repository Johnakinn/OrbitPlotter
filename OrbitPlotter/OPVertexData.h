//
//  OPVertexData.h
//  OrbitPlotter
//
//  Created by John Kinn on 12/6/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPVertexData_h
#define OPVertexData_h

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>

@interface OPVertexData : NSObject

@property const int vertexCnt;
//@property const int vertexAuxCnt;
@property GLfloat * vertexData;
//@property GLfloat * vertexDataAux;
@property NSString * typeName;
@property NSString * subTypeName;
@property const int collisionRange;
@property const int repairAbility;

- (id)init:(const int)pVertexCnt vertexData:(GLfloat *)pVertexData typeName:(NSString *)pTypeName subTypeName:(NSString *)pSubTypeName collisionRange:(int)pCollisionRange repairAbility:(int)pRepairAbility;

@end

#endif /* OPVertexData_h */
