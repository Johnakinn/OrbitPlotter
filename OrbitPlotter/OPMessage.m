//
//  OPMessage.m
//  OrbitPlotter
//
//  Created by John Kinn on 12/23/17.
//  Copyright © 2017 John Kinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPMessage.h"
#import "sharedTypes.h"

@implementation NSMutableArray (QueueAdditions)
// remove objects from the head
- (id) dequeue {
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

// Add to the tail of the queue)
- (void) enqueue:(id)anObject {
    [self addObject:anObject];
    //this method automatically adds to the end of the array
}
@end

@implementation ErrorRecord

@end

@implementation PopupMsgStoreData

@end

@implementation MsgReturnData

@end


@implementation OPMessage

//static NSMutableArray * messageArr;
//static NSMutableArray * popupMessageArr;
//static NSTimeInterval lastMessageDeliverTime;
//static NSTimeInterval lastPopupDeliveryTime;

static NSMutableDictionary * theErrorDict;

//static bool isPermanentPopup;

//static const int MIN_MESSAGE_WAIT_TIME = 4; // seconds
//static const int MESSAGE_REPEAT_SECONDS = 30;

//static long currWarnMsgCnt;
//static long lastWarnMsgCnt;
//
//static long currInfoMsgCnt;
//static long lastInfoMsgCnt;
//
//static long currErrMsgCnt;
//static long lastErrMsgCnt;
//
//static long currPopupMsgCnt;
//static long lastPopupMsgCnt;

//static OPMessage * sharedMessanger;

//+ (OPMessage *)getSharedMessanger {
//    if (sharedMessanger == nil) {
//        sharedMessanger = [[OPMessage alloc] init];
//    }
//    return sharedMessanger;
//}

+ (void)loadDetails:(NSMutableDictionary *)theDic {
    
//    currInfoMsgCnt = 0;
//    lastInfoMsgCnt = 0;
//
//    currWarnMsgCnt = 0;
//    lastWarnMsgCnt = 0;
//
//    currErrMsgCnt = 0;
//    lastErrMsgCnt = 0;
//
//    currPopupMsgCnt = 0;
//    lastPopupMsgCnt = 0;
    
    NSString * theName = [NSString stringWithFormat:@"DisplayMsgDetails"];
    
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
        
        NSString * msgName = nil;
        //PlanetType theType = PLANET;
        //float maxDistance = 0;
        long msgId = -1;
        int msgTime = 0;
        //int msgDelay = 0;
        SeverityType sevType = SEVERITY_INFO;
        DisplayType dspType = DISPLAY_LABEL;
        bool isContinous = false;
        int repeatSecs = 0;
        bool popupKeep = false;
        int strArrIdx = -1;
        DurationType durType = DURATION_TIMED;
        
        int addFieldsNum = 0;
        
        for (NSString * aStr in singleStrs) {
            
            if (aStr == nil || [aStr isEqualToString:@""]) {
                continue;
            }
            
            //name:WARN_MSG_PAUSED,id=10,time=PERM,repeat=0,severity=INFO,dspType=POPUP
            
            NSArray* nameValue =
            [aStr componentsSeparatedByCharactersInSet:
             [NSCharacterSet characterSetWithCharactersInString:@":"]];
            
            if ([nameValue[0] isEqualToString:@"name"]) {
                msgName = [nameValue objectAtIndex:1];
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"id"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                msgId = [longStr intValue];
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"time"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                msgTime = [longStr intValue];
                if (msgTime == 0)
                    popupKeep = true;
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"strArrIdx"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                strArrIdx = [longStr intValue];
                addFieldsNum++;
            }
            //else if ([nameValue[0] isEqualToString:@"delay"]) {
            //    NSString * intStr = [nameValue objectAtIndex:1];
            //    msgDelay = [intStr intValue];
            //    addFieldsNum++;
            //}
            else if ([nameValue[0] isEqualToString:@"repeat"]) {
                NSString * longStr = [nameValue objectAtIndex:1];
                repeatSecs = [longStr intValue];
                if (repeatSecs > 0)
                    isContinous = true;
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"duration"]) {
                NSString * durationStr = [nameValue objectAtIndex:1];
                
                if ([durationStr isEqualToString:@"TIMED"]) {
                    durType = DURATION_TIMED;
                }
                else if ([durationStr isEqualToString:@"USER_ACK"]) {
                    durType = DURATION_USER_ACK;
                }
                else if ([durationStr isEqualToString:@"REPLACED"]) {
                    durType = DURATION_UNTIL_REPLACED;
                }
                else if ([durationStr isEqualToString:@"PERIODIC"]) {
                    durType = DURATION_PERIODIC;
                }
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"severity"]) {
                NSString * sevStr = [nameValue objectAtIndex:1];
                
                if ([sevStr isEqualToString:@"INFO"]) {
                    sevType = SEVERITY_INFO;
                }
                else if ([sevStr isEqualToString:@"WARN"]) {
                    sevType = SEVERITY_WARNING;
                }
                else if ([sevStr isEqualToString:@"ERROR"]) {
                    sevType = SEVERITY_ERROR;
                }
                addFieldsNum++;
            }
            else if ([nameValue[0] isEqualToString:@"dspType"]) {
                NSString * dspStr = [nameValue objectAtIndex:1];
                
                if ([dspStr isEqualToString:@"LABEL"]) {
                    dspType = DISPLAY_LABEL;
                }
                else if ([dspStr isEqualToString:@"RED_LABEL"]) {
                    dspType = DISPLAY_RED_LABEL;
                }
                else if ([dspStr isEqualToString:@"POPUP"]) {
                    dspType = DISPLAY_POPUP;
                }
                else if ([dspStr isEqualToString:@"POPUP_PCT"]) {
                    dspType = DISPLAY_POPUP_PCT;
                }
                addFieldsNum++;
            }
            else {
                //NSLog(@"No way msg load %@",nameValue[0]);
                break;
            }
        }
        
        if (addFieldsNum == 8) {
            ErrorRecord * theRecord = [[ErrorRecord alloc] init];
            theRecord.eventShownTime = [NSDate timeIntervalSinceReferenceDate];
            theRecord.eventNum = msgId;
            theRecord.dispType = dspType;
            theRecord.durType = durType;
            theRecord.sevType = sevType;
            theRecord.displayTime = msgTime;
            theRecord.strArrIdx = strArrIdx;
            theRecord.delayForPeriodic = repeatSecs;
            theRecord.popupKeepUntilAck = popupKeep;
            theRecord.eventDisplayed = false;
            theRecord.eventActive = false;
            //theRecord.isContinuous = isContinous;
            theRecord.turnOffPending = false;
            //theErrorDict[[NSNumber numberWithLong:msgId]] = theRecord;
            
            [theDic setObject:theRecord forKey:[NSNumber numberWithLong:theRecord.eventNum]];
        }
        else {
            NSLog(@"wrong err inp %ld", msgId);
        }
    }
}

+ (void)initErrorDict {
    if (theErrorDict == nil) {
        theErrorDict =  [NSMutableDictionary dictionaryWithCapacity:NUM_MESSAGES];
        [OPMessage loadDetails:theErrorDict];
    }
}

+ (bool)getEventForDisplay:(long)theNum {
    
    if (theErrorDict == nil)
        [OPMessage initErrorDict];
        
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:theNum]];
    if (theRecord != nil) {
        if ([self isReadyForDisplay:theRecord]) {
            theRecord.messageDisplayTime = [NSDate timeIntervalSinceReferenceDate];
            theRecord.eventDisplayed = true;
            return true;
        }
    }
    return false;
}

+ (bool)isReadyForDisplay:(ErrorRecord *)theRecord {
    if (theRecord.eventActive && (theRecord.eventDisplayed == false ||
                                  (([NSDate timeIntervalSinceReferenceDate] - theRecord.messageDisplayTime) > theRecord.delayForPeriodic && theRecord.durType == DURATION_PERIODIC))) {
        return true;
    }
    return false;
}

+ (bool)isMsgDisplayed:(long)msgNum {
    
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:msgNum]];
    if (theRecord != nil) {
        if (theRecord.eventActive && theRecord.eventDisplayed) {
            return true;
        }
    }
    return false;
}

+ (bool)isErrorActive:(long)errNum {
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:errNum]];
    if (theRecord != nil) {
        if (theRecord.eventActive) {
            if (theRecord.turnOffPending && ([NSDate timeIntervalSinceReferenceDate] - theRecord.eventShownTime) > 2 && theRecord.eventDisplayed) {
                theRecord.eventDisplayed = false;
                theRecord.eventActive = false;
                theRecord.turnOffPending = false;
            }
        }
        return theRecord.eventActive;
    }
    return false;
}

+ (ErrorRecord *)getAnyEventForDisplay {
    ErrorRecord * theRecordToCheck;
    ErrorRecord * theReturnRec = nil;
    for(NSNumber * theNum in theErrorDict) {
        theRecordToCheck = [theErrorDict objectForKey:theNum];
        
        if (theRecordToCheck.dispType == DISPLAY_LABEL || theRecordToCheck.dispType == DISPLAY_RED_LABEL) {
            if ([OPMessage isReadyForDisplay:theRecordToCheck]) {
                if (theReturnRec == nil || theReturnRec.sevType < theRecordToCheck.sevType) {
                    theReturnRec = theRecordToCheck;
                }
            }
        }
    }
    
    if (theReturnRec != nil) {
        theReturnRec.messageDisplayTime = [NSDate timeIntervalSinceReferenceDate];
        theReturnRec.eventDisplayed = true;
    }
    
    return theReturnRec;
}

+ (bool)turnErrorOn:(long)theNum {
    bool retIsAlreadyActive = false;
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:theNum]];
    if (theRecord.eventActive) {
        retIsAlreadyActive = true;
    }
    theRecord.eventActive = true;
    theRecord.eventDisplayed = false;
    theRecord.turnOffPending = false;
    return retIsAlreadyActive;
}

+ (void)turnErrorOff:(long)theNum {
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:theNum]];
    if (theRecord != nil && theRecord.eventActive) {
        if (([NSDate timeIntervalSinceReferenceDate] - theRecord.eventShownTime) > 2 && theRecord.eventDisplayed) {
            theRecord.eventActive = false;
            theRecord.eventDisplayed = false;
        }
        else {
            theRecord.turnOffPending = true;
        }
    }
}

// Mesage area

+ (NSString *)getMsgStr:(ErrorRecord *)theRecord {
    
    //ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:msgIdx]];
    
    NSString * theStr = nil;
    switch(theRecord.sevType) {
        case SEVERITY_ERROR:
            theStr = theErrorStrings[theRecord.strArrIdx];
            //theRecord.msgCntNum = lastErrMsgCnt++;
            break;
            break;
        case SEVERITY_WARNING:
            theStr = theWarningStrings[theRecord.strArrIdx];
            //theRecord.msgCntNum = lastWarnMsgCnt++;
            break;
        case SEVERITY_INFO:
            theStr = theInfoStrings[theRecord.strArrIdx];
            //theRecord.msgCntNum = lastInfoMsgCnt++;
            break;
    }
    return theStr;
}

+ (bool)addMessage:(int)msgIdx {
    
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:msgIdx]];
    
    NSString * theStr = [OPMessage getMsgStr:theRecord];
    if (theStr != nil) {
        theRecord.displayStr = theStr;
        if ([OPMessage turnErrorOn:msgIdx])
            return true;
    }
    return false;
//    if (messageArr == nil)
//        messageArr = [NSMutableArray array];
//
//    NSString * theStr = theWarningStrings[msgIdx];
//
//    [messageArr enqueue:theStr];
}

+ (bool)addMessage:(int)msgIdx param1:(int)param1 param2:(int)param2 {
    
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:msgIdx]];
    
    NSString * theStr = [OPMessage getMsgStr:theRecord];

    if (theStr != nil) {
        theRecord.displayStr = [NSString stringWithFormat:theStr,param1,param2];
        if ([OPMessage turnErrorOn:msgIdx])
            return true;
    }
    return false;
    
//    if (messageArr == nil)
//        messageArr = [NSMutableArray array];
//
//    NSString * theStr = theWarningStrings[msgIdx];
//
//    [messageArr enqueue:[NSString stringWithFormat:theStr,param1,param2]];
}

+ (bool)addMessage:(int)msgIdx param1:(int)param1 {
    
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:msgIdx]];
    
    NSString * theStr = [OPMessage getMsgStr:theRecord];
    
    if (theStr != nil) {
        theRecord.displayStr = [NSString stringWithFormat:theStr,param1];
        if ([OPMessage turnErrorOn:msgIdx])
            return true;
    }
    return false;
    
//    if (messageArr == nil)
//        messageArr = [NSMutableArray array];
//
//    NSString * theStr = theWarningStrings[msgIdx];
//
//    [messageArr enqueue:[NSString stringWithFormat:theStr,param1]];
}

// Returns string.  Don't bother putting it in a record since it's not for message
// handling system or it's just the default.
+ (NSString *)getInfoMessage:(int)msgIdx param1:(int)param1 {
    return [NSString stringWithFormat:theInfoStrings[msgIdx],param1];
}

+ (NSString *)getInfoMessage:(int)msgIdx {
    return theInfoStrings[msgIdx];
}

+ (NSString *)getWarningMessage:(int)msgIdx {
    return theWarningStrings[msgIdx];
}

+ (void)addPopupMessage:(int)msgIdx minVal:(int)minVal maxVal:(int)maxVal curVal:(int)curVal remainPct:(int)remainPct {
    
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:msgIdx]];
    
    theRecord.minVal = minVal;
    theRecord.maxVal = maxVal;
    theRecord.curVal = curVal;
    //theRecord.remainingPct = remainPct;
    
    theRecord.pctDisplayStr = [NSString stringWithFormat:@"%d%%", remainPct];
    theRecord.displayStr = thePopupStrings[theRecord.strArrIdx];
    
    [OPMessage turnErrorOn:msgIdx];
    
    //theRecord.msgCntNum = currPopupMsgCnt++;
    
//    if (popupMessageArr == nil)
//        popupMessageArr = [NSMutableArray array];
//
//    PopupMsgStoreData * storeData = [[PopupMsgStoreData alloc] init];
//
//    storeData.remainingPct = remainPct;
//    storeData.minVal = minVal;
//    storeData.maxVal = maxVal;
//    storeData.curVal = curVal;
//    storeData.messageNum = msgIdx;
//
//    [popupMessageArr enqueue:storeData];
}

+ (ErrorRecord *)getPermanentPopupMessageData:(int)msgNum {
    
    ErrorRecord * theRecord = [theErrorDict objectForKey:[NSNumber numberWithLong:msgNum]];
    
    theRecord.minVal = 0;
    theRecord.maxVal = 0;
    theRecord.curVal = 0;
    //theRecord.remainingPct = remainPct;
    
    theRecord.pctDisplayStr = @""; //[NSString stringWithFormat:@"%d%%", remainPct];
    theRecord.displayStr = thePopupStrings[theRecord.strArrIdx];
    
    [OPMessage turnErrorOn:msgNum];
    
    // Don't bother increasing cnt, it's not logged just returned.
    //theRecord.msgCntNum = currPopupMsgCnt++;
    
    return theRecord;
    
//    MsgReturnData * retData = [[MsgReturnData alloc] init];
//
//    retData.msgNum = msgNum;
//
//    retData.pctWarnStr =  nil;
//    retData.warnStr = thePopupStrings[msgNum];
//    retData.minVal = 0;
//    retData.maxVal = 0;
//    retData.curVal = 0;
//
//    retData.duration = DURATION_PERMANENT;
//
//    //isPermanentPopup = true;
//
//    return retData;
}

+ (ErrorRecord *)getNextPopupMessageData {
    
    ErrorRecord * theRecordToCheck;
    ErrorRecord * theReturnRec = nil;
    for(NSNumber * theNum in theErrorDict) {
        theRecordToCheck = [theErrorDict objectForKey:theNum];
        
        if (theRecordToCheck.dispType == DISPLAY_POPUP) {
        
            if ([OPMessage isReadyForDisplay:theRecordToCheck]) {
                if (theReturnRec == nil || theReturnRec.sevType < theRecordToCheck.sevType) {
                    theReturnRec = theRecordToCheck;
                }
            }
            
        }
    }

    if (theReturnRec != nil) {
        theReturnRec.messageDisplayTime = [NSDate timeIntervalSinceReferenceDate];
        theReturnRec.eventDisplayed = true;
    }
    return theReturnRec;
    
//    if (popupMessageArr == nil) {
//        popupMessageArr = [NSMutableArray array];
//        return nil;
//    }
//
//    if (([NSDate timeIntervalSinceReferenceDate] - lastPopupDeliveryTime) < MIN_MESSAGE_WAIT_TIME) {
//        return nil;
//    }
//    if ([popupMessageArr count] > 0) {
//        PopupMsgStoreData * popupStoreData = [popupMessageArr dequeue];
//
//        if (popupStoreData == nil)
//            return nil;
//
//        MsgReturnData * retData = [[MsgReturnData alloc] init];
//
//        lastPopupDeliveryTime = [NSDate timeIntervalSinceReferenceDate];
//
//        retData.pctWarnStr =   [NSString stringWithFormat:thePopupPctStrings[popupStoreData.messageNum], popupStoreData.remainingPct];
//        retData.warnStr = thePopupStrings[popupStoreData.messageNum];
//        retData.minVal = popupStoreData.minVal;
//        retData.maxVal = popupStoreData.maxVal;
//        retData.curVal = popupStoreData.curVal;
//
//        retData.msgNum = popupStoreData.messageNum;
//
//        retData.duration = DURATION_SHORT;
//
//        return retData;
//    }
//    return nil;
}

//+ (ErrorRecord *)getNextDisplayMessage {
//    
//    if (messageArr == nil) {
//        messageArr = [NSMutableArray array];
//        return nil;
//    }
//
//    if (([NSDate timeIntervalSinceReferenceDate] - lastMessageDeliverTime) < MIN_MESSAGE_WAIT_TIME) {
//        return nil;
//    }
//    if ([messageArr count] > 0) {
//        lastMessageDeliverTime = [NSDate timeIntervalSinceReferenceDate];
//        return [messageArr dequeue];
//    }
//    return nil;
//}

@end
