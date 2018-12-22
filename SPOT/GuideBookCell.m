//
//  GuideBookCell.m
//  SPOT
//
//  Created by Truong Anh Tuan on 8/14/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "GuideBookCell.h"
#import "AppDelegate.h"

@interface GuideBookCell()
{
    
}

@end

@implementation GuideBookCell

AppDelegate *appDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code        
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    
    return self;
}

-(void)addUtilityButton{
  
    if (!self.rightUtilityButtons) {
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"Delete"] selectedIcon:[appDelegate getImageWithName:@"Delete"]];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"Edit"] selectedIcon:[appDelegate getImageWithName:@"Edit"]];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[appDelegate getImageWithName:@"Airdrop"] selectedIcon:[appDelegate getImageWithName:@"Airdrop"]];
        
        
        self.rightUtilityButtons = rightUtilityButtons;
    }
    
}

- (void)awakeFromNib
{
    // Initialization code
    
    self.nameLabel.font = appDelegate.normalFont;
    self.dateLabel.font = appDelegate.smallFont;
}

@end
