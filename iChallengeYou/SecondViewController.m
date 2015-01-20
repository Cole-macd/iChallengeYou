//
//  SecondViewController.m
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "SecondViewController.h"
#import "GCTurnBasedMatchHelper.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

//@synthesize colourChoiceLabel;
NSString *colourPressed;
NSString *previousColourPressed;
BOOL firstTurn = false;
BOOL gameOver = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    //[GCTurnBasedMatchHelper sharedInstance].delegate = self; should not be commented
    [self disablePlayingObjects];
    turnLabel.text = @"Game Not Started";
    colourChoiceLabel.text = @"Chosen: ";
    colourChoiceLabel.textColor = [UIColor blackColor];
    NSLog(@"I am here");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateLabelsAndSendTurn: (NSString*) colour {
    GKTurnBasedMatch *currentMatch =
    [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    GKTurnBasedParticipant *curr = currentMatch.currentParticipant;
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    NSUInteger nextIndex = (currentIndex + 1) % [currentMatch.participants count];
    GKTurnBasedParticipant *next = [currentMatch.participants objectAtIndex:nextIndex];
    
    if (!firstTurn){
        //gameOver = true;
        if ([colour isEqualToString:previousColourPressed]){
            NSLog(@"You guessed the correct colour");
            resultLabel.text = @"CORRECT!";
            curr.matchOutcome = GKTurnBasedMatchOutcomeWon;
            next.matchOutcome = GKTurnBasedMatchOutcomeLost;
            gameOver = true;
            
        }else{
            NSLog(@"You did not guess the correct colour");
            resultLabel.text = @"WRONG!";
            curr.matchOutcome = GKTurnBasedMatchOutcomeLost;
            next.matchOutcome = GKTurnBasedMatchOutcomeWon;
            gameOver = true;
        }
        
    }
    
    
    if ([colour isEqualToString:@"blue"]){
        NSLog(@"blue pressed");
        colourChoiceLabel.textColor = [UIColor blueColor];
        colourChoiceLabel.text = @"Chosen: Blue";
        colourPressed = @"blue";
    }else{
        NSLog(@"red pressed");
        colourChoiceLabel.textColor = [UIColor redColor];
        colourChoiceLabel.text = @"Chosen: Red";
        colourPressed = @"red";
    }
    
    [redButton setEnabled:NO];
    [redButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    [blueButton setEnabled:NO];
    [blueButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    turnLabel.text = @"Not Your turn.";
    
    NSData *data =
    [colourPressed dataUsingEncoding:NSUTF8StringEncoding ];
    
    //NSUInteger currentIndex = [currentMatch.participants
    //indexOfObject:currentMatch.currentParticipant];
    
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
    
    if (gameOver) {
        //self.currentMatch = match;
        NSLog(@"Match Ending");
        [currentMatch endMatchInTurnWithMatchData:data
                                completionHandler:^(NSError *error) {
                                    if (error) {
                                        NSLog(@"%@", error);
                                    }
                                }];
        
    }
    
    [currentMatch endTurnWithNextParticipant:nextParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];
    NSLog(@"Send Turn, %@, %@", data, nextParticipant);
    
    
}

- (IBAction)blueButtonPressed:(id)sender {
    [self updateLabelsAndSendTurn: @"blue"];
}


- (IBAction)redButtonPressed:(id)sender {
    [self updateLabelsAndSendTurn: @"red"];
}

- (void) enablePlayingObjects{
    [redButton setEnabled:YES];
    [redButton setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
    [blueButton setEnabled:YES];
    [blueButton setTitleColor: [UIColor blueColor] forState:UIControlStateNormal];
}

- (void) disablePlayingObjects{
    [redButton setEnabled:NO];
    [redButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
    [blueButton setEnabled:NO];
    [blueButton setTitleColor: [UIColor grayColor] forState:UIControlStateNormal];
}


#pragma mark - GCTurnBasedMatchHelperDelegate

-(void)enterNewGame:(GKTurnBasedMatch *)match {
    NSLog(@"Entering new game...");
    [self enablePlayingObjects];
    turnLabel.text = @"Your Turn";
    colourChoiceLabel.text = @"Chosen: ";
    colourChoiceLabel.textColor = [UIColor blackColor];
    firstTurn = true;
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    NSLog(@"Taking turn for existing game...");
    [self enablePlayingObjects];
    turnLabel.text = @"Your Turn";
    colourChoiceLabel.text = @"Chosen: ";
    colourChoiceLabel.textColor = [UIColor blackColor];
    if ([match.matchData bytes]) {
        previousColourPressed =
        [NSString stringWithUTF8String:[match.matchData bytes]];
        firstTurn = false;
    }
}


-(void)layoutMatch:(GKTurnBasedMatch *)match {
    NSLog(@"Viewing match where it's not our turn...");
    NSString *statusString;
    
    if (match.status == GKTurnBasedMatchStatusEnded) {
        statusString = @"Match Ended";
    } else {
        statusString = @"Not your turn";
    }
    turnLabel.text = statusString;
    [self disablePlayingObjects];
    
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    [self layoutMatch:match];
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