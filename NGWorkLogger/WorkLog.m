//
//  WorkLog.m
//  NGWorkLogger
//
//  Created by Nanda Gundapaneni on 10/7/15.
//  Copyright © 2015 NandaKG. All rights reserved.
//

#import "WorkLog.h"

@implementation WorkLogEntry

@dynamic entryDate;

@end

@implementation WorkLogExit

@dynamic exitDate;

@end

@implementation WorkLog

- (void) sortLogs
{
 
    if (self.entries) {
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                            sortDescriptorWithKey:kEntryDate
                                            ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
       self.entries = [self.entries sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    if (self.exits) {
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                            sortDescriptorWithKey:kExitDate
                                            ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
        self.exits = [self.exits sortedArrayUsingDescriptors:sortDescriptors];
    }
}
@end