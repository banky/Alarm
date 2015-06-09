//
//  DBManager.h
//  Alarm
//
//  Created by Bankole Adebajo on 2015-06-06.
//  Copyright (c) 2015 Banky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;

-(void)copyDatabaseIntoDocumentsDirectory;
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

-(NSArray *)loadDataFromDB:(NSString *)query;

-(void)executeQuery:(NSString *)query;

@end
