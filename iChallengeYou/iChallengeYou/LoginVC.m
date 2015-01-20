//
//  LoginVC.m
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "LoginVC.h"
#import "GCTurnBasedMatchHelper.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[GCTurnBasedMatchHelper sharedInstance] authenticateLocalUser];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToHomePageButton:(id)sender {
    NSLog(@"Next is pressed");
}




@end
