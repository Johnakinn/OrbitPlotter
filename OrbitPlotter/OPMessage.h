//
//  OPMessage.h
//  OrbitPlotter
//
//  Created by John Kinn on 12/23/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#ifndef OPMessage_h
#define OPMessage_h

static NSString * theErrorStrings[] = {
    @"Error Placeholder."
};

static NSString * theInfoStrings[] = {
    @"Thrust: Single direction thrust active.",
    @"Thrust: Perpetual thrust active.",
    @"Level: %d",
    @""
};

static NSString * theWarningStrings[] = {
    @"Planet proximity warning.",
    @"Fuel getting low.",
    @"Collision!  You've been hit.",
    @"Ship is heating up!  Too close to star.",
    @"Game Over.",
    @"You have reached next level!",
    @"You have refueled!",
    @"Heat shield has been repaired!",
    @"Structure damage has been repaired!",
    @"You must negotiate wormhole."
};

static NSString * thePopupStrings[] = {
    @"Remaining Fuel.",
    @"Remaining Shield Strength.",
    @"Remaining Heat Shield Strength.",
    @"Paused.",
    @"Game Over."
};

//static NSString * thePopupPctStrings[] = {
//    @"%d%%",
//    @"%d%%",
//    @"%d%%"
//};

enum severityType {
    SEVERITY_INFO,
    SEVERITY_WARNING,
    SEVERITY_ERROR
};
typedef enum severityType SeverityType;

enum displayType {
    DISPLAY_LABEL,
    DISPLAY_RED_LABEL,
    DISPLAY_POPUP,
    DISPLAY_POPUP_PCT
};
typedef enum displayType DisplayType;

enum durationType {
    DURATION_TIMED,
    DURATION_UNTIL_REPLACED,
    DURATION_USER_ACK,
    DURATION_PERIODIC
};
typedef enum durationType DurationType;

//static const int DURATION_SHORT = 0;
//static const int DURATION_LONG = 1;
//static const int DURATION_PERMANENT = 2;

//static const int POPUP_MSG_FUEL = 0;
//static const int POPUP_MSG_HIT = 1;
//static const int POPUP_MSG_HEAT = 2;
//static const int POPUP_MSG_PAUSED = 3;
//static const int POPUP_MSG_GAMEOVER = 4;

static const int INFO_MSG_THRUST = 0;
static const int INFO_MSG_PERPTHRUST = 1;
static const int INFO_MSG1_LEVEL = 2;

static const int INFO_MSG_HOLDER = 15;

@interface PopupMsgStoreData : NSObject

@property unsigned int messageNum;
@property int minVal;
@property int maxVal;
@property int curVal;
@property int remainingPct;

@end

@interface MsgReturnData : NSObject

@property int msgNum;

@property NSString * pctWarnStr;
@property NSString * warnStr;
@property int minVal;
@property int maxVal;
@property int curVal;

@property int duration;
@property NSTimeInterval shownTime;
//@property bool isShown;

@end

@interface ErrorRecord : NSObject

@property NSTimeInterval eventShownTime;
@property NSTimeInterval messageDisplayTime;
@property long eventNum;
@property DisplayType dispType;
@property SeverityType sevType;
@property DurationType durType;
@property int displayTime;
@property int delayForPeriodic;
@property Boolean eventActive;
@property Boolean eventDisplayed;
//@property Boolean isContinuous;
@property Boolean popupKeepUntilAck;
@property Boolean turnOffPending;

//@property bool isShown;

@property NSString * pctDisplayStr;
@property NSString * displayStr;
@property int minVal;
@property int maxVal;
@property int curVal;
@property int remainingPct;
@property int strArrIdx;

@property long msgCntNum;

@end

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end

@interface OPMessage : NSObject {
}

//@property NSArray * celestrialDetailArr;
//@property NSDictionary * celestrialDetailDic;

//+ (OPMessage *)getSharedMessanger;

+ (bool)getEventForDisplay:(long)theNum;
+ (bool)isReadyForDisplay:(ErrorRecord *)theRecord;
+ (bool)isErrorActive:(long)errNum;
+ (ErrorRecord *)getAnyEventForDisplay;
//+ (bool)turnErrorOn:(long)theNum;
+ (void)turnErrorOff:(long)theNum;
+ (bool)isMsgDisplayed:(long)msgNum;

+ (bool)addMessage:(int)msgIdx param1:(int)param1 param2:(int)param2;
+ (bool)addMessage:(int)msgIdx param1:(int)param1;
+ (bool)addMessage:(int)msgIdx;
//+ (ErrorRecord *)getNextDisplayMessage;

+ (NSString *)getInfoMessage:(int)msgIdx param1:(int)param1;
+ (NSString *)getInfoMessage:(int)msgIdx;
+ (NSString *)getWarningMessage:(int)msgIdx;

+ (void)addPopupMessage:(int)msgIdx minVal:(int)minVal maxVal:(int)maxVal curVal:(int)curVal remainPct:(int)remainPct;
+ (ErrorRecord *)getNextPopupMessageData;

+ (void)permanentMessageDown;
+ (ErrorRecord *)getPermanentPopupMessageData:(int)msgNum;

@end

#endif /* OPMessage_h */
