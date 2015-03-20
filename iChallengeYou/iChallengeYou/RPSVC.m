//
//  RPSVC.m
//  iChallengeYou
//
//  Created by Matt Gray on 2015-01-27.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "RPSVC.h"
#import "GCTurnBasedMatchHelper.h"
#import "FunctionLibrary.h"
#include <stdlib.h>

@interface RPSVC ()

@end

@implementation RPSVC

@synthesize numberOfRounds;
@synthesize currentRound;

int currentPlayerIndex = 0;
enum playerRole playerStatusRPS = observing;
int playerZeroScore = 0;
int playerOneScore = 0;
NSString *playerZeroMove;
NSString *playerOneMove;
NSString *playerZeroPreviousMove;
NSString *playerOnePreviousMove;
int previousWinningIndex;
bool currentPlayerHasTurn = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self disablePlayingObjects];
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    currentPlayerHasTurn = false;
    
    //update the playerStatusRPS based on participant index, also updates currentPlayerIndex
    [self updatePlayerStatus:currentMatch];
    
    //fill local variables with values from previous rounds of current game
    [self updateGameVariables:currentMatch];
    
    if(playerStatusRPS == takingTurn){
        NSLog(@"player status is takingTurn");
        [self displayTurnAvailable];
    }else if (playerStatusRPS == observing){
        NSLog(@"player status is observing");
        [self displayObservingStatus];
    }else if(playerStatusRPS == roundOver){
        [self displayPreviousRoundResult:currentMatch];
        NSLog(@"insert round over here");
    }else{
        [self displayGameOver];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updatePlayerStatus:(GKTurnBasedMatch *)match{
    GKPlayer *turnHolder = match.currentParticipant.player;
    GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
    if([turnHolder isEqual:localPlayer]){
        //current player has the turn
        NSLog(@"current player has the turn");
        playerStatusRPS = takingTurn;
        currentPlayerHasTurn = true;
        currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
    }else{
        //other player has the turn
        NSLog(@"Other player has the turn");
        playerStatusRPS = observing;
        currentPlayerHasTurn = false;
        currentPlayerIndex = 1 - [match.participants indexOfObject:match.currentParticipant];
    }
}


-(void)updateGameVariables:(GKTurnBasedMatch *)match {
    if ([match.matchData bytes]) {
        //at least one player has made a move
        NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        NSLog(@"incoming match data is %@" , incomingData);
        
        playerZeroMove = dataItems[1];
        playerOneMove = dataItems[2];
        playerZeroScore = [dataItems[3] intValue];
        playerOneScore = [dataItems[4] intValue];
        currentRound = [dataItems[5] intValue];
        numberOfRounds = [dataItems[6] intValue];
        playerZeroPreviousMove = dataItems[8];
        playerOnePreviousMove = dataItems[9];
        bool playerZeroSeenResult = [dataItems[10] boolValue];
        bool playerOneSeenResult = [dataItems[11] boolValue];
        previousWinningIndex = [dataItems[12] intValue];
        
        if([dataItems[7] isEqualToString:@"gameOver"]){
            bool gameScoreHasBeenReported = true;
            playerStatusRPS = gameOver;
            GKPlayer *indexZeroPlayer = [[match.participants objectAtIndex:0] player];
            GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
            if([localPlayer isEqual:indexZeroPlayer]){
                NSLog(@"current player index is 0");
                currentPlayerIndex = 0;
                gameScoreHasBeenReported = [dataItems[13] boolValue];
            }else{
                NSLog(@"current player index is 1");
                currentPlayerIndex = 1;
                gameScoreHasBeenReported = [dataItems[14] boolValue];

            }
            
            if(!gameScoreHasBeenReported){
                [self sendScoreToLeaderboard:@"gameWin"];
                
                NSString* matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%@,%@,%@,%@,gameOver,%@,%@,%@,%@,%@,true,true,true,true,", dataItems[1], dataItems[2],dataItems[3],dataItems[4],dataItems[5],dataItems[6],dataItems[8],dataItems[9],dataItems[10],dataItems[11],dataItems[12]];
                
                NSLog(@"new game over match data is %@", matchMessage);
                
                NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
                [match endMatchInTurnWithMatchData:data
                                 completionHandler:^(NSError *error) {
                                     if (error) {
                                         NSLog(@"%@", error);
                                     }
                                 }];
            }
        }else{
            if(currentPlayerIndex == 0){
                if(!playerZeroSeenResult){
                    //this player hasnt seen the result of the last round
                    playerStatusRPS = roundOver;
                    NSLog(@"current player (0) has not seen round result yet");
                }
            }else{
                if(!playerOneSeenResult){
                    //this player hasnt seen the result of the last round
                    playerStatusRPS = roundOver;
                    NSLog(@"current player (1) has not seen round result yet");
                }
            }
        }
        bool roundScoreHasBeenReported = true;
        if(currentPlayerIndex == 0){
            roundScoreHasBeenReported = [dataItems[15] boolValue];
        }else{
            roundScoreHasBeenReported = [dataItems[16] boolValue];
        }
        
        if(!roundScoreHasBeenReported){
            NSString* matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,true,true,", dataItems[1], dataItems[2],dataItems[3],dataItems[4],dataItems[5],dataItems[6],dataItems[7],dataItems[8],dataItems[9],dataItems[10],dataItems[11],dataItems[12],dataItems[13],dataItems[14]];
            NSLog(@"ABOUT TO REPORT ROUND WIN SCORE");
            [self sendScoreToLeaderboard:@"roundWin"];
            NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
            [match endTurnWithNextParticipant:match.currentParticipant
                                    matchData:data completionHandler:^(NSError *error) {
                                        if (error) {
                                            NSLog(@"%@", error);
                                        }
                                    }];

        }

    }else{
        //no game has been started yet
        playerZeroMove = @"null";
        playerOneMove = @"null";
        playerZeroScore = 0;
        playerOneScore = 0;
        currentRound = 1;
    }
}


-(void)performTurn:(NSString *)playerChoice{

    playerStatusRPS = observing;
    [self displayObservingStatus];
    
    NSLog(@"performTurn() called");
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    NSString *incomingData = [NSString stringWithUTF8String:[currentMatch.matchData bytes]];
    NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    currentPlayerIndex = (int)currentIndex;
    
    //update the next participant in the game
    int nextPlayerIndex;
    GKTurnBasedParticipant *nextParticipant;
    if(currentIndex == 0){
        nextParticipant = [currentMatch.participants objectAtIndex: 1];
        nextPlayerIndex = 1;
    }else{
        //currentIndex = 1
        nextParticipant = [currentMatch.participants objectAtIndex: 0];
        nextPlayerIndex = 0;
    }
    
    NSString *matchMessage;
    bool endOfRound = false;
    int winningIndex;
    bool p0RoundReportStatus = true;
    bool p1RoundReportStatus = true;
    
    //compare the match data to see if the round is over or not
    if ([currentMatch.matchData bytes]) {
        //at least one player has already made a move

        if (currentPlayerIndex == 0){
            if([playerZeroMove isEqualToString:@"null"] && ![playerOneMove isEqualToString:@"null"]){
                //both players have made their moves, now the round is over
                NSLog(@"matchMessage1");
                endOfRound = true;
                playerZeroMove = playerChoice;
                
                //update the global player scores and return the index of the winning player (-1 for tie)
                winningIndex = [self updatePlayerScores:playerZeroMove p1Move:playerOneMove];
                if(winningIndex != -1){
                    currentRound = currentRound + 1;
                }
                
                //update the previous moves before saving the matchMessage
                playerZeroPreviousMove = playerZeroMove;
                playerOnePreviousMove = playerOneMove;
                previousWinningIndex = winningIndex;
                
                //format is RPS, p0CurrentMove, p1CurrentMove, m0Score, p1Score, currentRound, numberOfRounds, gameStatus, p0PreviousMove, p1PreviousMove, p0SeenResult, p1SeenResult
                if(winningIndex == currentPlayerIndex){
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,running,%@,%@,true,false,%d,true,true,true,true,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove,winningIndex];
                    [self sendScoreToLeaderboard:@"roundWin"];
                }else if(winningIndex == (1- currentPlayerIndex)){
                    //other player wins this round, needs to report score
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,running,%@,%@,true,false,%d,true,true,true,false,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove,winningIndex];
                    p1RoundReportStatus = false;
                }else{
                    NSLog(@"tie1");
                    //tie
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,running,%@,%@,true,false,%d,true,true,true,true,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove,winningIndex];
                }
            }else{
                //other player has not made a move, current player is making the first move of the round
                playerZeroMove = playerChoice;
                matchMessage = [NSString stringWithFormat:@"RPS,%@,null,%u,%u,%u,%u,running,%@,%@,true,false,%d,true,true,true,%@,", playerZeroMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroPreviousMove, playerOnePreviousMove,previousWinningIndex,dataItems[16]];
                p1RoundReportStatus = [dataItems[16] boolValue];
                NSLog(@"matchMessage2");
            }
        }else{
            //currentPlayerIndex = 1
            if([playerOneMove isEqualToString:@"null"] && ![playerZeroMove isEqualToString:@"null"]){
                //both players have made their moves, now this round is over
                endOfRound = true;
                playerOneMove = playerChoice;
                
                //update the global player scores and return the index of the winning player (-1 for tie)
                winningIndex = [self updatePlayerScores:playerZeroMove p1Move:playerOneMove];
                if(winningIndex != -1){
                    currentRound = currentRound + 1;
                }
                
                //update the previous moves before saving the matchMessage
                playerZeroPreviousMove = playerZeroMove;
                playerOnePreviousMove = playerOneMove;
                previousWinningIndex = winningIndex;
                
                if(winningIndex == currentPlayerIndex){
                    NSLog(@"matchMessage3");
                    //format is RPS, p0CurrentMove, p1CurrentMove, m0Score, p1Score, currentRound, numberOfRounds, gameStatus, p0PreviousMove, p1PreviousMove, p0SeenResult, p1SeenResult,p0reportedGameScore,p1reportedGameScore
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,running,%@,%@,false,true,%d,true,true,true,true,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex];
                    [self sendScoreToLeaderboard:@"roundWin"];
                }else if (winningIndex == (1-currentPlayerIndex)){
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,running,%@,%@,false,true,%d,true,true,false,true,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex];
                    p0RoundReportStatus = false;
                }else{
                    //tie
                    NSLog(@"tie2");
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,running,%@,%@,true,false,%d,true,true,true,true,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove,winningIndex];
                }
            }else{
                //other player has not made a move, current player is making the first move
                playerOneMove = playerChoice;
                matchMessage = [NSString stringWithFormat:@"RPS,null,%@,%u,%u,%u,%u,running,%@,%@,false,true,%d,true,true,%@,true,", playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroPreviousMove,playerOnePreviousMove,previousWinningIndex,dataItems[15]];
                p0RoundReportStatus = [dataItems[15] boolValue];
                NSLog(@"matchMessage4");
            }
        }
    }else{
        //this is the first move of the game, most fields in the match data are null
        matchMessage = [NSString stringWithFormat:@"RPS,%@,null,0,0,1,%u,running,null,null,true,true,-2,true,true,true,true,", playerChoice, numberOfRounds];
        NSLog(@"matchMessage5");
    }
    
    if(endOfRound){
        //round is over, unknown if game is over
        NSLog(@"Round is over");
        
        GKTurnBasedParticipant *playerZero = [currentMatch.participants objectAtIndex: 0];
        GKTurnBasedParticipant *playerOne = [currentMatch.participants objectAtIndex: 1];
        
        bool gameIsOver = [self isGameOver:playerZeroScore p1Score:playerOneScore];
        if((gameIsOver) && (winningIndex != -1)){
            //game is over and the last round was not a tie
            NSLog(@"GAME IS NOW OVER");
            bool gameScoreSent = false;
            currentRound = numberOfRounds;
            
            NSString* p0RoundReport = p0RoundReportStatus ? @"true" : @"false";
            NSString* p1RoundReport = p1RoundReportStatus ? @"true" : @"false";
            
            if(playerZeroScore > playerOneScore){
                //player 0 wins
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeWon;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeLost;
                if(currentPlayerIndex == 0){
                    //this player wins
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,gameOver,%@,%@,true,true,%d,true,true,%@,%@,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex, p0RoundReport, p1RoundReport];
                    [self sendScoreToLeaderboard:@"gameWin"];
                    gameScoreSent = true;
                }else{
                    //opponent wins
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,gameOver,%@,%@,true,true,%d,false,true,%@,%@,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex, p0RoundReport, p1RoundReport];
                }
                
            }else{
                //player 1 wins
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeLost;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeWon;
                
                if(currentPlayerIndex == 0){
                    //other player wins
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,gameOver,%@,%@,true,true,%d,true,false,%@,%@,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex, p0RoundReport, p1RoundReport];
                }else{
                    //this player wins
                    matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,gameOver,%@,%@,true,true,%d,true,true,%@,%@,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex, p0RoundReport, p1RoundReport];
                    [self sendScoreToLeaderboard:@"gameWin"];
                    gameScoreSent = true;
                }
            }
            
            //save the most recent matchMessage
            //matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,gameOver,%@,%@,true,true,%d,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex];
            
            //send the matchMessage to the GK server
            NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
            
            if(gameScoreSent){
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
            
            //update previous moves just for end game display purposes
            playerZeroPreviousMove = playerZeroMove;
            playerOnePreviousMove = playerOneMove;
            [self displayGameOver];
        }else{
            //round is over, but game is not over
            NSLog(@"matchMessage6");
            
            //send the previously created matchMessage to the GK server
            //turn stays with the current player, because now they make the first move of the next round
            NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
            [currentMatch endTurnWithNextParticipant:currentMatch.currentParticipant
                                           matchData:data completionHandler:^(NSError *error) {
                                               if (error) {
                                                   NSLog(@"%@", error);
                                               }
                                           }];
            
            //not necessary??
            previousWinningIndex = winningIndex;
            playerZeroPreviousMove = playerZeroMove;
            playerOnePreviousMove = playerOneMove;
            
            //immediately display the result of the current round
            [self displayRoundOver:winningIndex];
        }
    }else{
        //round is still ongoing, just send the matchMessage to GK server
        //player is already in observing status
        NSLog(@"matchMessage7");
        NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
        [currentMatch endTurnWithNextParticipant:nextParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];
    }
    NSLog(@"sent:%@", matchMessage);

}


-(void)enterNewGame:(GKTurnBasedMatch *)match
          numRounds:(int)numRounds{
    NSLog(@"enterNewGame() called");
    
    //initialize the game variables
    currentPlayerIndex = 0;
    playerZeroMove = @"null";
    playerOneMove = @"null";
    playerZeroPreviousMove = @"null";
    playerOnePreviousMove = @"null";
    playerZeroScore = 0;
    playerOneScore = 0;
    currentRound = 1;
    numberOfRounds = numRounds;
    
    //immediately allow the player to make the first move
    playerStatusRPS = takingTurn;
    [self displayTurnAvailable];
    turnStateLabel.text = @"Your turn";
    nextRoundButton.hidden = true;
    [self enablePlayingObjects];
    [self displayRoundNumber:currentRound];
    
    //save the basic/trivial game variables in case the player leaves and comes back without having made a move
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];

    NSString *matchMessage = [NSString stringWithFormat:@"RPS,null,null,0,0,1,%u,running,null,null,true,true,-2,true,true,true,true,", numberOfRounds];
    NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
    [currentMatch endTurnWithNextParticipant:currentMatch.currentParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];
    
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    //takeTurn called when it is this player's turn.
    //since takeTurn was called, this players index is the index of the player whose turn it is
    currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
    playerStatusRPS = takingTurn;
    [self updateGameVariables:match];
    [self displayTurnAvailable];
    NSLog(@"takeTurn() called");
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    //layoutMatch called when gameOver or when it is not the player's turn
    int otherPlayersIndex = [match.participants indexOfObject:match.currentParticipant];
    currentPlayerIndex = 1 - otherPlayersIndex;
    playerStatusRPS = observing;        //temporary, will change
    [self updateGameVariables:match];
    [self displayObservingStatus];
    NSLog(@"layoutMatch() called");
    
}

-(void)sendScoreToLeaderboard:(NSString*)scoreType{
    //the format of this method is different than CF because of the way performTurn is organized
    NSArray* lbInfo1;
    NSArray* lbInfo2;
    NSArray* lbInfo3;
    NSLog(@"sending game end score for this player");
    if([scoreType isEqualToString:@"gameWin"]){
        //increment round based leaderboard, total coin flip leaderboard, and total game wins leaderboard
        lbInfo1 = [FunctionLibrary getLeaderboardNameAndID:RPS numRounds:numberOfRounds lType:@"totalWins"];
        lbInfo2 = [FunctionLibrary getLeaderboardNameAndID:RPS numRounds:-1 lType:@"totalWins"];
        lbInfo3 = [FunctionLibrary getLeaderboardNameAndID:TOTAL numRounds:-1 lType:@"totalWins"];
        
        //NSLog(@"Incrementing leaderboard:%@,", [lbInfo1 objectAtIndex:0]);
        [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo1 objectAtIndex:0] leaderboardID:[lbInfo1 objectAtIndex:1]];
        //NSLog(@"Incrementing leaderboard:%@,", [lbInfo2 objectAtIndex:0]);
        [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo2 objectAtIndex:0] leaderboardID:[lbInfo2 objectAtIndex:1]];
        //NSLog(@"Incrementing leaderboard:%@,", [lbInfo3 objectAtIndex:0]);
        [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo3 objectAtIndex:0] leaderboardID:[lbInfo3 objectAtIndex:1]];
    }else{
        //need to increment total rounds won leaderboard
        lbInfo1 = [FunctionLibrary getLeaderboardNameAndID:TOTAL numRounds:-1 lType:@"roundWins"];
        //NSLog(@"Incrementing leaderboard:%@,", [lbInfo1 objectAtIndex:0]);
        [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo1 objectAtIndex:0] leaderboardID:[lbInfo1 objectAtIndex:1]];
    
        //both round win and game win will increment the round win by 1
        lbInfo2 = [FunctionLibrary getLeaderboardNameAndID:RPS numRounds:-1 lType:@"roundWins"];
        [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo2 objectAtIndex:0] leaderboardID:[lbInfo2 objectAtIndex:1]];
    }
    
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    //never actually called?
    NSLog(@"recieveEndGame() called");
    playerStatusRPS = gameOver;
}

- (IBAction)paperPressed:(id)sender {
    [self performTurn:@"paper"];
}

- (IBAction)scissorsPressed:(id)sender {
    [self performTurn:@"scissors"];
}

- (IBAction)rockPressed:(id)sender {
    [self performTurn:@"rock"];
}

- (IBAction)nextRoundPressed:(id)sender {
    nextRoundButton.hidden = true;
    buttonPressResultLabel.text = @"";
    
    GKTurnBasedMatch *match = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    GKPlayer *turnHolder = match.currentParticipant.player;
    GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if([turnHolder isEqual:localPlayer]){
        //current player has turn
        playerStatusRPS = takingTurn;
        [self displayTurnAvailable];
    }else{
        //other player has turn
        playerStatusRPS = observing;
        [self displayObservingStatus];
    }
}

-(void)displayTurnAvailable{
    turnStateLabel.text = @"Your turn";
    nextRoundButton.hidden = true;
    NSLog(@"displayTurnAvailable() called");
    [self enablePlayingObjects];
    [self displayRoundNumber:currentRound];
}

-(void)displayObservingStatus{
    turnStateLabel.text = @"Not your turn. Please wait";
    nextRoundButton.hidden = true;
    NSLog(@"displayObservingStatus() called");
    [self disablePlayingObjects];
    [self displayRoundNumber:currentRound];
}

-(void)displayPreviousRoundResult:(GKTurnBasedMatch *)match {
    [self displayRoundOver:previousWinningIndex];
    if(currentPlayerHasTurn){
        //if this player has the turn, update the match data to show that this player has seen the result of the last round
        nextRoundButton.hidden = false;
        
        NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        
        //update the match data to show that both players have seen the result so the previous results aren't continuously displayed when the match is opened
        NSString* matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%@,%@,%@,%@,running,%@,%@,true,true,%@,%@,%@,%@,%@,", dataItems[1], dataItems[2], dataItems[3], dataItems[4], dataItems[5], dataItems[6], dataItems[8], dataItems[9], dataItems[12],dataItems[13],dataItems[14],dataItems[15],dataItems[16]];
        NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
        [match endTurnWithNextParticipant:match.currentParticipant
                                matchData:data completionHandler:^(NSError *error) {
                                    if (error) {
                                        NSLog(@"%@", error);
                                    }
         }];
    }else{
        nextRoundButton.hidden = true;
        turnStateLabel.text = @"Round over, waiting for opponent to play his turn";
    }
}

-(void)displayRoundOver:(int)winningPlayerIndex{
    turnStateLabel.text = @"Round over";
    NSLog(@"displayRoundOver() called");
    [self disablePlayingObjects];
    nextRoundButton.hidden = false;
    
    if(winningPlayerIndex != -1){
        //the current round had already been incremented, display the previous round when showing round results
        [self displayRoundNumber:(currentRound-1)];
    }else{
        //current round was not incremented earlier, can keep the same round number since a tie doesnt end a round
        [self displayRoundNumber:currentRound];
    }
    
    if(winningPlayerIndex == -2){
        //something messed up
        NSLog(@"SOMETHING WENT WRONG, WINNING PLAYER INDEX IS -2");
    }
    
    if(currentPlayerIndex == 0){
        if(winningPlayerIndex == 0){
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Your %@ beat your opponent's %@. You win!", playerZeroPreviousMove,playerOnePreviousMove]];
        }else if(winningPlayerIndex == 1){
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Opponent's %@ beat your %@. You lose!", playerOnePreviousMove,playerZeroPreviousMove]];
        }else{
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Both players chose %@. Tie!", playerOnePreviousMove]];
        }
    }else{
        if(winningPlayerIndex == 0){
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Opponent's %@ beat your %@. You lose!", playerZeroPreviousMove,playerOnePreviousMove]];
        }else if(winningPlayerIndex == 1){
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Your %@ beat your opponent's %@. You win!", playerOnePreviousMove,playerZeroPreviousMove]];
        }else{
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Both players chose %@. Tie!", playerOnePreviousMove]];
        }
    }
}

-(void)displayGameOver{
    turnStateLabel.text = @"Game over";
    if(currentPlayerIndex == 0){
        if(playerZeroScore > playerOneScore){
            buttonPressResultLabel.text = @"You won!";
        }else{
            buttonPressResultLabel.text = @"You lost!";
        }
    }else{
        if(playerZeroScore > playerOneScore){
            buttonPressResultLabel.text = @"You lost!";
        }else{
            buttonPressResultLabel.text = @"You won!";
        }
    }
    NSLog(@"displayGameOver() called");
    [self disablePlayingObjects];
    [self displayRoundNumber:currentRound];
    nextRoundButton.hidden = true;
}

-(void)displayRoundNumber: (int)roundNumToDisplay{
    //NSLog(@"display is %u, cr is %u",roundNumToDisplay,currentRound);
    [roundLabel setText:[NSString stringWithFormat:@"%u of %u", roundNumToDisplay,numberOfRounds]];
    if(currentPlayerIndex == 0){
        [p0ScoreLabel setText:[NSString stringWithFormat:@"%u (you)", playerZeroScore]];
        [p1ScoreLabel setText:[NSString stringWithFormat:@"%u", playerOneScore]];
    }else{
        [p0ScoreLabel setText:[NSString stringWithFormat:@"%u", playerZeroScore]];
        [p1ScoreLabel setText:[NSString stringWithFormat:@"%u (you)", playerOneScore]];
    }
}


-(void)disablePlayingObjects{
    [rockButton setEnabled:NO];
    [rockButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    [paperButton setEnabled:NO];
    [paperButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    [scissorsButton setEnabled:NO];
    [scissorsButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
}

-(void)enablePlayingObjects{
    [rockButton setEnabled:YES];
    [rockButton setTitleColor: [UIColor blueColor] forState:UIControlStateNormal];
    [paperButton setEnabled:YES];
    [paperButton setTitleColor: [UIColor blueColor] forState:UIControlStateNormal];
    [scissorsButton setEnabled:YES];
    [scissorsButton setTitleColor: [UIColor blueColor] forState:UIControlStateNormal];
}

-(bool) isGameOver:(int)p0Score
           p1Score:(int)p1Score{
    if(numberOfRounds == 1){
        return true;
    }else if(numberOfRounds == 3){
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

-(int) updatePlayerScores:(NSString *)p0Move
             p1Move:(NSString *)p1Move{
    if([p0Move isEqualToString:@"rock"]){
        if([p1Move isEqualToString:@"rock"]){
            //tie
            return -1;
        }else if([p1Move isEqualToString:@"paper"]){
            //p1 wins
            playerOneScore = playerOneScore + 1;
            return 1;
        }else{
            //p1 played scissors, p0 wins
            playerZeroScore = playerZeroScore + 1;
            return 0;
        }
            
    }else if([p0Move isEqualToString:@"paper"]){
        if([p1Move isEqualToString:@"rock"]){
            //p0 wins
            playerZeroScore = playerZeroScore + 1;
            return 0;
        }else if([p1Move isEqualToString:@"paper"]){
            //tie
            return -1;
        }else{
            //p1 played scissors, p1 wins
            playerOneScore = playerOneScore + 1;
            return 1;
        }
    }else{
        //p0 played scissors
        if([p1Move isEqualToString:@"rock"]){
            //p1 wins
            playerOneScore = playerOneScore + 1;
            return 1;
        }else if([p1Move isEqualToString:@"paper"]){
            //p0 wins
            playerZeroScore = playerZeroScore + 1;
            return 0;
        }else{
            //p1 played scissors, tie
            return -1;
        }
    }
    //should never get here
    return -1;
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
