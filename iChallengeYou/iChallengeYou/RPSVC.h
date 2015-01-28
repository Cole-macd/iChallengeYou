//
//  RPSVC.h
//  iChallengeYou
//
//  Created by Matt Gray on 2015-01-27.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"


@interface RPSVC : UIViewController <GCTurnBasedMatchHelperDelegate> {
    
    __weak IBOutlet UILabel *turnStateLabel;
    __weak IBOutlet UIButton *rockButton;
    __weak IBOutlet UIButton *paperButton;
    __weak IBOutlet UIButton *scissorsButton;
    
    enum playerRole{takingTurn, observing, roundOver, gameOver};
}

@property(nonatomic) int numberOfRounds;
@property(nonatomic) int currentRound;

@end
