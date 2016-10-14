//
//  FocusDatabase.h
//  Focus
//
//  Created by Kevin Yang on 6/4/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#define FocusDatabaseAvailable @"FocusDatabaseAvailable"

@interface FocusDatabase : NSObject

+ (FocusDatabase *)sharedDefaultFocusDatabase;
+ (FocusDatabase *)sharedFocusDatabaseWithName:(NSString *)name;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end
