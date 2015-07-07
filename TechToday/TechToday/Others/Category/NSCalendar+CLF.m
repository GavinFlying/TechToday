//
//  NSCalendar+CLF.m
//  jinri
//
//  Created by CaiGavin on 7/6/15.
//  Copyright (c) 2015 戴进江. All rights reserved.
//

#import "NSCalendar+CLF.h"

@implementation NSCalendar (CLF)

- (BOOL)isDateInThisYear:(NSDate *)date {
    NSDateComponents *yearNow = [self components:NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateComponents *yearDate = [self components:NSCalendarUnitYear fromDate:date];
    
    return yearNow.year == yearDate.year;
}

- (NSDateComponents *)deltaWithNow:(NSDate *)date {
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [self components:unit fromDate:date toDate:[NSDate date] options:0];
}

@end
