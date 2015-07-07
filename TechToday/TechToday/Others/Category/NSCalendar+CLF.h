//
//  NSCalendar+CLF.h
//  TechToday
//
//  Created by CaiGavin on 7/6/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (CLF)

- (BOOL)isDateInThisYear:(NSDate *)date;
- (NSDateComponents *)deltaWithNow:(NSDate *)date;

@end
