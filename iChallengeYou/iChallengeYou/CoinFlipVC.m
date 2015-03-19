//
//  CoinFlipVC.m
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//


#import "CoinFlipVC.h"
#import "GCTurnBasedMatchHelper.h"
#import "FunctionLibrary.h"
#include <stdlib.h>
#include <unistd.h>

@interface CoinFlipVC ()

@end

@implementation CoinFlipVC

@synthesize coinView;

@synthesize numberOfRounds;
@synthesize currentRound;
int currentPlayerIndex;
int mostRecentPlayerIndex;
int playerZeroScoreCF = 0;
int playerOneScoreCF = 0;
int previousRoundWinningIndex;
NSString *mostRecentPlayerMove;
NSString *coinResult;
enum playerRole playerStatusCF = observing;


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"View did load");
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    nextRoundButton.hidden = true;
    
    //UNCOMMENT, JUST FOR TESTING
    UIImageView *tailView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"dollartail.png"]];
    
    UIImageView *profileView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"dollarhead.png"]];
    
    [coinView setPrimaryView: profileView];
    [coinView setSecondaryView: tailView];
    [coinView setSpinTime:0.1];
    
    [self updateGameVariables:currentMatch];
    [self updatePlayerStatus:currentMatch];
    
    if (playerStatusCF == observing){
        NSLog(@"player status is observing");
        [self displayObservingStatus];
    }else if(playerStatusCF == takingTurn){
        [self displayCallingStatus];
        NSLog(@"player status is calling");
    }else if(playerStatusCF == roundOver){
        if(currentPlayerIndex == mostRecentPlayerIndex){
            [self displayRoundResult:true];
            nextRoundButton.hidden = false;
        }else{
            [self displayRoundResult:false];
            nextRoundButton.hidden = false;
        }
    }else if(playerStatusCF == gameOver){
        NSLog(@"player status is game over");
        [self recieveEndGame:currentMatch];
    }
}

- (void)viewDidUnload{
    NSLog(@"view did unload");
    [self disablePlayingObjects];
    roundLabel.text = @"";
    gameStateLabel.text = @"";
    turnLabel.text = @"";
}

-(void)updateCurrentPlayerIndex:(GKTurnBasedMatch *)match{
    GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    //if([match.matchData bytes]){
        GKPlayer *indexZeroPlayer = [[match.participants objectAtIndex:0] player];
        if([localPlayer isEqual:indexZeroPlayer]){
            NSLog(@"current player index is 0");
            currentPlayerIndex = 0;
        }else{
            NSLog(@"current player index is 1");
            currentPlayerIndex = 1;
        }
    /*}else{
        currentPlayerIndex = 0;
    }*/
}


-(void)updateGameVariables:(GKTurnBasedMatch *)match{
    //NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
    //NSLog(@"match data is %@", incomingData);
    if ([match.matchData bytes]) {
        NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        mostRecentPlayerMove = dataItems[2];
        coinResult = dataItems[3];
        currentRound = [dataItems[4] intValue];
        numberOfRounds = [dataItems[5] intValue];
        playerZeroScoreCF = [dataItems[6] intValue];
        playerOneScoreCF = [dataItems[7] intValue];
        mostRecentPlayerIndex = [dataItems[8] intValue];
        previousRoundWinningIndex = [dataItems[9] intValue];
        
        //most recent change moving this if statement inside if(matchData)
        GKPlayer *turnHolder = match.currentParticipant.player;
        GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
        NSLog(@"setting1");
        /*if([turnHolder isEqual:localPlayer]){
            currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
        }else{
            currentPlayerIndex = 1 - [match.participants indexOfObject:match.currentParticipant];
        }*/
        [self updateCurrentPlayerIndex:match];
        
        if([dataItems[1] isEqualToString:@"gameOver"]){
            //p0 bool is at index 10, p1 bool is at index 11
            bool hasReportedGameScore;
            if(currentPlayerIndex == 0){
                hasReportedGameScore = [dataItems[10] boolValue];
            }else{
                hasReportedGameScore = [dataItems[11] boolValue];
            }

            if(!hasReportedGameScore){
                NSLog(@"I AM ABOUT TO REPORT GAME SCORE");
                //game should not have ended yet, should be able to end the match with new match data
                [self sendScoreToLeaderboard:@"gameWin"];
                NSString* matchMessage = [NSString stringWithFormat:@"CF,gameOver,%@,%@,%u,%u,%u,%u,%u,%d,true,true,true,true,",mostRecentPlayerMove, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,mostRecentPlayerIndex,previousRoundWinningIndex];
                
                NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
                [match endMatchInTurnWithMatchData:data
                                 completionHandler:^(NSError *error) {
                                     if (error) {
                                         NSLog(@"%@", error);
                                     }
                                 }];
            }
        }else{
            NSLog(@"p0reported is:%@,%d, p1reported is:%@,%d", dataItems[12], [dataItems[12] boolValue], dataItems[13], [dataItems[13] boolValue]);
            bool hasReportedRoundScore;
            if(currentPlayerIndex == 0){
                hasReportedRoundScore = [dataItems[12] boolValue];
            }else{
                hasReportedRoundScore = [dataItems[13] boolValue];
            }
            
            if(!hasReportedRoundScore){
                NSLog(@"I AM ABOUT TO REPORT ROUND SCORE");
                [self sendScoreToLeaderboard:@"roundWin"];
                NSString* matchMessage = [NSString stringWithFormat:@"CF,%@,%@,%@,%u,%u,%u,%u,%u,%d,true,true,true,true,",dataItems[1], mostRecentPlayerMove, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,mostRecentPlayerIndex,previousRoundWinningIndex];
                
                NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
                [match endTurnWithNextParticipant:match.currentParticipant
                                               matchData:data completionHandler:^(NSError *error) {
                                                   if (error) {
                                                       NSLog(@"%@", error);
                                                   }
                                               }];
                
                
            }
            
        }
    }else{
        playerZeroScoreCF = 0;
        playerOneScoreCF = 0;
        currentRound = 1;
        NSLog(@"setting2");
        currentPlayerIndex = 0;
    }
}


-(void)updatePlayerStatus:(GKTurnBasedMatch *)match{
    GKPlayer *turnHolder = match.currentParticipant.player;
    GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if([match.matchData bytes]){
        NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        [self updateCurrentPlayerIndex:match];
        if ([dataItems[1] isEqualToString:@"gameOver"]){
            
            playerStatusCF = gameOver;
            /*GKPlayer *indexZeroPlayer = [[match.participants objectAtIndex:0] player];
            NSLog(@"setting3");
            if([localPlayer isEqual:indexZeroPlayer]){
                NSLog(@"current player index is 0");
                currentPlayerIndex = 0;
            }else{
                NSLog(@"current player index is 1");
                currentPlayerIndex = 1;
            }*/
        }else{
            if([turnHolder isEqual:localPlayer]){
                GKTurnBasedParticipant *thisParticipant = [match.participants objectAtIndex:1];
                if (thisParticipant.lastTurnDate == NULL) {
                    //the first "call" of the game
                    playerStatusCF = takingTurn;
                }else{
                    //this players turn to call, must display previous round results first
                    playerStatusCF = roundOver;
                }
                NSLog(@"current player has the turn");
                NSLog(@"setting4");
                //currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
            }else{
                NSLog(@"Other player has the turn");
                NSLog(@"setting5");
                playerStatusCF = observing;
                //currentPlayerIndex = 1 - [match.participants indexOfObject:match.currentParticipant];
            }
        }
    }else{
        playerStatusCF = takingTurn;
        NSLog(@"setting6");
        currentPlayerIndex = 0;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)headPressed:(id)sender {
    [self performTurn:@"heads"];
}
- (IBAction)tailsPressed:(id)sender {
    [self performTurn:@"tails"];
}

//runs when a person calls the coin
-(void)performTurn:(NSString *)playerChoice{
    NSLog(@"perform turn pressed");
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    int nextPlayerIndex;
    
    //check if player's call was correct
    mostRecentPlayerMove = playerChoice;
    int coinResultInt = arc4random_uniform(2);
    
    [coinView flipCoin: 4+coinResultInt];
    
    if (coinResultInt == 0){
        coinResult = @"heads";
    }else{
        coinResult = @"tails";
    }
    
    bool playerChoiceCorrect = [playerChoice isEqualToString:coinResult];
    
    
    if(currentIndex == 0){
        nextParticipant = [currentMatch.participants objectAtIndex: 1];
        nextPlayerIndex = 1;
        
        //update the winning player's score
        if(playerChoiceCorrect){
            playerZeroScoreCF = playerZeroScoreCF + 1;
            NSLog(@"player guessed correct coin, is index 0");
        }else{
            playerOneScoreCF = playerOneScoreCF + 1;
            NSLog(@"player guessed incorrect coin, is index 0");
        }
        
    }else{
        //current index is 1
        nextParticipant = [currentMatch.participants objectAtIndex: 0];
        nextPlayerIndex = 0;
        
        //update the winning player's score
        if(playerChoiceCorrect){
            playerOneScoreCF = playerOneScoreCF + 1;
            NSLog(@"player guessed correct coin, is index 1");
        }else{
            playerZeroScoreCF = playerZeroScoreCF + 1;
            NSLog(@"player guessed incorrect coin, is index 1");
        }
    }
    
    currentRound = currentRound + 1;
    
    //format is "CF,playerRole,playerCoinCall,coinCallResult,currentRound,numberOfRounds,playerAtIndexZeroScore,playerAtIndexOneScore,callingPlayerIndex,p0reportedGameScore,p1reportedGameScore,p0reportedRoundScore,p1reportedRoundScore"
    NSString *matchMessage;
    NSData *data;
    
    if([self checkForEndGame:playerZeroScoreCF p1Score:playerOneScoreCF]){
        GKTurnBasedParticipant *playerZero = [currentMatch.participants objectAtIndex: 0];
        GKTurnBasedParticipant *playerOne = [currentMatch.participants objectAtIndex: 1];
        
        int winningIndex;
        bool gameResultSent = false;
        
        if(playerZeroScoreCF > playerOneScoreCF){
            playerZero.matchOutcome = GKTurnBasedMatchOutcomeWon;
            playerOne.matchOutcome = GKTurnBasedMatchOutcomeLost;
            winningIndex = 0;
            NSLog(@"player zero wins");
            if(currentPlayerIndex == 0){
                matchMessage = [NSString stringWithFormat:@"CF,gameOver,%@,%@,%u,%u,%u,%u,%u,%u,true,true,true,true,",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex,winningIndex];
                [self sendScoreToLeaderboard:@"gameWin"];
                gameResultSent = true;
            }else{
                //currentPlayerIndex = 1, so p0 needs to report scores later
                matchMessage = [NSString stringWithFormat:@"CF,gameOver,%@,%@,%u,%u,%u,%u,%u,%u,false,true,true,true,",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex,winningIndex];
            }
            
        }else{
            playerZero.matchOutcome = GKTurnBasedMatchOutcomeLost;
            playerOne.matchOutcome = GKTurnBasedMatchOutcomeWon;
            winningIndex = 1;
            NSLog(@"player one wins");
            if(currentPlayerIndex == 0){
                matchMessage = [NSString stringWithFormat:@"CF,gameOver,%@,%@,%u,%u,%u,%u,%u,%u,true,false,true,true,",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex,winningIndex];
            }else{
                matchMessage = [NSString stringWithFormat:@"CF,gameOver,%@,%@,%u,%u,%u,%u,%u,%u,true,true,true,true,",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex,winningIndex];
                [self sendScoreToLeaderboard:@"gameWin"];
                gameResultSent = true;
            }
        }
        
        //matchMessage = [NSString stringWithFormat:@"CF,gameOver,%@,%@,%u,%u,%u,%u,%u,%u",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex,winningIndex];
        data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
        
        if(gameResultSent){
            
            [currentMatch endMatchInTurnWithMatchData:data
                                    completionHandler:^(NSError *error) {
                                        if (error) {
                                            NSLog(@"%@", error);
                                        }
                                    }];
        }else{
            [currentMatch endTurnWithNextParticipant:nextParticipant
                                           matchData:data completionHandler:^(NSError *error) {
                                               if (error) {
                                                   NSLog(@"%@", error);
                                               }
                                           }];
        }
        playerStatusCF = gameOver;
        
        //display the result of this player's call immediately
        [self performSelector:@selector(displayRoundResultTrue) withObject:nil afterDelay:1];
        
        
        
    }else{
        if(playerChoiceCorrect){
            matchMessage = [NSString stringWithFormat:@"CF,call,%@,%@,%u,%u,%u,%u,%u,%u,true,true,true,true,",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex,currentPlayerIndex];
            [self sendScoreToLeaderboard:@"roundWin"];
        }else{
            if(currentPlayerIndex == 0){
                matchMessage = [NSString stringWithFormat:@"CF,call,%@,%@,%u,%u,%u,%u,%u,%u,true,true,true,false,",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex,nextPlayerIndex];
            }else{
                matchMessage = [NSString stringWithFormat:@"CF,call,%@,%@,%u,%u,%u,%u,%u,%u,true,true,false,true,",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex, nextPlayerIndex];
            }
        }
        
        //matchMessage = [NSString stringWithFormat:@"CF,call,%@,%@,%u,%u,%u,%u,%u,true,true,",playerChoice, coinResult, currentRound, numberOfRounds,playerZeroScoreCF,playerOneScoreCF,currentPlayerIndex];
        data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
        
        NSArray* nextList = [[NSArray alloc] initWithObjects:nextParticipant,nil];
        
        //[currentMatch endTurnWithNextParticipant:nextParticipant
        [currentMatch endTurnWithNextParticipants:nextList turnTimeout:86400
                                        matchData:data completionHandler:^(NSError *error) {
                                            if (error) {
                                                NSLog(@"%@", error);
                                            }
                                        }];
        NSLog(@"round but not game over, sending %@", matchMessage);
        NSString *ddata = [NSString stringWithUTF8String:[currentMatch.matchData bytes]];
        NSLog(@"after updating, match data is %@", ddata);
        
        playerStatusCF = observing;
        
        //display the result of this player's call immediately
        
        [self performSelector:@selector(displayRoundResultFalse) withObject:nil afterDelay:1];
        
        //nextRoundButton.hidden = false;
        
        
    }
}



-(void)enterNewGame:(GKTurnBasedMatch *)match
          numRounds:(int)numRounds{
    NSLog(@"New game, number of rounds is %d", numberOfRounds);
    
    [roundLabel setText:[NSString stringWithFormat:@"1 of %u", numberOfRounds]];
    nextRoundButton.hidden = true;
    NSLog(@"setting7");
    currentRound = 1;
    currentPlayerIndex = 0;
    playerZeroScoreCF = 0;
    playerOneScoreCF = 0;
    numberOfRounds = numRounds;
    
    playerStatusCF = observing;
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    [self displayObservingStatus];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    
    GKTurnBasedParticipant *nextParticipant;
    if(currentIndex == 0){
        nextParticipant = [currentMatch.participants objectAtIndex: 1];
    }else{
        nextParticipant = [currentMatch.participants objectAtIndex: 0];
    }
    
    //format is "playerRole,playerCoinCall,coinCallResult,currentRound,numberOfRounds,playerAtIndexZeroScore,playerAtIndexOneScore,callingPlayerIndex"
    NSString *matchMessage = [NSString stringWithFormat:@"CF,call,none,none,%u,%u,0,0,1,0,true,true,true,true,",currentRound, numberOfRounds];
    
    NSData *data =
    [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
    
    [currentMatch endTurnWithNextParticipant:nextParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];
    NSLog(@"Send Turn, %@, %@", data, nextParticipant);
    
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    //looking at match when it is your turn
    NSLog(@"YOUR TURN");
    [self enablePlayingObjects];
    
    if ([match.matchData bytes]) {
        NSString *data =
        [NSString stringWithUTF8String:[match.matchData bytes]];
        //NSArray *dataItems = [data componentsSeparatedByString:@","];
        
        [self updateGameVariables:match];
        
        NSLog(@"here1");
        GKTurnBasedParticipant *thisParticipant = [match.participants objectAtIndex:1];
        if (thisParticipant.lastTurnDate == NULL) {
            //the first "call" of the game. after this call, every
            NSLog(@"here2");
            playerStatusCF = takingTurn;
            [self displayCallingStatus];
        }else{
            //this players turn to call, must display previous round results first
            playerStatusCF = roundOver;
            if(currentPlayerIndex == mostRecentPlayerIndex){
                [self displayRoundResult:true];
            }else{
                [self displayRoundResult:false];
            }
            nextRoundButton.hidden = false;
            NSLog(@"here3");
        }
        NSLog(@"match data is:%@", data);
    }
    
}
- (IBAction)nextRoundPressed:(id)sender {
    //next round
    NSLog(@"Next Round button pressed");
    nextRoundButton.hidden = true;
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    if(currentPlayerIndex == [currentMatch.participants indexOfObject:currentMatch.currentParticipant]){
        playerStatusCF = takingTurn;
        [self displayCallingStatus];
    }else{
        playerStatusCF = observing;
        [self displayObservingStatus];
    }
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    //looking at match when it is not your turn
    NSLog(@"layout match called");
    if ([match.matchData bytes]) {
        
        NSString *data = [NSString stringWithUTF8String:[match.matchData bytes]];
        NSArray *dataItems = [data componentsSeparatedByString:@","];
        
        [self updateGameVariables:match];
        
        /*if(playerStatusCF == roundEnd){
         //here when it is this players turn to call, but first must show the results of previous round
         //currentPlayerIndex already set in takeTurn
         NSLog(@"ROUND IS OVER");
         [self displayRoundResult:dataItems[2] coinResult:dataItems[3] justSent:false match:match];
         nextRoundButton.hidden = false;
         playerStatus = calling;
         }else*/
        if([dataItems[1]  isEqual: @"gameOver"]){
            NSLog(@"Now i am in game over layout match");
            playerStatusCF = gameOver;
        }else{
            //since layoutMatch is called when it is not the player's turn, the current player index is the opposite of whose turn it is
            NSLog(@"OTHER PLAYERS TURN");
            playerStatusCF = observing;
            [self displayObservingStatus];
        }
    }else{
        //no other player in the game yet, still player at index 0
        NSLog(@"setting8");
        currentPlayerIndex = 0;
        NSLog(@"OTHER PLAYERS TURN");
        playerStatusCF = observing;
        [self displayObservingStatus];
    }
}

-(void)sendScoreToLeaderboard:(NSString*)scoreType{
    NSArray* lbInfo1;
    NSArray* lbInfo2;
    NSArray* lbInfo3;
    NSArray* lbInfo4;
    NSLog(@"sending game end score for this player");
    if([scoreType isEqualToString:@"gameWin"]){
        //increment round based leaderboard, total coin flip leaderboard, and total game wins leaderboard
        lbInfo1 = [FunctionLibrary getLeaderboardNameAndID:CF numRounds:numberOfRounds lType:@"totalWins"];
        lbInfo2 = [FunctionLibrary getLeaderboardNameAndID:CF numRounds:-1 lType:@"totalWins"];
        lbInfo3 = [FunctionLibrary getLeaderboardNameAndID:TOTAL numRounds:-1 lType:@"totalWins"];
        
        //NSLog(@"Incrementing leaderboard:%@,", [lbInfo1 objectAtIndex:0]);
        [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo1 objectAtIndex:0] leaderboardID:[lbInfo1 objectAtIndex:1]];
        //NSLog(@"Incrementing leaderboard:%@,", [lbInfo2 objectAtIndex:0]);
        [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo2 objectAtIndex:0] leaderboardID:[lbInfo2 objectAtIndex:1]];
        //NSLog(@"Incrementing leaderboard:%@,", [lbInfo3 objectAtIndex:0]);
        [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo3 objectAtIndex:0] leaderboardID:[lbInfo3 objectAtIndex:1]];
    }
    //need to increment total rounds won leaderboard
    lbInfo1 = [FunctionLibrary getLeaderboardNameAndID:TOTAL numRounds:-1 lType:@"roundWins"];
    //NSLog(@"Incrementing leaderboard:%@,", [lbInfo1 objectAtIndex:0]);
    [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo1 objectAtIndex:0] leaderboardID:[lbInfo1 objectAtIndex:1]];
    
    //both round win and game win will increment the round win by 1
    lbInfo2 = [FunctionLibrary getLeaderboardNameAndID:CF numRounds:-1 lType:@"roundWins"];
    [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo2 objectAtIndex:0] leaderboardID:[lbInfo2 objectAtIndex:1]];
    
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"GAME END");
    playerStatusCF = gameOver;
    [self updateGameVariables:match];
    [self displayPlayerScores];
    [self displayGameOver];
    [roundLabel setText:[NSString stringWithFormat:@"Game Over"]];
    turnLabel.text = @"Game has ended";
    
}


-(void)displayRoundResult:(BOOL)justSent{
    NSLog(@"player status is endRound");
    //nextRoundButton.hidden = false;
    [self disablePlayingObjects];
    [self displayPlayerScores];
    
    if(justSent){
        [gameStateLabel setText:[NSString stringWithFormat:@"You called %@, result was %@", mostRecentPlayerMove, coinResult]];
    }else{
        [gameStateLabel setText:[NSString stringWithFormat:@"Opponent called %@, result was %@", mostRecentPlayerMove, coinResult]];
    }
    
    if([self checkForEndGame:playerZeroScoreCF p1Score:playerOneScoreCF]){
        //game is over
        [roundLabel setText:[NSString stringWithFormat:@"GAME OVER"]];
    }else{
        //displaying the results of the previous round.
        int tempRound = currentRound - 1;
        [roundLabel setText:[NSString stringWithFormat:@"%u of %u", tempRound,numberOfRounds]];
    }
}

-(void)displayRoundResultTrue{
    NSLog(@"player status is endRound");
    //nextRoundButton.hidden = false;
    [self disablePlayingObjects];
    [self displayPlayerScores];
    
    [gameStateLabel setText:[NSString stringWithFormat:@"You called %@, result was %@", mostRecentPlayerMove, coinResult]];
    
    if([self checkForEndGame:playerZeroScoreCF p1Score:playerOneScoreCF]){
        //game is over
        [roundLabel setText:[NSString stringWithFormat:@"GAME OVER"]];
    }else{
        //displaying the results of the previous round.
        int tempRound = currentRound - 1;
        [roundLabel setText:[NSString stringWithFormat:@"%u of %u", tempRound,numberOfRounds]];
    }
}

-(void)displayRoundResultFalse{
    NSLog(@"player status is endRound");
    nextRoundButton.hidden = false;
    [self disablePlayingObjects];
    [self displayPlayerScores];
    
    [gameStateLabel setText:[NSString stringWithFormat:@"You called %@, result was %@", mostRecentPlayerMove, coinResult]];
    
    if([self checkForEndGame:playerZeroScoreCF p1Score:playerOneScoreCF]){
        //game is over
        [roundLabel setText:[NSString stringWithFormat:@"GAME OVER"]];
    }else{
        //displaying the results of the previous round.
        int tempRound = currentRound - 1;
        [roundLabel setText:[NSString stringWithFormat:@"%u of %u", tempRound,numberOfRounds]];
    }
}

-(bool)checkForEndGame:(int)p0Score
               p1Score:(int)p1Score{
    
    if(numberOfRounds == 1){
        //this is called after a round has been played, so for a 1 round game, this is the end
        return true;
    }else if (numberOfRounds == 3){
        if((p0Score >= 2) || (p1Score >= 2)){
            return true;
        }
    }else{
        if((p0Score >= 3) || (p1Score >= 3)){
            return true;
        }
    }
    return false;
}

-(void)displayGameOver{
    NSLog(@"Now in game over display");
    [self disablePlayingObjects];
    turnLabel.text = @"Game is over";
    
    if(previousRoundWinningIndex == 0){
        //player 0 wins
        if(currentPlayerIndex == 0){
            [gameStateLabel setText:[NSString stringWithFormat:@"You beat your opponent %u to %u", playerZeroScoreCF, playerOneScoreCF]];
        }else{
            [gameStateLabel setText:[NSString stringWithFormat:@"Your opponent beat you %u to %u", playerZeroScoreCF, playerOneScoreCF]];
        }
    }else{
        //player 1 wins
        if(currentPlayerIndex == 0){
            [gameStateLabel setText:[NSString stringWithFormat:@"Your opponent beat you %u to %u", playerOneScoreCF, playerZeroScoreCF]];
        }else{
            [gameStateLabel setText:[NSString stringWithFormat:@"You beat your opponent %u to %u", playerOneScoreCF, playerZeroScoreCF]];
        }
    }
}

-(void)displayPlayerScores{
    if(currentPlayerIndex == 0){
        [playerZeroScoreLabel setText:[NSString stringWithFormat:@"%u (you)", playerZeroScoreCF]];
        [playerOneScoreLabel setText:[NSString stringWithFormat:@"%u", playerOneScoreCF]];
    }else{
        [playerZeroScoreLabel setText:[NSString stringWithFormat:@"%u", playerZeroScoreCF]];
        [playerOneScoreLabel setText:[NSString stringWithFormat:@"%u (you)", playerOneScoreCF]];
    }
}

-(void)displayObservingStatus{
    NSLog(@"player status is observing");
    [self disablePlayingObjects];
    turnLabel.text = @"Please wait, not your turn";
    [gameStateLabel setText:[NSString stringWithFormat:@"You are player %u", currentPlayerIndex]];
    nextRoundButton.hidden = true;
    [roundLabel setText:[NSString stringWithFormat:@"%u of %u", currentRound,numberOfRounds]];
    [self displayPlayerScores];
}

-(void)displayCallingStatus{
    NSLog(@"player status is calling");
    [self enablePlayingObjects];
    turnLabel.text = @"Your turn, call the coin";
    [gameStateLabel setText:[NSString stringWithFormat:@"You are player %u", currentPlayerIndex]];
    nextRoundButton.hidden = true;
    [roundLabel setText:[NSString stringWithFormat:@"%u of %u", currentRound,numberOfRounds]];
    [self displayPlayerScores];
}

-(void)disablePlayingObjects{
    [headsButton setEnabled:NO];
    [headsButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    [tailsButton setEnabled:NO];
    [tailsButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
}

-(void)enablePlayingObjects{
    [headsButton setEnabled:YES];
    [headsButton setTitleColor: [UIColor blueColor] forState:UIControlStateNormal];
    [tailsButton setEnabled:YES];
    [tailsButton setTitleColor: [UIColor blueColor] forState:UIControlStateNormal];
}

/*
 - (void) handleTurnEventForMatch:(GKTurnBasedMatch *)match
 {
 NSLog(@"Turn has happened");
 if ([match.matchID isEqualToString:currentMatch.matchID])
 {
 currentMatch = match; // <-- renew your instance!
 }
 }*/

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

