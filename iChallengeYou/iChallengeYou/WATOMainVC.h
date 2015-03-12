//
//  WATOMainVC.h
//  iChallengeYou
//
//  Created by Matt Gray on 2015-03-11.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

@interface WATOMainVC : UIViewController <GCTurnBasedMatchHelperDelegate> {
    //NSString* betMessage;
}
@property(nonatomic) NSString* betMessage;

@property (weak, nonatomic) IBOutlet UILabel *betMessageLabel;

@end
