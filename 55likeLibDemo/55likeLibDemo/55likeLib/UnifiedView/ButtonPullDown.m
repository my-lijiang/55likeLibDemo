//
//  ButtonPullDown.m
//  SampleCheck55like
//
//  Created by junseek on 2017/2/6.
//  Copyright © 2017年 55like lj. All rights reserved.
//

#import "ButtonPullDown.h"
#import "RHMethods.h"

@interface ButtonPullDown (){
    
    
}

@end
@implementation ButtonPullDown
-(instancetype)initWithFrame:(CGRect)frame withSel:(SEL)sel addTarget:(id)target buttonTitle:(NSString *)strTitle{
    self=[super initWithFrame:frame];
    if (self) {
        //self=[RHMethods buttonWithFrame:CGRectMakeXY(0, 0, frame.size) title:@"" image:@"menuicondown" bgimage:nil];
        self.titleLabel.font=fontTitle;
        self.backgroundColor=[UIColor whiteColor];
        [self addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
        
        [self setImage:[UIImage imageNamed:@"typeBtnJT1"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"typeBtnJT2"] forState:UIControlStateSelected];
        [self setTitleColor:rgbpublicColor forState:UIControlStateSelected];
        [self setTitleColor:rgbTitleColor forState:UIControlStateNormal];
        [self setButtonTitle:strTitle];
       // self.layer.masksToBounds = YES;
       // self.layer.cornerRadius =4.0;
        //self.layer.borderWidth=0.5;
        //self.layer.borderColor =[rgbTxtGray CGColor];
    }
    return self;
}
-(void)setButtonTitle:(NSString *)strTitle{
    [self setTitle:strTitle forState:UIControlStateNormal];
    CGSize imageSize = self.imageView.frame.size;
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageSize.width, 0, imageSize.width)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleLabel.bounds.size.width, 0, -self.titleLabel.bounds.size.width)];
   
}
////重写该方法后可以让超出父视图范围的子视图响应事件
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//    if (view == nil) {
//        for (UIView *subView in self.subviews) {
//            CGPoint tp = [subView convertPoint:point fromView:self];
//            if (CGRectContainsPoint(subView.bounds, tp)) {
//                view = subView;
//            }
//        }
//    }
//    return view;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
