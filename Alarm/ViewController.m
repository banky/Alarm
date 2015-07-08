//
//  ViewController.m
//  Alarm
//
//  Created by Bankole Adebajo on 2015-06-04.
//  Copyright (c) 2015 Banky. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>

//About 10 kilometers from the location received from Google
#define radius 10000

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrLocationInfo;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) CLLocation *userCurrentLocation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[[UINavigationBar appearance]setBackgroundColor:[UIColor greenColor]];//[UIColor colorWithRed:217 green:81 blue:81 alpha:1]];
    //self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:217 green:81 blue:81 alpha:1];
    
    
    
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"locationsDatabase.sql"];
    [self loadData];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager requestAlwaysAuthorization];
    //self.locationManager.pausesLocationUpdatesAutomatically = YES;
    
    
    //TODO: Find a better way to do this
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"location updating");
    self.userCurrentLocation = [locations lastObject];

    NSInteger indexOfLatitude = [self.dbManager.arrColumnNames indexOfObject:@"latitude"];
    NSInteger indexOfLongitude = [self.dbManager.arrColumnNames indexOfObject:@"longitude"];
    
    for (int i = 0; i < self.arrLocationInfo.count; i++) {
        CLLocationDegrees latitude = [[[self.arrLocationInfo objectAtIndex:i] objectAtIndex:indexOfLatitude] doubleValue];
        CLLocationDegrees longitude = [[[self.arrLocationInfo objectAtIndex:i] objectAtIndex:indexOfLongitude] doubleValue];
        CLLocation *destination = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        //Check every destination to see if the user has arrived at one of them
        if ([self.userCurrentLocation distanceFromLocation:destination] <= radius) {
            NSLog(@"here");
            //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrLocationInfo.count;
}

- (BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        int recordIDToDelete = [[[self.arrLocationInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from userLocations where userLocationID=%d", recordIDToDelete];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // Reload the table view.
        [self loadData];
    }
    
    NSLog(@"Deleted row.");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self loadData];
    static NSString *tableIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
    }
    

    NSInteger indexOfCity = [self.dbManager.arrColumnNames indexOfObject:@"city"];
   
    cell.textLabel.text = [[self.arrLocationInfo objectAtIndex:(indexPath.row)] objectAtIndex:indexOfCity];
    
    return cell;
}

- (void)tableView:(UITableView*)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%ld", (long)indexPath.row);
    
    
    [tableview deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from userLocations";
    
    // Get the results.
    if (self.arrLocationInfo != nil) {
        self.arrLocationInfo = nil;
    }
    self.arrLocationInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if (self.arrLocationInfo.count == 0) {
        [self.tableView setHidden:YES];
    } else {
        [self.tableView setHidden:NO];
    }
    
    // Reload the table view.
    [self.tableView reloadData];

}

- (void)pushDestinationView: (NSIndexPath*)indexPath{
    NSInteger indexOfLatitude = [self.dbManager.arrColumnNames indexOfObject:@"latitude"];
    NSInteger indexOfLongitude = [self.dbManager.arrColumnNames indexOfObject:@"longitude"];
    
    
    
}

@end
