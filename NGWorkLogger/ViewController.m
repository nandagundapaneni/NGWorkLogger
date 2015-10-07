//
//  ViewController.m
//  NGWorkLogger
//
//  Created by Nanda Gundapaneni on 10/7/15.
//  Copyright © 2015 NandaKG. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationManagerSingleton.h"
#import "WorkLog.h"
#import "WorkLogTableViewController.h"

#define kWorkZoneLocation @"kWorkZoneLocation"
#define kDefaultDistance 250
#define kDefaultSpanDistance 1000

@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKCircle* circle;
@property (nonatomic,assign) CLLocationCoordinate2D currentCoordinate;

@end

@implementation ViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCoreDateSaveError:) name:kCoreDataSaveErrorNotification object:nil];
    
    [[LocationManagerSingleton sharedInstance] setDelegate:self];
    [[LocationManagerSingleton sharedInstance] requestAlwaysAuthorization];
    
   }

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (IBAction)monitorCurrentLocation:(id)sender {
    [self showAlertForStartingWorkZoneMonitoring];
}
- (IBAction)drawBoundariesTapped:(id)sender {
    
    [self drawBoundariesAroundWorkZone];
}

- (void) startMonitoringWorkZone
{
    [self clearCoreDataLogs];
    CLCircularRegion* regionC = [[CLCircularRegion alloc] initWithCenter:self.circle.coordinate radius:kDefaultDistance identifier:kWorkZoneLocation];
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [[LocationManagerSingleton sharedInstance] startMonitoringForRegion:regionC];
    }

}

- (void) showCoreDateSaveError:(NSNotification*)notification
{
    [self showAlertForError:(NSError*)notification.object];
}

- (void) clearCoreDataLogs
{
    NSManagedObjectContext* context = self.managedObjectContext;
    
    NSError* error;
    
    NSFetchRequest *fetchRequestEntry = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityEntry = [NSEntityDescription entityForName:kWorkLogEntry
                                                   inManagedObjectContext:context];
    [fetchRequestEntry setEntity:entityEntry];
    NSArray *fetchedObjectsEntry = [context executeFetchRequest:fetchRequestEntry error:&error];

    
    NSFetchRequest *fetchRequestExit = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityExit = [NSEntityDescription entityForName:kWorkLogExit
                                                  inManagedObjectContext:context];
    [fetchRequestExit setEntity:entityExit];
    NSArray *fetchedObjectsExit = [context executeFetchRequest:fetchRequestExit error:&error];

    
    if (error == nil) {
        for (NSManagedObject* object in fetchedObjectsEntry) {
            [context  deleteObject:object];
        }
        
        for (NSManagedObject* object in fetchedObjectsExit) {
            [context  deleteObject:object];
        }
    }else{
        [self showAlertForError:error];
    }

}

- (void) drawBoundariesAroundWorkZone
{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentCoordinate, kDefaultSpanDistance, kDefaultSpanDistance);
    
    [self.mapView setCenterCoordinate:self.currentCoordinate];
    
    [self.mapView setRegion:region animated:YES];
    
    if (self.mapView.overlays.count > 0) {
        [self.mapView removeOverlays:self.mapView.overlays];
    }

    self.circle = [MKCircle circleWithCenterCoordinate:self.currentCoordinate radius:kDefaultDistance];
    [self.mapView addOverlay:self.circle];

}

#pragma mark - CoreLocation Manager Delegate
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{

    [self.mapView setShowsUserLocation:(status == kCLAuthorizationStatusAuthorizedAlways)];
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [[LocationManagerSingleton sharedInstance] startUpdatingLocation];
    }
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
   [self showAlertForError:error];
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self showAlertForEnteringExitingWorkSpace:YES];
    }
    
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [self showAlertForEnteringExitingWorkSpace:NO];
    }
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    
    self.currentCoordinate = location.coordinate;
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self showAlertForError:error];
}

- (void) showAlertForEnteringExitingWorkSpace:(BOOL)enter
{
    NSString* alertBody = enter?[NSString stringWithFormat:@"You entered your workspace TIME LOG:%@",[NSDate date]]:[NSString stringWithFormat:@"You entered your workspace TIME LOG:%@",[NSDate date]];
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"WORK LOG" message:alertBody preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];

}

- (void) showAlertForError:(NSError*)error
{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"ERROR" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) showAlertForStartingWorkZoneMonitoring
{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"Add as work zone" message:@"Would like to set current region marked on the map as your work zone? This will clear the all the data from previous work zone." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startMonitoringWorkZone];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    
    [controller addAction:okAction];
    [controller addAction:cancelAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 
    if ([segue.identifier isEqualToString:@"workLogSegue"]) {
        
        WorkLogTableViewController* worklogTableViewController = (WorkLogTableViewController*)[segue destinationViewController];
        [worklogTableViewController setManagedObjectContext:self.managedObjectContext];
        
    }
}

#pragma mark - MapKit delegate


- (MKCircleRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    [circleView setFillColor:[UIColor blueColor]];
    [circleView setStrokeColor:[UIColor blackColor]];
    [circleView setAlpha:0.5f];
    return circleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
