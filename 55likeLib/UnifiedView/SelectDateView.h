//
//  SelectDateView.h
//  ZKwwlk
//
//  Created by junseek on 14-7-24.
//  Copyright (c) 2014年 五五来客. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SelectDateView;
@protocol SelectDateViewDelegate <NSObject>

@optional  //可选
-(void)select:(SelectDateView *)sview object:(id )dic;

@end


@interface SelectDateView : UIView

@property (strong,nonatomic)NSString *strTime;//时间戳
@property (strong,nonatomic)NSString *strType;
@property (strong,nonatomic)NSString *strId;

@property (nonatomic, weak) id<SelectDateViewDelegate> delegate;

- (void)show;
- (void)hidden;
@end
