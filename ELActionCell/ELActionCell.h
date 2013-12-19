//
//  ELMailCell.h
//  ELMailCell
//
//  Created by Dmitry Nesterenko on 19.12.13.
//  Copyright (c) 2013 e-legion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+CellSearching.h"

@protocol ELMailCellDelegate <NSObject>

@optional
- (void)tableView:(UITableView *)tableView didTapButtonAtIndex:(NSUInteger)buttonIndex forCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface ELActionCell : UITableViewCell

@property (nonatomic, weak) id<ELMailCellDelegate> delegate;

@property (nonatomic, weak, readonly) UIButton *otherButton;
@property (nonatomic, weak, readonly) UIButton *destructiveButton;

@end
