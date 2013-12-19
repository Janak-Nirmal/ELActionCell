//
//  ViewController.m
//  MailCell
//
//  Created by Dmitry Nesterenko on 19.12.13.
//  Copyright (c) 2013 e-legion. All rights reserved.
//

#import "ViewController.h"
#import "ELActionCell.h"

@interface ViewController () <ELActionCellDelegate, UIActionSheetDelegate>

@end

@implementation ViewController

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.delegate = self;
    cell.textLabel.text = [NSString stringWithFormat:@"cell %@", indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didTapButtonAtIndex:(NSUInteger)buttonIndex forCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (buttonIndex == 0)
        [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Forward", @"Flag", @"Mark as Unread", nil] showInView:self.view];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;

    NSIndexPath *indexPath = [self.tableView indexPathForEditingCell];
    NSAssert(indexPath, @"Table must have cell in editing mode");
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setEditing:NO animated:YES];
}

@end
