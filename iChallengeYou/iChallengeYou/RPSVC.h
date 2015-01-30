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
    
    IBOutlet UILabel *turnStateLabel;

    IBOutlet UIButton *rockButton;
    IBOutlet UIButton *scissorsButton;
    IBOutlet UIButton *paperButton;
    
    enum playerRoleRPS{takingTurn, observing, roundOver, gameOver};
}

@property(nonatomic) int numberOfRounds;
@property(nonatomic) int currentRound;

@end
