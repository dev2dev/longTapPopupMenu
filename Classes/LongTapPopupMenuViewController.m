//
//  LongTapPopupMenuViewController.m
//  LongTapPopupMenu
//
//  Created by Алексеев Влад on 12.06.11.
//  Copyright 2011 beefon software. All rights reserved.
//

#import "LongTapPopupMenuViewController.h"

#import "BFLongTapPopupMenu.h"

@implementation LongTapPopupMenuViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showMenu:(id)sender {
	
	BFLongTapPopupMenu *menu = [BFLongTapPopupMenu longTapPopupMenuWithWidth:180];
	[menu setItems:[NSArray arrayWithObjects:@"Русская", @"English (US)", @"Other", nil]];
	[menu setSelectedIndex:2];
	
	[menu showFromView:sender];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
