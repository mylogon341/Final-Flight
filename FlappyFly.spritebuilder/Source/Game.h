//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import <iAd/iAd.h>
#import "CCNode.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "GAITrackedViewController.h"
#import "Menu.h"

@class AppController;
@class Game;

@interface Game : CCNode <CCPhysicsCollisionDelegate, ADBannerViewDelegate, GameCenterManagerDelegate>
{
    int scoreInt;
    int hardScore;
    int diffInt;
    int hS;
    int newHS;
    int hardHS;
    CGFloat no;
    CGFloat scroll;
    BOOL bannerIsVisible;
    BOOL isVolumeMuted;
    ADBannerView *_adView;
    AVAudioPlayer *soundEffectsPlayer;

    int five;
    int twenty;
    int thirty;
    int fourty;


}
-(void)hundredDeaths;
-(void)gameCenterFinished;
-(void)ifChecks;
-(void)stopAnimation;
-(void)loopLayers;


@end
