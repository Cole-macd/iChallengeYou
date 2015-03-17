//
//  FunctionLibrary.h
//  iChallengeYou
//
//  Created by Cole MacDonald on 2015-01-20.
//  Copyright (c) 2015 Cole MacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FunctionLibrary : NSObject {}

enum GameTypes{CF, RPS, WATO};

+(unsigned int)calculatePlayerGroup:(enum GameTypes)gameType
                          numRounds:(int)numRounds;
+(NSArray *)getLeaderboardNameAndID:(enum GameTypes)gameType
                          numRounds:(int)numRounds
                              lType:(NSString *)lType;

@end
