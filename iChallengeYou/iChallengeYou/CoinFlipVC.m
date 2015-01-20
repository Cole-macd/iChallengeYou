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

@interface CoinFlipVC ()
//@property (weak, nonatomic) IBOutlet UILabel *turnLabel;

@end

@implementation CoinFlipVC

int activePlayer;
@synthesize numberOfRounds;
@synthesize currentRound;
int turnsCompleted = 0;
int currentPlayerIndex;
enum playerRole playerStatus = observing;

//GKTurnBasedMatch *currentMatch;



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"View did load");
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    nextRoundButton.hidden = true;
    
    if (playerStatus == observing){
        NSLog(@"player status is observing");
        [self displayObservingStatus];
    }else if(playerStatus == calling){
        [self displayCallingStatus];
        NSLog(@"player status is calling");
    }else if(playerStatus == roundEnd){
        [self layoutMatch:currentMatch];
    }
}

- (void)viewDidUnload{
    NSLog(@"view did unload");
    [self disablePlayingObjects];
    roundLabel.text = @"";
    gameStateLabel.text = @"";
    turnLabel.text = @"";
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
    
    //get the previous existing scores
    NSString *incomingData =
    [NSString stringWithUTF8String:[currentMatch.matchData bytes]];
    NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
    
    int playerAtIndexZeroScore = [dataItems[5] intValue];
    int playerAtIndexOneScore = [dataItems[6] intValue];
    
    //check if player's call was correct
    int coinResultInt = arc4random_uniform(2);
    NSString *coinResult;
    if (coinResultInt == 0){
        coinResult = @"heads";
    }else{
        coinResult = @"tails";
    }
    
    bool playerChoiceCorrect = [playerChoice isEqualToString:coinResult];
    
    if(currentIndex == 0){
        nextParticipant = [currentMatch.participants objectAtIndex: 1];
        if(nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit){
            NSLog(@"No player in the game who has not quit");
        }
        
        //update the winning player's score
        if(playerChoiceCorrect){
            playerAtIndexZeroScore = playerAtIndexZeroScore + 1;
        }else{
            playerAtIndexOneScore = playerAtIndexOneScore + 1;
        }
        
    }else{
        //current index is 1
        nextParticipant = [currentMatch.participants objectAtIndex: 0];
        if(nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit){
            NSLog(@"No player in the game who has not quit");
        }
        
        //update the winning player's score
        if(playerChoiceCorrect){
            playerAtIndexOneScore = playerAtIndexOneScore + 1;
        }else{
            playerAtIndexZeroScore = playerAtIndexZeroScore + 1;
        }
    }
    
    currentRound = currentRound + 1;
    
    //format is "playerRole,playerCoinCall,coinCallResult,currentRound,numberOfRounds,playerAtIndexZeroScore,playerAtIndexOneScore,callingPlayerIndex"
    NSString *matchMessage = [NSString stringWithFormat:@"call,%@,%@,%u,%u,%u,%u,%u",playerChoice, coinResult, currentRound, numberOfRounds,playerAtIndexZeroScore,playerAtIndexOneScore,(unsigned int)currentIndex];
    
    NSData *data =
    [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
    
    [currentMatch endTurnWithNextParticipant:nextParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];
    NSLog(@"Send Turn, %@, %@", matchMessage, nextParticipant);
    
    //display the result of this player's call immediately
    [self displayRoundResult:playerChoice coinResult:coinResult justSent:true match:currentMatch];
    playerStatus = observing;
}



-(void)enterNewGame:(GKTurnBasedMatch *)match{
    NSLog(@"New game, number of rounds is %d", numberOfRounds);
    
    [roundLabel setText:[NSString stringWithFormat:@"Round 1 of %u", numberOfRounds]];
    currentRound = 1;
    nextRoundButton.hidden = true;
    currentPlayerIndex = 0;
    
    playerStatus = observing;
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    [self displayObservingStatus];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    
    GKTurnBasedParticipant *nextParticipant;
    if(currentIndex == 0){
        nextParticipant = [currentMatch.participants objectAtIndex: 1];
        if(nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit){
            NSLog(@"No player in the game who has not quit");
        }
    }else{
        nextParticipant = [currentMatch.participants objectAtIndex: 0];
        if(nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit){
            NSLog(@"No player in the game who has not quit");
        }
    }
    //format is "playerRole,playerCoinCall,coinCallResult,currentRound,numberOfRounds,playerAtIndexZeroScore,playerAtIndexOneScore,callingPlayerIndex"
    NSString *matchMessage = [NSString stringWithFormat:@"call,none,none,%u,%u,0,0,1",currentRound, numberOfRounds];
    
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
        NSArray *dataItems = [data componentsSeparatedByString:@","];
        currentRound = [dataItems[3] intValue];
        numberOfRounds = [dataItems[4] intValue];
        
        //since takeTurn was called, this is the player whose current turn it is
        currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
        NSLog(@"Just set currentPlayerIndex to %d", currentPlayerIndex);
        
        if([dataItems[0]  isEqual: @"call"]){
            NSLog(@"here1");
            GKTurnBasedParticipant *thisParticipant = [match.participants objectAtIndex:1];
            if (thisParticipant.lastTurnDate == NULL) {
                //the first "call" of the game
                NSLog(@"here2");
                playerStatus = calling;
                [self displayCallingStatus];
            }else{
                //this players turn to call, must display previous round results first
                playerStatus = roundEnd;
                [self displayRoundResult:dataItems[1] coinResult:dataItems[2] justSent:false match:match];
                nextRoundButton.hidden = false;
                NSLog(@"here3");
            }
            
            //playerStatus = calling;
            //[self displayCallingStatus];
        }else if([dataItems[0]  isEqual: @"observing"]){
            playerStatus = observing;
            [self displayObservingStatus];
            NSLog(@"here4");
        }else{
            //should never get here
            NSLog(@"I AM HEREEE");
            /*playerStatus = roundEnd;
             NSLog(@"data string is '%@', there are %lu items in the data array", data, (unsigned long)[dataItems count]);
             [self displayRoundResult:dataItems[1] coinResult:dataItems[2] callingPlayerIndex:[dataItems[7] intValue] match:match];*/
        }
        NSLog(@"match data is:%@", data);
    }
    
}
- (IBAction)nextRoundPressed:(id)sender {
    //next round
    NSLog(@"Next Round button pressed");
    playerStatus = calling;
    [self displayCallingStatus];
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    //looking at match when it is not your turn
    //need to add check for if round over
    
    if ([match.matchData bytes]) {
        NSString *data =
        [NSString stringWithUTF8String:[match.matchData bytes]];
        NSArray *dataItems = [data componentsSeparatedByString:@","];
        
        
        
        
        currentRound = [dataItems[3] intValue];
        numberOfRounds = [dataItems[4] intValue];
        if(playerStatus == roundEnd){
            //here when it is this players turn to call, but first must show the results of previous round
            //currentPlayerIndex already set in takeTurn
            NSLog(@"ROUND IS OVER");
            NSLog(@"data string is '%@', there are %lu items in the data array", data, (unsigned long)[dataItems count]);
            [self displayRoundResult:dataItems[1] coinResult:dataItems[2] justSent:false match:match];
            nextRoundButton.hidden = false;
            playerStatus = calling;
        }else{
            //since layoutMatch is called when it is not the player's turn, the current player index is the opposite of whose turn it is
            int otherPlayersIndex = [match.participants indexOfObject:match.currentParticipant];
            currentPlayerIndex = 1 - otherPlayersIndex;
            NSLog(@"OTHER PLAYERS TURN");
            playerStatus = observing;
            [self displayObservingStatus];
        }
    }else{
        //no other player in the game yet, still player at index 0
        currentPlayerIndex = 0;
        NSLog(@"OTHER PLAYERS TURN");
        playerStatus = observing;
        [self displayObservingStatus];
    }
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"GAME END");
    [self layoutMatch:match];
    turnLabel.text = @"Game has ended";
}

-(void) endGame:(int)winningPlayerIndex{
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    NSString *incomingData =[NSString stringWithUTF8String:[currentMatch.matchData bytes]];
    NSData *outgoingData = [incomingData dataUsingEncoding:NSUTF8StringEncoding ];
    
    
    
    GKTurnBasedParticipant *playerZero = [currentMatch.participants objectAtIndex: 0];
    GKTurnBasedParticipant *playerOne = [currentMatch.participants objectAtIndex: 1];
    
    if(winningPlayerIndex == 0){
        playerZero.matchOutcome = GKTurnBasedMatchOutcomeWon;
        playerOne.matchOutcome = GKTurnBasedMatchOutcomeLost;
        NSLog(@"player zero wins");
    }else{
        playerZero.matchOutcome = GKTurnBasedMatchOutcomeLost;
        playerOne.matchOutcome = GKTurnBasedMatchOutcomeWon;
        NSLog(@"player one wins");
    }
    
    [currentMatch endMatchInTurnWithMatchData:outgoingData
                            completionHandler:^(NSError *error) {
                                if (error) {
                                    NSLog(@"%@", error);
                                }
                            }];
}

-(bool)checkForEndGame:(int)p0Score
               p1Score:(int)p1Score{
    
    if(numberOfRounds == 1){
        //this is called after a round has been played, so for a 1 round game, this is the end
        return true;
    }else if (numberOfRounds == 3){
        if(p0Score >= 2){
            return true;
        }else if(p1Score >= 2){
            return true;
        }
    }else{
        if(p0Score >= 3){
            return true;
        }else if(p1Score >= 3){
            return true;
        }
    }
    return false;
}

-(void)displayRoundResult:(NSString *)playerChoice
               coinResult:(NSString *)coinResult
                 justSent:(bool)justSent
                    match:(GKTurnBasedMatch *)match{
    NSLog(@"player status is endRound");
    //nextRoundButton.hidden = false;
    [self disablePlayingObjects];
    
    
    if(justSent){
        [gameStateLabel setText:[NSString stringWithFormat:@"You called %@, result was %@", playerChoice, coinResult]];
    }else{
        [gameStateLabel setText:[NSString stringWithFormat:@"Other player called %@, result was %@", playerChoice, coinResult]];
    }
    
    NSString *incomingData =[NSString stringWithUTF8String:[match.matchData bytes]];
    NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
    int playerZeroScore = [dataItems[5] intValue];
    int playerOneScore = [dataItems[6] intValue];
    bool isGameOver = [self checkForEndGame:playerZeroScore p1Score:playerOneScore];
    
    if(isGameOver){
        [roundLabel setText:[NSString stringWithFormat:@"GAME OVER"]];
        if(playerZeroScore > playerOneScore){
            [self endGame:0];
        }else{
            [self endGame:1];
        }
    }else{
        //displaying the results of the previous round.
        int tempRound = currentRound - 1;
        [roundLabel setText:[NSString stringWithFormat:@"Round %u of %u", tempRound,numberOfRounds]];
    }
    
    
}

-(void)displayObservingStatus{
    NSLog(@"player status is observing");
    [self disablePlayingObjects];
    turnLabel.text = @"Please wait, not your turn";
    [gameStateLabel setText:[NSString stringWithFormat:@"You are player %u", currentPlayerIndex]];
    nextRoundButton.hidden = true;
    [roundLabel setText:[NSString stringWithFormat:@"Round %u of %u", currentRound,numberOfRounds]];
}

-(void)displayCallingStatus{
    NSLog(@"player status is calling");
    [self enablePlayingObjects];
    turnLabel.text = @"Your turn, call the coin";
    [gameStateLabel setText:[NSString stringWithFormat:@"You are player %u", currentPlayerIndex]];
    nextRoundButton.hidden = true;
    [roundLabel setText:[NSString stringWithFormat:@"Round %u of %u", currentRound,numberOfRounds]];
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

