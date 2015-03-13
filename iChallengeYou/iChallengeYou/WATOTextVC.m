//
//  WATOTextVC.m
//  iChallengeYou
//
//  Created by Matt Gray on 2015-03-11.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "WATOTextVC.h"
#import "WATOMainVC.h"
#import "FunctionLibrary.h"
#import "GCTurnBasedMatchHelper.h"

@interface WATOTextVC ()

@end

@implementation WATOTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_betTextBox setDelegate:self];
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

- (IBAction)sendInvitationPressed:(id)sender {
    if(![_betTextBox.text  isEqual: @""]){
        unsigned int pType = [FunctionLibrary calculatePlayerGroup:WATO numRounds:1];
        [GCTurnBasedMatchHelper sharedInstance].WATObetMessage = _betTextBox.text;
        NSLog(@"ptype is %u", pType);
        [[GCTurnBasedMatchHelper sharedInstance]
         findMatchWithMinPlayers:2 maxPlayers:2 viewController:self showMatches:false playerGroup:pType];
        [self performSegueWithIdentifier:@"WATOTextToNumberSegue" sender:self];


    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Bet"
                                                        message:@"You must enter some text to continue"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //[GCTurnBasedMatchHelper sharedInstance].delegate = (RPSVC *)segue.destinationViewController;
    

    if([segue.identifier isEqualToString:@"WATOTextToNumberSegue"]){
        NSLog(@"segue method running");
        WATONumberVC *controller = (WATONumberVC *)segue.destinationViewController;
        controller.betMessage = _betTextBox.text;
    }
}*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
