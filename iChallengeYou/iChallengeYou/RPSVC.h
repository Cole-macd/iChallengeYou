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

    IBOutlet UIButton *rockButton;
    IBOutlet UIButton *scissorsButton;
    IBOutlet UIButton *paperButton;
    
    IBOutlet UIButton *nextRoundButton;
    
    IBOutlet UILabel *turnStateLabel;
    IBOutlet UILabel *buttonPressResultLabel;
    IBOutlet UILabel *roundLabel;
    IBOutlet UILabel *p0ScoreLabel;
    IBOutlet UILabel *p1ScoreLabel;
    
    //enum playerRoleRPS{takingTurn, observing, roundOver, gameOver};
}

@property(nonatomic) int numberOfRounds;
@property(nonatomic) int currentRound;

@end
