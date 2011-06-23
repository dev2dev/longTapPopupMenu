//
//  BFLongTapPopupMenu.h
//  LongTapPopupMenu
//
//  Created by Алексеев Влад on 12.06.11.
//  Copyright 2011 beefon software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class BFLongTapPopupMenu;
@protocol BFLongTapPopupMenuDelegate <NSObject>
- (void)longTapPopupMenu:(BFLongTapPopupMenu *)menu willDismissWithIndex:(NSUInteger)index;
- (void)longTapPopupMenuDidDismiss:(BFLongTapPopupMenu *)menu;
@end


@interface BFLongTapPopupMenu : UIView <UITableViewDelegate, UITableViewDataSource> {
	id <BFLongTapPopupMenuDelegate> _delegate;
	UITableView *_tableView;
	NSArray *_items;
	CAShapeLayer *_maskLayer;
	UIWindow *_menuWindow;
	CGFloat _calloutOffset;
	NSInteger _selectedIndex;
	UITableViewCellSelectionStyle _selectionStyle;
}
@property (nonatomic, assign) id <BFLongTapPopupMenuDelegate> delegate;
@property (nonatomic, retain, readonly) UITableView *tableView;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

+ (id)longTapPopupMenuWithWidth:(CGFloat)width;
- (void)showFromView:(UIView *)view;

@end

@interface BFLongTapPopupMenuCell : UITableViewCell {
	CGFloat _desiredHeight;
	UIImageView *_backgroundImageView;
}

@property (nonatomic, assign) CGFloat desiredHeight;

@end
