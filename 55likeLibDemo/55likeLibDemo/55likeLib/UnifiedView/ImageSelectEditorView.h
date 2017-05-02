//
//  ImageSelectEditorView.h
//  XinKaiFa55like
//
//  Created by junseek on 2017/3/23.
//  Copyright © 2017年 55like lj. All rights reserved.
//图片选择器可以选择多张图片，可以删除，拍照

#import <UIKit/UIKit.h>

typedef void (^ImageSelectEditorViewBlock)(NSInteger suc);
@interface ImageSelectEditorView : UIView


@property (nonatomic, strong) ImageSelectEditorViewBlock imageChange;
/**
 最多多少张图片
 */
@property(nonatomic,assign)int maxNumber;


/**
 imageviewArray
 */
@property(nonatomic,strong)NSMutableArray *imageViewArray;
@property(nonatomic,strong)NSMutableArray *arrayDeleteIds;



/**
 获取上传数组字典 key关键字
 
 @param key 上传的关键字
 @return 上传的数组
 */
-(NSMutableArray*)getRequsetArrywithkey:(NSString*)key removeServer:(BOOL)abool;


/**
 设置网络或得的图片数组
 
 @param array @[@{@"url":@"",@"id":@"1"}]
 */
-(void)setImageUrlArray:(NSArray *)array imageChange:(ImageSelectEditorViewBlock)imgChange;

@end
