//
//  CYMainViewController.m
//  CYFilter
//
//  Created by yi chen on 12-7-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "CYMainViewController.h"
#import "CYShowCaseFilterViewController.h"

@interface CYMainViewController ()

@end

@implementation CYMainViewController
@synthesize startButton = _startButton;

- (void)dealloc{
	self.startButton = nil;
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView{
	[super loadView];
	[self.view addSubview: self.startButton];
}

/**
 *	测试按钮
 */
- (UIButton *)startButton{
	if (!_startButton) {
		//test code...
		UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		startButton.frame = CGRectMake(50, 50, 100, 50);
		[startButton setTitle:@"开始" forState:UIControlStateNormal];
		[startButton setTitle:@"开始" forState:(UIControlStateHighlighted | UIControlStateSelected ) ];
		[startButton addTarget:self action:@selector(onClickStartButton) forControlEvents:UIControlEventTouchUpInside];
		startButton.backgroundColor = [UIColor clearColor];
		_startButton = startButton;
	}
	return _startButton;
}

/**
 * 测试按钮点击
 */
- (void)onClickStartButton{
	CYShowCaseFilterViewController *showCaseFilterViewController = [[CYShowCaseFilterViewController alloc]init];
	[self presentModalViewController:showCaseFilterViewController animated:YES];
//	[self.navigationController pushViewController:showCaseFilterViewController animated:YES];
	[showCaseFilterViewController release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.startButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
