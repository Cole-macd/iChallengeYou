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

/*
+(void)initialize{
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
}*/

- (void)viewDidLoad {
    [super viewDidLoad];
    [self disablePlayingObjects];
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    currentPlayerHasTurn = false;
    
    [self updatePlayerStatus:currentMatch];
    [self updateGameVariables:currentMatch];
    
    // Do any additional setup after loading the view.
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
        NSLog(@"current player has the turn");
        playerStatusRPS = takingTurn;
        currentPlayerHasTurn = true;
        currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
    }else{
        NSLog(@"Other player has the turn");
        playerStatusRPS = observing;
        currentPlayerHasTurn = false;
        currentPlayerIndex = 1 - [match.participants indexOfObject:match.currentParticipant];
    }
}


-(void)updateGameVariables:(GKTurnBasedMatch *)match {
    if ([match.matchData bytes]) {
        NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        NSLog(@"match data is %@" , incomingData);
        
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
            playerStatusRPS = gameOver;
            GKPlayer *indexZeroPlayer = [[match.participants objectAtIndex:0] player];
            GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
            if([localPlayer isEqual:indexZeroPlayer]){
                NSLog(@"current player index is 0");
                currentPlayerIndex = 0;
            }else{
                NSLog(@"current player index is 1");
                currentPlayerIndex = 1;
            }
        }else{
            if(currentPlayerIndex == 0){
                if(!playerZeroSeenResult){
                    //this player hasnt seen the result of the last rounf
                    playerStatusRPS = roundOver;
                    NSLog(@"current player (0) has not seen round result yet");
                }
            }else{
                if(!playerOneSeenResult){
                    playerStatusRPS = roundOver;
                    NSLog(@"current player (1) has not seen round result yet");
                }
            }
        }
    }else{
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
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    currentPlayerIndex = currentIndex;
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
    
    
    if ([currentMatch.matchData bytes]) {

        if (currentPlayerIndex == 0){
            if([playerZeroMove isEqualToString:@"null"] && ![playerOneMove isEqualToString:@"null"]){
                //other player has made his move, now this round is over
                NSLog(@"matchMessage1");
                endOfRound = true;
                playerZeroMove = playerChoice;
                winningIndex = [self updatePlayerScores:playerZeroMove p1Move:playerOneMove];
                if(winningIndex != -1){
                    currentRound = currentRound + 1;
                }
                
                playerZeroPreviousMove = playerZeroMove;
                playerOnePreviousMove = playerOneMove;
                previousWinningIndex = winningIndex;
                
                matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,running,%@,%@,true,false,%d,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove,winningIndex];
            }else{
                //other player has not made a move, current player is making the first move
                //playerZeroPreviousMove = playerZeroMove;
                playerZeroMove = playerChoice;
                matchMessage = [NSString stringWithFormat:@"RPS,%@,null,%u,%u,%u,%u,running,%@,%@,true,false,%d,", playerZeroMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroPreviousMove, playerOnePreviousMove,previousWinningIndex];
                NSLog(@"matchMessage2");
            }
        }else{
            //currentPlayerIndex = 1
            if([playerOneMove isEqualToString:@"null"] && ![playerZeroMove isEqualToString:@"null"]){
                //other player has made his move, now this round is over
                endOfRound = true;
                
                //if this is the last round of the game and it is over, currentRound will be decremented below in the if gameOver if statement
                playerOneMove = playerChoice;
                winningIndex = [self updatePlayerScores:playerZeroMove p1Move:playerOneMove];
                if(winningIndex != -1){
                    currentRound = currentRound + 1;
                }
                
                playerZeroPreviousMove = playerZeroMove;
                playerOnePreviousMove = playerOneMove;
                previousWinningIndex = winningIndex;
                
                NSLog(@"matchMessage3");
                //format is RPS, p0CurrentMove, p1CurrentMove, m0Score, p1Score, currentRound, numberOfRounds, gameStatus, p0PreviousMove, p1PreviousMove, p0SeenResult, p1SeenResult
                matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,running,%@,%@,false,true,%d,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex];
            }else{
                //other player has not made a move, current player is making the first move
                //playerOnePreviousMove = playerOneMove;
                playerOneMove = playerChoice;
                
                matchMessage = [NSString stringWithFormat:@"RPS,null,%@,%u,%u,%u,%u,running,%@,%@,false,true,%d,", playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroPreviousMove,playerOnePreviousMove,previousWinningIndex];
                NSLog(@"matchMessage4");
            }
        }
    }else{
        matchMessage = [NSString stringWithFormat:@"RPS,%@,null,0,0,1,%u,running,null,null,true,true,-2,", playerChoice, numberOfRounds];
        NSLog(@"matchMessage5");
    }
    
    if(endOfRound){
        NSLog(@"Round is over");
        //below function call is updatePlayerScores
        //int winningIndex = [self getRPSWinner:playerZeroMove p1Move:playerOneMove];
        //bool didTie = (winningIndex == -1);
        
        
        GKTurnBasedParticipant *playerZero = [currentMatch.participants objectAtIndex: 0];
        GKTurnBasedParticipant *playerOne = [currentMatch.participants objectAtIndex: 1];
        
        bool gameIsOver = [self isGameOver:playerZeroScore p1Score:playerOneScore];
        if((gameIsOver) && (winningIndex != -1)){
            NSLog(@"GAME IS NOW OVER");
            currentRound = currentRound - 1;
            if(playerZeroScore > playerOneScore){
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeWon;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }else{
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeLost;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            
            matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,gameOver,%@,%@,true,true,%d,", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,playerZeroMove,playerOneMove, winningIndex];
            
            
            NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
            [currentMatch endMatchInTurnWithMatchData:data
                                    completionHandler:^(NSError *error) {
                                        if (error) {
                                            NSLog(@"%@", error);
                                        }
                                    }];
            playerZeroPreviousMove = playerZeroMove;
            playerOnePreviousMove = playerOneMove;
            [self displayGameOver];
            
        }else{
            //round is over, game is not over
            NSLog(@"matchMessage6");
            NSLog(@"saved data:%@",matchMessage);
            NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
            [currentMatch endTurnWithNextParticipant:currentMatch.currentParticipant
                                           matchData:data completionHandler:^(NSError *error) {
                                               if (error) {
                                                   NSLog(@"%@", error);
                                               }
                                           }];
            previousWinningIndex = winningIndex;
            playerZeroPreviousMove = playerZeroMove;
            playerOnePreviousMove = playerOneMove;
            
            [self displayRoundOver:winningIndex];
        }
    }else{
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
    currentPlayerIndex = 0;
    
    playerZeroMove = @"null";
    playerOneMove = @"null";
    playerZeroPreviousMove = @"null";
    playerOnePreviousMove = @"null";
    playerZeroScore = 0;
    playerOneScore = 0;
    currentRound = 1;
    numberOfRounds = numRounds;
    
    playerStatusRPS = takingTurn;

    [self displayTurnAvailable];
    turnStateLabel.text = @"Your turn";
    nextRoundButton.hidden = true;
    [self enablePlayingObjects];
    [self displayRoundNumber:currentRound];
    
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];

    NSString *matchMessage = [NSString stringWithFormat:@"RPS,null,null,0,0,1,%u,running,null,null,true,true,-2,", numberOfRounds];
    NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
    [currentMatch endTurnWithNextParticipant:currentMatch.currentParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];
    
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    
    //since takeTurn was called, this players index is the index of the player whose turn it is
    currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
    playerStatusRPS = takingTurn;
    [self updateGameVariables:match];
    [self displayTurnAvailable];
    NSLog(@"takeTurn() called");
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    
    int otherPlayersIndex = [match.participants indexOfObject:match.currentParticipant];
    currentPlayerIndex = 1 - otherPlayersIndex;
    playerStatusRPS = observing;        //temporary, will change
    [self updateGameVariables:match];
    [self displayObservingStatus];
    NSLog(@"layoutMatch() called");
    
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
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
        NSLog(@"current player STILL has turn");
        playerStatusRPS = takingTurn;
        [self displayTurnAvailable];
    }else{
        NSLog(@"OTHER P HAS TURN");
        playerStatusRPS = observing;
        [self displayObservingStatus];
    }
}

-(void)displayTurnAvailable{
    turnStateLabel.text = @"Your turn";
    nextRoundButton.hidden = true;
    NSLog(@"displayTurnAvailable() called");
    
    //GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    //[self updateGameVariables:currentMatch];
    
    [self enablePlayingObjects];
    [self displayRoundNumber:currentRound];
}

-(void)displayObservingStatus{
    turnStateLabel.text = @"Not your turn. Please wait";
    nextRoundButton.hidden = true;
    NSLog(@"displayObservingStatus() called");
    
    //GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    //[self updateGameVariables:currentMatch];
    [self disablePlayingObjects];
    [self displayRoundNumber:currentRound];
}

-(void)displayPreviousRoundResult:(GKTurnBasedMatch *)match {
    [self displayRoundOver:previousWinningIndex];
    if(currentPlayerHasTurn){
        nextRoundButton.hidden = false;
        
        NSString *incomingData = [NSString stringWithUTF8String:[match.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        
        //update the match data to show that both players have seen the result
        NSString* matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%@,%@,%@,%@,running,%@,%@,true,true,%@,", dataItems[1], dataItems[2], dataItems[3], dataItems[4], dataItems[5], dataItems[6], dataItems[8], dataItems[9], dataItems[12]];
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
        [self displayRoundNumber:(currentRound-1)];
    }else{
        [self displayRoundNumber:currentRound];
    }
    
    if(winningPlayerIndex == -2){
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
