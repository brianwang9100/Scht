//
//  TodayViewController.m
//  DailySchacts
//
//  Created by Brian Wang on 1/18/15.
//  Copyright (c) 2015 Scht. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#define ARC4RANDOM_MAX 0x100000000
@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    NSArray *_dailySchacts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dailySchacts = @[
                      @"Water makes up about 75 percent of your bowel movements. The rest is an often-stinky combination of fiber, dead and live bacteria, other cells, and mucus.",
                      @"Soluable fibers such as nuts and beans can assist with",
                      @"Having too much fiber can actually cause constipation because fiber absorbs water",
                      @"Eating lots of fiberous foods can assist with treating constipation as it flushes out your system.",
                      @"Be wary of color changes, although red can represent blood, it can also represent just passing beets.",
                      @"The most optimal shape of a poop is as thick as a log and is S - shaped.",
                      @"Pencil-thin poops can be a sign of rectal cancer, which narrows the opening in which poop passes.",
                      @"Many hard pieces may represent constipation, so drink lots of water and eat fiber!",
                      @"If your poo smells exceptionally bad, it might be a sign of an infection, of a bug called the parasite giardia, ingested by swimming in fresh water lakes. It can also suggest ulcerative colitis, Crohn's diseas, or celiac disease.",
                      @"How often should you go poo? It all depends on you, as long as you have a routine and that you're consistent. Factors include diet changes, overactive thyroids, gastrointestinal disorders, cultural differences, and colon cancer.",
                      @"Average American man excretes 150 grams/ one third of a pound of poop every day! That's 5 tons of poop in a lifetime!",
                      @"Digestion can take anywhere between 24 to 72 hours, so it's highly unlikely that today's poo came from today's food!",
                      @"Diarrhea happens when poop passes too quickly without water absorption. Other factors include stomach viruses, allergies, and other digestive issues.",
                      @"Floating poop signals high fat content, which is a sign for malabsoprtion, which means you're not absorbing enough fat and other nutrients. Poop should sink.",
                      @"Passing gas is completely healthy. Your colon is filled with bacteria that assist with digestion. Don't keep it in as it can damage your digestive system.",
                      @"You pass gas somewhere between 10-18 times a day.",
                      @"Reading on the toilet isn't healthy because it develops hemorrhoids or swollen blood vessels in and around the anus. Don't stay on the toilet too long because it's bad and causes hemorrhoids.",
                      @"EAT MORE FIBER. Most Americans eat 10-15 grams of fiber, which is less than the 30-35 gram recommended amount.",
                      @"Wash your hands. British researchers discovered that one in six cell phones may be contaminated with fecal matter.",
                      @"Farts are created from your body's inability to process certain foods, and as a result, some leftover gas is left behind.",
                      @"Bacteria called lactase also break down lactose, or ferment the sugar which creates flatulence.",
                      @"When constipated, avoid milk and spicy foods. They suck.",
                      @"Our poop is brown because of a pigment called bilirubin which is created from the breakdown of red blood cells in the liver and bone marrow.",
                      @"Bird poop is white because birds don't urinate. their kidneys extrat waste from the bloodsteam and spew it as white uric acid instead of watery pee.",
                      @"Burning anus usually is a result of eating spicy related foods. These oils cause hot farts."
                      ];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
    _message.text = [_dailySchacts objectAtIndex:[self randomFloat]];
    completionHandler(NCUpdateResultNewData);
}

-(float) randomFloat
{
    float val = ((float)arc4random()/ARC4RANDOM_MAX)*[_dailySchacts count];
    return val;
}

@end
