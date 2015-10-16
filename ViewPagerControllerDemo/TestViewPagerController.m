//
//  TestViewPagerController.m
//  ViewPagerControllerDemo
//
//  Created by arbullzhang on 10/15/15.
//  Copyright © 2015 arbullzhang. All rights reserved.
//

#import "TestViewPagerController.h"

@interface TestViewPagerController ()<ViewPagerDataSource, ViewPagerDelegate>

@property (nonatomic, assign) NSInteger tabsTotal;
@property (nonatomic, assign) CGFloat myTabsViewWidth;

@end

@implementation TestViewPagerController

- (void)viewDidLoad
{
    // Do any additional setup after loading the view.
    self.tabsTotal = 3;
    self.myTabsViewWidth = 300;
    
    self.dataSource = self;
    self.delegate = self;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewPagerDataSource

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
    return self.tabsTotal;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    
    NSString *title = @"";
    switch (index) {
        case 0:
            title = @"测试1";
            break;
        case 1:
            title = @"测试2";
            break;
        case 2:
            title = @"测试3";
            break;
        default:
            break;
    }
    label.text = title;
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{
    UIViewController *vc = nil;
    switch (index) {
        case 0:
        {
            vc = [[UIViewController alloc] init];
            vc.view.backgroundColor = [UIColor lightGrayColor];
            [[vc.view viewWithTag:888888] removeFromSuperview];
            
            UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, 200, 100, 40)];
            [testButton setTitle:@"Tab个数切换" forState:UIControlStateNormal];
            [testButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            testButton.titleLabel.font = [UIFont systemFontOfSize:12];
            testButton.backgroundColor = [UIColor grayColor];
            testButton.tag = 888888;
            [testButton addTarget:self action:@selector(testButtonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
            [vc.view addSubview:testButton];
        }
            
            break;
        case 1:
            vc = [[UIViewController alloc] init];
            vc.view.backgroundColor = [UIColor yellowColor];
            break;
        case 2:
            vc = [[UIViewController alloc] init];
            vc.view.backgroundColor = [UIColor orangeColor];
            break;
        default:
            vc = [[UIViewController alloc] init];
            vc.view.backgroundColor = [UIColor orangeColor];
            break;
    }
    return vc;
}

- (void)testButtonClickedAction:(id)sender
{
    if(self.tabsTotal == 2)
    {
        self.tabsTotal = 3;
        self.myTabsViewWidth = 300;
    }
    else
    {
        self.tabsTotal = 2;
        self.myTabsViewWidth = 200;
    }
    
    [self reloadData];
}

#pragma mark - ViewPagerDelegate

- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value
{
    switch (option) {
        case ViewPagerOptionTabWidth:
            return self.myTabsViewWidth / self.tabsTotal;
            break;
        case ViewPagerOptionTabHeight:
            return 64;
            break;
        case ViewPagerOptionTabsViewXStartPos:
            return (self.view.frame.size.width - self.myTabsViewWidth) / 2;
            break;
        case ViewPagerOptionTabsViewWidth:
            return self.myTabsViewWidth;
            break;
        case ViewPagerOptionTabsViewYStartPos:
            return 20;
            break;
        case ViewPagerOptionIndicatorXStartPos:
            return 30;
            break;
        case ViewPagerOptionIndicatorWidth:
            return 36;
            break;
        default:
            break;
    }
    
    return value;
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color
{
    switch (component) {
        case ViewPagerTabsView:
            return [UIColor whiteColor];
            break;
        case ViewPagerIndicator:
            return [UIColor blueColor];
            break;
        case ViewPagerContentTextNormalColor:
            return [UIColor orangeColor];
            break;
        case ViewPagerContentTextSelectedColor:
            return [UIColor blueColor];
            break;
        default:
            break;
    }
    return color;
}

@end
