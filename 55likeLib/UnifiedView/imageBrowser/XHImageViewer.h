//
//  XHImageViewer.h
//  XHImageViewer
//
//  Created by
//  Copyright (c)  All rights reserved.
//

#import <UIKit/UIKit.h>
@class XHImageViewer;
@protocol XHImageViewerDelegate <NSObject>

@optional  //可选
- (void)imageViewer:(XHImageViewer *)imageViewer willDismissWithSelectedView:(UIImageView*)selectedView;
- (void)imageViewer:(XHImageViewer *)imageViewer endDismissWithSelectedView:(UIImageView*)selectedView;
//删除操作后剩下的imageviewArray
- (void)imageViewer:(XHImageViewer *)imageViewer deleteImageView:(NSArray*)views withArray:(NSArray *)arr;

@end

@interface XHImageViewer : UIView

@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, copy) NSMutableArray *selectIndexArray;
@property (nonatomic, weak) id<XHImageViewerDelegate> delegate;
@property (nonatomic, assign) CGFloat backgroundScale;
@property (nonatomic, assign) BOOL hiddenDeleteButton;//是否显示删除按钮，默认不显示
@property (nonatomic, assign) BOOL hiddenNumIndex;//是否显示数字下标，默认显示
- (void)showWithImageViews:(NSArray*)views selectedView:(UIImageView*)selectedView;
@end
