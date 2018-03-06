//
//  sharedTypes.h
//  orbitPlotter3
//
//  Created by John Kinn on 7/30/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#ifndef orbitPlotter3_sharedTypes_h
#define orbitPlotter3_sharedTypes_h

#pragma once

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

//#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / PIE ) )

static const bool is_debug = false;

//#define MIN(a,b)    ((a) < (b) ? (a) : (b))
//#define MAX(a,b)    ((a) > (b) ? (a) : (b))

static const float gravity = 6.673E-11;
static const float earthMass = 5.98E24;
static const float earthRadius = 6.37E06;

//static const int ANGLE_ROUGH_AVOID_NUM = 50;

static const int repairBitHeat = 1;
static const int repairBitStructure = 2;
static const int repairBitFuel = 4;
static const int repairBitHelm = 8;
static const int repairBitWorm = 16;
static const int repairBitHold = 32;

//static const int UP = 1;
//static const int DOWN = 2;

//static const float centerDistZ = -400;

static const float PIE = M_PI;
static const float HALFPIE = PIE/2;
static const float QPIE = HALFPIE/2;
static const float TWOPIE = PIE+PIE;
//static const float MAX_ROTATE_X = PIE;
//static const float MAX_ROTATE_Y = TWOPIE;

static const int earthOrbitalPeriodSec = 93600;

static const int STAR_TEXTURE_TYPE = 5;

//static const float mapBoundryAsteroid = 16000;
//static const float mapBoundryPlanet = 100000; //35000;

static const int PERSP_ID0 = 0;
static const int PERSP_ID1 = 1;
static const int PERSP_ID2 = 2;

static const int WARN_MSG_PROXIMITY = 0;
static const int WARN_MSG_FUELLOW = 1;
static const int WARN_MSG_HIT = 2;
static const int WARN_MSG_HEAT = 3;
static const int WARN_MSG_GAMEOVER = 4;
static const int WARN_MSG_NEXT_LEVEL = 5;

static const int WARN_MSG_REFUELED = 6;
static const int WARN_MSG_HEAT_REPAIRED = 7;
static const int WARN_MSG_HIT_REPAIRED = 8;
static const int WARN_MSG_WORMHOLE = 9;

static const int WARN_POPUP_FUEL = 10;
static const int WARN_POPUP_SHIELD = 11;
static const int WARN_POPUP_HEAT = 12;
static const int WARN_POPUP_PAUSED = 13;
static const int WARN_POPUP_GAMEOVER = 14;

static const int NUM_MESSAGES = 15;

//static const int MIN_NUM_PLANETS = 6;

static const int MAX_CONSEC_SHOTS = 10;

static const float mapBoundryFrontier = 300;

enum thrustType {
    SOLO_THRUST,
    PERPETUAL_THRUST,
    SLOWING_DOWN,
    STOPPED
};
typedef enum thrustType ThrustType;

enum textureType {
    NATURAL,
    ARTIFICIAL,
    UNSPECIFIED
};
typedef enum textureType TextureType;

//enum vertexType {
//    STRIP,
//   FAN,
//    DEFAULT_VERTEX
//};
//typedef enum vertexType VertexType;

enum perspecType {
    WE_ARE,
    LOOKING_AT
};
typedef enum perspecType PersType;

enum turnDirection {
    TURN_UP,
    TURN_DOWN,
    TURN_LEFT,
    TURN_RIGHT,
    TURN_NONE
};
typedef enum turnDirection TurnDirection;


enum persNorthSouth {
    IN_NORTH,
    IN_SOUTH
};
typedef enum persNorthSouth PersNorthSouth;

enum perspecUpDown {
    FACING_UP,
    FACING_DOWN
};
typedef enum perspecUpDown PersUpDown;

enum perspecLeftRight {
    FACING_RIGHT,
    FACING_LEFT
};
typedef enum perspecLeftRight PersRightLeft;

enum perspecForwardBack {
    FACING_FORWARD,
    FACING_BACK
};
typedef enum perspecForwardBack PersForwardBack;


static const int NumMovingCelestrialShapes = 3;
enum movingCelestrialShape {
    POLYGON,
    SPHERE,
    CONE,
    RING
};
typedef enum movingCelestrialShape MovingCelestrialShape;


static const int NumCelestrialLifeScopeTypes = 3;
enum lifeScopeType {
    PIVOTAL,
    ABIDING,
    TRANSITORY,
};
typedef enum lifeScopeType LifeScopeType;

static const int NUM_PLANET_TYPES = 9;
enum planetType {
    PLANET,
    ASTEROID,
    SHIP_CELESTRIAL,
    SPACE_STATION,
    MOON,
    SATELLITE,
    PLASMA,
    STAR,
    WALL
};
typedef enum planetType PlanetType;

//enum planetSubType {
//    SATTELITE1,
//    SATTELITE2,
//    SATTELITE3,
//    ASTEROID1,
//    ASTEROID2,
//    MOON1,
//    MOON2,
//    PLANET1,
//    PLANET2,
//    PLANET3,
//    CIRCLE1,
//    CONE1,
//    LANDINGPAD,
//    NONE
//};
//typedef enum planetSubType PlanetSubType;

enum rotateAxis {
    ROTATE_AXIS_NONE = 1,
    ROTATE_AXIS_X = 2,
    ROTATE_AXIS_Y = 4,
    ROTATE_AXIS_Z = 8
};
//typedef enum rotateAxis RotateAxis;

struct OPPoint {
    CGFloat x;
    CGFloat y;
    CGFloat z;
};
typedef struct OPPoint OPPoint;

typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat normX;
    GLfloat normY;
    GLfloat normZ;
    GLfloat r;
    GLfloat g;
    GLfloat b;
    GLfloat alpha;
    GLfloat textX;
    GLfloat textY;
} Vertex3D;

//static const int MAX_STARS = 20;
//static const int MAX_PLANETS = 0;
//static const int MAX_ASTEROIDS =  300;
//static const int MAX_REFULERS = 40;

//static const int CHANCE_OF_NEW_REFULER = 100;
//static const int CHANCE_OF_NEW_STAR = 150;
//static const int CHANCE_OF_NEW_PLANET = 0;
//static const int CHANCE_OF_NEW_ASTEROID = 5;

static const int baseConeScaleFactor = 15;

//static const float MAX_MOMENTUM = 16;

//static const int minMoonScaleFactor = 20;
//static const int maxMoonScaleFactor = 40;

//static const int minPlanetScaleFactor = 150;
//static const int maxPlanetScaleFactor = 250;

//static const int minStarScaleFactor = 600;
//static const int maxStarScaleFactor = 850;

//static const int minAsteroidScaleFactor = 10;
//static const int maxAsteroidScaleFactor = 30;

//static const int minShipScaleFactor = 15;
//static const int maxShipScaleFactor = 30;

//static const int minSatScaleFactor = 5;
//static const int maxSatScaleFactor = 14;

//static const int minRingScaleFactor = 5;
//static const int maxRingScaleFactor = 8;

//static const int minConeScaleFactor = 5;
//static const int maxConeScaleFactor = 8;

static const float MAX_CELESTRIAL_DISTANCE = 100000;
static const float MAX_ASTERIOD_DISTANCE = 16000;

//typedef struct planetTypeDetail {
//    const char * orbitalName;
//    PlanetType theType;
//    const float maxDistance;
//    const long minScaleFactor;
//    const long maxScaleFactor;
//    const float maxMomentum;
//    const bool isOrbital;
//    const float minNewTime;
//    const float maxActive;
//    const float chanceOfNew;
//    LifeScopeType lifeScope;
//    MovingCelestrialShape theFamily;
//
//} PlanetTypeDetail;

//static const PlanetTypeDetail theTypeDetails[NUM_PLANET_TYPES] = {
//        {"PLANET",PLANET,MAX_CELESTRIAL_DISTANCE,minPlanetScaleFactor,maxPlanetScaleFactor,0,NO,1,MAX_PLANETS,CHANCE_OF_NEW_PLANET,ABIDING,SPHERE},
//    {"ASTEROID",ASTEROID,MAX_ASTERIOD_DISTANCE,minAsteroidScaleFactor,maxAsteroidScaleFactor,MAX_MOMENTUM,NO,.1,MAX_ASTEROIDS,CHANCE_OF_NEW_ASTEROID,TRANSITORY,POLYGON},
//    {"SHIP_CELESTRIAL",SHIP_CELESTRIAL,MAX_CELESTRIAL_DISTANCE,minShipScaleFactor,maxShipScaleFactor,MAX_MOMENTUM,NO,1,MAX_REFULERS,CHANCE_OF_NEW_REFULER,PIVOTAL,POLYGON},
//        {"MOON",MOON,MAX_CELESTRIAL_DISTANCE,minMoonScaleFactor,maxMoonScaleFactor,0,YES,1,0,0,ABIDING,SPHERE},
//        {"SATELLITE",SATELLITE,MAX_CELESTRIAL_DISTANCE,minSatScaleFactor,maxSatScaleFactor,0,YES,1,0,0,TRANSITORY,POLYGON},
//        {"RING",RING,MAX_CELESTRIAL_DISTANCE,minRingScaleFactor,maxRingScaleFactor,MAX_MOMENTUM,NO,1,0,0,TRANSITORY,SHAPE},
//        {"CONE",CONE,MAX_CELESTRIAL_DISTANCE,minConeScaleFactor,maxConeScaleFactor,MAX_MOMENTUM,NO,1,0,0,TRANSITORY,SHAPE},
//        {"STAR",STAR,MAX_CELESTRIAL_DISTANCE,minStarScaleFactor,maxStarScaleFactor,0,NO,5,MAX_STARS,CHANCE_OF_NEW_STAR,ABIDING,SPHERE}
//};

#endif
