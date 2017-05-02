//
//  LJImageRollingView.h
//  JiuSheng55like
//
//  Created by junseek on 2016/11/8.
//  Copyright © 2016年 55like lj. All rights reserved.
//图片循环滚动

#import <UIKit/UIKit.h>

@class LJImageRollingView;
@protocol LJImageRollingViewDelegate <NSObject>

@optional  //可选

-(void)selectView:(LJImageRollingView *)selectView ad:(NSDictionary *)dic index:(NSInteger )index;

@end

@interface LJImageRollingView : UIView
@property (nonatomic, weak) id<LJImageRollingViewDelegate> delegateDiscount;
/*
 images@[@{
 (UIImage *)DefaultImage   //默认图片（有数据时候优先显示）
 (NSString *)url           //大图路径
 }]
 */
-(void)reloadImageView:(NSArray *)images selectIndex:(NSInteger )sIndex;
    
-(void)startAnimation;
-(void)stopAnimation;
@end
