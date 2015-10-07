//
//  WorkLog.h
//  NGWorkLogger
//
//  Created by Nanda Gundapaneni on 10/7/15.
//  Copyright © 2015 NandaKG. All rights reserved.
//

#import <CoreData/CoreData.h>

#define kWorkLogEntry @"WorkLogEntry"
#define kWorkLogExit @"WorkLogExit"
#define kEntryDate @"entryDate"
#define kExitDate @"exitDate"

@interface WorkLogEntry : NSManagedObject

@property (nonatomic, strong) NSDate* entryDate;


@end

@interface WorkLogExit:NSManagedObject

@property (nonatomic, strong) NSDate* exitDate;

@end

@interface WorkLog : NSObject

@property (nonatomic, strong) NSArray* entries;
@property (nonatomic, strong) NSArray* exits;

- (void) sortLogs;


@end