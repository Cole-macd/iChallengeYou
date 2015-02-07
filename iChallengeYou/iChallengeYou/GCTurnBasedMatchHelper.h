//
//  GCTurnBasedMatchHelper.h
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@protocol GCTurnBasedMatchHelperDelegate
- (void)enterNewGame:(GKTurnBasedMatch *)match numRounds:(int)numRounds;
- (void)layoutMatch:(GKTurnBasedMatch *)match;
- (void)takeTurn:(GKTurnBasedMatch *)match;
- (void)recieveEndGame:(GKTurnBasedMatch *)match;
- (void)sendNotice:(NSString *)notice
          forMatch:(GKTurnBasedMatch *)match;
@end

@interface GCTurnBasedMatchHelper : NSObject
<GKTurnBasedMatchmakerViewControllerDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    UIViewController *presentingViewController;
    
    id <GCTurnBasedMatchHelperDelegate> delegate;
    
    GKTurnBasedMatch *currentMatch;
    
    enum playerRole{takingTurn, observing, roundOver, gameOver};
    
}

@property (retain) GKTurnBasedMatch * currentMatch;
@property (assign, readonly) BOOL gameCenterAvailable;
@property (nonatomic, retain)id <GCTurnBasedMatchHelperDelegate> delegate;
@property (nonatomic) int numberOfRounds;


+ (GCTurnBasedMatchHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                    showMatches:(bool)showMatches
                    playerGroup:(unsigned int)playerGroup;

@end