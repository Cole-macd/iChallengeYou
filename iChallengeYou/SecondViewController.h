//
//  SecondViewController.h
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

//@interface ViewController : UIViewController <UITextFieldDelegate,
//GCTurnBasedMatchHelperDelegate> {

@interface SecondViewController : UIViewController <GCTurnBasedMatchHelperDelegate> {
    
    IBOutlet UILabel *turnLabel;
    IBOutlet UILabel *colourChoiceLabel;
    IBOutlet UIButton *blueButton;
    IBOutlet UIButton *redButton;
    IBOutlet UILabel *resultLabel;
    
}


- (IBAction)blueButtonPressed:(id)sender;
- (IBAction)redButtonPressed:(id)sender;

//- (IBAction)redButtonPressed:(id)sender;

//- (IBAction)blueButtonPressed:(id)sender;

@end
