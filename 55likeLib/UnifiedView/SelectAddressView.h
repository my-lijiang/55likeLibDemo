//
//  SelectAddressView.h
//  JXGGWWLiKe
//
//  Created by junseek on 15-1-22.
//  Copyright (c) 2015年 五五来客 李江. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SelectAddressView;
@protocol SelectAddressViewDelegate <NSObject>

@optional  //可选

-(void)selectPicker:(SelectAddressView *)selectView address1:(id)addres_a address2:(id)address_b address3:(id)address_c;

@end


@interface SelectAddressView : UIView

@property (nonatomic, weak) id<SelectAddressViewDelegate> delegate;


@property (nonatomic,strong) NSArray * arrayAddress;


@property (nonatomic,strong) NSDictionary * dicP1;
@property (nonatomic,strong) NSDictionary * dicP2;
@property (nonatomic,strong) NSDictionary * dicP3;

- (void)show;
- (void)hidden;

@end
