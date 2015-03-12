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
            //2 is WATO, will there be multiple rounds?
            result = 7;
            break;
    }
    return result;
}

@end