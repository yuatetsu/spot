//
//  GuideBookInfoDayView.m
//  SPOT
//
//  Created by Truong Anh Tuan on 10/6/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "GuideBookInfoDayView.h"
#import "AppDelegate.h"

@interface GuideBookInfoDayView() {
    NSMutableArray *days;
    
}

@property (weak, nonatomic) UIButton *day1Button;

@property (weak, nonatomic) UIButton *day2Button;

@property (weak, nonatomic) UIButton *day3Button;

@property (weak, nonatomic) UIButton *day4Button;

@property (weak, nonatomic) UIButton *day5Button;

@end

@implementation GuideBookInfoDayView

AppDelegate *appDelegate;

- (id)initWithDayFromStartDay:(int)dayFromStartDay andDayCount:(int)dayCount {
    self = [super init];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor colorWithRed:69/255.0 green:164/255.0 blue:235/255.0 alpha:1];
        
        self.dayFromStartDay = dayFromStartDay;
        self.dayCount = dayCount;
        
        [self initButtons];
        
        [self setBounds:CGRectMake(0, 0, 320, 30)];
    }
    
    return self;
}


- (void)setTitleForButton:(UIButton *)button day:(int)day {
    NSString *text;
    if (day == 1) {
        text = @"1st day";
    }
    else if (day == 2) {
        text = @"2nd day";
    }
    else {
        text = [NSString stringWithFormat:@"day %d", day];
    }
    
    if (button != self.day1Button) {
        NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString: text];
        
        [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
        
        [button setAttributedTitle:commentString forState:UIControlStateNormal];
    }
    else {
        [button setTitle: text forState:UIControlStateNormal];
    }
    
    //    [days addObject:[NSNumber numberWithInt: day]];
    
    
}

- (void)initButtons {
    @autoreleasepool {
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 90, 30)];
        button1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:button1];
        self.day1Button = button1;
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(103, 0, 48, 30)];
        [button2 addTarget:self action:@selector(day2ButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button2];
        self.day2Button = button2;
        
        
        UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(159, 0, 48, 30)];
        [button3 addTarget:self action:@selector(day3ButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button3];
        self.day3Button = button3;
        
        UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(215, 0, 48, 30)];
        [button4 addTarget:self action:@selector(day4ButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button4];
        self.day4Button = button4;
        
        UIButton *button5 = [[UIButton alloc] initWithFrame:CGRectMake(271, 0, 48, 30)];
        [button5 addTarget:self action:@selector(day5ButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button5];
        self.day5Button = button5;
        
        
        self.day1Button.titleLabel.font = appDelegate.smallFont;
        self.day2Button.titleLabel.font = appDelegate.smallFont;
        self.day3Button.titleLabel.font = appDelegate.smallFont;
        self.day4Button.titleLabel.font = appDelegate.smallFont;
        self.day5Button.titleLabel.font = appDelegate.smallFont;
        
        self.day1Button.titleLabel.textColor = [UIColor whiteColor];
        self.day2Button.titleLabel.textColor = [UIColor whiteColor];
        self.day3Button.titleLabel.textColor = [UIColor whiteColor];
        self.day4Button.titleLabel.textColor = [UIColor whiteColor];
        self.day5Button.titleLabel.textColor = [UIColor whiteColor];
        
        if (days) {
            [days removeAllObjects];
        }
        else {
            days = [NSMutableArray new];
        }
        
        [days addObject:[NSNumber numberWithInt: self.dayFromStartDay]];
        
        if (self.dayFromStartDay - 2 > 0) {
            [days addObject:[NSNumber numberWithInt: self.dayFromStartDay - 2]];
        }
        if (self.dayFromStartDay - 1 > 0) {
            [days addObject:[NSNumber numberWithInt: self.dayFromStartDay - 1]];
        }
        
        if (self.dayFromStartDay + 1 <= self.dayCount && days.count < 5) {
            [days addObject:[NSNumber numberWithInt: self.dayFromStartDay + 1 ]];
        }
        
        if (self.dayFromStartDay + 2 <= self.dayCount && days.count < 5) {
            [days addObject:[NSNumber numberWithInt: self.dayFromStartDay + 2 ]];
        }
        
        if (self.dayFromStartDay + 3 <= self.dayCount && days.count < 5) {
            [days addObject:[NSNumber numberWithInt: self.dayFromStartDay + 3 ]];
        }
        
        if (self.dayFromStartDay + 4 <= self.dayCount && days.count < 5) {
            [days addObject:[NSNumber numberWithInt: self.dayFromStartDay + 4 ]];
        }
        
        if (days.count < 5) {
            if (self.dayFromStartDay - 3 > 0) {
                [days insertObject:[NSNumber numberWithInt: (self.dayFromStartDay - 3)] atIndex:1 ];
            }
        }
        
        if (days.count < 5) {
            if (self.dayFromStartDay - 4 > 0) {
                [days insertObject:[NSNumber numberWithInt: (self.dayFromStartDay - 4) ] atIndex:1 ];
            }
        }
        
        for (int i = 0; i < 5; i++) {
            @autoreleasepool {
                BOOL hidden = NO;
                if (i > days.count - 1) {
                    hidden = YES;
                }
                switch (i) {
                    case 0:
                        [self setTitleForButton:self.day1Button day:[[days objectAtIndex:i] intValue]];
                        break;
                    case 1:
                        if (hidden) {
                            [self.day2Button setHidden:YES];
                        }
                        else {
                            [self setTitleForButton:self.day2Button day:[[days objectAtIndex:i] intValue]];
                        }
                        break;
                    case 2:
                        if (hidden) {
                            [self.day3Button setHidden:YES];
                        }
                        else {
                            [self setTitleForButton:self.day3Button day:[[days objectAtIndex:i] intValue]];
                        }
                        break;
                    case 3:
                        if (hidden) {
                            [self.day4Button setHidden:YES];
                        }
                        else {
                            [self setTitleForButton:self.day4Button day:[[days objectAtIndex:i] intValue]];
                        }
                        break;
                    case 4:
                        if (hidden) {
                            [self.day5Button setHidden:YES];
                        }
                        else {
                            [self setTitleForButton:self.day5Button day:[[days objectAtIndex:i] intValue]];
                        }
                        break;
                    default:
                        break;
                }

            }
        }
    }
    
}

- (void)day2ButtonClicked {
    NSLog(@"button 2 clicked");
    NSNumber *day = days[1];
    [self.delegate dayButtonClicked: day.intValue sender: self];
}
- (void)day3ButtonClicked {
    NSLog(@"button 3 clicked");
    NSNumber *day = days[2];
    [self.delegate dayButtonClicked: day.intValue sender:self];
}
- (void)day4ButtonClicked {
    NSLog(@"button 4 clicked");
    NSNumber *day = days[3];
    [self.delegate dayButtonClicked: day.intValue sender:self];
}
- (void)day5ButtonClicked {
    NSLog(@"button 5 clicked");
    NSNumber *day = days[4];
    [self.delegate dayButtonClicked: day.intValue sender:self];
}


@end
