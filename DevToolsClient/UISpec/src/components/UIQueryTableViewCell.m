#import "UIQueryTableViewCell.h"

@implementation UIQueryTableViewCell

- (void) delete
{
	UITableView* parentTableView = (UITableView*) self.parent.tableView;

	[parentTableView.dataSource tableView: parentTableView
                       commitEditingStyle: UITableViewCellEditingStyleDelete
                        forRowAtIndexPath: [parentTableView indexPathForCell: [self.views objectAtIndex: 0]]];
}

@end
