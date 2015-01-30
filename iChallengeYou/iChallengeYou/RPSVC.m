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
enum playerRoleRPS playerStatusRPS;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self disablePlayingObjects];
    // Do any additional setup after loading the view.
    if(playerStatusRPS == takingTurn){
        NSLog(@"player status is takingTurn");
        [self displayTurnAvailable];
    }else if (playerStatusRPS == observing){
        [self displayObservingStatus];
    }else if(playerStatusRPS == roundOver){
        [self displayRoundOver];
    }else{
        [self displayGameOver];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)performTurn:(NSString *)playerChoice{
    
    playerStatusRPS = observing;
    [self displayObservingStatus];
    
    NSLog(@"perform turn pressed");
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    currentPlayerIndex = currentIndex;
    GKTurnBasedParticipant *nextParticipant;
    
    if(currentIndex == 0){
        nextParticipant = [currentMatch.participants objectAtIndex: 1];
    }else{
        //currentIndex = 1
        nextParticipant = [currentMatch.participants objectAtIndex: 0];
    }
    NSString *matchMessage;
    bool endOfRound = false;
    
    if ([currentMatch.matchData bytes]) {
        
        NSString *incomingData = [NSString stringWithUTF8String:[currentMatch.matchData bytes]];
        NSArray *dataItems = [incomingData componentsSeparatedByString:@","];
        NSString *p0Move = dataItems[0];
        NSString *p1Move = dataItems[1];
        int p0Score = [dataItems[2] intValue];
        int p1Score = [dataItems[3] intValue];
        currentRound = [dataItems[4] intValue];

        if (currentPlayerIndex == 0){
            if([p0Move isEqualToString:@"null"] && ![p1Move isEqualToString:@"null"]){
                //other player has made his move, now this round is over
                NSLog(@"round is ova");
                endOfRound = true;
            }else{
                //other player has not made a move, current player is making the first move
                NSLog(@"first part of round is ova, player %u has made a move", currentPlayerIndex);
                matchMessage = [NSString stringWithFormat:@"%@,null,%u,%u,%u,%u", playerChoice, p0Score, p1Score, currentRound, numberOfRounds];
            }
        }else{
            //currentPlayerIndex = 1
            if([p1Move isEqualToString:@"null"] && ![p0Move isEqualToString:@"null"]){
                //other player has made his move, now this round is over
                endOfRound = true;
                NSLog(@"round is ova");
            }else{
                //other player has not made a move, current player is making the first move
                matchMessage = [NSString stringWithFormat:@"null,%@,%u,%u,%u,%u", playerChoice, p0Score, p1Score, currentRound, numberOfRounds];
                NSLog(@"first part of round is ova, player %u has made a move", currentPlayerIndex);
            }
        }
    }else{
        matchMessage = [NSString stringWithFormat:@"%@,null,0,0,1,%u", playerChoice, numberOfRounds];
    }
    
    if(endOfRound){
        [self displayRoundOver];
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


-(void)enterNewGame:(GKTurnBasedMatch *)match{
    NSLog(@"entered new game");
    currentPlayerIndex = 0;
    playerStatusRPS = takingTurn;
    [self displayTurnAvailable];
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    //since takeTurn was called, this players index is the index of the player whose turn it is
    currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
    playerStatusRPS = takingTurn;
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    int otherPlayersIndex = [match.participants indexOfObject:match.currentParticipant];
    currentPlayerIndex = 1 - otherPlayersIndex;
    playerStatusRPS = observing;        //temporary, will change
    
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"GAME END");
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
    playerStatusRPS = takingTurn;
    [self displayTurnAvailable];
}

-(void)displayTurnAvailable{
    turnStateLabel.text = @"Your turn";
    nextRoundButton.hidden = true;
    NSLog(@"here1");
    [self enablePlayingObjects];
}

-(void)displayObservingStatus{
    turnStateLabel.text = @"Not your turn. Please wait";
    nextRoundButton.hidden = true;
    NSLog(@"here2");
    [self disablePlayingObjects];
}

-(void)displayRoundOver{
    turnStateLabel.text = @"Round over";
    NSLog(@"here3");
    [self disablePlayingObjects];
    nextRoundButton.hidden = false;
    
}

-(void)displayGameOver{
    turnStateLabel.text = @"Game over";
    NSLog(@"here4");
    [self disablePlayingObjects];
    nextRoundButton.hidden = true;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
