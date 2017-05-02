//
//  MyWebView.h
//  ZhuiKe55like
//
//  Created by junseek on 15-4-13.
//  Copyright (c) 2015年 五五来客 李江. All rights reserved.
//WebKit

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MyWebView : WKWebView
-(void)refreshWeb;
-(void)loadMyWeb:(NSString *)url;
@end
