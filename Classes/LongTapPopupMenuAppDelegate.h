//
//  LongTapPopupMenuAppDelegate.h
//  LongTapPopupMenu
//
//  Created by Алексеев Влад on 12.06.11.
//  Copyright 2011 beefon software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LongTapPopupMenuViewController;

@interface LongTapPopupMenuAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LongTapPopupMenuViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LongTapPopupMenuViewController *viewController;

@end

