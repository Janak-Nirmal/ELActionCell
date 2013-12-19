//
//  ELActionCell.m
//  ELActionCell
//
//  Created by Dmitry Nesterenko on 19.12.13.
//  Copyright (c) 2013 e-legion. All rights reserved.
//

#import "ELActionCell.h"

#define BUTTON_WIDTH 74.0

@interface ELActionCellScrollView : UIScrollView

@property (nonatomic, weak) ELActionCell *cell;

@end

@implementation ELActionCellScrollView

- (BOOL)editingCellShouldDismiss
{
    UITableView *tableView = [self.cell performSelector:@selector(tableView)];
    
    NSUInteger index = [tableView.indexPathsForVisibleRows indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:obj];
        return cell.isEditing && cell != self.cell;
    }];
    
    if (index == NSNotFound)
        return NO;
    
    NSIndexPath *indexPath = tableView.indexPathsForVisibleRows[index];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setEditing:NO animated:YES];
    
    return YES;
}

#pragma mark - Managing Gesture Recognizers

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self editingCellShouldDismiss] == NO;
}

#pragma mark - Responding to Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    if (!self.cell.isEditing) {
        if ([self editingCellShouldDismiss] == NO)
            [self.cell touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.canCancelContentTouches)
        [self.cell touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.cell touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.cell touchesCancelled:touches withEvent:event];
}

@end

@interface ELActionCell () <UIScrollViewDelegate>

// views
@property (nonatomic, weak) UIScrollView *scrollView;

// data
@property (nonatomic, assign) CGFloat scrollViewContentRightInset;

@end

@implementation ELActionCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    UIView *contentView = self.contentView;
    
    // scroll view
    ELActionCellScrollView *scrollView = [[ELActionCellScrollView alloc] initWithFrame:self.contentView.bounds];
    scrollView.cell = self;
    scrollView.showsHorizontalScrollIndicator =
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = self.frame.size;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView.superview addSubview:scrollView];
    [self.contentView removeFromSuperview];
    [scrollView addSubview:contentView];
    _scrollView = scrollView;

    // tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerStateDidChange:)];
    tap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tap];
    
    // delete button
    UIButton *destructiveButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - BUTTON_WIDTH, 0, BUTTON_WIDTH, self.contentView.bounds.size.height - 1 / [UIScreen mainScreen].scale)];
    [destructiveButton setTitle:@"Trash" forState:UIControlStateNormal];
    destructiveButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    destructiveButton.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:61.0/255.0 blue:57.0/255.0 alpha:1.0];
    destructiveButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.scrollView.superview insertSubview:destructiveButton belowSubview:self.scrollView];
    _destructiveButton = destructiveButton;
    
    // other button
    UIButton *otherButton = [[UIButton alloc] initWithFrame:CGRectOffset(self.destructiveButton.frame, -BUTTON_WIDTH, 0)];
    [otherButton setTitle:@"More" forState:UIControlStateNormal];
    otherButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    otherButton.backgroundColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
    otherButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.scrollView.superview insertSubview:otherButton belowSubview:self.scrollView];
    _otherButton = otherButton;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.scrollViewContentRightInset = CGRectGetMaxX(self.destructiveButton.frame) - CGRectGetMinX(self.otherButton.frame);
}

#pragma mark - Managing Cell Selection and Highlighting

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.scrollView.panGestureRecognizer.enabled = !self.isSelected;
}

#pragma mark - Observing View-Related Changes

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil)
        [self setTableViewObservationEnabled:NO];
}

- (void)didMoveToSuperview
{
    [self setTableViewObservationEnabled:YES];
}

#pragma mark - Table View

- (UITableView *)tableView
{
    UIView *view = self;
    while (view.superview != nil) {
        view = view.superview;
        if ([view isKindOfClass:[UITableView class]])
            break;
    }
    
    NSAssert([view isKindOfClass:[UITableView class]], @"Cell %@ must be descendant of UITableView", self);
    return (UITableView *)view;
}

- (void)setTableViewObservationEnabled:(BOOL)enabled
{
    UITableView *tableView = [self tableView];
    
    if (enabled)
        [tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:0 context:NULL];
    else
        [tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[UITableView class]] && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        UITableView *tableView = object;
        NSIndexPath *indexPath = [tableView indexPathForEditingCell];
        if (indexPath != nil) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setEditing:NO animated:YES];
        }
    }
}

#pragma mark - Editing the Cell

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (self.isEditing == editing)
        return;
  
    [super setEditing:editing animated:animated];

    if (!animated)
        return;

    // reset gesture recognizers session
    UITableView *tableView = [self tableView];
    tableView.panGestureRecognizer.enabled = NO;
    tableView.panGestureRecognizer.enabled = YES;
    
    if (editing)
        [self.scrollView setContentOffset:CGPointMake(self.scrollViewContentRightInset, self.scrollView.contentOffset.y) animated:animated];
    else
        [self.scrollView setContentOffset:CGPointZero animated:animated];
}

#pragma mark - Laying Out

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.backgroundView.superview insertSubview:self.backgroundView belowSubview:self.scrollView];
    [self.selectedBackgroundView.superview insertSubview:self.selectedBackgroundView belowSubview:self.scrollView];
    
    self.backgroundView.frame = CGRectOffset(self.backgroundView.frame, -self.scrollView.contentOffset.x, 0);
    self.selectedBackgroundView.frame = CGRectOffset(self.selectedBackgroundView.frame, -self.scrollView.contentOffset.x, 0);
}

#pragma mark - Scroll View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.scrollView)
        return;

    // content offset/inset
    if (scrollView.contentOffset.x <= 0)
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
    else {
        self.editing = YES;
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, self.scrollViewContentRightInset);
    }
    
    // relayout background views
    [self setNeedsLayout];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView != self.scrollView)
        return;
    
    if (CGPointEqualToPoint(velocity, CGPointZero)) {
        if (scrollView.contentOffset.x < self.scrollViewContentRightInset / 2) {
            if (CGPointEqualToPoint(scrollView.contentOffset, CGPointZero))
                self.editing = NO;
            else
                [scrollView setContentOffset:CGPointZero animated:YES];
        } else
            [scrollView setContentOffset:CGPointMake(scrollView.contentInset.right, scrollView.contentOffset.y) animated:YES];
        
    } else if (targetContentOffset->x < self.scrollViewContentRightInset && targetContentOffset->x >= 0) {
        if (velocity.x > 0)
            targetContentOffset->x = self.scrollViewContentRightInset;
        else
            targetContentOffset->x = 0;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0)
        self.editing = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0)
        self.editing = NO;
}

#pragma mark - Gesture Recognition

- (void)tapGestureRecognizerStateDidChange:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        if (CGRectContainsPoint(self.contentView.bounds, [gestureRecognizer locationInView:self.contentView])) {
            if (!CGPointEqualToPoint(self.scrollView.contentOffset, CGPointZero))
                [self.scrollView setContentOffset:CGPointZero animated:YES];
                
            return;
        }

        if (![self.delegate respondsToSelector:@selector(tableView:didTapButtonAtIndex:forCell:atIndexPath:)])
            return;

        UITableView *tableView = [self tableView];
        NSIndexPath *indexPath = [tableView indexPathForCell:self];

        if (CGRectContainsPoint(self.otherButton.bounds, [gestureRecognizer locationInView:self.otherButton]))
            [self.delegate tableView:tableView didTapButtonAtIndex:0 forCell:self atIndexPath:indexPath];
        else if (CGRectContainsPoint(self.destructiveButton.bounds, [gestureRecognizer locationInView:self.destructiveButton]))
            [self.delegate tableView:tableView didTapButtonAtIndex:1 forCell:self atIndexPath:indexPath];
    }
}

@end
