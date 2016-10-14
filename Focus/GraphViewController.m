//
//  GraphViewController.m
//  Focus
//
//  Created by Kevin Yang on 6/5/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "FocusDatabase.h"
#import <CoreData/CoreData.h>


@interface GraphViewController ()
@property (strong, nonatomic) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

- (void)viewDidAppear:(BOOL)animated
{
    //CODE CHANGE
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
    if ([self.graphView isKindOfClass:[GraphView class]])
    {
        [self.graphView removeFromSuperview];
    }
    self.graphView = [[GraphView alloc] init];
    self.graphView.frame = self.view.frame;
    [self.view addSubview:self.graphView];
    [self.view sendSubviewToBack:self.graphView];
    //-------------
    [self updateDatabase];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:@"background_image_name"]]];
    //self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

- (void)updateDatabase
{
    FocusDatabase *focusdb = [FocusDatabase sharedDefaultFocusDatabase];
    if (focusdb.managedObjectContext) {
        self.managedObjectContext = focusdb.managedObjectContext;
        self.graphView.weekData = [self fetchData];
    } else {
        __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:FocusDatabaseAvailable
                                                                                       object:focusdb
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
                                                                                       self.managedObjectContext = focusdb.managedObjectContext;
                                                                                       [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                                       self.graphView.weekData = [self fetchData];
                                                                                   }];
    }
}

- (NSDate *)morningStartOfDay:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *morningStart = [calendar dateFromComponents:components];
    return morningStart;
}

- (NSArray *)fetchData{
    NSMutableArray *weekData = [[NSMutableArray alloc] init];
    NSDate *startDate = [NSDate date];
    startDate = [self morningStartOfDay:startDate];
    int dayIncrement = 1;

    
    for(int i=0; i<7; i++){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ToDo"];
        NSDate *endDate = [startDate dateByAddingTimeInterval:60*60*24*dayIncrement];
        request.predicate = [NSPredicate predicateWithFormat:@"(deadline >= %@) AND (deadline <= %@)", startDate, endDate];
        
        NSError *error;
        NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        [weekData addObject:[NSNumber numberWithInt:(int)[matches count]]];
        startDate = endDate;
    }
    return weekData;
}



@end
