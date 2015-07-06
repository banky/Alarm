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


@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrPeopleInfo;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.tableView.delegate = self;
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"locationsDatabase.sql"];
    [self loadData];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    
    
    //TODO: Find a better way to do this
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrPeopleInfo.count;
}

- (BOOL) tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        int recordIDToDelete = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
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
    
    //if (self.arrPeopleInfo[indexPath.row][3]) {
        //cell.textLabel.text = [NSString stringWithFormat:@"%@", self.arrPeopleInfo[indexPath.row]];
    NSInteger indexOfCity = [self.dbManager.arrColumnNames indexOfObject:@"city"];
    NSLog(@"indexpath.row: %ld", (long)indexPath.row);
    cell.textLabel.text = [[self.arrPeopleInfo objectAtIndex:(indexPath.row)] objectAtIndex:indexOfCity];
    
    //[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfFirstname]
    //} else {
    //    cell.textLabel.text = @"Could not get";
    //}
    return cell;
}

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from userLocations";
    
    // Get the results.
    if (self.arrPeopleInfo != nil) {
        self.arrPeopleInfo = nil;
    }
    self.arrPeopleInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    if (self.arrPeopleInfo.count == 0) {
        [self.tableView setHidden:YES];
    } else {
        [self.tableView setHidden:NO];
    }
    
    // Reload the table view.
    [self.tableView reloadData];
}
@end
