//
//  MoreBlankTableViewHeaderFooterView.m
//  ZhuiKe55like
//
//  Created by junseek on 16/8/18.
//  Copyright © 2016年 五五来客 李江. All rights reserved.
//空白头

#import "MoreBlankTableViewHeaderFooterView.h"

@implementation MoreBlankTableViewHeaderFooterView

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
//        self.backgroundColor=[UIColor clearColor];
        self.contentView.backgroundColor=[UIColor clearColor];
        UIView *headView = [[UIView alloc] initWithFrame:self.bounds];
        headView.backgroundColor = [UIColor clearColor];
        self.backgroundView=headView;
//        [self addSubview:headView];
    }
    return self;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
