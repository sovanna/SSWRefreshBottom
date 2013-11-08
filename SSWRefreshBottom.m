//
//  SSWRefreshBottom.m
//
//  Created by Sovanna Hing on 17/08/12.
//
//  Copyright (c) 2012, Sovanna Hing.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "SSWRefreshBottom.h"

@interface SSWRefreshBottom()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) UIView *pullBottomRefreshView;
@property (nonatomic) BOOL canRefresh;
@property (nonatomic) BOOL canRefreshSendEvent;
@end

@implementation SSWRefreshBottom

@synthesize scrollView = _scrollView;
@synthesize pullBottomRefreshView = _pullBottomRefreshView;
@synthesize isAlreadyRefresh = _isAlreadyRefresh;
@synthesize canRefreshSendEvent = _canRefreshSendEvent;

#pragma mark -
#pragma mark Initializer

- (id)initInTableView:(UITableView *)scrollView
{
    self = [super initWithFrame:CGRectMake(0,
                                           0,
                                           scrollView.frame.size.width,
                                           DEFAULT_HEIGHT)];
    
    if (self) {
        _scrollView = scrollView;
        
        [_scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
        [_scrollView addObserver:self
                      forKeyPath:@"contentSize"
                         options:NSKeyValueObservingOptionNew context:nil];
        
        UIActivityIndicatorView *activity =
        [[UIActivityIndicatorView alloc]
         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [activity setCenter:CGPointMake(floor(self.frame.size.width / 2),
                                        floor(self.frame.size.height / 2))];
        [activity setAutoresizingMask:
         UIViewAutoresizingFlexibleLeftMargin |
         UIViewAutoresizingFlexibleRightMargin];
        
        [activity startAnimating];
        
        [self addSubview:activity];
    }
    
    return self;
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    self.scrollView = nil;
}

- (void)beginRefreshing
{
    if (!((UITableView *)self.scrollView).tableFooterView) {
        [((UITableView *)self.scrollView) setTableFooterView:self];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)endRefreshing
{
    [self removeBottomView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{   
    CGFloat offset = [[change objectForKey:@"new"] CGPointValue].y;
    
    if ((!self.isAlreadyRefresh) &&
        [self.scrollView isDragging] && (offset > 0.0)) {
        [self onDragging];
    }
    
    if ([self.scrollView isDecelerating] &&
        self.isAlreadyRefresh && self.canRefreshSendEvent) {
        [self setCanRefreshSendEvent:NO];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark -
#pragma mark Private

- (void)onDragging
{
    NSInteger currentOffset = self.scrollView.contentOffset.y;
    NSInteger maximumOffset = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset < -50) {
        [self addBottomView];
        [self setCanRefreshSendEvent:YES];
    }
}

#pragma mark -
#pragma mark PullBottomRefresh

- (void)initPullBottomRefresh
{
    // activity on bottom of the tableView
    self.pullBottomRefreshView = nil;
    
    UIView *tmpView = [[UIView alloc] init];
    [self setPullBottomRefreshView:tmpView];
    [self.pullBottomRefreshView
     setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] init];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [activity startAnimating];
    [activity setCenter:self.pullBottomRefreshView.center];
    
    [self.pullBottomRefreshView addSubview:activity];
    
    activity = nil;
}

- (void)addBottomView
{
    [self setIsAlreadyRefresh:YES];
    
    [self initPullBottomRefresh];
    [((UITableView *)self.scrollView) setTableFooterView:self.pullBottomRefreshView];
}

- (void)removeBottomView
{
    [self setIsAlreadyRefresh:NO];
    
    [self.pullBottomRefreshView removeFromSuperview];
    self.pullBottomRefreshView = nil;
    
    ((UITableView *)self.scrollView).tableFooterView = nil;
}

@end
