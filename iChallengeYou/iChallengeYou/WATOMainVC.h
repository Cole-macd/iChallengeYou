//
//  WATOMainVC.h
//  iChallengeYou
//
//  Created by Matt Gray on 2015-03-11.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

@interface WATOMainVC : UIViewController <GCTurnBasedMatchHelperDelegate>{
    //NSString* betMessage;
}
@property(nonatomic) NSString* betMessage;
@property (weak, nonatomic) IBOutlet UILabel *betMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *guessMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *turnLabel;


@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *rangeSliderLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitRangeButton;
@property (weak, nonatomic) IBOutlet UIImageView *submitRangeGraphics;


@property (weak, nonatomic) IBOutlet UISlider *guessSlider;
@property (weak, nonatomic) IBOutlet UILabel *guessSliderLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitGuessButton;
@property (weak, nonatomic) IBOutlet UIImageView *submitGuessGraphics;

enum playerRoleWATO{settingRange, settingGuess, observingGame, gameIsOver};

@end
