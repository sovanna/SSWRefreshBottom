SSWRefreshBottom
================

PullToRefresh from bottom, a classic UIActivityIndicatorView displayed on the bottom of a tableview

This little lib was develop in 2012 when I've used the ODRefreshControl from here [ODRefreshControl](https://github.com/Sephiroth87/ODRefreshControl)
I've decided to do the same process but for the bottom, removing all chimeric and unecessary things ... and voilà

## Usage

Simply import the lib

	#import "SSWRefreshBottom.h"
	
Create a strong ref in your controller

	@property (nonatomic, strong) SSWRefreshBottom *refreshBottomControl;
	
Initialize it with your scrollView (usually a tableView)

	self.refreshBottomControl = [[SSWRefreshBottom alloc]
                                 initInTableView:self.tableView];
	[self.refreshBottomControl addTarget:self
                                  action:@selector(dropViewBottomDidBeginRefreshing:)
                        forControlEvents:UIControlEventValueChanged];
                        
Implement the selector

	- (void)dropViewBottomDidBeginRefreshing:(UIControlEvents)sender
	{
    	// Load your data
	}
	
And when you've finished to load, call

	[self.refreshBottomControl endRefreshing];