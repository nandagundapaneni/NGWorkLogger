//
//  WorkLogTableViewController.m
//  NGWorkLogger
//
//  Created by Nanda Gundapaneni on 10/7/15.
//  Copyright © 2015 NandaKG. All rights reserved.
//

#import "WorkLogTableViewController.h"
#import "WorkLog.h"

@interface WorkLogTableViewController ()

@property (nonatomic,strong) WorkLog* workLog;

@end

@implementation WorkLogTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadWorkLogs];
}

- (void) loadWorkLogs
{
    if (self.managedObjectContext) {
        
        self.workLog = [WorkLog new];
        
        NSManagedObjectContext* context = self.managedObjectContext;
        
        NSError* error;
        
        NSFetchRequest *fetchRequestEntry = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityEntry = [NSEntityDescription entityForName:kWorkLogEntry
                                                       inManagedObjectContext:context];
        [fetchRequestEntry setEntity:entityEntry];
        NSArray *fetchedObjectsEntry = [context executeFetchRequest:fetchRequestEntry error:&error];
        [self.workLog setEntries:fetchedObjectsEntry];
        
        NSFetchRequest *fetchRequestExit = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityExit = [NSEntityDescription entityForName:kWorkLogExit
                                                      inManagedObjectContext:context];
        [fetchRequestExit setEntity:entityExit];
        NSArray *fetchedObjectsExit = [context executeFetchRequest:fetchRequestExit error:&error];
        
        [self.workLog setExits:fetchedObjectsExit];
        
        if (error == nil && self.workLog.entries.count != 0) {
            [self.workLog sortLogs];
            [self.tableView reloadData];
        }else{
            [self showAlertForError:error];
        }
        
        
    }

}

- (void) showAlertForError:(NSError*)error
{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"ERROR" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.workLog.entries.count;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDateFormatter* formatter = [self dateFormatter];
    
    [formatter setDateFormat:@"EEEE, dd MMMM yyyy"];
    
    WorkLogEntry* entry = self.workLog.entries[section];
    NSString *dateString = [formatter stringFromDate:entry.entryDate];
    
    return dateString;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* kLogCell = @"kLogCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLogCell forIndexPath:indexPath];
    
    WorkLogEntry* entry = self.workLog.entries[indexPath.section];
    
    WorkLogExit* exit;
    
    if (self.workLog.exits.count > indexPath.section) {
        exit = self.workLog.exits[indexPath.section];
    }
    
    NSDateFormatter* formatter = [self dateFormatter];
    
    [formatter setDateFormat:@"EEEE, dd MMMM yyyy hh:mm a"];
    
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:@"Entry Log"];
            if (entry != nil) {
                 NSString *dateString = [formatter stringFromDate:entry.entryDate];
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",dateString]];
            }
            
            break;
        case 1:
            [cell.textLabel setText:@"Exit Log"];
            
            if (exit != nil) {
                NSString *dateString = [formatter stringFromDate:exit.exitDate];
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",dateString]];
            }else{
                [cell.detailTextLabel setText:@"..."];
            }
            
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSDateFormatter*) dateFormatter
{
    static NSDateFormatter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSDateFormatter new];
    });
    return instance;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
