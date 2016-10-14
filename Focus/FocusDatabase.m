//
//  FocusDatabase.m
//  Focus
//
//  Created by Kevin Yang on 6/4/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "FocusDatabase.h"

@interface FocusDatabase()
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation FocusDatabase

+ (FocusDatabase *)sharedDefaultFocusDatabase
{
    return [self sharedFocusDatabaseWithName:@"FocusDatabase_DEFAULT"];
}

+ (FocusDatabase *)sharedFocusDatabaseWithName:(NSString *)name
{
    @synchronized(self)
    {
        static NSMutableDictionary *databases = nil;
        if (!databases) databases = [[NSMutableDictionary alloc] init];
        
        FocusDatabase *database = nil;
        if ([name length]) {
            database = databases[name];
            if (!database) {
                database = [[self alloc] initWithName:name];
                databases[name] = database;
            }
        }
        
        return database;
    }
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        if ([name length]) {
            NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask] firstObject];
            url = [url URLByAppendingPathComponent:name];
            UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
                [document openWithCompletionHandler:^(BOOL success) {
                    if (success) self.managedObjectContext = document.managedObjectContext;
                }];
            } else {
                [document saveToURL:url
                   forSaveOperation:UIDocumentSaveForCreating
                  completionHandler:^(BOOL success) {
                      if (success) {
                          self.managedObjectContext = document.managedObjectContext;
                      }
                      
                  }];
            }
        } else {
            self = nil;
        }
    }
    return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSLog(@"setManagedObjectContext");
    _managedObjectContext = managedObjectContext;
    [[NSNotificationCenter defaultCenter] postNotificationName:FocusDatabaseAvailable
                                                        object:self];
}

@end
