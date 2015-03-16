//
//  HomePageVC.h
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

@interface HomePageVC: UIViewController<GKGameCenterControllerDelegate>;

- (IBAction)selectNewGame:(UIButton *)sender;
@end

