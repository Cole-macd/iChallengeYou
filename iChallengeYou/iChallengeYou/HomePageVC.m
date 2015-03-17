//
//  HomePageVC.m
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "HomePageVC.h"
#import "GCTurnBasedMatchHelper.h"
#import "CoinFlipVC.h"
#import "FunctionLibrary.h" //just for test



@interface HomePageVC ()

@end

@implementation HomePageVC


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Home Page Loaded");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectNewGame:(id)sender {
    NSLog(@"select New Game pressed");
}

- (IBAction)viewCurrentMatches:(id)sender {
    //need to add something for if there are no current matches. right now, it tries to create a game which leads to problems.
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:true playerGroup:0];
}
- (IBAction)showLeaderboards:(id)sender {
    [[GCTurnBasedMatchHelper sharedInstance] showLeaderboard:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"directCoinFlip"]){
        NSLog(@"segue prep called");
        CoinFlipVC* gameVC = (CoinFlipVC*) segue.destinationViewController;
        [GCTurnBasedMatchHelper sharedInstance].delegate = gameVC;
        //gameVC.match = (GKTurnBasedMatch*) sender;
    }
}
- (IBAction)showAchievements:(id)sender {
    //[[GCTurnBasedMatchHelper sharedInstance] reportScore:70 leaderboardName:@"CoinFlip3RoundsTotalWins"];
    //[[GCTurnBasedMatchHelper sharedInstance] reportScore:10 leaderboardName:@"CoinFlipTotalWins"];
    
    NSArray* lbInfo = [FunctionLibrary getLeaderboardNameAndID:CF numRounds:3 lType:@"totalWins"];
    NSLog(@"lName is %@, lID is %@", [lbInfo objectAtIndex:0], [lbInfo objectAtIndex:1]);
    [[GCTurnBasedMatchHelper sharedInstance] incrementLeaderboardScore:[lbInfo objectAtIndex:0] leaderboardID:[lbInfo objectAtIndex:1]];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    NSLog(@"HAR2s");
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
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

