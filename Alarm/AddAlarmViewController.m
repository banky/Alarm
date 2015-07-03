//
//  AddAlarmViewController.m
//  Alarm
//
//  Created by Bankole Adebajo on 2015-06-05.
//  Copyright (c) 2015 Banky. All rights reserved.
//

#import "AddAlarmViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DBManager.h"

#define mapsAPI @"https://maps.googleapis.com/maps/api/geocode/json?address="
#define mapsAPIKey @"&key=AIzaSyD2nNGyWJXsrlAgIijoSEGuZCmGcC3wRlQ"

@interface AddAlarmViewController () <CLLocationManagerDelegate>{
    NSString *location;
}
@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation AddAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"locationsDatabase.sql"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addLocation:(UIButton *)sender {
    location = self.locationName.text;
    NSArray *locationResults = [[NSArray alloc] initWithArray:[self getLocationCoordinates]];
    if (locationResults.count == 0) {
        [self displayMessage:@"Location Not Found" description:@"No results were returned for this location"];
        return;
    }
    
    //Store the location that the user entered
    CLLocationDegrees latitude = [locationResults[0][@"geometry"][@"location"][@"lat"] doubleValue];
    CLLocationDegrees longitude = [locationResults[0][@"geometry"][@"location"][@"lng"] doubleValue];
    NSLog(@"Longitude: %f", longitude);
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self saveInfo:userLocation];
}

- (void)saveInfo:(CLLocation *)userLocation {
    NSString *query = [NSString stringWithFormat:@"insert into userLocations values(null, %f, %f);", userLocation.coordinate.latitude, userLocation.coordinate.longitude];
    NSLog(@"Query: %@", query);
    [self.dbManager executeQuery:query];
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        
        // Pop the view controller.
        [self displayMessage:@"Success!!!" description:@"The location was successfully saved to the database 😄"];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
    
}

- (NSArray *)getLocationCoordinates {
    NSString *stringURL = [NSString stringWithString:[mapsAPI stringByAppendingString:[NSString stringWithFormat:@"%@%@", location, mapsAPIKey]]];
    NSURL *url = [NSURL URLWithString:[stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //Check that a response was received from the server
    if (responseData == nil) {
        [self displayMessage:@"No Response" description:@"No response was received from the server 😩"];
        return 0;
    } else {
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
        return json[@"results"];
    }
}

- (void) displayMessage:(NSString *)errorTitle description:(NSString *)errorDescription {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:errorTitle message: errorDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
