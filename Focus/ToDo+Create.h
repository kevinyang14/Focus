//
//  ToDo+Create.h
//  Focus
//
//  Created by Kevin Yang on 6/4/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "ToDo.h"

@interface ToDo (Create)

+ (ToDo *)toDoWithText:(NSString *)text
          withDeadLine:(NSDate *)deadline
         withPhotoFile:(NSString *)photoURL
         withAudioFile:(NSString *)audioURL
           withUrgency:(NSNumber *)urgency
inManagedObjectContext:(NSManagedObjectContext *)context;

@end
