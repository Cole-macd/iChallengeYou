//
//  CoinFlipRoundChoiceVC.m
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "CoinFlipRoundChoiceVC.h"
#import "GCTurnBasedMatchHelper.h"
#import "FunctionLibrary.h"
#import "CoinFlipVC.h"

@interface CoinFlipRoundChoiceVC ()

@end

@implementation CoinFlipRoundChoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)oneRoundChosen:(id)sender {
    [GCTurnBasedMatchHelper sharedInstance].numberOfRounds = 1;
    unsigned int pType = [FunctionLibrary calculatePlayerGroup:CF numRounds:1];
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:false playerGroup:pType];
}

- (IBAction)threeRoundsChosen:(id)sender {
    [GCTurnBasedMatchHelper sharedInstance].numberOfRounds = 3;
    unsigned int pType = [FunctionLibrary calculatePlayerGroup:CF numRounds:3];
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:false playerGroup:pType];
}

- (IBAction)fiveRoundsChosen:(id)sender {
    [GCTurnBasedMatchHelper sharedInstance].numberOfRounds = 5;
    unsigned int pType = [FunctionLibrary calculatePlayerGroup:CF numRounds:5];
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:false playerGroup:pType];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    /*NSLog(@"segue method running");
    if([segue.identifier isEqualToString:@"CF1Round"]){
        CoinFlipVC *controller = (CoinFlipVC *)segue.destinationViewController;
        controller.numberOfRounds = 1;
    }else if([segue.identifier isEqualToString:@"CF3Rounds"]){
        CoinFlipVC *controller = (CoinFlipVC *)segue.destinationViewController;
        controller.numberOfRounds = 3;
    }else if([segue.identifier isEqualToString:@"CF5Rounds"]){
        CoinFlipVC *controller = (CoinFlipVC *)segue.destinationViewController;
        controller.numberOfRounds = 5;
    }*/
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
