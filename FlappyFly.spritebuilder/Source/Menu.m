//
//  Menu.m
//  FlappyFly
//
//  Created by Luke Sadler on 18/02/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Menu.h"
#import "Game.h"
#import "AppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "SKTAudio.h"


@implementation Menu
{

}

///1st hidden

-(void)music{
    NSLog(@"%d MUSIC",_musicPlaying);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loadString = [defaults objectForKey:@"MUSIC"];
    NSString *bLoadString = [defaults objectForKey:@"boot"];

    _musicPlaying = [loadString intValue];
    _booted = [bLoadString intValue];


    
    if (_musicPlaying == 0 && _booted == 0) {
        [[SKTAudio sharedInstance]playBackgroundMusic:@"jazz.mp3"];
        _musicPlaying = YES;
    
        NSString *strFromInt = [NSString stringWithFormat:@"%i",_musicPlaying];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:strFromInt forKey:@"MUSIC"];
        [defaults setObject:strFromInt forKey:@"boot"];

        [defaults synchronize];
    
    }
    
    NSLog(@"%d MUSIC",_musicPlaying);
}


-(void)counter{

NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
NSString *loadString = [defaults objectForKey:@"openedQ"];

        opened = [loadString intValue];
        NSLog(@"%d: opened",opened);
    opened ++;
    
        [self save];
    }

-(void)save{

    NSLog(@"%d: saved",opened);

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *strFromInt = [NSString stringWithFormat:@"%d", (int)opened];
        [defaults setObject:strFromInt forKey:@"openedQ"];        
        
        [defaults synchronize];
    
    if (opened == 20) {
        Game *game = [[Game alloc]init];
        [game hundredDeaths];
    }
}

/////2nd hidden

-(void)deathCounter{
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *loadString = [defaults objectForKey:@"diedQ"];
        
        died = [loadString intValue];
        NSLog(@"%d: deaths",died);
        died ++;
        
        [self deathSave];
    }
    
-(void)deathSave{
        
        NSLog(@"%d: deaths",died);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *strFromInt = [NSString stringWithFormat:@"%d", (int)died];
        [defaults setObject:strFromInt forKey:@"diedQ"];
        
        [defaults synchronize];
        
        if (died == 100) {
            Game *game = [[Game alloc]init];
            [game hundredDeaths];
        }
}
    
 
    -(void)bootGame{
        
        NSMutableDictionary *event =
        [[GAIDictionaryBuilder createEventWithCategory:@"Boot Game"
                                                action:@"buttonPress"
                                                 label:@"dispatch"
                                                 value:nil] build];
        [[GAI sharedInstance].defaultTracker send:event];
        [[GAI sharedInstance] dispatch];
              
      //  self.screenName = @"Game Opened";  // Done
    }
   
  

  -(void)restartedGame{
      NSMutableDictionary *event =
      [[GAIDictionaryBuilder createEventWithCategory:@"Pressed Restart"
                                              action:@"buttonPress"
                                               label:@"dispatch"
                                               value:nil] build];
      [[GAI sharedInstance].defaultTracker send:event];
      [[GAI sharedInstance] dispatch];    }


-(void)rateButton{

    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Pressed Rate"
                                            action:@"buttonPress"
                                             label:@"dispatch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    }
    -(void)normalDeaths{
        
        NSMutableDictionary *event =
        [[GAIDictionaryBuilder createEventWithCategory:@"Normal Death"
                                                action:@"buttonPress"
                                                 label:@"dispatch"
                                                 value:nil] build];
        [[GAI sharedInstance].defaultTracker send:event];
        [[GAI sharedInstance] dispatch];

    }

-(void)hardDeaths{

    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Died on Hard"
                                            action:@"buttonPress"
                                             label:@"dispatch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    
    }

-(void)twitButton{

    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Pressed the Twitter Button"
                                            action:@"buttonPress"
                                             label:@"dispatch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];

}

-(void)banner{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"Banner Loaded"
                                            action:@"buttonPress"
                                             label:@"dispatch"
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}



@end
