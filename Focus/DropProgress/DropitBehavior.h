//
//  DropitBehavior.h
//  Dropit
//
//  Created by Kevin Yang on 4/26/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropitBehavior : UIDynamicBehavior

- (void)addItem:(id <UIDynamicItem>) item;
- (void)removeItem:(id <UIDynamicItem>) item;

@end
