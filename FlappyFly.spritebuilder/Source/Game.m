//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "Game.h"
#import "Obstacle.h"
#import "SKTAudio.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Menu.h"
#import "GAI.h"


static const CGFloat firstObstaclePosition = 280.f;

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrdeHero
};


@implementation Game

{
    ADBannerView *_bannerView;

    CCSprite *_hero;
    CCSprite *_lvlUP;
    CCPhysicsNode *_physicsNode;
    CCPhysicsNode *_cloudNode;
    CCParticleSystem *_smoke;
    CCParticleSystem *_fire;
    CCParticleSystem *_sparks;
    CCNodeGradient *_pauseGrey;
    
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_cloud1;
    CCNode *_cloud2;
    CCNode *_bush1;
    CCNode *_bush2;
    CCNode *_upperPencil;
    NSArray *_grounds;
    NSArray *_clouds;
    
    NSTimeInterval _sinceTouch;
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    CCButton *_startButton;
    CCButton *_startBlank;
    CCButton *_muteButton;
    CCButton *_unmuteButton;
    CCButton *_menuButton;
    CCButton *_vONButton;
    CCButton *_vOFFButton;
    CCButton *_OKButton;
    CCButton *_hardDiff;
    CCButton *_normalDiff;
    CCButton *_followButton;
    CCButton *_rateButton;
   
    CCButton *_gameCentreButton;
    CCButton *_achButton;
    
    BOOL _bannerIsVisible;
    BOOL _gameOver;
    BOOL _bPaused;
    BOOL _started;
    BOOL _menuOpen;
    int isMuted;
    int isVibrate;
    int width;
    
    CGFloat _scrollSpeed;
    CGFloat _cloudSpeed;
    CGFloat _distanceBetweenObstacles;
    
    CGPoint _deathPoint;
    
    NSInteger _points;
    NSInteger _speedLvl;
    
    NSInteger _lvlIf;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_lvl;
    CCLabelTTF *_hScore;
    CCLabelTTF *_newHighScore;
    CCLabelTTF *_volumeText;
    CCLabelTTF *_vibrateText;
    CCLabelTTF *_diffText;
}

# pragma mark - iAd code

-(id)init
{
    if( (self= [super init]) )
    {
        no = 140;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
            
        } else {
            _adView = [[ADBannerView alloc] init];
        }
     
        [[[CCDirector sharedDirector]view]addSubview:_adView];
        [_adView setBackgroundColor:[UIColor clearColor]];
        [[[CCDirector sharedDirector]view]addSubview:_adView];
        _adView.delegate = self;
    }
    [self hideBannerView:_adView animated:YES];
    return self;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (_bannerIsVisible)
    {
        NSLog(@"failed ads");
       /* [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectMake(0, (self.scene.boundingBox.size.height)+50, 320, banner.frame.size.height);
        [UIView commitAnimations];
        [self hideBannerView:_adView animated:YES];
        */
        
        [self hideBannerView:_adView animated:YES];
        }
}

- (void)hideBannerView:(ADBannerView *)bannerView animated:(BOOL)animated {
    
  //  if ([bannerView superview] == nil)
   //     return;
    NSLog(@"hide");
 //   UIView *contentView = [CCDirector sharedDirector].view.bounds;
    
    
    CGRect contentFrame = [CCDirector sharedDirector].view.bounds;
    CGRect bannerFrame = bannerView.frame;
    
    bannerFrame.origin.y = CGRectGetMaxY(contentFrame) + bannerFrame.size.height;
    contentFrame.size.height += bannerFrame.size.height;
    
    void (^moveBannerView)(void) = ^ {
        
       // contentView.frame = contentFrame;
        bannerView.frame = bannerFrame;
    };
    
    if (animated) {
        
        [UIView animateWithDuration:0.3 animations:moveBannerView completion:^(BOOL finished) {
            
            [bannerView removeFromSuperview];
        }];
    }
    else {
        
        moveBannerView();
        [bannerView removeFromSuperview];
    }
}

- (void)showBannerView:(ADBannerView *)bannerView animated:(BOOL)animated {
    NSLog(@"show");
    if ([bannerView superview] != nil)
        return;
    

    CGRect contentFrame = [CCDirector sharedDirector].view.bounds;
    CGRect bannerFrame = bannerView.frame;
    bannerFrame.origin.y = CGRectGetMaxY(contentFrame);
    bannerView.frame = bannerFrame;
    
    [[[CCDirector sharedDirector]view] addSubview:_adView];
    
    contentFrame.size.height -= bannerFrame.size.height;
    bannerFrame.origin.y -= bannerFrame.size.height;
    
    void (^moveBannerView)(void) = ^{
        
       // contentView.frame = contentFrame;
        bannerView.frame = bannerFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:moveBannerView];
    }
    else {
        moveBannerView();
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    
    if (!_bannerIsVisible)
    {
       /* banner.frame = CGRectMake(0, (self.scene.boundingBox.size.height), 320, banner.frame.size.height);

        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        _bannerIsVisible = YES;

        */
        
        Menu *menu = [[Menu alloc]init];
        [menu banner];
        NSLog(@"banner loaded");
        [self showBannerView:_adView animated:YES];
        }
}


-(CGFloat) width
{
        return [self boundingBox].size.width;
}
    
-(CGFloat) height
{
    return [self boundingBox].size.height;
}



#pragma mark Game start
- (void)didLoadFromCCB {
    _sinceTouch = 0;
    _started = NO;
    _menuOpen = NO;
    _bannerIsVisible = NO;
    _startBlank.visible = NO;
    _bPaused = NO;
    _lvlUP.paused = YES;
    
    [[GameCenterManager sharedManager] setDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loadString = [defaults objectForKey:@"HIGHSCORE"];
    NSString *hloadString = [defaults objectForKey:@"hHIGHSCORE"];
    NSString *diffString = [defaults objectForKey:@"difficulty"];
    
    scoreInt = [loadString intValue];
    hardHS = [hloadString intValue];
    diffInt = [diffString intValue];
    
    
    
    
    NSLog(@"%i is the difficulty state", diffInt);
    
    if (diffInt == 1) {
        _hero.scale = 1.3;
    }else{
        _hero.scale = 1;
    }


    if (diffInt == 0) {
        
    _hScore.string = [NSString stringWithFormat:@"High Score: %i", scoreInt];
    }else{
        _hScore.color = [CCColor redColor];
        _hScore.string = [NSString stringWithFormat:@"High Score: %i", hardHS];
    }

    _hero.physicsBody.allowsRotation = FALSE;
    _distanceBetweenObstacles = 160.0f;
    _scrollSpeed = 0.0f;
    _cloudSpeed = 0.0f;
    
    _speedLvl = 1;
    self.userInteractionEnabled = TRUE;
    
    
    _physicsNode.gravity = CGPointMake(0, 0);
    _grounds = @[_ground1, _ground2, _bush1, _bush2, _upperPencil];
    _clouds = @[_cloud1, _cloud2];
    
    
    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    
    // set this class as delegate
    _physicsNode.collisionDelegate = self;
    // set collision type
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrdeHero;
    
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    [[GameCenterManager sharedManager] getChallengesWithCompletion:^(NSArray *challenges, NSError *error) {
        NSLog(@"Challenges: %@ \n Error: %@", challenges, error);
    }];
  
    [self performSelector:@selector(showStart) withObject:nil afterDelay:0.5];

    
//    [[GameCenterManager sharedManager] resetAchievementsWithCompletion:^(NSError *error) {
//        if (error) NSLog(@"Error: %@", error);
//    }];
    
}

-(void)rate{
    Menu *menu = [[Menu alloc]init];
    [menu rateButton];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id823264628"]];
}


-(void)follow{
    Menu *menu = [[Menu alloc]init];
    [[GameCenterManager sharedManager] saveAndReportAchievement:@"third" percentComplete:100 shouldDisplayNotification:YES];
    [menu twitButton];
    [self performSelector:@selector(following) withObject:nil afterDelay:1.5];
}

-(void)following{

    NSArray *urls = [NSArray arrayWithObjects:
                     @"twitter://user?screen_name={handle}", // Twitter
                     @"tweetbot:///user_profile/{handle}", // TweetBot
                     @"echofon:///user_timeline?{handle}", // Echofon
                     @"twit:///user?screen_name={handle}", // Twittelator Pro
                     @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
                     @"x-birdfeed://user?screen_name={handle}", // Birdfeed
                     @"tweetings:///user?screen_name={handle}", // Tweetings
                     @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
                     @"icebird://user?screen_name={handle}", // IceBird
                     @"fluttr://user/{handle}", // Fluttr
                     @"http://twitter.com/{handle}",
                     nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    
    for (NSString *candidate in urls) {
        NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:@"mylogon_"]];
        if ([application canOpenURL:url]) {
            [application openURL:url];
            // Stop trying after the first URL that succeeds
            return;
        }
    }
}




#pragma mark - Touch Handling
-(void)showStart{
    _startButton.visible = YES;
}


-(void)start{
    [[CCDirector sharedDirector] resume];
    
    
    Menu *menu = [Menu alloc];
    [menu music];
    
    if (diffInt == 0) {
        _scrollSpeed = 120;
        scroll = _scrollSpeed;
    }else{
        _scrollSpeed = 140;
        scroll = _scrollSpeed;
    }
    
    _sinceTouch = 0;

    _hero.physicsBody.allowsRotation = TRUE;
    hS = 0;
    _started = YES;
    _lvlIf = 0;
    [_hero.physicsBody applyImpulse:ccp(0, 350.f)];
  //  _hero.rotation = clampf(_hero.rotation, -30.f, 50.f);
    

    _cloudSpeed = 70.0f;
    
    _physicsNode.gravity = CGPointMake(0, -650);
   // _hero.physicsBody.affectedByGravity = YES;
    _sparks.paused = YES;

    _startButton.visible = NO;
    _startBlank.visible = NO;
//    self.scene.paused = NO;
    _bPaused = NO;
    
}



#pragma mark - CCPhysicsCollisionDelegate

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    
    _deathPoint = _hero.position;
    [self gameOver];
    return TRUE;
}


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
    [goal removeFromParent];
    
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    
    return TRUE;
}

#pragma mark - Game Actions



- (void)gameOver {
    if (!_gameOver) {
        
        _lvlIf = 61;
        [self stopAnimation];
        
        _hero.physicsBody.affectedByGravity = YES;
        
      
        [_sparks setPosition:_deathPoint];
        _sparks.visible = TRUE;
        _sparks.paused = NO;
        _smoke.visible = TRUE;
        _fire.visible = TRUE;

       
        _hero.physicsBody.force = ccp(_hero.position.x - 2000, 0);
        _physicsNode.gravity = ccp(0, -700);
        _scrollSpeed = 0.0f;
        _cloudSpeed = 0.0f;
        _gameOver = TRUE;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        _restartButton.visible = TRUE;

        
      //[[SKTAudio sharedInstance] pauseBackgroundMusic];
      
        if (isMuted == 0) {
        [[SKTAudio sharedInstance] playSoundEffect:@"zap.wav"];
       // [[SKTAudio sharedInstance] playSoundEffect:@"fire.mp3"];

        }
        [_hero setOpacity:0];
   
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *diffString = [defaults objectForKey:@"difficulty"];
        
        diffInt = [diffString intValue];
        
        
        if (diffInt == 1 && _points > hardHS) {

            hardHS = _points;
            
            NSString *strFromInt = [NSString stringWithFormat:@"%i",hardHS];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:strFromInt forKey:@"hHIGHSCORE"];
            [defaults synchronize];
            
            [[GameCenterManager sharedManager] saveAndReportScore:hardHS leaderboard:@"hard" sortOrder:GameCenterSortOrderHighToLow];
        }
        Menu *menu = [[Menu alloc]init];
        [menu deathCounter];
        
        if (diffInt == 0) {
            [menu normalDeaths];
        }
        if (diffInt == 1) {
            [menu hardDeaths];
        }
        
    if (diffInt==0 && _points > scoreInt) {
        
        newHS = _points;
        
        NSString *strFromInt = [NSString stringWithFormat:@"%i",newHS];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:strFromInt forKey:@"HIGHSCORE"];
        [defaults synchronize];
        
        [[GameCenterManager sharedManager] saveAndReportScore:newHS leaderboard:@"normal" sortOrder:GameCenterSortOrderHighToLow];
    }
        
        NSString *vibrateString = [defaults objectForKey:@"vibrate"];
        isVibrate = [vibrateString intValue];
        
        if (isVibrate == 1) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        _started = NO;

        }
    
}

- (void)restart {
    Menu *menu = [[Menu alloc]init];
    [menu restartedGame];
    _hero.physicsBody.velocity = _deathPoint;
    CCScene *scene = [CCBReader loadAsScene:@"Game"];
    [[CCDirector sharedDirector] replaceScene:scene];
    
    
}


-(void)gameCentre {
    [self hideBannerView:_adView animated:YES];
    AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
    [[CCDirector sharedDirector]pause];
    [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:app.navController];
}


- (void)gameCenterFinished {
    
    [[CCDirector sharedDirector]resume];
}

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
    AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
    [app.navController presentViewController:gameCenterLoginController animated:YES completion:^{
        NSLog(@"Finished Presenting Authentication Controller");
    }];
}

- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation
{
    NSLog(@"Changed Availability: %@",availabilityInformation);
}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error
{
    NSLog(@"Error: %@",error);
}

-(void)hard{
    NSString *strFromInt = [NSString stringWithFormat:@"1"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"difficulty"];
    [defaults synchronize];
    [self restart];
}

-(void)normal{
    NSString *strFromInt = [NSString stringWithFormat:@"0"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"difficulty"];
    [defaults synchronize];
    [self restart];

}

-(void)achievement{
    NSLog(@"Achievement Pressed");
    AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
    [[GameCenterManager sharedManager] presentAchievementsOnViewController:app.navController];
      }



- (void)gameCenterManager:(GameCenterManager *)manager reportedAchievement:(GKAchievement *)achievement withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Achievement: %@", achievement);
        
    } else {
        NSLog(@"GCM Error while reporting achievement: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedScore:(GKScore *)score withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Score: %@", score);
   
    } else {
        NSLog(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveScore:(GKScore *)score {
    NSLog(@"Saved GCM Score with value: %lld", score.value);
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveAchievement:(GKAchievement *)achievement {
    NSLog(@"Saved GCM Achievement: %@", achievement);
}



- (void)menu {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loadString = [defaults objectForKey:@"muted"];
    NSString *vibrateString = [defaults objectForKey:@"vibrate"];
    
    isVibrate = [vibrateString intValue];
    isMuted = [loadString intValue];
    
    _vibrateText.color = [CCColor blackColor];
    _volumeText.color = [CCColor blackColor];
    _diffText.color = [CCColor blackColor];
    [_achButton setLabelColor:[CCColor blackColor] forState:CCControlStateNormal];
    [_achButton setLabelColor:[CCColor darkGrayColor] forState:CCControlStateHighlighted];
    [_gameCentreButton setLabelColor:[CCColor blackColor] forState:CCControlStateNormal];
    [_gameCentreButton setLabelColor:[CCColor darkGrayColor] forState:CCControlStateHighlighted];
    
    
    _diffText.visible = YES;
    _hardDiff.visible = YES;
    _normalDiff.visible = YES;
    _achButton.visible = YES;
    _gameCentreButton.visible = YES;
    _pauseGrey.visible = YES;
    _followButton.visible = YES;

    
    if (_started == NO) {
        _gameCentreButton.opacity = 1;
        _gameCentreButton.enabled = YES;
        _achButton.opacity = 0;
        _achButton.enabled = YES;
    }else{
        _achButton.opacity = 0.2;
        _achButton.enabled = NO;
        _gameCentreButton.opacity = 0.2;
        _gameCentreButton.enabled = NO;
    }
    
    
    if (isMuted == 1) {
        
        _muteButton.visible = YES;
        _muteButton.enabled = NO;
        _muteButton.opacity = 0.4;
        
        _unmuteButton.visible = YES;
        _unmuteButton.enabled = YES;
        _unmuteButton.opacity = 1;
        _volumeText.visible = YES;
        _vibrateText.visible = YES;
    }
    
    if (isMuted == 0) {
        
        _muteButton.visible = YES;
        _muteButton.enabled = YES;
        _muteButton.opacity = 1;
        
        _unmuteButton.visible = YES;
        _unmuteButton.enabled = NO;
        _unmuteButton.opacity = 0.4;
        _volumeText.visible = YES;
        _vibrateText.visible = YES;
    }
    
    if (isVibrate == 1) {
        _vONButton.visible = YES;
        _vONButton.enabled = NO;
        _vONButton.opacity = 0.4;
        
        _vOFFButton.visible = YES;
        _vOFFButton.enabled = YES;
        _vOFFButton.opacity = 1;
        _volumeText.visible = YES;
        _vibrateText.visible = YES;
    }
    
    if (isVibrate == 0) {
        
        _vONButton.visible = YES;
        _vONButton.enabled = YES;
        _vONButton.opacity = 0;
        
        _vOFFButton.visible = YES;
        _vOFFButton.enabled = NO;
        _vOFFButton.opacity = 0.4;
        _volumeText.visible = YES;
        _vibrateText.visible = YES;
    }
        _startButton.opacity = 1;
        _gameCentreButton.visible = YES;
        self.scene.paused = YES;
        _startBlank.visible = YES;
        _startBlank.enabled = YES;
        _vOFFButton.visible = YES;
        _vONButton.visible = YES;
        _OKButton.visible = YES;
        _volumeText.visible = YES;
        _vibrateText.visible = YES;
    
 
}

-(void)OK{
        self.scene.paused = NO;
        _startBlank.visible = NO;
        _startBlank.enabled = NO;
        _vOFFButton.visible = NO;
        _vONButton.visible = NO;
        _muteButton.visible = NO;
        _unmuteButton.visible = NO;
        _OKButton.visible = NO;
        _volumeText.visible = NO;
        _vibrateText.visible = NO;
        _startButton.opacity = 1;
        _gameCentreButton.visible = NO;
        _diffText.visible = NO;
        _hardDiff.visible = NO;
        _normalDiff.visible = NO;
        _achButton.visible = NO;
        _pauseGrey.visible = NO;
        _followButton.visible = NO;
    
        }


#pragma mark - Obstacle Spawning

- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + _distanceBetweenObstacles, 0);
    [obstacle setupRandomPosition];
    obstacle.zOrder = DrawingOrderPipes;
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];

}

#pragma mark - Update

-(void)stopLvlAni{
        
    [_lvlUP removeFromParent];
    [self.scene addChild:_lvlUP];
    _lvlUP.paused = YES;
    
    
    }

-(void)stopAnimation{
    
    _newHighScore.visible = NO;
    
}

-(void)vibrateOFF{
    
    NSString *strFromInt = [NSString stringWithFormat:@"0"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"vibrate"];
    [defaults synchronize];
    
    _unmuteButton.visible = YES;
    _unmuteButton.enabled = YES;
    _muteButton.visible = NO;
    _muteButton.enabled = NO;
    
}

-(void)vibrateON{
    
    NSString *strFromInt = [NSString stringWithFormat:@"1"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"vibrate"];
    [defaults synchronize];
    
    _unmuteButton.visible = YES;
    _unmuteButton.enabled = YES;
    _muteButton.visible = NO;
    _muteButton.enabled = NO;
    
}


-(void)mute{
    
    NSString *strFromInt = [NSString stringWithFormat:@"1"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"muted"];
    [defaults synchronize];
    
    _unmuteButton.opacity = 1;
    _unmuteButton.enabled = YES;
    _muteButton.opacity = 0.4;
    _muteButton.enabled = NO;
    
}

-(void)unMute{
    
    NSString *strFromInt = [NSString stringWithFormat:@"0"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"muted"];
    [defaults synchronize];
    
    [[SKTAudio sharedInstance] playBackgroundMusic:@"jazz.mp3"];

    
    _unmuteButton.opacity = 0.4;
    _unmuteButton.enabled = NO;
    _muteButton.opacity = 1;
    _muteButton.enabled = YES;
}

-(void)vON{
    
    NSString *strFromInt = [NSString stringWithFormat:@"1"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"vibrate"];
    [defaults synchronize];
    
    _vOFFButton.opacity = 1;
    _vOFFButton.enabled = YES;
    _vONButton.opacity = 0.4;
    _vONButton.enabled = NO;
    isVibrate = 1;
    
}

-(void)vOFF{
    
    NSString *strFromInt = [NSString stringWithFormat:@"0"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"vibrate"];
    [defaults synchronize];
    
    _vOFFButton.opacity = 0.4;
    _vOFFButton.enabled = NO;
    _vOFFButton.label.opacity = 0.4;
    _vONButton.opacity = 1;
    _vONButton.enabled = YES;
    isVibrate = 0;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    
    if (!_gameOver && _started == YES) {
        
        
        if (_sinceTouch < 0.5) {
             [_hero.physicsBody applyImpulse:ccp(1, 250.f)];
        }
        if (_sinceTouch >= 0.5) {
      
             [_hero.physicsBody applyImpulse:ccp(1, 300.f)];
        }
            [_hero.physicsBody applyAngularImpulse:5000.f];
            _sinceTouch = 0.0f;
        
    }
}

-(void)update:(CCTime)delta {
    
    if (_started) {
        no = no + (scroll /60);
    }
    
    _hero.position = ccp(no, _hero.position.y);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loadString = [defaults objectForKey:@"muted"];
    
    isMuted = [loadString intValue];

    if (isMuted == 1) {
        
        [[SKTAudio sharedInstance] pauseBackgroundMusic];
    }
    
    if (_bPaused == YES) {
        self.scene.paused = YES;
    }else{
        self.scene.paused = NO;
    }
    
    
    CGPoint sPoint = _hero.position;
    [_smoke setPosition:CGPointMake(sPoint.x, sPoint.y+10)];
    [_fire setPosition:CGPointMake(sPoint.x, sPoint.y-5)];
    CGPoint pencilPoint = ccp(_hero.position.x, 650);
    
    _upperPencil.position = pencilPoint;
    
    _sinceTouch += delta;
 
    if (_hero.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_hero.physicsBody.angularVelocity, -2.f, 1.f);
        _hero.physicsBody.angularVelocity = angularVelocity;
    }
    
    if ((_sinceTouch > 0.3f)) {
        [_hero.physicsBody applyAngularImpulse:-2000.f*delta];
    }
  
    _hero.rotation = clampf(_hero.rotation, -20.f, 50.f);
  
    _lvl.string = [NSString stringWithFormat:@"Level %ld", (long)_speedLvl];
    _scrollSpeed = -80;
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed *delta), _physicsNode.position.y);
    _cloudNode.position = ccp(_cloudNode.position.x - (_cloudSpeed *delta), _cloudNode.position.y);
    
    [self ifChecks];
    [self loopLayers];
    
    
}

-(void)loopLayers{
    
    // loop the ground
    
    for (CCNode *ground in _grounds) {
        
        // get the world position of the ground
        
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        
        // get the screen position of the ground
        
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        
        if (groundScreenPosition.x <= -1 * ground.contentSize.width) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);

        }
    }
    
    //loop clouds
    
    for (CCNode *cloud in _clouds) {
        
        // get the world position of the clouds
        
        CGPoint cloudWorldPosition = [_cloudNode convertToWorldSpace:cloud.position];
        
        // get the screen position of the ground
        
        CGPoint cloudScreenPosition = [self convertToNodeSpace:cloudWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        
        if (cloudScreenPosition.x <= -1 * cloud.contentSize.width) {
            cloud.position = ccp(cloud.position.x + 2 * cloud.contentSize.width, cloud.position.y);
        }
    }
    
    
    NSLog(@"%@",_ground1);
    
    NSMutableArray *offScreenObstacles = nil;
    
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
    
}

-(void)vet{
    [[GameCenterManager sharedManager] saveAndReportAchievement:@"first" percentComplete:100 shouldDisplayNotification:YES];
}
-(void)hundredDeaths{
    [[GameCenterManager sharedManager] saveAndReportAchievement:@"second" percentComplete:100 shouldDisplayNotification:YES];

}

-(void)ifChecks{
    
    
    //Achievements
    
    if (_points != 5) {
        five = 0;
    }
    
    if (_points == 5) {
        five ++;
    }
   
    if (diffInt == 0 && five == 2) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"5pointsdone" percentComplete:100 shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"20points" percentComplete:25 shouldDisplayNotification:NO];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"30points" percentComplete:16 shouldDisplayNotification:NO];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"40points" percentComplete:13 shouldDisplayNotification:NO];
    }
    
    if (diffInt == 1 && five == 2) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"5pointsHard" percentComplete:100 shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"20pointsHard" percentComplete:25 shouldDisplayNotification:NO];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"30pointsHard" percentComplete:16 shouldDisplayNotification:NO];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"40pointsHard" percentComplete:13 shouldDisplayNotification:NO];
    }

    //// Twenty
    if (_points != 20) {
        twenty = 0;
    }
    
    if (_points == 20) {
        twenty ++;
    }
    
    if (diffInt == 0 && twenty == 2) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"20points" percentComplete:100 shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"30points" percentComplete:66 shouldDisplayNotification:NO];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"40points" percentComplete:50 shouldDisplayNotification:NO];

    }
    
    if (diffInt == 1 && twenty == 2) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"20pointsHard" percentComplete:100 shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"30pointsHard" percentComplete:66 shouldDisplayNotification:NO];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"40pointsHard" percentComplete:50 shouldDisplayNotification:NO];

    }
    
    //// Thirty
    
    if (_points != 30) {
        thirty = 0;
    }
    
    if (_points == 30) {
        thirty ++;
    }
    
    if (diffInt == 0 && thirty == 2) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"30points" percentComplete:100 shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"40points" percentComplete:75 shouldDisplayNotification:NO];

    }
    
    if (diffInt == 1 && thirty == 2) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"30pointsHard" percentComplete:100 shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"40pointsHard" percentComplete:75 shouldDisplayNotification:NO];

    }
    //// Fourty
    
    if (_points != 40) {
        fourty = 0;
    }
    
    if (_points == 40) {
        fourty ++;
    }
    
    if (diffInt == 0 && fourty == 2) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"40points" percentComplete:100 shouldDisplayNotification:YES];
    }
    
    if (diffInt == 1 && fourty == 2) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"40pointsHard" percentComplete:100 shouldDisplayNotification:YES];
    }
    //////
    
    if (_points > scoreInt && diffInt == 0) {
        
        hS++;
    }
    
    if (_points > hardHS && diffInt == 1) {
        
        hS++;
    }
    
    
    if (hS == 2 ) {
        
        _newHighScore.visible = YES;
         [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:2.5];
    }
    
    if (_lvlIf == 60) {
        
        if (isMuted == 0) {
           
        [[SKTAudio sharedInstance] playSoundEffect:@"levelup.wav"];
        
     /*
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"levelup" ofType:@"wav"];
            SystemSoundID soundID;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath: soundPath]), &soundID);
            AudioServicesPlaySystemSound (soundID);
       */
        }

        _lvlUP.visible = YES;
        _lvlUP.paused = NO;
        _scrollSpeed = _scrollSpeed + 20;
        [self performSelector:@selector(stopLvlAni) withObject:nil afterDelay:2];
        scroll = _scrollSpeed;
    }
    
    
    //////
    
    if (_points == 4) {
        _distanceBetweenObstacles = 500.0f;
    }
    
    if (_points == 5) {
        _distanceBetweenObstacles = 160;
        _lvlIf++;
        _speedLvl = 2;
    }
    
    if (_points == 6) {
        _lvlIf=0;
    }
    
    if (_points == 19) {
        _distanceBetweenObstacles = 500.0f;
    }
    
    if (_points == 20) {
        _distanceBetweenObstacles = 160.0f;
        _lvlIf++;
        _speedLvl = 3;
    }
    
    if (_points == 21) {
        _lvlIf = 0;
    }
    
    if (_points == 29) {
        _distanceBetweenObstacles = 500.0f;
    }
    
    if (_points == 30) {
        _distanceBetweenObstacles = 160.0f;
        _lvlIf++;
        _speedLvl = 4;
    }
    
    if (_points == 31) {
        _lvlIf = 0;
    }
    
    if (_points == 39) {
        _distanceBetweenObstacles = 500.0f;
    }
    
    if (_points == 40) {
        _distanceBetweenObstacles = 160.0f;
        _lvlIf++;
        _speedLvl = 5;
    }
    
    if (_points == 41) {
        _lvlIf = 0;
    }
    
    if (_gameOver == TRUE) {
        _scrollSpeed = 0;
    }
}

@end
