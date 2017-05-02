//
//  WWlikeRadioImageCropViewController.m
//  HairdressingHairStylist
//
//  Created by junseek on 2017/4/27.
//  Copyright © 2017年 55like lj. All rights reserved.
//

#import "WWlikeRadioImageCropViewController.h"
#import "LFImagePickerHeader.h"
#import "UIView+LFFrame.h"
#import "LFImagePickerController.h"

#pragma mark uiimage

#define kDefualRatioOfWidthAndHeight 1.0f

@interface UIImage (WWlikeImageCrop_Addition)

///压缩图片尺寸
-(UIImage*)imageWithScaledToSize:(CGSize)newSize;
///将根据所定frame来截取图片
- (UIImage*)WWlikeImageCrop_imageByCropForRect:(CGRect)targetRect;
- (UIImage *)WWlikeImageCrop_fixOrientation;
@end

@implementation UIImage (WWlikeImageCrop_Addition)


- (UIImage *)WWlikeImageCrop_fixOrientation {
    
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    UIImageOrientation io = self.imageOrientation;
    if (io == UIImageOrientationDown || io == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    }else if (io == UIImageOrientationLeft || io == UIImageOrientationLeftMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }else if (io == UIImageOrientationRight || io == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, 0, self.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        
    }
    
    if (io == UIImageOrientationUpMirrored || io == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }else if (io == UIImageOrientationLeftMirrored || io == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    if (io == UIImageOrientationLeft || io == UIImageOrientationLeftMirrored || io == UIImageOrientationRight || io == UIImageOrientationRightMirrored) {
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
    }else{
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage*)WWlikeImageCrop_imageByCropForRect:(CGRect)targetRect
{
    targetRect.origin.x*=self.scale;
    targetRect.origin.y*=self.scale;
    targetRect.size.width*=self.scale;
    targetRect.size.height*=self.scale;
    
    if (targetRect.origin.x<0) {
        targetRect.origin.x = 0;
    }
    if (targetRect.origin.y<0) {
        targetRect.origin.y = 0;
    }
    
    //宽度高度过界就删去
    CGFloat cgWidth = CGImageGetWidth(self.CGImage);
    CGFloat cgHeight = CGImageGetHeight(self.CGImage);
    if (CGRectGetMaxX(targetRect)>cgWidth) {
        targetRect.size.width = cgWidth-targetRect.origin.x;
    }
    if (CGRectGetMaxY(targetRect)>cgHeight) {
        targetRect.size.height = cgHeight-targetRect.origin.y;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, targetRect);
    UIImage *resultImage=[UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    //修正回原scale和方向
    resultImage = [UIImage imageWithCGImage:resultImage.CGImage scale:self.scale orientation:self.imageOrientation];
    
    return resultImage;
}
///压缩图片尺寸
-(UIImage*)imageWithScaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}
@end


@interface WWlikeRadioImageCropViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIView *overlayView; //中心截取区域的View

@property(nonatomic,strong) UIImageView *imageView;

@property(nonatomic,strong) UIWindow *actionWindow;

//其他View
@property(nonatomic,strong) UIView *topBlackView;
@property(nonatomic,strong) UIView *bottomBlackView;

@end

@implementation WWlikeRadioImageCropViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.navigationItem.rightBarButtonItem) {
        LFImagePickerController *imagePickerVc = (LFImagePickerController *)self.navigationController;
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:imagePickerVc.doneBtnTitleStr
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(onConfirm:)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat top = 0;
    CGFloat collectionViewHeight = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = 44;
        if (iOS7Later) top += 20;
        collectionViewHeight = self.view.height - top;;
    } else {
        CGFloat navigationHeight = 44;
        if (iOS7Later) navigationHeight += 20;
        collectionViewHeight = self.view.height - navigationHeight;
    }
    //设置frame,这里需要设置下，这样其会在最下层
    self.scrollView.frame = CGRectMake(0, top, self.view.width,  collectionViewHeight);//self.view.bounds;
    self.overlayView.layer.borderColor = [UIColor colorWithWhite:0.966 alpha:1.000].CGColor;
    self.scrollView.backgroundColor=[UIColor blackColor];
    
    //绘制上下两块灰色区域
    [self.view addSubview:self.topBlackView = [self acquireBlackTransparentOverlayView]];
    [self.view addSubview:self.bottomBlackView = [self acquireBlackTransparentOverlayView]];
    
   
    
    //双击事件
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    
}


#pragma mark create view helper
- (UIView*)acquireBlackTransparentOverlayView
{
    UIView *view = [[UIView alloc]init];
    view.userInteractionEnabled = NO;
    view.backgroundColor = [UIColor blackColor];
    view.layer.opacity = 0.25f;
    return view;
}

- (UIButton *)acquireCustomButtonWithTitle:(NSString*)title andAction:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;
    return button;
}

- (void)onConfirm:(id)sender
{
    if (!self.imageView.image) {
        return;
    }
    //不稳定下来，不让动
    if (self.scrollView.tracking||self.scrollView.dragging||self.scrollView.decelerating||self.scrollView.zoomBouncing||self.scrollView.zooming){
        return;
    }
    LFImagePickerController *imagePickerVc = (LFImagePickerController *)self.navigationController;
   
    
    [imagePickerVc showProgressHUD];
    
    __weak typeof(self) weakSelf = self;
    dispatch_globalQueue_async_safe(^{
        //根据区域来截图
        CGPoint startPoint = [self.overlayView convertPoint:CGPointZero toView:self.imageView];
        CGPoint endPoint = [self.overlayView convertPoint:CGPointMake(CGRectGetMaxX(self.overlayView.bounds), CGRectGetMaxY(self.overlayView.bounds)) toView:self.imageView];
        
        //这里获取的是实际宽度和zoomScale为1的frame宽度的比例
        CGFloat wRatio = self.imageView.image.size.width/(self.imageView.frame.size.width/self.scrollView.zoomScale);
        CGFloat hRatio = self.imageView.image.size.height/(self.imageView.frame.size.height/self.scrollView.zoomScale);
        CGRect cropRect = CGRectMake(startPoint.x*wRatio, startPoint.y*hRatio, (endPoint.x-startPoint.x)*wRatio, (endPoint.y-startPoint.y)*hRatio);
        
        UIImage *cropImage = [self.imageView.image WWlikeImageCrop_imageByCropForRect:cropRect];
        DLog(@"w:%f,h:%f",cropImage.size.width,cropImage.size.height)
        //压缩图片
        UIImage *editImage = cropImage;
        if (cropImage.size.width>imagePickerVc.cropImageSize.width) {
            editImage = [cropImage imageWithScaledToSize:imagePickerVc.cropImageSize];
        }
        DLog(@"editImage:w:%f,h:%f",editImage.size.width,editImage.size.height)
        
        dispatch_main_async_safe(^{
            [imagePickerVc hideProgressHUD];
            id <LFImagePickerControllerDelegate> pickerDelegate = (id <LFImagePickerControllerDelegate>)imagePickerVc.pickerDelegate;
            if ([pickerDelegate respondsToSelector:@selector(lf_imagePickerController:didFinishPickingRadioCropImages:originalImages:)]) {
                [pickerDelegate lf_imagePickerController:imagePickerVc didFinishPickingRadioCropImages:editImage originalImages:weakSelf.image];
            } else if (imagePickerVc.didFinishPickingPhotosHandle) {
                imagePickerVc.didFinishPickingRadioImagesHandle(editImage, weakSelf.image);
            }
            if (imagePickerVc.autoDismiss) {
                [imagePickerVc dismissViewControllerAnimated:YES completion:^{
                    
                }];
            } else {
                
            }
        });
    });
    
}


#pragma mark - tap
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.scrollView];
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) { //除去最小的时候双击最大，其他时候都还原成最小
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES]; //还原
    }
}

#pragma mark - getter or setter

- (void)setImage:(UIImage *)image
{
    if ([image isEqual:_image]) {
        return;
    }
    _image = image;
    
    //    [self.imageView cancelImageRequestOperation];
    self.imageView.image = [image WWlikeImageCrop_fixOrientation];
    if (self.isViewLoaded) {
        [self.view setNeedsLayout];
    }
}

- (UIView*)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc]init];
        _overlayView.layer.borderColor = [UIColor whiteColor].CGColor;
        _overlayView.layer.borderWidth = 1.0f;
        _overlayView.userInteractionEnabled = NO;
        [self.view addSubview:_overlayView];
    }
    return _overlayView;
}

- (UIScrollView*)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.exclusiveTouch = YES; //防止被触摸的时候还去触摸其他按钮，当然其防不住减速时候的弹跳黑框等特殊的，在onConfirm里面处理了
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView*)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        //                _imageView.backgroundColor = [UIColor yellowColor];
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

#pragma mark - other
//判断是否是以宽度为基准来截取
- (BOOL)isBaseOnWidthOfOverlayView
{
    //这里最好不要用＝＝判断，因为是CGFloat类型
    if (self.overlayView.frame.size.width < self.view.bounds.size.width) {
        return NO;
    }
    return YES;
}

#pragma mark - layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.view sendSubviewToBack:self.scrollView];
    //修正frame
    
    //    //底部按钮背景View
    //#define kButtonViewHeight 50
    //    self.buttonBackgroundView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds)-kButtonViewHeight, CGRectGetWidth(self.view.bounds),kButtonViewHeight);
    //    //底部俩按钮
    //#define kButtonWidth 50
    //    self.cancelButton.frame = CGRectMake(15, CGRectGetMinY(self.buttonBackgroundView.frame), kButtonWidth, kButtonViewHeight);
    //    self.confirmButton.frame = CGRectMake(CGRectGetWidth(self.buttonBackgroundView.frame)-kButtonWidth-15, CGRectGetMinY(self.buttonBackgroundView.frame), kButtonWidth, kButtonViewHeight);
    
    //scrollView
    CGFloat top = 0;
    CGFloat collectionViewHeight = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = 44;
        if (iOS7Later) top += 20;
        collectionViewHeight = self.view.height - top;;
    } else {
        CGFloat navigationHeight = 44;
        if (iOS7Later) navigationHeight += 20;
        collectionViewHeight = self.view.height - navigationHeight;
    }
    self.scrollView.frame = CGRectMake(0, top, self.view.width,  collectionViewHeight);
    //重置下
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    LFImagePickerController *imagePickerVc = (LFImagePickerController *)self.navigationController;
    //overlayView
    //根据宽度找高度
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = width/(imagePickerVc.cropImageSize.width/imagePickerVc.cropImageSize.height);
    BOOL isBaseOnWidth = YES;
    if (height>self.scrollView.bounds.size.height) {
        //超过屏幕了那就只能是，高度定死，宽度修正
        height = self.scrollView.bounds.size.height;
        width = height*(imagePickerVc.cropImageSize.width/imagePickerVc.cropImageSize.height);
        isBaseOnWidth = NO;
    }
    self.overlayView.frame = CGRectMake(0, 0, width, height);
    self.overlayView.center = self.scrollView.center;//CGPointMake(self.scrollView.bounds.size.width/2, (self.scrollView.bounds.size.height)/2 );
    
    //上下黑色覆盖View
    if (isBaseOnWidth) {
        //上和下
        self.topBlackView.frame = CGRectMake(0, 0, width, CGRectGetMinY(self.overlayView.frame));
        self.bottomBlackView.frame = CGRectMake(0, CGRectGetMaxY(self.overlayView.frame), width, CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.overlayView.frame));
    }else{
        //左和右
        self.topBlackView.frame = CGRectMake(0, top, CGRectGetMinX(self.overlayView.frame), height);
        self.bottomBlackView.frame = CGRectMake(CGRectGetMaxX(self.overlayView.frame),top, CGRectGetWidth(self.view.bounds)-CGRectGetMaxX(self.overlayView.frame), height);
    }
    
    //imageView的frame和scrollView的内容
    [self adjustImageViewFrameAndScrollViewContent];
}

#pragma mark - adjust image frame and scrollView's  content
- (void)adjustImageViewFrameAndScrollViewContent
{
    CGRect frame = self.scrollView.frame;
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        if (frame.size.width<=frame.size.height) {
            //说白了就是竖屏时候
            CGFloat ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        }else{
            CGFloat ratio = frame.size.height/imageFrame.size.height;
            imageFrame.size.width = imageFrame.size.width*ratio;
            imageFrame.size.height = frame.size.height;
        }
        
        self.scrollView.contentSize = frame.size;
        
        BOOL isBaseOnWidth = [self isBaseOnWidthOfOverlayView];
        if (isBaseOnWidth) {
            self.scrollView.contentInset = UIEdgeInsetsMake(CGRectGetMinY(self.overlayView.frame)-64, 0, CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.overlayView.frame), 0);
        }else{
            self.scrollView.contentInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.overlayView.frame), 0, CGRectGetWidth(self.view.bounds)-CGRectGetMaxX(self.overlayView.frame));
        }
        
        self.imageView.frame = imageFrame;
        
        //初始化,让其不会有黑框出现
        CGFloat minScale = self.overlayView.frame.size.height/imageFrame.size.height;
        CGFloat minScale2 = self.overlayView.frame.size.width/imageFrame.size.width;
        minScale = minScale>minScale2?minScale:minScale2;
        
        self.scrollView.minimumZoomScale = minScale;
        self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale*3<2.0f?2.0f:self.scrollView.minimumZoomScale*3;
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        
        //调整下让其居中
        if (isBaseOnWidth) {
            CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height)?
            (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
            self.scrollView.contentOffset = CGPointMake(0, -offsetY);
        }else{
            CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)?
            (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
            self.scrollView.contentOffset = CGPointMake(-offsetX,0);
        }
    }else{
        frame.origin = CGPointZero;
        self.imageView.frame = frame;
        //重置内容大小
        self.scrollView.contentSize = self.imageView.frame.size;
        
        self.scrollView.minimumZoomScale = 1.0f;
        self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale; //取消缩放功能
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
