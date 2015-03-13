//
//  WATONumberVC.m
//  iChallengeYou
//
//  Created by Matt Gray on 2015-03-11.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "WATOMainVC.h"
#import "GCTurnBasedMatchHelper.h"
#include <stdlib.h>

@interface WATOMainVC ()

@end

//@synthesize betMessage;
NSString* betMessage;
int guessRange;
int currentPlayerGuess = -1;
int opponentGuess = -1;
int currentPlayerIndex;
//bool currentPlayerHasTurn = false;
NSString* gameState;
int winningIndex = -1;

enum playerRoleWATO playerStatusWATO = observingGame;

@implementation WATOMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    NSLog(@"in view did load");
    
    [self updatePlayerStatus:currentMatch];
    [self updateGameVariables:currentMatch];
    [self displayFormatFromPlayerStatus];
}

- (void)didReceiveMemoryWarning {
    //[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateGameVariables:(GKTurnBasedMatch*)match{
    if([match.matchData bytes]){
        NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
        NSLog(@"incoming match message is %@", incomingData);
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        betMessage = dataItems[1];
        guessRange = [dataItems[2] intValue];
        gameState = dataItems[5];
        winningIndex = [dataItems[6] intValue];
        if(currentPlayerIndex == 0){
            currentPlayerGuess = [dataItems[3] intValue];
            opponentGuess = [dataItems[4] intValue];
        }else{
            currentPlayerGuess = [dataItems[4] intValue];
            opponentGuess = [dataItems[3] intValue];
        }
    }
}

-(void)updatePlayerStatus:(GKTurnBasedMatch *)match{
    GKPlayer *turnHolder = match.currentParticipant.player;
    GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
    GKPlayer *indexZeroPlayer = [[match.participants objectAtIndex:0] player];
    
    if([turnHolder isEqual:localPlayer]){
        //current player has the turn
        NSLog(@"current player has the turn");
        
        if([match.matchData bytes]){
            NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
            NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
            gameState = dataItems[5];
            if([gameState isEqualToString:@"settingRange"]){
                playerStatusWATO = settingRange;
                currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
            }else if([gameState isEqualToString:@"settingGuess"]){
                playerStatusWATO = settingGuess;
                currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
            }else if([gameState isEqualToString:@"gameOver"]){
                playerStatusWATO = gameIsOver;
                if([localPlayer isEqual:indexZeroPlayer]){
                    currentPlayerIndex = 0;
                }else{
                    currentPlayerIndex = 1;
                }
            }
        }else{
            //match just started since match data is empty
            playerStatusWATO = settingRange;
            gameState = @"settingRange";
            currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
        }
    }else{
        //other player has the turn
        if([match.matchData bytes]){
            NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
            NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
            gameState = dataItems[5];
            if([gameState isEqualToString:@"gameOver"]){
                playerStatusWATO = gameIsOver;
                if([localPlayer isEqual:indexZeroPlayer]){
                    currentPlayerIndex = 0;
                }else{
                    currentPlayerIndex = 1;
                }
            }else{
                //game is still running, player is observing
                playerStatusWATO = observingGame;
                currentPlayerIndex = 1 - [match.participants indexOfObject:match.currentParticipant];
            }
        }else{
            //match just started since match data is empty, should never get here
            playerStatusWATO = observingGame;
            currentPlayerIndex = 1 - [match.participants indexOfObject:match.currentParticipant];
        }
        
    }
}


- (IBAction)rangeSliderValueChanged:(id)sender {
    self.rangeSliderLabel.text = [NSString stringWithFormat:@"%d", (int)(self.rangeSlider.value*98 + 2)];
    _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, (int)(self.rangeSlider.value*98 + 2)];
}

- (IBAction)guessSliderValueChanged:(id)sender {
    self.guessMessageLabel.text = [NSString stringWithFormat:@"My guess is %d", (int)(self.guessSlider.value*(guessRange-1) + 1)];
    self.guessSliderLabel.text = [NSString stringWithFormat:@"%d", (int)(self.guessSlider.value*(guessRange-1) + 1)];
}

- (IBAction)submitOddsPressed:(id)sender {
    
    guessRange = self.rangeSlider.value*98 + 2;
    self.guessSliderLabel.text = [NSString stringWithFormat:@"%d", (int)(guessRange/2)];
    self.guessMessageLabel.text = [NSString stringWithFormat:@"My guess is %d", (int)(guessRange/2)];
    _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, guessRange];
    [self displaySettingGuess];
    
    //format is WATO,betMessage,betRange,p0Guess,p1Guess,gameState
    NSString *matchMessage = [NSString stringWithFormat:@"WATO,%@,%d,-1,-1,settingGuess,-1,", betMessage, guessRange];
    [self sendTurn:matchMessage nextIndex:1];
    gameState = @"settingGuess";
    playerStatusWATO = settingGuess;
    
    //[_rangeSlider setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
}

- (IBAction)submitGuessPressed:(id)sender {
    [self hideSliderSet:_guessSlider label:_guessSliderLabel button:_submitGuessButton];
    currentPlayerGuess = self.guessSlider.value*(guessRange-1)+1;
    GKTurnBasedMatch *match = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    if(currentPlayerIndex == 0){
        //after player 0 submits his guess, the game is over
        
        GKTurnBasedParticipant *playerZero = [match.participants objectAtIndex: 0];
        GKTurnBasedParticipant *playerOne = [match.participants objectAtIndex: 1];
        
        if(currentPlayerGuess == opponentGuess){
            if(currentPlayerIndex == 0){
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeWon;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeLost;
                winningIndex = 0;
            }else{
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeLost;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeWon;
                winningIndex = 1;
            }
        }else{
            if(currentPlayerIndex == 0){
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeLost;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeWon;
                winningIndex = 1;
            }else{
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeWon;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeLost;
                winningIndex = 0;
            }
        }
        
        //format is WATO,betMessage,betRange,p0Guess,p1Guess,gameState
        NSString *matchMessage = [NSString stringWithFormat:@"WATO,%@,%d,%d,%d,gameOver,%d,", betMessage, guessRange, currentPlayerGuess, opponentGuess, winningIndex];
        NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];

        [match endMatchInTurnWithMatchData:data
                                completionHandler:^(NSError *error) {
                                    if (error) {
                                        NSLog(@"%@", error);
                                    }
                                }];
        [self displayGameOver:winningIndex];
    }else{
        //currentPlayerIndex = 1
        //original player has not made his guess yet
        [self displayObservingStatus];
        
        //format is WATO,betMessage,betRange,p0Guess,p1Guess,gameState
        NSString *matchMessage = [NSString stringWithFormat:@"WATO,%@,%d,-1,%d,settingGuess,-1,", betMessage, guessRange, currentPlayerGuess];
        [self sendTurn:matchMessage nextIndex:0];
    }
    
}

-(void)enterNewGame:(GKTurnBasedMatch *)match
                msg:(NSString*)msg{
    NSLog(@"new game NOW");
    betMessage = msg;
    _betMessageLabel.text = msg;
    _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 - %d", betMessage, 50];
    
    //format is WATO,betMessage,betRange,p0Guess,p1Guess,gameState
    NSString *matchMessage = [NSString stringWithFormat:@"WATO,%@,-1,-1,-1,settingRange,-1,", msg];
    [self sendTurn:matchMessage nextIndex:1];
    gameState = @"settingRange";
    playerStatusWATO = settingRange;
    [self displayObservingStatus];
}

-(void)sendTurn:(NSString*)matchMessage
      nextIndex:(int)nextIndex{
    
    GKTurnBasedMatch *match = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
    GKTurnBasedParticipant *nextParticipant = [match.participants objectAtIndex: nextIndex];
    
    //save the bet message to the match data and send turn to opposing player
    [match endTurnWithNextParticipant:nextParticipant
                            matchData:data completionHandler:^(NSError *error) {
                                if (error) {
                                    NSLog(@"%@", error);
                                }
                            }];
    NSLog(@"sent matchmessage with format WATO,betMessage,betRange,p0Guess,p1Guess,gameState: %@", matchMessage);

}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    NSLog(@"inside takeTurn");
    [self updatePlayerStatus:match];
    [self updateGameVariables:match];
    [self displayFormatFromPlayerStatus];

}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    NSLog(@"inside layout match");
    [self updatePlayerStatus:match];
    [self updateGameVariables:match];
    [self displayFormatFromPlayerStatus];
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"game is over NOW");
    [self updatePlayerStatus:match];
    [self updateGameVariables:match];
    [self displayFormatFromPlayerStatus];
}

-(void)displaySettingRange{
    _turnLabel.text = @"Your turn, enter the range of odds";
    [self hideSliderSet:_guessSlider label:_guessSliderLabel button:_submitGuessButton];
    [self revealSliderSet:_rangeSlider label:_rangeSliderLabel button:_submitRangeButton];
    _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, 50];
}

-(void)displaySettingGuess{
    _turnLabel.text = @"Your turn, enter your guess";
    _guessMessageLabel.text = [NSString stringWithFormat:@"My guess is %d", (int)(guessRange/2)];
    [self hideSliderSet:_rangeSlider label:_rangeSliderLabel button:_submitRangeButton];
    [self revealSliderSet:_guessSlider label:_guessSliderLabel button:_submitGuessButton];
    _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, guessRange];
    
}

-(void)displayObservingStatus{
    [self hideSliderSet:_rangeSlider label:_rangeSliderLabel button:_submitRangeButton];
    [self hideSliderSet:_guessSlider label:_guessSliderLabel button:_submitGuessButton];
    NSLog(@"here3");
    if([gameState isEqualToString:@"settingRange"]){
        NSLog(@"here1");
        _turnLabel.text = @"Not your turn. Please wait for opponent to set the odds";
        _betMessageLabel.text = @"";
        _guessMessageLabel.text = @"";
    }else if([gameState isEqualToString:@"settingGuess"]){
        NSLog(@"here2");
        _turnLabel.text = @"Not your turn. Please wait for opponent to make his move";
        _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, guessRange];
        _guessMessageLabel.text = [NSString stringWithFormat:@"My guess is %d", (int)(currentPlayerGuess)];
    }
}

-(void)displayGameOver:(int)winningIndex{
    [self hideSliderSet:_rangeSlider label:_rangeSliderLabel button:_submitRangeButton];
    [self hideSliderSet:_guessSlider label:_guessSliderLabel button:_submitGuessButton];
    if(winningIndex == 0){
        if(currentPlayerIndex == 0){
            //current player won
            _turnLabel.text = @"You won! You guessed correctly!";
            _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, guessRange];
            _guessMessageLabel.text = [NSString stringWithFormat:@"Both players guessed %d", (int)(currentPlayerGuess)];
        }else{
            //opponent won
            _turnLabel.text = @"You lost. Your opponent guessed correctly.";
            _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, guessRange];
            _guessMessageLabel.text = [NSString stringWithFormat:@"Both players guessed %d", (int)(currentPlayerGuess)];
        }
    }else{
        //winning index is 1
        if(currentPlayerIndex == 0){
            //current player lost
            _turnLabel.text = @"You lost. You guessed incorrectly";
            _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, guessRange];
            _guessMessageLabel.text = [NSString stringWithFormat:@"You guessed %d, your opponent guessed %d", (int)currentPlayerGuess, (int)opponentGuess];
        }else{
            //current player won
            _turnLabel.text = @"You won! Your opponent guessed incorrectly";
            _betMessageLabel.text = [NSString stringWithFormat:@"The odds of %@ are 1 in %d", betMessage, guessRange];
            _guessMessageLabel.text = [NSString stringWithFormat:@"You guessed %d, your opponent guessed %d", (int)currentPlayerGuess, (int)opponentGuess];
        }
    }

}

-(void) hideSliderSet:(UISlider *)slider
             label:(UILabel *)label
            button:(UIButton *)button{
    [slider setEnabled:NO];
    slider.hidden = true;
    label.hidden = true;
    [button setEnabled:NO];
    button.hidden = true;
    
}

-(void) revealSliderSet:(UISlider *)slider
               label:(UILabel *)label
              button:(UIButton *)button{
    [slider setEnabled:YES];
    slider.hidden = false;
    label.hidden = false;
    [button setEnabled:YES];
    button.hidden = false;
}

-(void)displayFormatFromPlayerStatus{
    if(playerStatusWATO == settingRange){
        NSLog(@"player status is settingRange");
        [self displaySettingRange];
    }else if(playerStatusWATO == settingGuess){
        NSLog(@"player status is settingGuess");
        [self displaySettingGuess];
    }else if(playerStatusWATO == observingGame){
        NSLog(@"player status is observingGame");
        [self displayObservingStatus];
    }else if(playerStatusWATO == gameIsOver){
        [self displayGameOver:winningIndex];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
