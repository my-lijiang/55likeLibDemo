//
//  UILabel+atrribulttext.h
//  GangFuBao
//
//  Created by home on 15/12/6.
//  Copyright © 2015年 55like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (atrribulttext)


/**
 局部文字颜色变化

 @param textcoler 目标颜色
 @param text 目标文字
 */
-(void)setColor:(UIColor *)textcoler contenttext:(NSString*)text;
/**
 局部文字颜色变化
 
 @param textcoler 目标颜色
 @param textFont 目标字体
 @param text 目标文字
 */
-(void)setColor:(UIColor *)textcoler font:(UIFont *)textFont contenttext:(NSString*)text;

-(void)setAllTextLineSpacing:(CGFloat)lineS;

@end
