//
//  Menu.h
//  FlappyFly
//
//  Created by Luke Sadler on 18/02/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "GAITrackedViewController.h"
@class Menu;


@interface Menu : GAITrackedViewController
{
    int opened;
    int died;
    BOOL _musicPlaying;
    BOOL _booted;
}

-(void)bootGame;
-(void)restartedGame;
-(void)rateButton;
-(void)normalDeaths;
-(void)hardDeaths;
-(void)twitButton;
-(void)banner;
-(void)music;

-(void)counter;
-(void)deathCounter;

@end
