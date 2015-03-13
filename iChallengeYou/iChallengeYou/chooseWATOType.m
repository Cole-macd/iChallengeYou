//
//  chooseWATOType.m
//  iChallengeYou
//
//  Created by Matt Gray on 2015-03-13.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "chooseWATOType.h"
#import "FunctionLibrary.h"
#import "GCTurnBasedMatchHelper.h"

@interface chooseWATOType ()

@end

@implementation chooseWATOType

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)joinExistingPressed:(id)sender {
    unsigned int pType = [FunctionLibrary calculatePlayerGroup:WATO numRounds:1];
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:false playerGroup:pType];
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
