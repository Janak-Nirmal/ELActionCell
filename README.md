ELActionCell
============

Requirements
------------

iOS6.0+

Usage
-----

```
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
```
