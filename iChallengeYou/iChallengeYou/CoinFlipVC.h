//
//  CoinFlipVC.h
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

@interface CoinFlipVC : UIViewController <GCTurnBasedMatchHelperDelegate> {
    IBOutlet UILabel *turnLabel;
    IBOutlet UILabel *gameStateLabel;
    IBOutlet UILabel *roundLabel;
    
    IBOutlet UIButton *tailsButton;
    IBOutlet UIButton *headsButton;
    IBOutlet UIButton *nextRoundButton;
    
    enum playerRole{calling, observing, roundEnd, gameOver};
}

@property(nonatomic) int numberOfRounds;
@property(nonatomic) int currentRound;

@end