//
//  ClassCell.h
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 13.08.08.
//  Copyright 2008 seriot.ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassCell : UITableViewCell
{
	IBOutlet UILabel *label;
	IBOutlet UIButton *button;
    id parentTableView;
}

@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UIButton* button;
@property (nonatomic, retain) id parentTableView;

- (IBAction) onPressButton: (id)sender;

@end
