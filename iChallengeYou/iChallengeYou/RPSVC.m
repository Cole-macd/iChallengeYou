//
//  RPSVC.m
//  iChallengeYou
//
//  Created by Matt Gray on 2015-01-27.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "RPSVC.h"

@interface RPSVC ()

@end

@implementation RPSVC

@synthesize numberOfRounds;
@synthesize currentRound;

int currentPlayerIndex = 0;
enum playerRole playerStatus = observing;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(playerStatus == takingTurn){
        [self displayTurnAvailable];
    }else if (playerStatus == observing){
        [self displayObservingStatus];
    }else if(playerStatus == roundOver){
        [self displayRoundOver];
    }else{
        [self displayGameOver];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)enterNewGame:(GKTurnBasedMatch *)match{
    currentPlayerIndex = 0;
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    //since takeTurn was called, this players index is the index of the player whose turn it is
    currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    int otherPlayersIndex = [match.participants indexOfObject:match.currentParticipant];
    currentPlayerIndex = 1 - otherPlayersIndex;
    
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
