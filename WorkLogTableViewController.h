//
//  WorkLogTableViewController.h
//  NGWorkLogger
//
//  Created by Nanda Gundapaneni on 10/7/15.
//  Copyright © 2015 NandaKG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface WorkLogTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end
