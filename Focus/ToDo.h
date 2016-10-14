//
//  ToDo.h
//  Focus
//
//  Created by Kevin Yang on 6/5/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ToDo : NSManagedObject

@property (nonatomic, retain) NSString * audioURL;
@property (nonatomic, retain) NSDate * deadline;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * urgency;
@property (nonatomic, retain) NSDate * timeStamp;

@end
