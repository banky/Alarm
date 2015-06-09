//
//  AddAlarmViewController.m
//  Alarm
//
//  Created by Bankole Adebajo on 2015-06-05.
//  Copyright (c) 2015 Banky. All rights reserved.
//

#import "AddAlarmViewController.h"
#import <CoreLocation/CoreLocation.h>

#define mapsAPI @"https://maps.googleapis.com/maps/api/geocode/json?address="
#define mapsAPIKey @"&key=AIzaSyD2nNGyWJXsrlAgIijoSEGuZCmGcC3wRlQ"

@interface AddAlarmViewController () <CLLocationManagerDelegate>{
    NSString *location;
}


@end

@implementation AddAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addLocation:(UIButton *)sender {
    location = self.locationName.text;
    NSArray *locationResults = [[NSArray alloc] initWithArray:[self getLocationCoordinates]];
    //CLLocationDegrees *latitude = 45.66545;
    if (locationResults.count == 0) {
        [self displayError:@"Location Not Found" description:@"No results were returned for this location"];
        return;
    }
    
    //Store the location that the user entered
    CLLocationDegrees latitude = [locationResults[0][@"geometry"][@"location"][@"lat"] doubleValue];
    CLLocationDegrees longitude = [locationResults[0][@"geometry"][@"location"][@"long"] doubleValue];
    CLLocationCoordinate2DMake(latitude, longitude);
}

- (NSArray *)getLocationCoordinates {
    NSURL *url = [NSURL URLWithString:[mapsAPI stringByAppendingString:[NSString stringWithFormat:@"%@%@", location, mapsAPIKey]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //Check that a response was received from the server
    if (responseData == nil) {
        [self displayError:@"No Response" description:@"No response was received from the server 😩"];
        return 0;
    } else {
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
        return json[@"results"];
    }
}

- (void) displayError:(NSString *)errorTitle description:(NSString *)errorDescription {
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
