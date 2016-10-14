//
//  MessageBubbleCell.h
//  Focus
//
//  Created by Kevin Yang on 6/1/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomToDoCell : UITableViewCell

@property (nonatomic, strong) NSString *todo;
@property (nonatomic, strong) NSDate *deadline;
@property int urgency;
@property (nonatomic, strong) NSString *photo_filename;
@property (nonatomic, strong) NSString *audio_filename;

@end
