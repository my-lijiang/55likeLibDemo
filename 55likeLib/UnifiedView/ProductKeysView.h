//
//  ProductKeysView.h
//  XinKaiFa55like
//
//  Created by junseek on 2017/2/10.
//  Copyright © 2017年 55like lj. All rights reserved.
//搜索关键词、搜索历史记录

#import <UIKit/UIKit.h>

@class ProductKeysView;
@protocol ProductKeysViewDelegate <NSObject>

@optional  //可选

-(void)productKeysView:(ProductKeysView *)selectView clickeDic:(NSDictionary *)dic;

@end
@interface ProductKeysView : UIView

@property (nonatomic, weak) id<ProductKeysViewDelegate> delegate;
- (void)showAllArray:(NSArray *)arrayTitle;
- (void)show;
- (void)hidden;


@end
