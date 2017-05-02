//
//  WebImagesViewController.h
//  ZhuiKe55like
//
//  Created by junseek on 16/10/11.
//  Copyright © 2016年 五五来客 李江. All rights reserved.
// web页图片预览-大图

#import "BaseViewController.h"

@interface WebImagesViewController : BaseViewController

/**
 *浏览图片 多张图片对象
 (NSArray*)images
 
 (UIImage *)DefaultImage   //默认图片（有数据时候优先显示）
 (NSString *)DefaultName   //默认图片
 (nsstring *)cacheUrl      //缓存图片路径（小图路径）
 (NSString *)url           //大图路径
 
 @[@{@"DefaultImage":image,@"DefaultName":@"imageName",@"url":@"http:xxx.jpg"}]
 
 
 
 otherInfo{
 @"lookImages":images;//所有图片
 @"lookSelectIndex":1//选择下标
 }
 
 */


@end
