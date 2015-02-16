//
//  CoinView.h
//  iChallengeYou
//
//  Created by Kelly Morrison on 2015-02-08.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoinView : UIView

- (id) initWithPrimaryView: (UIView *) view1 andSecondaryView: (UIView *) view2 inFrame: (CGRect) frame;
- (void)flipCoin:(int)repeat;

@property (nonatomic, retain) UIView *primaryView;
@property (nonatomic, retain) UIView *secondaryView;
@property float spinTime;

@end
