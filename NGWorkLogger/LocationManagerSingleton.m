//
//  LocationManagerSingleton.m
//  NGWorkLogger
//
//  Created by Nanda Gundapaneni on 10/7/15.
//  Copyright © 2015 NandaKG. All rights reserved.
//

#import "LocationManagerSingleton.h"

@implementation LocationManagerSingleton


+(LocationManagerSingleton *) sharedInstance
{
    static LocationManagerSingleton *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

@end
