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
enum playerRoleRPS playerStatusRPS = observing;
int playerZeroScore = 0;
int playerOneScore = 0;
NSString *playerZeroMove;
NSString *playerOneMove;

+(void)initialize{
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self disablePlayingObjects];
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    
    
    [self updatePlayerStatus:currentMatch];
    [self updateGameVariables:currentMatch];
    
    //[self updateGameVariables:currentMatch];
    
    // Do any additional setup after loading the view.
    if(playerStatusRPS == takingTurn){
        NSLog(@"player status is takingTurn");
        [self displayTurnAvailable];
    }else if (playerStatusRPS == observing){
        NSLog(@"player status is observing");
        [self displayObservingStatus];
    }else if(playerStatusRPS == roundOver){
        //[self displayRoundOver];
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
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    GKPlayer *turnHolder = currentMatch.currentParticipant.player;
    GKPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
    if([turnHolder isEqual:localPlayer]){
        NSLog(@"current player has the turn");
        playerStatusRPS = takingTurn;
        currentPlayerIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    }else{
        NSLog(@"Other player has the turn");
        playerStatusRPS = observing;
        currentPlayerIndex = 1 - [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    }
    

}

-(void)performTurn:(NSString *)playerChoice{
    
    playerStatusRPS = observing;
    [self displayObservingStatus];
    
    NSLog(@"perform turn pressed");
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
    NSString *p0Move;
    NSString *p1Move;
    
    if ([currentMatch.matchData bytes]) {
        
        NSString *incomingData = [NSString stringWithUTF8String:[currentMatch.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        //p0Move = dataItems[1];
        //p1Move = dataItems[2];
        //playerZeroScore = [dataItems[3] intValue];
        //playerOneScore = [dataItems[4] intValue];
        //currentRound = [dataItems[5] intValue];

        if (currentPlayerIndex == 0){
            if([playerZeroMove isEqualToString:@"null"] && ![playerOneMove isEqualToString:@"null"]){
                //other player has made his move, now this round is over
                NSLog(@"round is ova");
                endOfRound = true;
                playerZeroMove = playerChoice;
                matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,%u", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,currentIndex];
            }else{
                //other player has not made a move, current player is making the first move
                NSLog(@"first part of round is ova, player %u has made a move", currentPlayerIndex);
                matchMessage = [NSString stringWithFormat:@"RPS,%@,null,%u,%u,%u,%u,%u", playerChoice, playerZeroScore, playerOneScore, currentRound, numberOfRounds,nextPlayerIndex];
            }
        }else{
            //currentPlayerIndex = 1
            if([playerOneMove isEqualToString:@"null"] && ![playerZeroMove isEqualToString:@"null"]){
                //other player has made his move, now this round is over
                endOfRound = true;
                playerOneMove = playerChoice;
                NSLog(@"round is ova");
                matchMessage = [NSString stringWithFormat:@"RPS,%@,%@,%u,%u,%u,%u,%u", playerZeroMove, playerOneMove, playerZeroScore, playerOneScore, currentRound, numberOfRounds,currentIndex];
            }else{
                //other player has not made a move, current player is making the first move
                matchMessage = [NSString stringWithFormat:@"RPS,null,%@,%u,%u,%u,%u,%u", playerChoice, playerZeroScore, playerOneScore, currentRound, numberOfRounds,nextPlayerIndex];
                NSLog(@"first part of round is ova, player %u has made a move", currentPlayerIndex);
            }
        }
    }else{
        matchMessage = [NSString stringWithFormat:@"RPS,%@,null,0,0,1,%u,1", playerChoice, numberOfRounds];
    }
    
    if(endOfRound){
        NSLog(@"Round is over");
        int winningIndex = [self getRPSWinner:playerZeroMove p1Move:playerOneMove];
        bool didTie = false;
        
        if(winningIndex == 0){
            playerZeroScore = playerZeroScore + 1;
        }else if (winningIndex == 1){
            playerOneScore = playerOneScore + 1;
        }else{
            didTie = true;
        }
        
        GKTurnBasedParticipant *playerZero = [currentMatch.participants objectAtIndex: 0];
        GKTurnBasedParticipant *playerOne = [currentMatch.participants objectAtIndex: 1];
        
        bool gameIsOver = [self isGameOver:playerZeroScore p1Score:playerOneScore];
        if(gameIsOver){
            NSLog(@"GAME IS NOW OVER");
            if(playerZeroScore > playerOneScore){
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeWon;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }else{
                playerZero.matchOutcome = GKTurnBasedMatchOutcomeLost;
                playerOne.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            
            [self displayGameOver];
            NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
            [currentMatch endMatchInTurnWithMatchData:data
                                    completionHandler:^(NSError *error) {
                                        if (error) {
                                            NSLog(@"%@", error);
                                        }
                                    }];
            
            
        }else{
            NSLog(@"saved data:%@",matchMessage);
            NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
            [currentMatch endTurnWithNextParticipant:currentMatch.currentParticipant
                                           matchData:data completionHandler:^(NSError *error) {
                                               if (error) {
                                                   NSLog(@"%@", error);
                                               }
                                           }];
            currentRound = currentRound + 1;
            [self displayRoundOver:winningIndex];
        }
    }else{
        NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
        [currentMatch endTurnWithNextParticipant:nextParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];
        NSLog(@"sent:%@", matchMessage);
    }

}


-(void)enterNewGame:(GKTurnBasedMatch *)match
          numRounds:(int)numRounds{
    NSLog(@"entered new game");
    currentPlayerIndex = 0;
    
    playerZeroMove = @"null";
    playerOneMove = @"null";
    playerZeroScore = 0;
    playerOneScore = 0;
    currentRound = 1;
    numberOfRounds = numRounds;
    NSLog(@"number of rounds is %u", numberOfRounds);
    
    
    playerStatusRPS = takingTurn;

    [self displayTurnAvailable];
    turnStateLabel.text = @"Your turn";
    nextRoundButton.hidden = true;
    [self enablePlayingObjects];
    [self displayRoundNumber:currentRound];
    
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];

    NSString *matchMessage = [NSString stringWithFormat:@"RPS,null,null,0,0,1,%u,0", numberOfRounds];
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
    NSLog(@"takeTurn called");
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    
    int otherPlayersIndex = [match.participants indexOfObject:match.currentParticipant];
    currentPlayerIndex = 1 - otherPlayersIndex;
    playerStatusRPS = observing;        //temporary, will change
    [self updateGameVariables:match];
    NSLog(@"number of rounds is %u", numberOfRounds);
    [self displayObservingStatus];
    NSLog(@"layoutMatch called");
    
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"GAME END");
    playerStatusRPS = gameOver;
}

-(void)updateGameVariables:(GKTurnBasedMatch *)match {
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    if ([currentMatch.matchData bytes]) {
        NSString *incomingData = [NSString stringWithUTF8String:[currentMatch.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        playerZeroMove = dataItems[1];
        playerOneMove = dataItems[2];
        playerZeroScore = [dataItems[3] intValue];
        playerOneScore = [dataItems[4] intValue];
        currentRound = [dataItems[5] intValue];
        NSLog(@"dataitems6 is %@",dataItems[6]);
        numberOfRounds = [dataItems[6] intValue];
        NSLog(@"now, NOR is set to %u", numberOfRounds);
    }else{
        playerZeroMove = @"null";
        playerOneMove = @"null";
        playerZeroScore = 0;
        playerOneScore = 0;
        currentRound = 1;
    }
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
    NSLog(@"next round pressed");
    nextRoundButton.hidden = true;
    playerStatusRPS = takingTurn;
    [self displayTurnAvailable];
}

-(void)displayTurnAvailable{
    turnStateLabel.text = @"Your turn";
    nextRoundButton.hidden = true;
    NSLog(@"here1");
    
    //GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    //[self updateGameVariables:currentMatch];
    
    [self enablePlayingObjects];
    NSLog(@"about to print round number and scores");
    [self displayRoundNumber:currentRound];
}

-(void)displayObservingStatus{
    turnStateLabel.text = @"Not your turn. Please wait";
    nextRoundButton.hidden = true;
    NSLog(@"here2");
    
    //GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    //[self updateGameVariables:currentMatch];
    [self disablePlayingObjects];
    [self displayRoundNumber:currentRound];
}

-(void)displayRoundOver:(int)winningPlayerIndex{
    turnStateLabel.text = @"Round over";
    NSLog(@"here3");
    [self disablePlayingObjects];
    nextRoundButton.hidden = false;
    [self displayRoundNumber:(currentRound-1)];
    if(currentPlayerIndex == 0){
        if(winningPlayerIndex == 0){
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Your %@ beat your opponent's %@. You win!", playerZeroMove,playerOneMove]];
        }else if(winningPlayerIndex == 1){
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Opponent's %@ beat your %@. You lose!", playerOneMove,playerZeroMove]];
        }else{
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Both players chose %@. Tie!", playerOneMove]];
        }
    }else{
        if(winningPlayerIndex == 0){
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Opponent's %@ beat your %@. You lose!", playerZeroMove,playerOneMove]];
        }else if(winningPlayerIndex == 1){
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Your %@ beat your opponent's %@. You win!", playerOneMove,playerZeroMove]];
        }else{
            [buttonPressResultLabel setText:[NSString stringWithFormat:@"Both players chose %@. Tie!", playerOneMove]];
        }
    }
}

-(void)displayGameOver{
    turnStateLabel.text = @"Game over";
    NSLog(@"here4");
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

-(int) getRPSWinner:(NSString *)p0Move
             p1Move:(NSString *)p1Move{
    if([p0Move isEqualToString:@"rock"]){
        if([p1Move isEqualToString:@"rock"]){
            //tie
            return -1;
        }else if([p1Move isEqualToString:@"paper"]){
            //p1 wins
            return 1;
        }else{
            //p1 played scissors, p0 wins
            return 0;
        }
            
    }else if([p0Move isEqualToString:@"paper"]){
        if([p1Move isEqualToString:@"rock"]){
            //p0 wins
            return 0;
        }else if([p1Move isEqualToString:@"paper"]){
            //tie
            return -1;
        }else{
            //p1 played scissors, p1 wins
            return 1;
        }
    }else{
        //p0 played scissors
        if([p1Move isEqualToString:@"rock"]){
            //p1 wins
            return 1;
        }else if([p1Move isEqualToString:@"paper"]){
            //p0 wins
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
