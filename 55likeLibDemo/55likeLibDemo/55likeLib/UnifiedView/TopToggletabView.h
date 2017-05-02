//
//  TopToggletabView.h
//  XinKaiFa55like
//
//  Created by junseek on 2017/3/24.
//  Copyright © 2017年 55like lj. All rights reserved.
//顶部切换分类

#import <UIKit/UIKit.h>

typedef void (^TopToggletabBlock)(NSDictionary *dicSelect);
@interface TopToggletabView : UIView


@property (nonatomic, strong) TopToggletabBlock toggleTab;
////titleArray:@[@{@"title":@"xxx",@"id":@"1"}]  , sIndex 默认 0
-(void)setTiltelArray:(NSArray*)titleArray toggleTab:(TopToggletabBlock)aToggleTab;
////赋值基础--titleArray:@[@{@"title":@"xxx",@"id":@"1"}  ，sIndex==-1 表示不选中回调{}
-(void)setTiltelArray:(NSArray*)titleArray toggleTab:(TopToggletabBlock)aToggleTab selectIndex:(NSInteger)sIndex;

@end
