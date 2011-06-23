//
//  BFLongTapPopupMenu.m
//  LongTapPopupMenu
//
//  Created by Алексеев Влад on 12.06.11.
//  Copyright 2011 beefon software. All rights reserved.
//

#import "BFLongTapPopupMenu.h"

#define kBFLongTapPopupMenuShadowRadius 4
#define kBFLongTapPopupMenuCalloutHeight 15.0f

@interface BFLongTapPopupMenu ()
- (void)setOriginPoint:(CGPoint)point;
- (void)dismissWithSelection:(NSUInteger)selection;

@property (nonatomic, assign) CGFloat calloutOffset;

@end

@implementation BFLongTapPopupMenu

@synthesize delegate = _delegate;
@synthesize items = _items;
@synthesize calloutOffset = _calloutOffset;
@synthesize selectedIndex = _selectedIndex;
@synthesize selectionStyle = _selectionStyle;

+ (UIImage *)backgroundGradientImageForSize:(CGSize)size path:(CGPathRef)path {
	CGSize imageSize = size;
	
	UIGraphicsBeginImageContext(imageSize);
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	if (currentContext == nil) {
		return nil;
	}
	
	if (path) {
		CGContextAddPath(currentContext, path);	
		CGContextSetStrokeColorWithColor(currentContext, [[UIColor clearColor] CGColor]);
		CGContextSetLineWidth(currentContext, 0.0);
	}
	
	CGGradientRef glossGradient;
	CGColorSpaceRef rgbColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };

	CGFloat components[8] = { 
		0.569, 0.565, 0.608, 1.0,  // Start color
		0.427, 0.431, 0.463, 1.0   // End color
	};
	
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
	CGPoint topCenter = CGPointMake(0.0f, 0.0f);
	CGPoint bottomCenter = CGPointMake(0.0f, imageSize.height);
	CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
	
	CGGradientRelease(glossGradient);
	CGColorSpaceRelease(rgbColorspace); 
	
	CGContextStrokePath(currentContext);
	
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return outputImage;
}

- (CGPathRef) newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
	
	CGRect innerRect = CGRectInset(rect, radius, radius);
	
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
	
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
	
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
	
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
	
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
	
	CGPathCloseSubpath(retPath);
	
	return retPath;
}

+ (id)longTapPopupMenuWithWidth:(CGFloat)width {
	id menu = [[self alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
	return [menu autorelease];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:[self tableView]];
		[[self tableView] setDelegate:self];
		[[self tableView] setDataSource:self];
		
		if ([[self layer] respondsToSelector:@selector(shadowColor)]) {
			[[self layer] setShadowColor:[[UIColor blackColor] CGColor]];
			[[self layer] setShadowOffset:CGSizeMake(0, 2)];
			[[self layer] setShadowRadius:kBFLongTapPopupMenuShadowRadius];
			[[self layer] setShadowOpacity:0.75];	
		}
		
		_maskLayer = [[CAShapeLayer alloc] init];		
		[[[self tableView] layer] setMask:_maskLayer];
		
		_selectedIndex = NSUIntegerMax;
		_selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    return self;
}

- (void)dealloc {
	[_tableView release];
	[_items release];
	[_maskLayer release];
	[_menuWindow release], _menuWindow = nil;
	
    [super dealloc];
}

- (UITableView *)tableView {
	if (_tableView == nil) {
		CGRect tableFrame = [self bounds];
		tableFrame.size.width += 4;
		tableFrame.origin.x -= 2;
		
		_tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
		[_tableView setBackgroundColor:[UIColor clearColor]];
		[_tableView setClipsToBounds:YES];
		[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		
		[_tableView setBounces:NO];
		[_tableView setAlwaysBounceVertical:NO];
		[_tableView setAlwaysBounceHorizontal:NO];
		[_tableView setScrollEnabled:NO];
		[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	}
	return _tableView;
}

- (void)setItems:(NSArray *)items {
	if (_items == items)
		return;
	
	[_items release];
	_items = [items retain];
	
	NSUInteger numberOfItems = [items count];
	CGFloat height = numberOfItems * 50.0f + 10.0f;
	
	CGRect frame = [self frame];
	frame.size.height = height;
	[self setFrame:frame];
}

- (CGFloat)calloutOffset {
	return _calloutOffset + 10.0f;
}

- (void)setCalloutOffset:(CGFloat)offset {
	if (offset < 0)
		offset = 0.0f;
	
	if (offset > self.frame.size.width - 20.0f)
		offset = self.frame.size.width - 20.0f;
	
	_calloutOffset = offset;
}

- (void)setFrame:(CGRect)f {
	[super setFrame:f];
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGRect croppedRect = [self bounds];
	croppedRect.size.height -= kBFLongTapPopupMenuCalloutHeight;
	croppedRect.origin.x += 0;
	croppedRect.size.width -= 0;
	
	
	CGPathRef roundedPath = [self newPathForRoundedRect:croppedRect radius:10];
	CGPathAddPath(path, nil, roundedPath);
	
	// добавляем сноску внизу
	CGPathMoveToPoint(path, NULL, croppedRect.origin.x + self.calloutOffset, croppedRect.origin.y + croppedRect.size.height);
	CGPathAddLineToPoint(path, NULL, croppedRect.origin.x + self.calloutOffset + 13, croppedRect.origin.y + croppedRect.size.height + 10);
	CGPathAddLineToPoint(path, NULL, croppedRect.origin.x + self.calloutOffset + 13 + 13, croppedRect.origin.y + croppedRect.size.height);
	CGPathAddLineToPoint(path, NULL, croppedRect.origin.x + self.calloutOffset, croppedRect.origin.y + croppedRect.size.height);
	
	[_maskLayer setPath:path];
	[_maskLayer setFillColor:[[UIColor greenColor] CGColor]];
	[_maskLayer setPosition:CGPointMake(2, 2)];
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[[self class] backgroundGradientImageForSize:f.size path:path]];
	[[self tableView] setBackgroundView:[backgroundImageView autorelease]];
	
	CGPathRelease(path);
}

- (void)setSelectedIndex:(NSInteger)index {
	if (_selectedIndex == index) {
		return;
	}
	_selectedIndex = index;
	
	[[self tableView] reloadData];
	[[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
								  animated:NO
							scrollPosition:UITableViewScrollPositionNone];
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)style {
	if (_selectionStyle == style) {
		return;
	}
	
	_selectionStyle = style;
	[[self tableView] reloadData];
}

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [[self items] count] - 1) {
		return 50.0f + kBFLongTapPopupMenuCalloutHeight;
	}
	return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BFLongTapPopupMenuCell *cell = [[[BFLongTapPopupMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
																  reuseIdentifier:nil] autorelease];
	[cell setDesiredHeight:50.0f];
	
	[[cell textLabel] setText:[[self items] objectAtIndex:indexPath.row]];
	[[cell textLabel] setTextAlignment:UITextAlignmentCenter];
	[[cell textLabel] setTextColor:[UIColor whiteColor]];
	[[cell textLabel] setHighlightedTextColor:[UIColor whiteColor]];
	[[cell textLabel] setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
	[[cell textLabel] setShadowOffset:CGSizeMake(0, -1)];
	[cell setSelectionStyle:self.selectionStyle];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self dismissWithSelection:indexPath.row];
}

#pragma mark -
#pragma mark Manipulating

- (void)dismissWithSelection:(NSUInteger)selection {
	if ([[self delegate] respondsToSelector:@selector(longTapPopupMenu:willDismissWithIndex:)]) {
		[[self delegate] longTapPopupMenu:self willDismissWithIndex:selection];
	}
	
	[UIView beginAnimations:@"dismissAnimation" context:nil];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:)];
	[_menuWindow setAlpha:0.0];
	[UIView commitAnimations];
}

- (void)setOriginPoint:(CGPoint)point {
	[_menuWindow addSubview:self];
	[self setHidden:NO];
	
	CGRect myFrame = [self frame];
	
	CGRect myNewFrame = myFrame;
	myNewFrame.origin.x = point.x - 13.0f*2.0f;
	myNewFrame.origin.y = point.y - myFrame.size.height;
	
	if (myNewFrame.origin.y < 0)
		myNewFrame.origin.y = 0;
	
	if (myNewFrame.origin.x + myNewFrame.size.width > _menuWindow.frame.size.width - 2*kBFLongTapPopupMenuShadowRadius) {
		CGFloat diff = (myNewFrame.origin.x + myNewFrame.size.width) - (_menuWindow.frame.size.width - 2*kBFLongTapPopupMenuShadowRadius);
		myNewFrame.origin.x = _menuWindow.frame.size.width - 2*kBFLongTapPopupMenuShadowRadius - myNewFrame.size.width;
		[self setCalloutOffset:diff];
	}
	else if (myNewFrame.origin.x < kBFLongTapPopupMenuShadowRadius) {
		CGFloat diff = kBFLongTapPopupMenuShadowRadius;
		myNewFrame.origin.x = kBFLongTapPopupMenuShadowRadius;
		[self setCalloutOffset:diff];
	}
	
	[self setFrame:myNewFrame];	
}

- (void)dismissAnimationDidStop:(id)animation {
	if ([[self delegate] respondsToSelector:@selector(longTapPopupMenuDidDismiss:)]) {
		[[self delegate] longTapPopupMenuDidDismiss:self];
	}		 
	
	[[[[UIApplication sharedApplication] windows] objectAtIndex:0] makeKeyWindow];
	[_menuWindow release], _menuWindow = nil;
}

- (void)windowTapped:(id)sender {
	[self dismissWithSelection:NSUIntegerMax];
}

- (void)showFromView:(UIView *)view {
	
	_menuWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_menuWindow.windowLevel = UIWindowLevelStatusBar;
	_menuWindow.hidden = NO;
	_menuWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	
	UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[dismissButton setFrame:[_menuWindow bounds]];
	[dismissButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[dismissButton addTarget:self
					  action:@selector(windowTapped:)
			forControlEvents:UIControlEventTouchUpInside];
	[_menuWindow addSubview:dismissButton];
	
	[_menuWindow makeKeyAndVisible];
	
	CGRect viewFrameInWindow = [[view superview] convertRect:view.frame toView:nil];
	[self setOriginPoint:CGPointMake(CGRectGetMidX(viewFrameInWindow), viewFrameInWindow.origin.y)];
}

@end



@implementation BFLongTapPopupMenuCell

@synthesize desiredHeight = _desiredHeight;

+ (UIImage *)backgroundGradientImageForDesiredHeight:(CGFloat)height {
	CGSize imageSize = CGSizeMake(1.0, height);
	
	UIGraphicsBeginImageContext(imageSize);
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGPoint topCenter = CGPointMake(0.0f, 0.0f);
	CGPoint bottomCenter = CGPointMake(0.0f, imageSize.height);
	
	CGFloat pointSize = 1.0f;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		pointSize = [[UIScreen mainScreen] scale];
	}
	CGContextSetLineWidth(currentContext, pointSize);
	
	UIColor *topLineColor = [UIColor colorWithWhite:1.0 alpha:0.33];
	CGContextSetStrokeColorWithColor(currentContext, [topLineColor CGColor]);
	CGContextMoveToPoint(currentContext, 0, topCenter.y);
	CGContextAddLineToPoint(currentContext, 1.0, topCenter.y);
	
	CGContextStrokePath(currentContext);
	
	UIColor *bottomLineColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	CGContextSetStrokeColorWithColor(currentContext, [bottomLineColor CGColor]);
	CGContextMoveToPoint(currentContext, 0, bottomCenter.y);
	CGContextAddLineToPoint(currentContext, 1.0, bottomCenter.y);
	
	CGContextStrokePath(currentContext);
	
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return [outputImage stretchableImageWithLeftCapWidth:0 topCapHeight:8];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[[self textLabel] setBackgroundColor:[UIColor clearColor]];
		
		_backgroundImageView = [[UIImageView alloc] init];
		[_backgroundImageView setContentMode:UIViewContentModeScaleToFill];
		[_backgroundImageView setFrame:[[self contentView] bounds]];
		[_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[[self contentView] insertSubview:_backgroundImageView belowSubview:[self textLabel]];
	}
	return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	// do nothing
}

- (void)setDesiredHeight:(CGFloat)desiredHeight {
	_desiredHeight = desiredHeight;
	
	[_backgroundImageView setImage:[[self class] backgroundGradientImageForDesiredHeight:desiredHeight]];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect textLabelFrame = [[self textLabel] frame];
	textLabelFrame.size.height = self.desiredHeight;
	[[self textLabel] setFrame:textLabelFrame];
}

- (void)dealloc {
	[_backgroundImageView release], _backgroundImageView = nil;
	
	[super dealloc];
}

@end
