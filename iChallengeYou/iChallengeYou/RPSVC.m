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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(playerStatusRPS == takingTurn){
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
    
    if ([currentMatch.matchData bytes]) {
        NSLog(@"game already going");
    }else{
        matchMessage = [NSString stringWithFormat:@"%@,null,0,0,1,%u", playerChoice, numberOfRounds];
    }
    
    NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
    
    [currentMatch endTurnWithNextParticipant:nextParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];
    NSLog(@"sent:%@", matchMessage);

}


-(void)enterNewGame:(GKTurnBasedMatch *)match{
    currentPlayerIndex = 0;
    playerStatusRPS = takingTurn;
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    //since takeTurn was called, this players index is the index of the player whose turn it is
    currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    int otherPlayersIndex = [match.participants indexOfObject:match.currentParticipant];
    currentPlayerIndex = 1 - otherPlayersIndex;
    
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"GAME END");
    playerStatusRPS = gameOver;
}
- (IBAction)paperPressed:(id)sender {
}

- (IBAction)scissorsPressed:(id)sender {
}

- (IBAction)rockPressed:(id)sender {
}

-(void)displayTurnAvailable{
    turnStateLabel.text = @"Your turn";
    [self enablePlayingObjects];
}

-(void)displayObservingStatus{
    turnStateLabel.text = @"Not your turn. Please wait";
    [self disablePlayingObjects];
}

-(void)displayRoundOver{
    turnStateLabel.text = @"Round over";
    [self disablePlayingObjects];
}

-(void)displayGameOver{
    turnStateLabel.text = @"Game over";
    [self disablePlayingObjects];
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
