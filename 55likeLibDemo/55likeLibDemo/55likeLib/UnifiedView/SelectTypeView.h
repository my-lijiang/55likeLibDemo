//
//  SelectTypeView.h
//  JiuSheng55like
//
//  Created by junseek on 2016/11/9.
//  Copyright © 2016年 55like lj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectTypeView;
@protocol SelectTypeViewDelegate <NSObject>

@optional  //可选
-(void)selectTypeView:(SelectTypeView *)sview object:(NSDictionary *)dic;
-(void)selectTypeViewHidden:(SelectTypeView *)sview;//隐藏

@end

@interface SelectTypeView : UIView

@property (nonatomic, weak) id<SelectTypeViewDelegate> delegate;

@property (nonatomic,assign) float floatTypeY;//
@property (nonatomic,strong) NSString * strType;//
- (void)showAllArray:(NSArray *)typeArray selectDic:(NSDictionary *)selectDic;
- (void)hidden;
@end
