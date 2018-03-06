//
//  GameViewController.m
//  orbitPlotter3
//
//  Created by John Kinn on 7/29/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "OPPlanet.h"
//#import "OPSatellite.h"
//#import "OPRing.h"
#import "OPPlanetManager.h"
#import "OPCtrlPanelViewCtrlr.h"
#import "OPStatsViewCtrlr.h"
#import "OPPlanetFactory.h"
#import "OPPlanetController.h"
#import "OPMessage.h"
#import "OPWormHoleController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
//#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

//static NSString * theInfoStrings[] = {
//    @"Thrust: Single direction thrust active.",
//    @"Thrust: Perpetual thrust active.",
//    @"Planet proximity warning.",
//    @"Level %d",
//    @""
//};
//
//static NSString * theWarningStrings[] = {
//    @"Planet proximity warning.",
//    @"Fuel getting low.",
//    @"Collision!  You've been hit.",
//    @"Ship is heating up!  Too close to star.",
//    @"Game Over."
//};

enum textType {
    INFO,
    WARNING,
};
typedef enum textType TextType;

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

//enum SimState {
//    STATE_ACTIVE,
//    STATE_PAUSE,
//    SATTE_TO_ACTIVE
//};

@interface GameViewController () {
    
    //bool local_debug_on;
    
    CGFloat lightPosX;
    
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    
    ErrorRecord *popupMsgData;
    //NSTimeInterval lastPopupWarningTime;
    NSTimeInterval lastLabelWarningTime;
    
    Boolean labelWarningShown;
    //Boolean popupWarningShown;
    int warningNum;
    
    NSTimeInterval motionTime;

    //OPOrbitBase * aPlanet;
    
    //Boolean isAltPerspectiveUsed;
    
    //long lastUpdate;
    
    //bool resetOldPlanet;
    //CGFloat xSign;
    
    //int chanceOfNewLower;
    //int chanceOfNewupper;
    //int chanceOfNewPlanet;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property GLKTextureInfo* earthTextureInfo;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation GameViewController

@synthesize earthTextureInfo;

//@synthesize xAngleLabel;
//@synthesize yAngleLabel;
//@synthesize zAngleLabel;

@synthesize oneTap;
@synthesize twoTap;

//@synthesize xTextField;
//@synthesize yTextField;
//@synthesize zTextField;

@synthesize mapView;

@synthesize levelLabel;
@synthesize timeLabel;
@synthesize pointsLabel;
@synthesize damageLabel;
@synthesize fuelPctLabel;
@synthesize slideTimeLabel;

@synthesize longPress;

@synthesize motionManager;

//@synthesize xVelocityLebel;
//@synthesize yVelocityLabel;
//@synthesize zVelocityLabel;

@synthesize thrustButton;
@synthesize controlButton;

@synthesize perspHelper;

@synthesize pop;

@synthesize infoView;

@synthesize guideButton;

@synthesize thrustPerpetualButton;

@synthesize infoLabel;

@synthesize warnSlider;
@synthesize warningView;
@synthesize warnLabel;
@synthesize warnPercentLabel;
//@synthesize gameContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    perspHelper = [[PerspectiveHelper alloc] init];
    
    mapView.persHelper = perspHelper;
    infoView.persHelper = perspHelper;
    
    //NSLog(@"h %.2f w %.2f", [perspHelper screenHeight], [perspHelper screenWidth]);
    
    [OPPlanetFactory getSharedFactory].perspHelper = perspHelper;
    //[OPPlanetFactory getSharedFactory].perspHelper = gameContext;
    [OPPlanetController getSharedController].perspHelper = perspHelper;
    //[OPPlanetController getSharedController].perspHelper = perspHelper;
    [OPWormHoleController getSharedController].perspHelper = perspHelper;
    //[OPWormHoleController getSharedController].perspHelper = perspHelper;
    
    motionManager = [[CMMotionManager alloc] init];
    
    //[self displayInfoOrWarning:[OPMessage getInfoMessage:INFO_MSG1_LEVEL param1:gameContext.levelNum] labelType:INFO];
    
    //[self displayInfo:3 labelType:INFO intVal:[OPPlanetController getSharedController].gameContext.levelNum];
    
    //lastWarningTime = 0;
    //popupWarningShown = false;
    labelWarningShown = false;
    
    //warningView.frame = CGRectMake(15,20,352,128);
    [warningView setHidden:true];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    [OPMessage getEventForDisplay:WARN_MSG_FUELLOW];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [oneTap requireGestureRecognizerToFail:twoTap];
    [oneTap requireGestureRecognizerToFail:oneTap];
    
    motionTime = [NSDate timeIntervalSinceReferenceDate];
    
    [self motionControl];
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];

    glEnable(GL_DEPTH_TEST);

    glViewport(0,0, [perspHelper screenWidth], [perspHelper screenHeight]);
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;

    // --------------
    self.effect.light0.diffuseColor = GLKVector4Make(0.8, 0.8, 0.8, 1.0);
    self.effect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 0.4);
    self.effect.light0.specularColor = GLKVector4Make(0.6, 0.6, 0.2, 1.0);

    self.effect.light0.position = GLKVector4Make(50.0, 50.0, 50.0, 1.0);
    self.effect.light0.spotDirection =  GLKVector3Make(-10.0, -5.0, -3.0);

    self.effect.colorMaterialEnabled = GL_TRUE;
    // --------------------
    
    
    //glEnable(GL_DEPTH_TEST);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    int filePrdicateNum = 1;
    glActiveTexture(GL_TEXTURE0);
    for (;;) {
        
        NSString * theName = [NSString stringWithFormat:@"txtureNat%d",filePrdicateNum];
        
        NSString* path = [[NSBundle mainBundle] pathForResource:theName
                                                         ofType:@"png"];
        if (path == nil)
            break;
        
        NSError *error;
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,[NSNumber numberWithBool:YES],GLKTextureLoaderSRGB,nil];
        
        //NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft];
        GLKTextureInfo *texture;
        
        texture = [GLKTextureLoader textureWithContentsOfFile:path
                                                      options:options error:&error];
        if (texture == nil)
            NSLog(@"Error loading texture: %@", [error localizedDescription]);
        
//        GLKEffectPropertyTexture *tex = [[GLKEffectPropertyTexture alloc] init];
//        tex.enabled = YES;
//        tex.envMode = GLKTextureEnvModeDecal;
//        tex.target = GLKTextureTarget2D;
//        tex.name = texture.name;
        
        filePrdicateNum++;
    }
    perspHelper.numNaturalTextures = filePrdicateNum-1;
    
    filePrdicateNum = 1;
    //glActiveTexture(GL_TEXTURE1);
    for (;;) {

        NSString * theName = [NSString stringWithFormat:@"txtureArt%d",filePrdicateNum];

        NSString* path = [[NSBundle mainBundle] pathForResource:theName
                                                         ofType:@"png"];
        if (path == nil)
            break;

        NSError *error;
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,[NSNumber numberWithBool:YES],GLKTextureLoaderSRGB,nil];
        
        GLKTextureInfo *texture;
        
        texture = [GLKTextureLoader textureWithContentsOfFile:path
                                                      options:options error:&error];
        if (texture == nil)
            NSLog(@"Error loading texture: %@", [error localizedDescription]);

//        GLKEffectPropertyTexture *tex = [[GLKEffectPropertyTexture alloc] init];
//        tex.enabled = YES;
//        tex.envMode = GLKTextureEnvModeDecal;
//        tex.name = texture.name;
        //NSLog(@"txt name %d", texture.name);

        filePrdicateNum++;
    }
    perspHelper.numArtificialTextures = filePrdicateNum;
    
    NSString * theName = @"txtureFloor";
    
    NSString* path = [[NSBundle mainBundle] pathForResource:theName
                                                     ofType:@"png"];
    if (path != nil) {
    
        NSError *error;
    
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,[NSNumber numberWithBool:YES],GLKTextureLoaderSRGB,nil];
    
        GLKTextureInfo *texture;
    
        texture = [GLKTextureLoader textureWithContentsOfFile:path
                                                  options:options error:&error];
        if (texture == nil) {
            NSLog(@"Error loading texture: %@", [error localizedDescription]);
        }
        else {
            perspHelper.textureFloorNum = (perspHelper.numArtificialTextures+perspHelper.numNaturalTextures);
        }
    }
    
    theName = @"txtureBlank";
    
    path = [[NSBundle mainBundle] pathForResource:theName ofType:@"png"];
    if (path != nil) {
        
        NSError *error;
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,[NSNumber numberWithBool:YES],GLKTextureLoaderSRGB,nil];
        
        GLKTextureInfo *texture;
        
        texture = [GLKTextureLoader textureWithContentsOfFile:path
                                                      options:options error:&error];
        if (texture == nil) {
            NSLog(@"Error loading texture: %@", [error localizedDescription]);
        }
        else {
            perspHelper.textureBlankNum = perspHelper.numArtificialTextures+perspHelper.numNaturalTextures+1;
        }
    }
    
    perspHelper.effect = self.effect;
    //perspHelper.boundsRect = self.view.bounds;
    
    [[OPPlanetController getSharedController] setupInitialCelestrials];
    
    if (!is_debug) {
        [perspHelper setInWormHole];
        //perspHelper.inWormHole = true;
    }
    
    //[perspHelper changePerspType];
    
    glBindVertexArrayOES(0);
    
//    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

    [mapView setNeedsDisplay];
}

- (void)formPopupMessage:(ErrorRecord *)pPopupMsgData {
    
    popupMsgData = pPopupMsgData;
    
    //popupMsgData.isShown = true;
    popupMsgData.eventDisplayed = true;
    //popupWarningShown = true;
    
    popupMsgData.displayTime = [NSDate timeIntervalSinceReferenceDate];
    //lastPopupWarningTime = [NSDate timeIntervalSinceReferenceDate];
    
    warnLabel.text = popupMsgData.displayStr;
    
    if (popupMsgData.maxVal == 0) {
        [warnSlider setHidden:true];
        [warnPercentLabel setHidden:true];
    }
    else {
        [warnSlider setHidden:false];
        [warnPercentLabel setHidden:false];
        
        warnPercentLabel.text = popupMsgData.pctDisplayStr;

        warnSlider.minimumValue = popupMsgData.minVal;
        warnSlider.maximumValue = popupMsgData.maxVal;
        [warnSlider setValue:popupMsgData.curVal];
    }
    [warningView setHidden:false];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    if (perspHelper.isGameOver) {
        if (!labelWarningShown || warningNum != 4) {
            
            ErrorRecord * vPopupMsgData = [OPMessage getPermanentPopupMessageData:WARN_POPUP_GAMEOVER];
            if (vPopupMsgData != nil) {
                [self formPopupMessage:vPopupMsgData];
            }
            
            [OPMessage addMessage:WARN_MSG_GAMEOVER];
            
            //[self displayInfoOrWarning:[OPMessage getWarningMessage:WARN_MSG_GAMEOVER] labelType:WARNING];
            
            //[self displayInfo:4 labelType:WARNING];
        
            //[resetButton setHidden:false];
            //[infoLabel setHidden:true];
        }
        
        //[infoView setHidden:false];
        [warningView setHidden:true];
        
        UIImage * butt = [UIImage imageNamed:@"buttonReset.png"];
        [thrustPerpetualButton setImage:butt forState:UIControlStateNormal];
        
        [NSThread sleepForTimeInterval:2.0f];
        return;
    }
    
    if ((popupMsgData == nil) && [OPMessage getEventForDisplay:WARN_MSG_FUELLOW]) {
        //popupWarningShown = true;
        [OPMessage addMessage:WARN_MSG_FUELLOW];
        [OPMessage addPopupMessage:WARN_POPUP_FUEL minVal:0 maxVal:MAX_FUEL curVal:perspHelper.fuelCapacityIdx remainPct:[perspHelper getRemainingFuelPct]];
    }
    
    if ((popupMsgData == nil) && [OPMessage getEventForDisplay:WARN_MSG_HIT]) {
        
        //NSLog(@"Hit+++++ %d", popupWarningShown);
        
        //popupWarningShown = true;
        
        [self resetThrusts];
        
        [OPMessage addMessage:WARN_MSG_HIT];
        [OPMessage addPopupMessage:WARN_POPUP_SHIELD minVal:0 maxVal:MAX_SHIELD_STRENGTH curVal:perspHelper.impactShiledCapacityIdx remainPct:(int)(((float)((float)perspHelper.impactShiledCapacityIdx)/MAX_SHIELD_STRENGTH)*100)];
    }
    
    if ((popupMsgData == nil) && [OPMessage getEventForDisplay:WARN_MSG_HEAT]) {
        [OPMessage addMessage:WARN_MSG_HEAT];
        [OPMessage addPopupMessage:WARN_POPUP_HEAT minVal:0 maxVal:MAX_SHIELD_STRENGTH curVal:perspHelper.heatShieldCapacityIdx remainPct:(int)(((float)((float)perspHelper.heatShieldCapacityIdx)/MAX_HEAT_SHIELD_STRENGTH)*100)];
    }
    
    [self displayReleventInfo];
    
    if (!is_debug)
        if ([perspHelper isPaused])
            return;
    
    if (perspHelper.inWormHole) {
        if (!perspHelper.isWormHoleReady) {
            [mapView setHidden:true];
            [self resetThrusts];
            perspHelper.perspectType = WE_ARE;
            [OPMessage turnErrorOff:WARN_MSG_HEAT];
            [perspHelper straighten];
            perspHelper.currWallFloorTrackIdx = 4;
            [[OPWormHoleController getSharedController] setupInitial];
            [OPMessage addMessage:WARN_MSG_WORMHOLE];
        }
        [[OPWormHoleController getSharedController] updateWalls];
        perspHelper.isWormHoleReady = true;
    }
    else {
        [[OPPlanetController getSharedController] updatePlanets];
    }
    
    [mapView setNeedsDisplay];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if (!is_debug) {
      if ([perspHelper isPaused])
        return;
    }
    
    if (!perspHelper.inWormHole && [perspHelper isLevelDone]) {
        [OPMessage addMessage:WARN_MSG_NEXT_LEVEL];
        //[self displayInfoOrWarning:[OPMessage getWarningMessage:WARN_MSG_NEXT_LEVEL] labelType:WARNING];
        [perspHelper getNextLevel];
    }
    
    if (perspHelper.inWormHole && [perspHelper isWormDone]) {
        [OPPlanetController reset];
        [self associateThrustButtons];
        //[perspHelper straighten];
        [mapView setHidden:false];
        perspHelper.inWormHole = false;
        perspHelper.isWormHoleReady = false;
        //[PerspectiveHelper resetAngles:perspHelper];
        [perspHelper straighten];
    }
    
    if ([OPMessage isErrorActive:WARN_MSG_HIT]) {
        if (perspHelper.numUpdates % 2 == 0)
            glClearColor(1.0f, 0.0f, 0.0f, 1.0f );
        else
            glClearColor(0.0f, 0.0f, 0.0f, 1.0f );
    
    }
    else {
       glClearColor(0.0f, 0.0f, 0.0f, 1.0f );
    }
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (perspHelper.inWormHole) {
        if (perspHelper.isWormHoleReady)
            [[OPWormHoleController getSharedController] renderWalls];
    }
    else {
        [[OPPlanetController getSharedController] renderCircles];
        [[OPPlanetController getSharedController] renderCelestrial];
    }
    [infoView redrawIfNeeded];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    // Create shader program.
    _program = glCreateProgram();

    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }

    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }

    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);

    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);

    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
//    glBindAttribLocation(_program, GLKVertexAttribColor, "color");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");

    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);

        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }

        return NO;
    }

    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");

    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }

    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;

    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        glDeleteShader(*shader);
        return NO;
    }

    return YES;
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [[OPPlanetController getSharedController] tearDownPlanets];
    
    self.effect = nil;
}

- (IBAction)twoTapAction:(UITapGestureRecognizer *)sender {
    [perspHelper setPause:![perspHelper isPaused]];
    if ([perspHelper isPaused]) {
        ErrorRecord * vPopupMsgData = [OPMessage getPermanentPopupMessageData:WARN_POPUP_PAUSED];
        if (vPopupMsgData != nil) {
            [self formPopupMessage:vPopupMsgData];
        }
    }
    else {
        if (popupMsgData != nil && popupMsgData.eventNum == WARN_POPUP_PAUSED) {
            [warningView setHidden:true];
            [OPMessage turnErrorOff:WARN_POPUP_PAUSED];
            popupMsgData = nil;
        }
    }
}

- (IBAction)pinchAction:(UIPinchGestureRecognizer *)sender {
    
    float scale = sender.scale;
    
    [perspHelper adjustZCoord:scale];
}

- (IBAction)panAction:(UIPanGestureRecognizer *)sender {
    
    if (!is_debug)
    if ([perspHelper isPaused])
        return;
    
    CGPoint fingerVelocity = [sender velocityInView:self.view];

    if (ABS(fingerVelocity.x) > ABS(fingerVelocity.y)) {
        if(fingerVelocity.x > 0)
        {
            if (perspHelper.inWormHole && [infoView isShotFired]) {
                perspHelper->bulletXOffset+=10;
            }
            else {
            if (perspHelper.turnMoveId == 0) {  // Turn
                if (perspHelper.rotateYorZ == 0 && !perspHelper.inWormHole) {
                    [perspHelper rotateAction:TURN_RIGHT];
                }
                else {
                    [perspHelper rotateActionUsingZ:TURN_RIGHT rotateSpeed:50];
                }
                if (perspHelper.currThrustType == PERPETUAL_THRUST)
                    [perspHelper consumeFuel:perspHelper.thrustVelocity];
            }
            else {
                //[self updateXCoord:xVelosity];
                [perspHelper adjustXCoord:50];
                //[self updateZCoord:zVelosity];
            }
            }
        }
        else
        {
            if (perspHelper.inWormHole && [infoView isShotFired]) {
                perspHelper->bulletXOffset-=10;
            }
            else {
            if (perspHelper.turnMoveId == 0) {
                if (perspHelper.rotateYorZ == 0 && !perspHelper.inWormHole) {
                    [perspHelper rotateAction:TURN_LEFT];
                }
                else {
                    [perspHelper rotateActionUsingZ:TURN_LEFT rotateSpeed:50];
                }
                if (perspHelper.currThrustType == PERPETUAL_THRUST)
                    [perspHelper consumeFuel:perspHelper.thrustVelocity];
            }
            else {
                 [perspHelper adjustXCoord:-50];
            }
            }
        }
    }
    else {
        if (!perspHelper.inWormHole) {
            if (fingerVelocity.y > 0)
            {
                if (perspHelper.turnMoveId == 0) {
                    [perspHelper rotateAction:TURN_UP];
                    if (perspHelper.currThrustType == PERPETUAL_THRUST)
                        [perspHelper consumeFuel:perspHelper.thrustVelocity];
                }
                else {
                    [perspHelper adjustYCoord:-50];
                }
            }
            else
            {
                if (perspHelper.turnMoveId == 0) {
                    [perspHelper rotateAction:TURN_DOWN];
                    if (perspHelper.currThrustType == PERPETUAL_THRUST)
                        [perspHelper consumeFuel:perspHelper.thrustVelocity];
                }
                else {
                    [perspHelper adjustYCoord:50];
                }
            }
        }
        else if ([infoView isShotFired]) {
            if (fingerVelocity.y > 0) {
                perspHelper->bulletYOffset+=10;
            }
            else {
                perspHelper->bulletYOffset-=10;
            }
        }
    }
    [mapView setNeedsDisplay];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    
    CGPoint tapPt = [sender locationInView:self.view];
    
    if (!mapView.isHidden && CGRectContainsPoint(mapView.frame, tapPt)) {
        [mapView toggleRotatePersp];
    } else if ((!warningView.isHidden) && CGRectContainsPoint(warningView.frame, tapPt)) {        
        if (popupMsgData == nil || (popupMsgData != nil && popupMsgData.durType != DURATION_UNTIL_REPLACED)) {
            popupMsgData = nil;
            [warningView setHidden:true];
        }
    } else {
    
        perspHelper->bulletXOffset = tapPt.x;
        perspHelper->bulletYOffset = tapPt.y;
        [infoView fireShot];
        
        if (!perspHelper.inWormHole) {
            [[OPPlanetController getSharedController] getNearestCelestrial:tapPt];
        }
        else {
        }
    }
}

- (void)motionControl {
    
    if (perspHelper.useMotion) {
        if (![motionManager isAccelerometerActive] && [motionManager isAccelerometerAvailable] == YES) {
        [motionManager startAccelerometerUpdates];
        [motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error)
         {
             BOOL shouldMoveX = NO;
             BOOL shouldMoveY = NO;
             
             if (data.acceleration.z < -0.2) { // tilting the device to the right
                 //destX = currentX + (data.acceleration.y * kPlayerSpeed);
                 //destY = currentY;
                 shouldMoveY = YES;
             } else if (data.acceleration.z > 0.2) { // tilting the device to the left
                 //destX = currentX + (data.acceleration.y * kPlayerSpeed);
                 //destY = currentY;
                 shouldMoveY = YES;
             }
             if (data.acceleration.x < -0.25) { // tilting the device to the right
                 //destX = currentX + (data.acceleration.y * kPlayerSpeed);
                 //destY = currentY;
                 shouldMoveX = YES;
             } else if (data.acceleration.x > 0.25) { // tilting the device to the left
                 //destX = currentX + (data.acceleration.y * kPlayerSpeed);
                 //destY = currentY;
                 shouldMoveX = YES;
             }
             
             if(shouldMoveX || shouldMoveY) {
            
                 if (( [NSDate timeIntervalSinceReferenceDate] - motionTime) > .05)
                 {
                     if (data.acceleration.x > 0.17) {
                         if (perspHelper.turnMoveId == 0) {  // Turn
                             [perspHelper rotateAction:TURN_RIGHT];
                         }
                         else {
                             //[self updateXCoord:xVelosity];
                             [perspHelper adjustXCoord:50];
                             //[self updateZCoord:zVelosity];
                         }
                     }
                     else if (data.acceleration.x < -0.17) {
                         if (perspHelper.turnMoveId == 0) {
                             [perspHelper rotateAction:TURN_LEFT];
                         }
                         else {
                             [perspHelper adjustXCoord:-50];
                         }
                     }
                     
//                     if (data.acceleration.y > -0.92 && data.acceleration.y < 0) {
//                         [perspHelper adjustYCoord:50];
//                     }
//                     else if (data.acceleration.y < 0.92 && data.acceleration.y > 0) {
//                         [perspHelper adjustXCoord:-50];
//                     }
                     
                     if (data.acceleration.z < -0.20) {
                         if (perspHelper.turnMoveId == 0) {
                             [perspHelper rotateAction:TURN_UP];
                         }
                         else {
                             [perspHelper adjustYCoord:-50];
                         }
                     }
                     else if (data.acceleration.z > 0.2) {
                         if (perspHelper.turnMoveId == 0) {
                             [perspHelper rotateAction:TURN_DOWN];
                         }
                         else {
                             [perspHelper adjustYCoord:50];
                         }
                     }
                     
                     //NSLog(@"Moving %.2f %.2f %.2f", data.acceleration.x, data.acceleration.y, data.acceleration.z);
                     motionTime = [NSDate timeIntervalSinceReferenceDate];
                 }
             }
         }];
    }
    }
    else if (perspHelper.useMotion == false) {
        [motionManager stopAccelerometerUpdates];
    }
}

//- (void)lookBehind {
//
//    perspHelper.rotationY += PIE;
//
//    //mapView.rotAngleY = perspHelper.rotationY;
//    [mapView setNeedsDisplay];
//
//    NSLog(@"Look Behind");
//}

- (IBAction)longPressAction:(UILongPressGestureRecognizer *)sender {
  
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!perspHelper.inWormHole) {
            [perspHelper changePerspType];
            infoView.needsUpd = true;
        }
    }
    //[self resetActions];
}

//- (IBAction)x90Action:(UIButton *)sender {
//
//    perspHelper.rotationX += PIE/2;
//
//    //mapView.rotAngleX = perspHelper.rotationX;
//    [mapView setNeedsDisplay];
//
//}
//
//- (IBAction)y90Action:(UIButton *)sender {
//
//    perspHelper.rotationY += PIE/2;
//
//    //mapView.rotAngleY = perspHelper.rotationY;
//    [mapView setNeedsDisplay];
//
//}

//- (IBAction)z90Aciton:(UIButton *)sender {
//
//    _rotationY += PIE/2;
 //
//    mapView.rotAngleZ = _rotationY;
//    [mapView setNeedsDisplay];
//
//}

- (void)displayReleventInfo {
    
    if (([NSDate timeIntervalSinceReferenceDate] - lastLabelWarningTime) > 5) {
 
        labelWarningShown = false;
    
        ErrorRecord * errRec = [OPMessage getAnyEventForDisplay];
    
        if (errRec != nil) {
            [self displayInfoOrWarning:errRec];
        }
//        else if (perspHelper.currThrustType == PERPETUAL_THRUST) {
//            [self displayInfoOrWarning:[OPMessage getInfoMessage:INFO_MSG_PERPTHRUST] labelType:INFO];
//            //[OPMessage getInfoMessage:INFO_MSG_PERPTHRUST];
//            //[self displayInfo:1 labelType:INFO];
//        }
//        else if (perspHelper.currThrustType == SOLO_THRUST) {
//            [self displayInfoOrWarning:[OPMessage getInfoMessage:INFO_MSG_THRUST] labelType:INFO];
//            //[OPMessage getInfoMessage:INFO_MSG_THRUST];
//            //[self displayInfo:0 labelType:INFO];
//        }
//        else {
//            ErrorRecord * errRec = [OPMessage getAnyEventForDisplay];
//            if (errRec != nil) {
//                [self displayInfoOrWarning:errRec];
//            }
            else {
                if (![OPMessage isMsgDisplayed:INFO_MSG_HOLDER]) {
                    [OPMessage addMessage:INFO_MSG_HOLDER];
                    //[self displayInfoOrWarning:[OPMessage getInfoMessage:INFO_MSG_HOLDER  param1:perspHelper.levelNum] labelType:INFO];
                }
            }
//        }
    }
    
    if (popupMsgData == nil || ((([NSDate timeIntervalSinceReferenceDate] - popupMsgData.displayTime) > 5) && (popupMsgData.durType != DURATION_UNTIL_REPLACED && popupMsgData.durType != DURATION_USER_ACK ))) {
        ErrorRecord * vPopupMsgData = [OPMessage getNextPopupMessageData];
        if (vPopupMsgData != nil) {
            NSLog(@"popup on %ld", vPopupMsgData.eventNum);
            [self formPopupMessage:vPopupMsgData];
        }
        else if (popupMsgData != nil) {
            NSLog(@"popup off 5 secs %d", popupMsgData.durType);
            [warningView setHidden:true];
            //popupWarningShown = false;
            popupMsgData = nil;
            //[self resetThrusts];
        }
    }
    
    float levelTime = [NSDate timeIntervalSinceReferenceDate] - perspHelper.levelTime;
    
    if (((int)levelTime)%10 == 0) {
    
        levelLabel.text = [OPMessage getInfoMessage:INFO_MSG1_LEVEL  param1:perspHelper.levelNum];
        pointsLabel.text = [NSString stringWithFormat:@"Points: %ld", perspHelper.numPoints];
    
        timeLabel.text = [NSString stringWithFormat:@"Time: %d:%d", (int)(levelTime)/60, (int)(levelTime)%60] ;
        
        damageLabel.text = [NSString stringWithFormat:@"Dmg: %d%%",
                            (int)(((float)((float)perspHelper.impactShiledCapacityIdx)/MAX_SHIELD_STRENGTH)*100)];
        
        fuelPctLabel.text = [NSString stringWithFormat:@"Fuel: %d%%",
                             [perspHelper getRemainingFuelPct]];
        
        slideTimeLabel.text = [NSString stringWithFormat:@"WH: %d", (int)([perspHelper wormHoleCurTime])] ;
    }
}

//- (NSString *)getInfoStr:(int)idx labelType:(TextType)labelType {
//    if (labelType == INFO) {
//        return theInfoStrings[idx];
//    }
//    else {
//        return theWarningStrings[idx];
//    }
//}

//- (void)displayInfo:(int)idx labelType:(TextType)labelType intVal:(int)intVal {
//
//    NSString * theInfoStr = [self getInfoStr:idx labelType:labelType];
//
//    NSString * theFinalStr = [NSString stringWithFormat:theInfoStr, intVal];
//
//    [self displayInfoOrWarning:theFinalStr labelType:labelType];
//}
//
//- (void)displayInfo:(int)idx labelType:(TextType)labelType {
//
//    NSString * theInfoStr = [self getInfoStr:idx labelType:labelType];
//
//    [self displayInfoOrWarning:theInfoStr labelType:labelType];
//
//    //    if (labelType == INFO) {
//    //        [infoLabel setText:theInfoStrings[idx]];
//    //        [infoLabel setTextColor:[UIColor whiteColor]];
//    //    }
//    //    else {
//    //        [infoLabel setText:theWarningStrings[idx]];
//    //
//    //        lastWarningTime = [NSDate timeIntervalSinceReferenceDate];
//    //        warningShown = true;
//    //        [infoLabel setTextColor:[UIColor redColor]];
//    //    }
//}

//- (void)displayInfoOrWarning:(NSString *)theStr labelType:(TextType)labelType {
- (void)displayInfoOrWarning:(ErrorRecord *)theErrorRec {

    if (theErrorRec.sevType == SEVERITY_INFO) {
        [infoLabel setText:theErrorRec.displayStr];
        [infoLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        [infoLabel setText:theErrorRec.displayStr];
        
        lastLabelWarningTime = [NSDate timeIntervalSinceReferenceDate];
        labelWarningShown = true;
        [infoLabel setTextColor:[UIColor redColor]];
    }
}

- (IBAction)thrustPerpetualAction:(UIButton *)sender {
    
    if (perspHelper.isGameOver) {
        [self resetActions];
    }
    else if (![warningView isHidden]) {
        return;
    }
    else {
        [perspHelper togglePerpetualThrust];
        
        if (perspHelper.currThrustType == PERPETUAL_THRUST) {
            [perspHelper setRallyPtBasedOnAngles];
            [perspHelper ressetThrustAcceleration];
            //[[OPPlanetController getSharedController] ressetThrustVelocity];
            [perspHelper consumeFuel:perspHelper.thrustVelocity];
        }
        [self associateThrustButtons];
    }
    //[self displayReleventInfo];
}

- (IBAction)thrustAction:(id)sender {
    if (![warningView isHidden]) {
        return;
    }
    [perspHelper toggleSoloThrust];
    
    if (perspHelper.currThrustType == SOLO_THRUST) {
        [perspHelper setRallyPtBasedOnAngles];
        [perspHelper ressetThrustAcceleration];
        
        [perspHelper consumeFuel:perspHelper.thrustVelocity];
    }
    [self associateThrustButtons];
    //[self displayReleventInfo];
}

//- (IBAction)thrustVelocityChange:(UISlider *)sender {
//    [momCircManager setEqualizerValue:sender.value];
//}

//- (IBAction)returnActionForSegue:(UIStoryboardSegue *)returnSegue {
//    
//    if ([[returnSegue identifier] isEqualToString:@"ControlPanel"]) {
//        [self motionControl];
//    }
//}

- (IBAction)thrustRepeatTouch:(UIButton *)sender {
    NSLog(@"repeat touch thrust");
}

- (void)resetThrusts {
    [perspHelper killThrustAcceleration];
    
    [self associateThrustButtons];
}

- (void)associateThrustButtons {
    UIImage * butt;
    if (perspHelper.currThrustType == PERPETUAL_THRUST) {
        butt = [UIImage imageNamed:@"buttonStop.png"];
        [thrustPerpetualButton setImage:butt forState:UIControlStateNormal];
    }
    else {
        butt = [UIImage imageNamed:@"buttonThrustPerp.png"];
        [thrustPerpetualButton setImage:butt forState:UIControlStateNormal];
    }
    
    if (perspHelper.currThrustType == SOLO_THRUST) {
        butt = [UIImage imageNamed:@"buttonStop.png"];
        [thrustButton setImage:butt forState:UIControlStateNormal];
    }
    else {
        butt = [UIImage imageNamed:@"buttonThrustBurst.png"];
        [thrustButton setImage:butt forState:UIControlStateNormal];
    }
}

- (IBAction)rotateAction:(UIRotationGestureRecognizer *)sender {
    
}

- (void)resetActions {
    
    [OPPlanetController reset];
    
    [PerspectiveHelper reset:perspHelper];
    
    [OPWormHoleController reset];
    
    [[OPPlanetController getSharedController] setupInitialCelestrials];
    
    //[resetButton setHidden:true];
    [infoLabel setHidden:false];
    
    [warningView setHidden:true];
    [infoView setHidden:false];
    
    [self resetThrusts];
}

- (IBAction)resetAction:(UIButton *)sender {
    [self resetActions];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ControlPanel"]) {
        OPCtrlPanelViewCtrlr *vc = [segue destinationViewController];
        vc.perspHelper = perspHelper;
        vc.gameViewController = self;
    }
    else if ([[segue identifier] isEqualToString:@"Statistics"]) {
        OPStatsViewCtrlr *vc = [segue destinationViewController];
        vc.perspHelper = perspHelper;
    }
}

@end
