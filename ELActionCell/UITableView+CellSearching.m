//
//  UITableView+CellSearching.m
//  ELActionCell
//
//  Created by Dmitry Nesterenko on 19.12.13.
//  Copyright (c) 2013 e-legion. All rights reserved.
//

#import "UITableView+CellSearching.h"

@implementation UITableView (CellSearching)

- (NSIndexPath *)indexPathForEditingCell
{
    NSUInteger index = [self.indexPathsForVisibleRows indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:obj];
        return cell.isEditing;
    }];

    if (index == NSNotFound)
        return nil;
    
    return self.indexPathsForVisibleRows[index];
}

@end
