
//
//  UILabel+atrribulttext.m
//  GangFuBao
//
//  Created by home on 15/12/6.
//  Copyright © 2015年 55like. All rights reserved.
//

#import "UILabel+atrribulttext.h"

@implementation UILabel (atrribulttext)
-(void)setColor:(UIColor *)textcoler contenttext:(NSString *)text{
    [self setColor:textcoler font:self.font contenttext:text];
}
-(void)setColor:(UIColor *)textcoler font:(UIFont *)textFont contenttext:(NSString *)text{
    NSMutableAttributedString *attriString ;
    if (self.attributedText) {
        attriString=[[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
        
    }else{
        NSString*str= self.text;
        attriString = [[NSMutableAttributedString alloc] initWithString:str];
    }
    NSDictionary *attributeDict = @{
                                    NSForegroundColorAttributeName:textcoler,
                                    NSFontAttributeName:textFont
                                    };
    //NSRange hh=[self.text rangeOfString:text];
    //[attriString setAttributes:attributeDict range:hh];
    NSString *strTempTxt=self.text;
//      NSRange  hh ={0,1};
    BOOL boolNext=NO;
    float fx_temp=0;
    do {
        NSRange hh=[strTempTxt rangeOfString:text];
        if (hh.location == NSNotFound) {
            //不存在
        }else{
            [attriString setAttributes:attributeDict range:NSMakeRange(fx_temp+hh.location, hh.length)];
            fx_temp+=hh.location+hh.length;
            strTempTxt=[strTempTxt substringFromIndex:hh.location+hh.length];
            if ([strTempTxt containsString:text]) {
                boolNext=YES;
            }else{
                boolNext=NO;
            }
        }
    } while (boolNext);
    //        [attriString setAttributes:attributeDict range:[self.sumStr rangeOfString:RSC.bname]];
    //        self.aSumstr=attriString;
    self.attributedText=attriString;
}

-(void)setAllTextLineSpacing:(CGFloat)lineS{
    NSMutableAttributedString *attriString ;
    if (self.attributedText) {
        attriString=[[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    }else{
        NSString*str= self.text;
        attriString = [[NSMutableAttributedString alloc] initWithString:str];
    }
    NSMutableParagraphStyle *paragraphStyleT = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleT setLineSpacing:lineS];//调整行间距
    [paragraphStyleT setLineBreakMode:NSLineBreakByTruncatingTail];
    [attriString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleT range:NSMakeRange(0, [self.text length])];
    self.attributedText = attriString;
}

@end
