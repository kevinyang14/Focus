//
//  ToDoListCDTVC.m
//  Focus
//
//  Created by Kevin Yang on 5/25/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "ToDoListCDTVC.h"
#import "ToDoItemViewController.h"
#import "UIImage+ImageEffects.h"
#import "CustomToDoCell.h"
#import "FocusDatabase.h"
#import "ToDo.h"
#import "ImageViewController.h"

@interface ToDoListCDTVC ()
@end

@implementation ToDoListCDTVC

- (void)viewDidAppear:(BOOL)animated
{
    FocusDatabase *focusdb = [FocusDatabase sharedDefaultFocusDatabase];
    if (focusdb.managedObjectContext) {
        self.managedObjectContext = focusdb.managedObjectContext;
    } else {
        __block __weak id observer = [[NSNotificationCenter defaultCenter] addObserverForName:FocusDatabaseAvailable
                                                                                       object:focusdb
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
                                                                                       self.managedObjectContext = focusdb.managedObjectContext;
                                                                                       [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                                   }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ToDo"];
        request.predicate = nil;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"urgency"
                                                                  ascending:NO
                                                                   selector:@selector(compare:)],
                                    [NSSortDescriptor sortDescriptorWithKey:@"deadline"
                                                                  ascending:YES
                                                                   selector:@selector(compare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}


- (IBAction)updateUrgency:(UIButton *)sender {
    UIButton *senderButton = (UIButton *)sender;
    UITableViewCell *buttonCell = (UITableViewCell *)[[[senderButton superview]superview]superview];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:buttonCell];
    ToDo *toDo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    toDo.urgency = ([toDo.urgency integerValue] >= 3) ? [NSNumber numberWithInt:1]: [NSNumber numberWithInt:[toDo.urgency integerValue]+1];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *toDos = [self.fetchedResultsController fetchedObjects];
    return [toDos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"To-Do Cell";
    CustomToDoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ToDo *toDo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.todo = toDo.text;
    cell.deadline = toDo.deadline;
    cell.audio_filename = toDo.audioURL;
    cell.photo_filename = toDo.photoURL;
    cell.urgency = [toDo.urgency integerValue];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObject *objectToBeDeleted = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:objectToBeDeleted];
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Error deleting todo, %@", [error userInfo]);
        }
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if "Show ToDo" segue
    if ([segue.identifier isEqualToString:@"Show ToDo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if ([segue.destinationViewController isKindOfClass:[ToDoItemViewController class]]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            CustomToDoCell *custom_cell = (CustomToDoCell *)cell;
            ToDoItemViewController *tdivc = segue.destinationViewController;
            tdivc.toDoText = custom_cell.todo;
        }
    }
    
    //if "Display Photo" segue
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *senderButton = (UIButton *)sender;
        UITableViewCell *buttonCell = (UITableViewCell *)[[[senderButton superview]superview]superview];
        NSIndexPath* indexPath = [self.tableView indexPathForCell:buttonCell];
        if ([segue.identifier isEqualToString:@"Display Photo"]) {
            ToDo *toDo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [self prepareImageViewController:segue.destinationViewController withTodo:toDo];
        }
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier  isEqual: @"Display Photo"]) {
        UIButton *senderButton = (UIButton *)sender;
        UITableViewCell *buttonCell = (UITableViewCell *)[[[senderButton superview]superview]superview];
        NSIndexPath* indexPath = [self.tableView indexPathForCell:buttonCell];
        ToDo *toDo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (!toDo.photoURL) {
            [self showAlert:@"No photo taken!" withTitle:@"Photo"];
            return NO;
        }
    }
    return YES;
}

- (void)prepareImageViewController:(ImageViewController *)ivc
                         withTodo:(ToDo *)toDo

{
    ivc.imageURL = [NSURL URLWithString:toDo.photoURL];
    ivc.title = toDo.text;
}

- (void)showAlert:(NSString *)alertString withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: alertString
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
