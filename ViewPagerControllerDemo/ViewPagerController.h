//
//  ViewPagerController.h
//  ViewPagerControllerDemo
//
//  Created by arbullzhang on 10/15/15.
//  Copyright © 2015 arbullzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ViewPagerOption) {
    ViewPagerOptionTabsViewXStartPos,
    ViewPagerOptionTabsViewYStartPos,
    ViewPagerOptionTabsViewWidth,
    ViewPagerOptionTabHeight,
    ViewPagerOptionTabOffset,
    ViewPagerOptionTabWidth,
    ViewPagerOptionTabLocation,
    ViewPagerOptionStartFromSecondTab,
    ViewPagerOptionCenterCurrentTab,
    ViewPagerOptionIndicatorXStartPos,
    ViewPagerOptionIndicatorWidth,
    ViewPagerOptionIndicatorHeight
};

typedef NS_ENUM(NSUInteger, ViewPagerComponent) {
    ViewPagerIndicator,
    ViewPagerTabsView,
    ViewPagerContent,
    ViewPagerContentTextNormalColor,
    ViewPagerContentTextSelectedColor,
};

@protocol ViewPagerDataSource;
@protocol ViewPagerDelegate;

//////////////////////////////////////////////////////////////////////////////
///

@interface ViewPagerController : UIViewController

@property (nonatomic, assign) id<ViewPagerDataSource> dataSource;
@property (nonatomic, assign) id<ViewPagerDelegate> delegate;

@property (nonatomic, assign) CGFloat tabsViewXPosStart;
@property (nonatomic, assign) CGFloat tabsViewYPosStart;
@property (nonatomic, assign) CGFloat tabsViewWidth;

// Tab bar's height, defaults to 49.0
@property (nonatomic, assign) CGFloat tabHeight;
// Tab bar's offset from left, defaults to 56.0
@property (nonatomic, assign) CGFloat tabOffset;
// Any tab item's width, defaults to 128.0. To-do: make this dynamic
@property (nonatomic, assign) CGFloat tabWidth;

// 1.0: Top, 0.0: Bottom, changes tab bar's location in the screen
// Defaults to Top
@property (nonatomic, assign) CGFloat tabLocation;

// 1.0: YES, 0.0: NO, defines if view should appear with the second or the first tab
// Defaults to NO
@property (nonatomic, assign) CGFloat startFromSecondTab;

// 1.0: YES, 0.0: NO, defines if tabs should be centered, with the given tabWidth
// Defaults to NO
@property (nonatomic, assign) CGFloat centerCurrentTab;

@property (nonatomic, assign) CGFloat indicatorXStartPos;
@property (nonatomic, assign) CGFloat indicatorWidth;
@property (nonatomic, assign) CGFloat indicatorHeight;

// Colors for several parts
@property (nonatomic, retain) UIColor *indicatorColor;
@property (nonatomic, retain) UIColor *tabsViewBackgroundColor;
@property (nonatomic, retain) UIColor *contentViewBackgroundColor;
@property (nonatomic, retain) UIColor *contentViewTextNormalColor;
@property (nonatomic, retain) UIColor *contentViewTextSelectedColor;

// Reload all tabs and contents
- (void)reloadData;

@end

//////////////////////////////////////////////////////////////////////////////////////
///

@protocol ViewPagerDataSource <NSObject>

// Asks dataSource how many tabs will be
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager;
// Asks dataSource to give a view to display as a tab item
// It is suggested to return a view with a clearColor background
// So that un/selected states can be clearly seen
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index;

@optional
// The content for any tab. Return a view controller and ViewPager will use its view to show as content
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index;
- (UIView *)viewPager:(ViewPagerController *)viewPager contentViewForTabAtIndex:(NSUInteger)index;

@end

//////////////////////////////////////////////////////////////////////////////////////
///

@protocol ViewPagerDelegate <NSObject>

@optional
// delegate object must implement this method if wants to be informed when a tab changes
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index;
// Every time - reloadData called, ViewPager will ask its delegate for option values
// So you don't have to set options from ViewPager itself
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value;
/*
 * Use this method to customize the look and feel.
 * viewPager will ask its delegate for colors for its components.
 * And if they are provided, it will use them, otherwise it will use default colors.
 * Also not that, colors for tab and content views will change the tabView's and contentView's background 
 * (you should provide these views with a clearColor to see the colors),
 * and indicator will change its own color.
 */
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color;

@end
