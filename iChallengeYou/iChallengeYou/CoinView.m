//
//  CoinView.m
//  iChallengeYou
//
//  Created by Kelly Morrison on 2015-02-08.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "CoinView.h"
#import "time.h"


@interface CoinView (){
    bool displayingPrimary;
}
@end

@implementation CoinView

@synthesize primaryView=_primaryView, secondaryView=_secondaryView, spinTime;

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        displayingPrimary = YES;
        spinTime = 1.0;
    }
    return self;
}

- (id) initWithPrimaryView: (UIView *) primaryView andSecondaryView: (UIView *) secondaryView inFrame: (CGRect) frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.primaryView = primaryView;
        self.secondaryView = secondaryView;
        
        displayingPrimary = YES;
        spinTime = 5.0;
    }
    return self;
}

- (void) setPrimaryView:(UIView *)primaryView{
    _primaryView = primaryView;
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.primaryView setFrame: frame];
    [self roundView: self.primaryView];
    self.primaryView.userInteractionEnabled = YES;
    [self addSubview: self.primaryView];

    [self roundView:self];
}

- (void) setSecondaryView:(UIView *)secondaryView{
    _secondaryView = secondaryView;
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.secondaryView setFrame: frame];
    [self roundView: self.secondaryView];
    self.secondaryView.userInteractionEnabled = YES;
    [self addSubview: self.secondaryView];
    [self sendSubviewToBack:self.secondaryView];

    [self roundView:self];
}

- (void) roundView: (UIView *) view{
    [view.layer setCornerRadius: (self.frame.size.height/2)];
    [view.layer setMasksToBounds:YES];
}

- (void)flipCoin:(int)repeat{
    //flip coin method
    if (repeat == 0) {
        
    } else {
        [UIView transitionFromView:(displayingPrimary ? self.primaryView : self.secondaryView)
                            toView:(displayingPrimary ? self.secondaryView : self.primaryView)
                          duration: 0.2
                           options: UIViewAnimationOptionTransitionFlipFromBottom+UIViewAnimationOptionCurveEaseInOut
                        completion:^(BOOL finished) {
                            if (finished) {
                                displayingPrimary = !displayingPrimary;
                                [self flipCoin:(repeat-1)];
                            }
                        }
         ];
    }
}

@end