//
//  ViewPagerController.m
//  ViewPagerControllerDemo
//
//  Created by arbullzhang on 10/15/15.
//  Copyright © 2015 arbullzhang. All rights reserved.
//

#import "ViewPagerController.h"
#import <libextobjc/EXTScope.h>

#define kDefaultTabsViewXPosStart  0.0
#define kDefaultTabsViewYPosStart  0.0
#define kDefaultTabsViewWidth      self.view.frame.size.width

#define kDefaultTabHeight          44.0 // Default tab height
#define kDefaultTabOffset          56.0 // Offset of the second and further tabs' from left
#define kDefaultTabWidth           128.0

#define kDefaultTabLocation        1.0 // 1.0: Top, 0.0: Bottom

#define kDefaultStartFromSecondTab 0.0 // 1.0: YES, 0.0: NO

#define kDefaultCenterCurrentTab   0.0 // 1.0: YES, 0.0: NO

#define kDefaultIndicatorXStartPos 0.0
#define kDefaultIndicatorXEndPos   kDefaultTabWidth
#define kDefaultIndicatorHeight    2.0

#define kContentViewTag            777777
#define kTabViewContent            888888

#define kDefaultIndicatorColor [UIColor colorWithRed:178.0/255.0 green:203.0/255.0 blue:57.0/255.0 alpha:0.75]
#define kDefaultTabsViewBackgroundColor [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:0.75]
#define kDefaultContentViewBackgroundColor [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:0.75]

#define kDefaultContentViewTextNormalColor [UIColor blackColor]
#define kDefaultContentViewTextSelectedColor [UIColor blueColor]


///////////////////////////////////////////////////////////////////////////////////////////////////
///

// TabView for tabs, that provides un/selected state indicators
@interface TabView : UIView

@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, retain) UIColor *indicatorColor;

@property (nonatomic, assign) CGFloat indicatorXStartPos;
@property (nonatomic, assign) CGFloat indicatorWidth;
@property (nonatomic, assign) CGFloat indicatorHeight;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
///

// ViewPagerController
@interface ViewPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) UIPageViewController *pageViewController;
@property (nonatomic, assign) id<UIScrollViewDelegate> origPageScrollViewDelegate;
@property (nonatomic, retain) UIScrollView *tabsView;
@property (nonatomic, retain) UIView *contentView;

@property (nonatomic, retain) NSMutableArray *tabs;
@property (nonatomic, retain) NSMutableArray *contents;
@property (nonatomic, assign) NSUInteger tabCount;
@property (nonatomic, assign, getter = isAnimatingToTab) BOOL animatingToTab;

@property (nonatomic, assign) NSUInteger activeTabIndex;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///

@implementation ViewPagerController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self defaultSettings];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self defaultSettings];
    }
    return self;
}

- (void)defaultSettings
{
    // Default settings
    self.tabHeight = kDefaultTabHeight;
    self.tabOffset = kDefaultTabOffset;
    self.tabWidth = kDefaultTabWidth;
    
    self.tabLocation = kDefaultTabLocation;
    
    self.startFromSecondTab = kDefaultStartFromSecondTab;

    self.centerCurrentTab = kDefaultCenterCurrentTab;
    
    // Default colors
    self.indicatorColor = kDefaultIndicatorColor;
    self.tabsViewBackgroundColor = kDefaultTabsViewBackgroundColor;
    self.contentViewBackgroundColor = kDefaultContentViewBackgroundColor;
    
    // pageViewController
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    //Setup some forwarding events to hijack the scrollview
    self.origPageScrollViewDelegate = ((UIScrollView*)[self.pageViewController.view.subviews objectAtIndex:0]).delegate;
    [((UIScrollView*)[self.pageViewController.view.subviews objectAtIndex:0]) setDelegate:self];
    
    self.animatingToTab = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
}

- (void)viewWillLayoutSubviews
{
    CGRect frame;
    frame = self.tabsView.frame;
    frame.origin.x = self.tabsViewXPosStart;
    frame.origin.y = self.tabLocation ? self.tabsViewYPosStart : self.view.frame.size.height - self.tabHeight;
    frame.size.width = self.tabsViewWidth;
    frame.size.height = self.tabHeight - self.tabsViewYPosStart;
    self.tabsView.frame = frame;
    
    frame = self.contentView.frame;
    frame.origin.x = 0.0;
    frame.origin.y = self.tabLocation ? self.tabHeight : 0.0;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.frame.size.height - self.tabHeight;
    self.contentView.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)handleTapGesture:(id)sender
{
    self.animatingToTab = YES;
    
    // Get the desired page's index
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)sender;
    UIView *tabView = tapGestureRecognizer.view;
    NSUInteger index = [self.tabs indexOfObject:tabView];
    
    // Get the desired viewController
    UIViewController *viewController = [self viewControllerAtIndex:index];
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (index < self.activeTabIndex)
    {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    @weakify(self);
    [self.pageViewController setViewControllers:@[viewController]
                                      direction:direction
                                       animated:YES
                                     completion:^(BOOL completed) {
                                         @strongify(self);
                                         self.animatingToTab = NO;
                                         // Set the current page again to obtain synchronisation between tabs and content
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.pageViewController setViewControllers:@[viewController]
                                                                               direction:UIPageViewControllerNavigationDirectionForward
                                                                                animated:NO
                                                                              completion:nil];
                                         });
                                     }];
    // Set activeTabIndex
    self.activeTabIndex = index;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Re-align tabs if needed
    self.activeTabIndex = self.activeTabIndex;
}

#pragma mark - Setter/Getter

- (void)setActiveTabIndex:(NSUInteger)activeTabIndex
{
    TabView *activeTabView;
    // Set to-be-inactive tab unselected
    activeTabView = [self tabViewAtIndex:self.activeTabIndex];
    activeTabView.selected = NO;
    if([[activeTabView viewWithTag:kTabViewContent] isKindOfClass:[UILabel class]])
    {
        ((UILabel *)[activeTabView viewWithTag:kTabViewContent]).textColor = self.contentViewTextNormalColor;
    }
    
    // Set to-be-active tab selected
    activeTabView = [self tabViewAtIndex:activeTabIndex];
    activeTabView.selected = YES;
    if([[activeTabView viewWithTag:kTabViewContent] isKindOfClass:[UILabel class]])
    {
        ((UILabel *)[activeTabView viewWithTag:kTabViewContent]).textColor = self.contentViewTextSelectedColor;
    }
    
    // Set current activeTabIndex
    _activeTabIndex = activeTabIndex;
    
    // Inform delegate about the change
    if ([self.delegate respondsToSelector:@selector(viewPager:didChangeTabToIndex:)])
    {
        [self.delegate viewPager:self didChangeTabToIndex:self.activeTabIndex];
    }
    
    // Bring tab to active position
    // Position the tab in center if centerCurrentTab option provided as YES
    
    UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
    CGRect frame = tabView.frame;
    
    if (self.centerCurrentTab)
    {
        frame.origin.x += (frame.size.width / 2);
        frame.origin.x -= self.tabsView.frame.size.width / 2;
        frame.size.width = self.tabsView.frame.size.width;
        
        if (frame.origin.x < 0)
        {
            frame.origin.x = 0;
        }
        
        if ((frame.origin.x + frame.size.width) > self.tabsView.contentSize.width)
        {
            frame.origin.x = (self.tabsView.contentSize.width - self.tabsView.frame.size.width);
        }
    }
    else
    {
        frame.origin.x -= self.tabOffset;
        frame.size.width = self.tabsView.frame.size.width;
    }
    
    [self.tabsView scrollRectToVisible:frame animated:YES];
}

- (void)reloadData
{
    [self configCustomizationParams];
    
    // Empty tabs and contents
    [self.tabs removeAllObjects];
    [self.contents removeAllObjects];
    
    self.tabCount = [self.dataSource numberOfTabsForViewPager:self];
    self.tabs = [NSMutableArray arrayWithCapacity:self.tabCount];
    for(NSInteger index = 0; index < self.tabCount; ++index)
    {
        [self.tabs addObject:[NSNull null]];
    }
    
    self.contents = [NSMutableArray arrayWithCapacity:self.tabCount];
    for(NSInteger index = 0; index < self.tabCount; ++index)
    {
        [self.contents addObject:[NSNull null]];
    }
    
    if(self.tabsView)
    {
        [self.tabsView removeFromSuperview];
    }
    
    // Add tabsView
    self.tabsView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tabsViewXPosStart, self.tabsViewYPosStart, self.tabsViewWidth, self.tabHeight - self.tabsViewYPosStart)];
    self.tabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tabsView.backgroundColor = self.tabsViewBackgroundColor;
    self.tabsView.showsHorizontalScrollIndicator = NO;
    self.tabsView.showsVerticalScrollIndicator = NO;
    
    [self.view insertSubview:self.tabsView atIndex:0];
    
    // Add tab views to _tabsView
    CGFloat contentSizeWidth = 0;
    for (NSInteger index = 0; index < self.tabCount; ++index)
    {
        UIView *tabView = [self tabViewAtIndex:index];
        CGRect frame = tabView.frame;
        frame.origin.x = contentSizeWidth;
        frame.size.width = self.tabWidth;
        tabView.frame = frame;
        [self.tabsView addSubview:tabView];
        
        contentSizeWidth += tabView.frame.size.width;
        
        // To capture tap events
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tabView addGestureRecognizer:tapGestureRecognizer];
    }
    
    self.tabsView.contentSize = CGSizeMake(contentSizeWidth, self.tabHeight - self.tabsViewYPosStart);
    
    // Add contentView
    self.contentView = [self.view viewWithTag:kContentViewTag];
    if (!self.contentView)
    {
        self.contentView = self.pageViewController.view;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.backgroundColor = self.contentViewBackgroundColor;
        self.contentView.bounds = self.view.bounds;
        self.contentView.tag = kContentViewTag;
        [self.view insertSubview:self.contentView atIndex:0];
    }
    
    // Set first viewController
    UIViewController *viewController;
    if (self.startFromSecondTab)
    {
        viewController = [self viewControllerAtIndex:1];
    }
    else
    {
        viewController = [self viewControllerAtIndex:0];
    }
    
    if (viewController == nil)
    {
        viewController = [[UIViewController alloc] init];
        viewController.view = [[UIView alloc] init];
    }
    
    [self.pageViewController setViewControllers:@[viewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    // Set activeTabIndex
    self.activeTabIndex = self.startFromSecondTab;
}

- (void)configCustomizationParams
{
    // Get settings if provided
    if ([self.delegate respondsToSelector:@selector(viewPager:valueForOption:withDefault:)])
    {
        self.tabsViewXPosStart = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabsViewXStartPos withDefault:kDefaultTabsViewXPosStart];
        self.tabsViewYPosStart = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabsViewYStartPos withDefault:kDefaultTabsViewYPosStart];
        self.tabsViewWidth = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabsViewWidth withDefault:kDefaultTabsViewWidth];
        
        self.tabHeight = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabHeight withDefault:kDefaultTabHeight];
        self.tabOffset = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabOffset withDefault:kDefaultTabOffset];
        self.tabWidth = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabWidth withDefault:kDefaultTabWidth];
        
        self.tabLocation = [self.delegate viewPager:self valueForOption:ViewPagerOptionTabLocation withDefault:kDefaultTabLocation];
        
        self.startFromSecondTab = [self.delegate viewPager:self valueForOption:ViewPagerOptionStartFromSecondTab withDefault:kDefaultStartFromSecondTab];
        
        self.centerCurrentTab = [self.delegate viewPager:self valueForOption:ViewPagerOptionCenterCurrentTab withDefault:kDefaultCenterCurrentTab];
        
        self.indicatorXStartPos = [self.delegate viewPager:self valueForOption:ViewPagerOptionIndicatorXStartPos withDefault:kDefaultIndicatorXStartPos];
        self.indicatorWidth = [self.delegate viewPager:self valueForOption:ViewPagerOptionIndicatorWidth withDefault:kDefaultIndicatorXEndPos];
        self.indicatorHeight = [self.delegate viewPager:self valueForOption:ViewPagerOptionIndicatorHeight withDefault:kDefaultIndicatorHeight];
    }
    
    // Get colors if provided
    if ([self.delegate respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)])
    {
        self.indicatorColor = [self.delegate viewPager:self colorForComponent:ViewPagerIndicator withDefault:kDefaultIndicatorColor];
        self.tabsViewBackgroundColor = [self.delegate viewPager:self colorForComponent:ViewPagerTabsView withDefault:kDefaultTabsViewBackgroundColor];
        self.contentViewBackgroundColor = [self.delegate viewPager:self colorForComponent:ViewPagerContent withDefault:kDefaultContentViewBackgroundColor];
        self.contentViewTextNormalColor = [self.delegate viewPager:self colorForComponent:ViewPagerContentTextNormalColor withDefault:kDefaultContentViewTextNormalColor];
        self.contentViewTextSelectedColor = [self.delegate viewPager:self colorForComponent:ViewPagerContentTextSelectedColor withDefault:kDefaultContentViewTextSelectedColor];
    }
}

- (TabView *)tabViewAtIndex:(NSUInteger)index
{
    if (index >= self.tabCount)
    {
        return nil;
    }
    
    if ([[self.tabs objectAtIndex:index] isEqual:[NSNull null]])
    {
        // Get view from dataSource
        UIView *tabViewContent = [self.dataSource viewPager:self viewForTabAtIndex:index];
        // Create TabView and subview the content
        if([tabViewContent isKindOfClass:[UILabel class]])
        {
            ((UILabel *)tabViewContent).textColor = self.contentViewTextNormalColor;
        }
        tabViewContent.tag = kTabViewContent;
        TabView *tabView = [[TabView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tabWidth, self.tabHeight - self.tabsViewYPosStart)];
        tabView.indicatorXStartPos = self.indicatorXStartPos;
        tabView.indicatorWidth = self.indicatorWidth;
        tabView.indicatorHeight = self.indicatorHeight;
        [tabView addSubview:tabViewContent];
        [tabView setClipsToBounds:YES];
        [tabView setIndicatorColor:self.indicatorColor];
        
        //tabViewContent.center = tabView.center;
        tabViewContent.frame = tabView.bounds;
        
        // Replace the null object with tabView
        [self.tabs replaceObjectAtIndex:index withObject:tabView];
    }
    
    return [self.tabs objectAtIndex:index];
}

- (NSUInteger)indexForTabView:(UIView *)tabView
{
    return [self.tabs indexOfObject:tabView];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >= self.tabCount)
    {
        return nil;
    }
    
    if ([[self.contents objectAtIndex:index] isEqual:[NSNull null]])
    {
        UIViewController *viewController;
        
        if ([self.dataSource respondsToSelector:@selector(viewPager:contentViewControllerForTabAtIndex:)])
        {
            viewController = [self.dataSource viewPager:self contentViewControllerForTabAtIndex:index];
        }
        else if ([self.dataSource respondsToSelector:@selector(viewPager:contentViewForTabAtIndex:)])
        {
            UIView *view = [self.dataSource viewPager:self contentViewForTabAtIndex:index];
            // Adjust view's bounds to match the pageView's bounds
            UIView *pageView = [self.view viewWithTag:kContentViewTag];
            view.frame = pageView.bounds;
            
            viewController = [UIViewController new];
            viewController.view = view;
        }
        else
        {
            viewController = [[UIViewController alloc] init];
            viewController.view = [[UIView alloc] init];
        }
        
        [self.contents replaceObjectAtIndex:index withObject:viewController];
    }
    
    return [self.contents objectAtIndex:index];
}

- (NSUInteger)indexForViewController:(UIViewController *)viewController
{
    return [self.contents indexOfObject:viewController];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexForViewController:viewController];
    index++;
    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexForViewController:viewController];
    index--;
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *viewController = self.pageViewController.viewControllers[0];
    self.activeTabIndex = [self indexForViewController:viewController];
}

#pragma mark - UIScrollViewDelegate, Responding to Scrolling and Dragging

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.origPageScrollViewDelegate scrollViewDidScroll:scrollView];
    }
    
    if (![self isAnimatingToTab])
    {
        UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
        
        // Get the related tab view position
        CGRect frame = tabView.frame;
        
        CGFloat movedRatio = (scrollView.contentOffset.x / scrollView.frame.size.width) - 1;
        frame.origin.x += movedRatio * frame.size.width;
        
        if (self.centerCurrentTab)
        {
            frame.origin.x += (frame.size.width / 2);
            frame.origin.x -= self.tabsView.frame.size.width / 2;
            frame.size.width = self.tabsView.frame.size.width;
            
            if (frame.origin.x < 0)
            {
                frame.origin.x = 0;
            }
            
            if ((frame.origin.x + frame.size.width) > self.tabsView.contentSize.width)
            {
                frame.origin.x = (self.tabsView.contentSize.width - self.tabsView.frame.size.width);
            }
        }
        else
        {
            frame.origin.x -= self.tabOffset;
            frame.size.width = self.tabsView.frame.size.width;
        }
        
        [self.tabsView scrollRectToVisible:frame animated:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [self.origPageScrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
    {
        [self.origPageScrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [self.origPageScrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
    {
        return [self.origPageScrollViewDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
    {
        [self.origPageScrollViewDelegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
    {
        [self.origPageScrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [self.origPageScrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - UIScrollViewDelegate, Managing Zooming

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
    {
        return [self.origPageScrollViewDelegate viewForZoomingInScrollView:scrollView];
    }
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
    {
        [self.origPageScrollViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
        [self.origPageScrollViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)])
    {
        [self.origPageScrollViewDelegate scrollViewDidZoom:scrollView];
    }
}

#pragma mark - UIScrollViewDelegate, Responding to Scrolling Animations

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
    {
        [self.origPageScrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///

@implementation TabView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    // Update view as state changed
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *bezierPath;
    
    // Draw an indicator line if tab is selected
    if (self.selected)
    {
        bezierPath = [UIBezierPath bezierPath];
        
        // Draw the indicator
        [bezierPath moveToPoint:CGPointMake(self.indicatorXStartPos, rect.size.height - 1.0)];
        [bezierPath addLineToPoint:CGPointMake(self.indicatorXStartPos + self.indicatorWidth, rect.size.height - 1.0)];
        [bezierPath setLineWidth:self.indicatorHeight];
        [self.indicatorColor setStroke];
        [bezierPath stroke];
    }
}

@end