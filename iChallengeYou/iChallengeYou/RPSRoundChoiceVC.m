//
//  RPSRoundChoiceVC.m
//  iChallengeYou
//
//  Created by Matt Gray on 2015-01-27.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "RPSRoundChoiceVC.h"
#import "GCTurnBasedMatchHelper.h"
#import "FunctionLibrary.h"
#import "RPSVC.h"

@interface RPSRoundChoiceVC ()

@end

@implementation RPSRoundChoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)oneRoundChosen:(id)sender {
    unsigned int pType = [FunctionLibrary calculatePlayerGroup:RPS numRounds:1];
    NSLog(@"ptype is %u", pType);
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:false playerGroup:pType];
}

- (IBAction)threeRoundsChosen:(id)sender {
    unsigned int pType = [FunctionLibrary calculatePlayerGroup:RPS numRounds:3];
    NSLog(@"ptype is %u", pType);
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:false playerGroup:pType];
}


- (IBAction)fiveRoundsChosen:(id)sender {
    unsigned int pType = [FunctionLibrary calculatePlayerGroup:RPS numRounds:5];
    NSLog(@"ptype is %u", pType);
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:false playerGroup:pType];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"segue method running");
    if([segue.identifier isEqualToString:@"RPS1Round"]){
        RPSVC *controller = (RPSVC *)segue.destinationViewController;
        controller.numberOfRounds = 1;
    }else if([segue.identifier isEqualToString:@"RPS3Rounds"]){
        RPSVC *controller = (RPSVC *)segue.destinationViewController;
        controller.numberOfRounds = 3;
    }else if([segue.identifier isEqualToString:@"RPS5Rounds"]){
        RPSVC *controller = (RPSVC *)segue.destinationViewController;
        controller.numberOfRounds = 5;
    }
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
