//
//  AddAlarmViewController.h
//  Alarm
//
//  Created by Bankole Adebajo on 2015-06-05.
//  Copyright (c) 2015 Banky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddAlarmViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *locationName;

- (IBAction)addLocation:(UIButton *)sender;

@end
