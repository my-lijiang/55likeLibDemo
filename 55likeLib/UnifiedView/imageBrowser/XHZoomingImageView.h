//
//  XHZoomingImageView.h
//  XHImageViewer
//
//  Created by
//  Copyright (c) All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLGIFImage.h"
#import "YLImageView.h"

@interface XHZoomingImageView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) YLImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, readonly) BOOL isViewing;

@end
