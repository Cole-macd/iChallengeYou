//
//  GCTurnBasedMatchHelper.m
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import "GCTurnBasedMatchHelper.h"
#import "CoinFlipVC.h"
#import "RPSVC.h"
#import "HomePageVC.h"
#import "WATOMainVC.h"
#import "WATOTextVC.h"
#import "chooseWATOType.h"

@implementation GCTurnBasedMatchHelper

@synthesize gameCenterAvailable;
@synthesize currentMatch;
@synthesize delegate;
@synthesize numberOfRounds;
@synthesize WATObetMessage;

int playerCount = 0;
bool bothPlayersJoined = false;

#pragma mark Initialization

static GCTurnBasedMatchHelper *sharedHelper = nil;
+ (GCTurnBasedMatchHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCTurnBasedMatchHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated &&
        !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated &&
               userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

#pragma mark User functions

- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer]
         authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
    // Get the default leaderboard identifier.
    [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            NSLog(@"Got the leaderboard");
            _leaderboardIdentifier = leaderboardIdentifier;
        }
    }];
    NSLog(@"Authentication complete");
    
}

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                    showMatches:(bool)showMatches
                    playerGroup:(unsigned int)playerGroup{
    
    if (!gameCenterAvailable) return;
    presentingViewController = viewController;
    
    self.currentMatch = nil;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    request.playerGroup = playerGroup;      //will only match with players who have same playerGroup.
    
    GKTurnBasedMatchmakerViewController *mmvc =
    [[GKTurnBasedMatchmakerViewController alloc]
     initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = showMatches;
    
    /*SOLUTION AT THIS SITE HAS STUFF WE MAY NEED FOR PLAYER INVITES
     http://stackoverflow.com/questions/14275255/how-to-present-gkmatchmakerviewcontroller-to-presented-view-controller*/
    
    [presentingViewController presentViewController:mmvc
                                           animated:YES
                                         completion:nil];
    //wait 1 second before the segue so it doesnt transition immediately and then load the GC menu
    //CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, false);
    //[presentingViewController performSegueWithIdentifier: @"homeToGameMenuSegue" sender: presentingViewController];
}




#pragma mark GKTurnBasedMatchmakerViewControllerDelegate

-(void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                            didFindMatch:(GKTurnBasedMatch *)match {
    
    
    self.currentMatch = match;
    
    GKTurnBasedParticipant *firstParticipant =
    [match.participants objectAtIndex:0];
    if (firstParticipant.lastTurnDate == NULL) {
        // It's a new game!
        NSLog(@"GC here 1");
        
        if([presentingViewController isKindOfClass:[HomePageVC class]]){
            //plus button was pressed from current match menu
            [presentingViewController performSegueWithIdentifier:@"newGameSegue" sender:presentingViewController];
            [presentingViewController
             dismissModalViewControllerAnimated:YES];
            [match removeWithCompletionHandler:^(NSError *error) {
                                               if (error) {
                                                   NSLog(@"%@", error);
                                               }
                                           }];
        }else if([presentingViewController isKindOfClass:[WATOTextVC class]]){
            //wato new game pressed
            [presentingViewController
             dismissModalViewControllerAnimated:YES];
            [delegate enterNewGame:match msg:WATObetMessage];
        }else if([presentingViewController isKindOfClass:[chooseWATOType class]]){
            //wato join existing game pressed, shouldn't create a new game, delete the newly created match
            NSLog(@"I AM NOW HERE WHAT");
            [presentingViewController dismissModalViewControllerAnimated:YES];
            [match removeWithCompletionHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                }
            }];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No games found"
                                                            message:@"No existing What Are The Odds? games found"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [presentingViewController performSegueWithIdentifier:@"WATONewGameSegue" sender:presentingViewController];

        }else{
            //coin flip and RPS
            [presentingViewController
             dismissModalViewControllerAnimated:YES];
            [delegate enterNewGame:match numRounds:numberOfRounds];
        }
    } else {
        [presentingViewController
         dismissModalViewControllerAnimated:YES];
        
        if([presentingViewController isKindOfClass:[HomePageVC class]]){
            //current matches pressed
            NSString *matchData = [NSString stringWithUTF8String:[match.matchData bytes]];
            NSArray *dataItems = [matchData componentsSeparatedByString:@","];
            NSString *gameType = dataItems[0];
            if([gameType isEqualToString:@"CF"]){
                CoinFlipVC *newDel;
                delegate = newDel;
            }else if ([gameType isEqualToString:@"RPS"]){
                RPSVC *newDel;
                delegate = newDel;
            }else if ([gameType isEqualToString:@"WATO"]){
                WATOMainVC *newDel;
                delegate = newDel;
            }
        }

        if ([match.currentParticipant.playerID
             isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // It's your turn!
            NSLog(@"GC calling takeTurn()");
            [delegate takeTurn:match];
        } else {
            // It's not your turn, just display the game state.
            NSLog(@"GC calling layoutMatch()");
            [delegate layoutMatch:match];
        }
        
        //navigate to the correct game vc
        if([presentingViewController isKindOfClass:[HomePageVC class]]){
            NSLog(@"performing direct segue");
            
            NSString *matchData = [NSString stringWithUTF8String:[match.matchData bytes]];
            NSArray *dataItems = [matchData componentsSeparatedByString:@","];
            NSString *gameType = dataItems[0];
            if([gameType isEqualToString:@"CF"]){
                [presentingViewController performSegueWithIdentifier:@"directCoinFlip" sender:presentingViewController];
            }else if ([gameType isEqualToString:@"RPS"]){
                [presentingViewController performSegueWithIdentifier:@"directRPS" sender:presentingViewController];
            }else if ([gameType isEqualToString:@"WATO"]){
                [presentingViewController performSegueWithIdentifier:@"directWATO" sender:presentingViewController];
            }
            NSLog(@"gametype is %@", gameType);
            NSLog(@"Match Data from GC is %@", matchData);
        }
    }
    
}

//report scores to leaderboard
-(void)reportScore:(int)gameScore{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
    score.value = gameScore;
    
    //reportscores takes in an array
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)showLeaderboard:(UIViewController *)vc{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = vc;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = _leaderboardIdentifier;
    //[self presentViewController:gcViewController animated:YES completion:nil];
    [vc presentViewController:gcViewController
                                           animated:YES
                                         completion:nil];
}

- (void) handleTurnEventForMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"Turn has happened");
    if ([match.matchID isEqualToString:currentMatch.matchID])
    {
        self.currentMatch = match; // <-- renew your instance!
    }
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    NSLog(@"HAR1");
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}


-(void)turnBasedMatchmakerViewControllerWasCancelled:
(GKTurnBasedMatchmakerViewController *)viewController {
    [presentingViewController
     dismissModalViewControllerAnimated:YES];
    NSLog(@"has cancelled");
}

-(void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                        didFailWithError:(NSError *)error {
    [presentingViewController
     dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

-(void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
                      playerQuitForMatch:(GKTurnBasedMatch *)match {
    NSLog(@"playerquitforMatch, %@, %@",
          match, match.currentParticipant);
}

-(void)handleMatchEnded:(GKTurnBasedMatch *)match {
    NSLog(@"Game has endededed");
    self.currentMatch = match;
    if ([match.matchID isEqualToString:currentMatch.matchID]) {
        [delegate recieveEndGame:match];
    } else {
        [delegate sendNotice:@"Another Game Ended!" forMatch:match];
    }
}



@end