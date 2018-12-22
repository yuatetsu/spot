//
//  customButton.m
//  SPOT
//
//  Created by nguyen hai dang on 9/16/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "customButton.h"

@implementation customButton

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        
        self.selected = NO;
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
       self.selected = NO;
    }
    
    return self;
}

-(void)setSelectedStatus:(BOOL)selected{
    
    if (selected==YES) {
        
        self.selected = YES;
        
        [self setImage:self.selectedImage forState:UIControlStateNormal];
    }
    
    else{
        
        self.selected = NO;
        
        [self setImage:self.nonSelectImage forState:UIControlStateNormal];
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
