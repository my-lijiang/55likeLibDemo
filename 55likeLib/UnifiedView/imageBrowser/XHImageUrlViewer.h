//
//  XHImageUrlViewer.h
//  BBS
//
//  Created by junseek on 15-7-12.
//  Copyright (c) 2015年 iOS-4. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHImageUrlViewer;
@protocol XHImageUrlViewerDelegate <NSObject>

@optional  //可选

//删除操作后剩下的imageArray
- (void)imageUrlViewer:(XHImageUrlViewer *)view deleteArray:(NSArray*)deleteArray remainArray:(NSArray *)remainArray;

@end
@interface XHImageUrlViewer : UIView

@property (nonatomic, weak) id<XHImageUrlViewerDelegate> delegate;


@property (nonatomic, assign) BOOL hiddenDeleteButton;//是否显示删除按钮，默认不显示
@property (nonatomic, assign) BOOL hiddenNumIndex;//是否显示数字下标，默认显示


/**
 *浏览图片 多张图片对象
 (NSArray*)images
 
 (UIImage *)DefaultImage   //默认图片（有数据时候优先显示）
 (NSString *)DefaultName   //默认图片
 (nsstring *)cacheUrl      //缓存图片路径（小图路径）
 (NSString *)url           //大图路径
 
 @[@{@"DefaultImage":image,@"DefaultName":@"imageName",@"url":@"http:xxx.jpg"}]
 */

- (void)showWithImageDatas:(NSArray*)images selectedIndex:(NSInteger)index;
@end
