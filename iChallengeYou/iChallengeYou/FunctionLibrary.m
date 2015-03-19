//
//  FunctionLibrary.m
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunctionLibrary.h"

@implementation FunctionLibrary : NSObject



+(unsigned int)calculatePlayerGroup:(enum GameTypes)gameType
                          numRounds:(int)numRounds {
    unsigned int result = 0;
    
    //can't switch on string, need to switch on enum
    switch(gameType){
        case (0):
            //0 is coin flip
            switch(numRounds){
                case (1):
                    result = 1;
                    break;
                case (3):
                    result = 2;
                    break;
                case(5):
                    result = 3;
                    break;
            }
            break;
        case (1):
            //1 is RPS
            switch(numRounds){
                case (1):
                    result = 4;
                    break;
                case (3):
                    result = 5;
                    break;
                case(5):
                    result = 6;
                    break;
            }
            break;
        case (2):
            //2 is WATO
            result = 7;
            break;
    }
    return result;
}

+(NSArray *)getLeaderboardNameAndID:(enum GameTypes)gameType
                          numRounds:(int)numRounds
                              lType:(NSString *)lType{
    NSString* lName = @"Empty";
    NSString* lID = @"Empty";
    
    switch(gameType){
        case (0):
            //0 is coin flip
            if([lType isEqualToString:@"roundWins"]){
                lName = @"Coin Flip Total Rounds Won";
                lID = @"CoinFlipTotalRoundsWon";
                break;
            }else{
                switch(numRounds){
                    case (1):
                        lName = @"Coin Flip 1 Round Games Won";
                        lID = @"CoinFlip1RoundTotalWins";
                        break;
                    case (3):
                        lName = @"Coin Flip 3 Round Games Won";
                        lID = @"CoinFlip3RoundsTotalWins";
                        break;
                    case(5):
                        lName = @"Coin Flip 5 Round Games Won";
                        lID = @"CoinFlip5RoundsTotalWins";
                        break;
                    case(-1):
                        lName = @"Coin Flip Total Games Won";
                        lID =@"CoinFlipTotalGamesWon";
                }
                break;
            }
        case (1):
            if([lType isEqualToString:@"roundWins"]){
                lName = @"RPS Total Rounds Won";
                lID = @"RPSTotalRoundsWon";
                break;
            }else{
                switch(numRounds){
                    case (1):
                        lName = @"RPS 1 Round Games Won";
                        lID = @"RPS1RoundTotalWins";
                        break;
                    case (3):
                        lName = @"RPS 3 Round Games Won";
                        lID = @"RPS3RoundsTotalWins";
                        break;
                    case(5):
                        lName = @"RPS 5 Round Games Won";
                        lID = @"RPS5RoundsTotalWins";
                        break;
                    case(-1):
                        lName = @"RPS Total Games Won";
                        lID = @"RPSTotalGamesWon";
                        break;
                }
                break;
            }
        case (2):
            //2 is WATO
            lName = @"What Are The Odds Games Won";
            lID = @"WATOGamesWon";
            break;
        case(3):
            //3 is TOTAL
            if([lType isEqualToString:@"roundWins"]){
                lName = @"Total Rounds Won";
                lID = @"TotalRoundsWon";
                break;
            }else{
                lName = @"Total Games Won";
                lID = @"TotalGamesWon";
                break;
            }
    }

    NSArray *retArray = [NSArray arrayWithObjects:lName,lID,nil];
    return retArray;
}

@end