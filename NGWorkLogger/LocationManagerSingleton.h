//
//  LocationManagerSingleton.h
//  NGWorkLogger
//
//  Created by Nanda Gundapaneni on 10/7/15.
//  Copyright © 2015 NandaKG. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface LocationManagerSingleton : CLLocationManager

+(LocationManagerSingleton *) sharedInstance;



@end
