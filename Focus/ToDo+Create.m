//
//  ToDo+Create.m
//  Focus
//
//  Created by Kevin Yang on 6/4/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "ToDo+Create.h"

@implementation ToDo (Create)

+ (ToDo *)toDoWithText:(NSString *)text
          withDeadLine:(NSDate *)deadline
         withPhotoFile:(NSString *)photoURL
         withAudioFile:(NSString *)audioURL
           withUrgency:(NSNumber *)urgency
inManagedObjectContext:(NSManagedObjectContext *)context;
{
    ToDo *todo = nil;
    
    if ([text length]) {
            todo = [NSEntityDescription insertNewObjectForEntityForName:@"ToDo"
                                                         inManagedObjectContext:context];
            todo.text = text;
            todo.deadline = deadline;
            todo.audioURL = audioURL;
            todo.photoURL = photoURL;
            todo.urgency = urgency;
            todo.timeStamp = [NSDate date];
            NSLog(@"created at: %@", todo.timeStamp);
    }
    return todo;
}

@end
