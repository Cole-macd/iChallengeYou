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

@implementation WATOMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [GCTurnBasedMatchHelper sharedInstance].delegate = self;
    //_betMessageLabel.text = _betMessage;
    //NSLog(@"bet message is %@", _betMessage);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    //[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)enterNewGame:(GKTurnBasedMatch *)match
                msg:(NSString*)msg{
    NSLog(@"new game NOW");
    betMessage = msg;
    _betMessageLabel.text = msg;
    
    //format is WATO,betMessage,betRange,p0Guess,p1Guess
    NSString *matchMessage = [NSString stringWithFormat:@"WATO,%@,-1,-1,-1,", msg];
    NSData *data = [matchMessage dataUsingEncoding:NSUTF8StringEncoding ];
    
    GKTurnBasedParticipant *nextParticipant = [match.participants objectAtIndex: 1];

    //save the bet message to the match data and send turn to opposing player
    [match endTurnWithNextParticipant:nextParticipant
                                   matchData:data completionHandler:^(NSError *error) {
                                       if (error) {
                                           NSLog(@"%@", error);
                                       }
                                   }];

}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    NSLog(@"take turn NOW");
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    NSLog(@"layout match pressed");
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"game is over NOW");
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
