//
//  XHImageUrlViewer.m
//  BBS
//
//  Created by junseek on 15-7-12.
//  Copyright (c) 2015年 iOS-4. All rights reserved.
//

#import "XHImageUrlViewer.h"
#import "XHZoomingImageView.h"


#import "XHViewState.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


typedef void(^SaveImageCompletion)(NSError* error);

#pragma mark cell
@interface ImagesCollectionCell : UICollectionViewCell<UIActionSheetDelegate>{
   
    UITapGestureRecognizer *tapTwo;
    MKNetworkOperation *opTemp;
    MKNetworkOperation *opTemp_cache;
    
}

@property (nonatomic, strong)XHZoomingImageView *tmp;
- (void)setValueDefaultImage:(UIImage *)tImage DefaultImageName:(NSString *)strImage cacheUrl:(NSString *)cacheUrl urlImage:(NSString *)strUrl indexPath:(NSIndexPath *)indexPath  tapGesture:(UITapGestureRecognizer *)gesture;
@end

@implementation ImagesCollectionCell
@synthesize tmp;


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        tmp = [[XHZoomingImageView alloc] initWithFrame:self.bounds];
        tmp.backgroundColor=[UIColor blackColor];
        tmp.imageView = [[YLImageView alloc] initWithFrame:tmp.bounds];//[RHMethods imageviewWithFrame:tmp.bounds defaultimage:@""];
        
        
        tapTwo=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(topTwo:)];
        [tapTwo setNumberOfTapsRequired:2];
        [tmp addGestureRecognizer:tapTwo];
        
        
        UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 1.0;
        [tmp addGestureRecognizer:longPressGr];
        
        [self addSubview:tmp];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


//cell数据值
#pragma mark initData
- (void)setValueDefaultImage:(UIImage *)tImage DefaultImageName:(NSString *)strImage cacheUrl:(NSString *)cacheUrl urlImage:(NSString *)strUrl indexPath:(NSIndexPath *)indexPath tapGesture:(UITapGestureRecognizer *)gesture
{
    
    tmp.imageView.transform = CGAffineTransformIdentity;
    UIImage *image=[UIImage imageNamed:strImage];
    if (tImage) {//优先
        image=tImage;
    }
    
    tmp.image=image;
    if ([cacheUrl notEmptyOrNull]) {
        [tmp.imageView imageWithCacheUrl:cacheUrl];
    }
    
    
    CGSize size = image ? image.size : tmp.imageView.frame.size;
    CGFloat ratio = MIN(W(self) / size.width, H(self) / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    tmp.imageView.frame = CGRectMake(0, 0, W, H);
    
    for (UIView *viewT in [tmp.imageView subviews]) {
        [viewT removeFromSuperview];
    }
    if ([strUrl notEmptyOrNull]) {
        if (opTemp) {
            [opTemp cancel];
        }
        opTemp = [tmp.imageView imageWithURL:strUrl useProgress:YES useActivity:NO defaultImage:@"" showGifImage:YES];
    }
    
    
    [gesture requireGestureRecognizerToFail:tapTwo];
}

-(void)topTwo:(UITapGestureRecognizer *)tap{
    XHZoomingImageView *viewT=(XHZoomingImageView *)tap.view;
    
    CGFloat zs = viewT.scrollView.zoomScale;
    zs = (zs == 1.0) ? 2.0 : 1.0;
    [viewT.scrollView setZoomScale:zs animated:YES];
    
    
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片到相册" otherButtonTitles:nil, nil];
        action.delegate=self;
        [action showInView:self];
        
        
    }
}

#pragma mark UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //chushih
    if (buttonIndex==0) {
        [SVProgressHUD showWithStatus:@"正在保存..."];
        if (kVersion8) {
            [self save];
        }else{
            [self createAlbum];
        }
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            // 耗时的操作
//            UIImageWriteToSavedPhotosAlbum(tmp.image, self, @selector(image:didFinishSavingWithError:contextInfo:) , nil ) ;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//            });
//        });
        
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subViwe in actionSheet.subviews) {
        if ([subViwe isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subViwe;
            [button setTitleColor:rgbTitleColor forState:UIControlStateNormal];
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [SVProgressHUD dismiss];
    if(error != NULL)
        
    {
        NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        [[Utility Share] ShowMessage:@"图片保存失败！" msg:[NSString stringWithFormat:@"请在 设置->隐私->照片 中开启 %@ 对照片的访问权限",app_Name]];
    }
    
    else
        
    {
        [SVProgressHUD showSuccessWithStatus:@"保存图片成功"];
        
    }
    
}
- (void)createAlbum
{
    
    NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups=[[NSMutableArray alloc]init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group)
        {
            [groups addObject:group];
        }
        
        else
        {
            BOOL haveHDRGroup = NO;
            
            for (ALAssetsGroup *gp in groups)
            {
                NSString *name =[gp valueForProperty:ALAssetsGroupPropertyName];
                
                if ([name isEqualToString:app_Name])
                {
                    haveHDRGroup = YES;
                }
            }
            
            if (!haveHDRGroup)
            {
                //do add a group named "XXXX"
                
                [assetsLibrary addAssetsGroupAlbumWithName:app_Name
                                               resultBlock:^(ALAssetsGroup *group)
                 {
                     [groups addObject:group];
                     
                 }failureBlock:^(NSError *error) {                         
                     DLog(@"error Photo ：%@",error);
                 }];
                
                haveHDRGroup = YES;
            }
        }
        
    };
    //创建相簿
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock failureBlock:nil];
    
    [self saveToAlbumWithMetadata:nil imageData:UIImagePNGRepresentation(tmp.image) customAlbumName:app_Name completionBlock:^
     {
         //这里可以创建添加成功的方法
         [SVProgressHUD showSuccessWithStatus:@"保存图片成功"];
         
     }failureBlock:^(NSError *error){
         [SVProgressHUD dismiss];
         //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
         dispatch_async(dispatch_get_main_queue(), ^{
             
             //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
             if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                 NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
                 [[Utility Share] ShowMessage:@"图片保存失败！" msg:[NSString stringWithFormat:@"请在 设置->隐私->照片 中开启 %@ 对照片的访问权限",app_Name]];
             }
         });
     }];
}

- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                customAlbumName:(NSString *)customAlbumName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    __weak ALAssetsLibrary *weakSelf = assetsLibrary;
    void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
                    [group addAsset:asset];
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    };
    [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        if (customAlbumName) {
            [assetsLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    [weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group addAsset:asset];
                        if (completionBlock) {
                            completionBlock();
                        }
                    } failureBlock:^(NSError *error) {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }];
                } else {
                    AddAsset(weakSelf, assetURL);
                }
            } failureBlock:^(NSError *error) {
                AddAsset(weakSelf, assetURL);
            }];
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}



- (void)save {
    // 0.判断状态
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusNotDetermined) {
         [self saveImage];
    }else{
        [SVProgressHUD dismiss];
        NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        [[Utility Share] ShowMessage:@"图片保存失败！" msg:[NSString stringWithFormat:@"请在 设置->隐私->照片 中开启 %@ 对照片的访问权限",app_Name]];
    }
//    if (status == PHAuthorizationStatusDenied) {
////        BSLog(@"用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关");
//    }else if (status == PHAuthorizationStatusRestricted){
////        BSLog(@"家长控制,不允许访问");
//    }else if (status == PHAuthorizationStatusNotDetermined){
////        BSLog(@"用户还没有做出选择");
//        [self saveImage];
//    }else if (status == PHAuthorizationStatusAuthorized){
////        BSLog(@"用户允许当前应用访问相册");
//        [self saveImage];
//    }
}

/**
 *  返回相册
 */
- (PHAssetCollection *)collection{
    NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    // 先获得之前创建过的相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:app_Name]) {
            return collection;
        }
    }
    
    // 如果相册不存在,就创建新的相册(文件夹)
    __block NSString *collectionId = nil; // __block修改block外部的变量的值
    // 这个方法会在相册创建完毕后才会返回
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:app_Name].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}


/**
 *  返回相册,避免重复创建相册引起不必要的错误
 */
- (void)saveImage{
    /*
     PHAsset : 一个PHAsset对象就代表一个资源文件,比如一张图片
     PHAssetCollection : 一个PHAssetCollection对象就代表一个相册
     */
    
    __block NSString *assetId = nil;
    // 1. 存储图片到"相机胶卷"
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{ // 这个block里保存一些"修改"性质的代码
        // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
        // 返回PHAsset(图片)的字符串标识
        assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:tmp.image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            DLog(@"保存图片到相机胶卷中失败");
            [SVProgressHUD showImage:nil status:@"保存图片到相机胶卷中失败"];
            return;
        }
        DLog(@"成功保存图片到相机胶卷中");
        
        // 2. 获得相册对象
        PHAssetCollection *collection = [self collection];
        
        // 3. 将“相机胶卷”中的图片添加到新的相册
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
            // 根据唯一标示获得相片对象
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            // 添加图片到相册中
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                DLog(@"添加图片到相册中失败");
                [SVProgressHUD showImage:nil status:@"添加图片到相册中失败"];
                return;
            }
            DLog(@"成功添加图片到相册中");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            }];
        }];
    }];
}


@end

//-----------------------------------------------------------------------------







@interface XHImageUrlViewer ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    
    NSInteger selectIndex;
    UILabel *lblNum_index;
    NSMutableArray *mutArrayImageData;
    NSMutableArray *selectIndexArray;
    
    UICollectionView *collectionImages;
    UITapGestureRecognizer *gesture;
    
    UIButton *btnDelete;
}

//@property (nonatomic, strong) NSMutableArray *selectIndexArray;
//@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation XHImageUrlViewer
//@synthesize selectIndexArray=_selectIndexArray,selectIndex;
-(void)setHiddenNumIndex:(BOOL)hiddenNumIndex{
    if (_hiddenNumIndex!=hiddenNumIndex) {
        _hiddenNumIndex=hiddenNumIndex;
        if (lblNum_index) {
            lblNum_index.hidden=_hiddenNumIndex;
        }
    }
}
-(void)setHiddenDeleteButton:(BOOL)hiddenDeleteButton{
    if (_hiddenDeleteButton!=hiddenDeleteButton) {
        _hiddenDeleteButton=hiddenDeleteButton;
        
        if (btnDelete) {
            btnDelete.hidden=_hiddenDeleteButton;
        }
    }
    
}

- (id)init {
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    _hiddenNumIndex=NO;//默认显示
    self.hiddenDeleteButton=YES;//默认不显示
    
    mutArrayImageData=[[NSMutableArray alloc]init];
    selectIndexArray=[[NSMutableArray alloc]init];
    
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    //设置只能横向滑动
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    collectionImages=[[UICollectionView alloc] initWithFrame:CGRectMake(0, kVersion7?0:20, kScreenWidth,kScreenHeight-(kVersion7?0:20)) collectionViewLayout:flowLayout];
    [collectionImages registerClass:[ImagesCollectionCell class] forCellWithReuseIdentifier:@"ImagesCollectionCell"];
    [collectionImages setDelegate:self];
    [collectionImages setDataSource:self];
    [collectionImages setBackgroundColor:[UIColor whiteColor]];
    [collectionImages setPagingEnabled:YES];
    [collectionImages setShowsHorizontalScrollIndicator:NO];
    [self addSubview:collectionImages];
    collectionImages.backgroundColor=[UIColor blackColor];
    
    
    gesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
    [collectionImages addGestureRecognizer:gesture];
    
    
    btnDelete=[RHMethods buttonWithFrame:CGRectMake(kScreenWidth-50,20, 50, 44) title:@"" image:@"ImageBrowser" bgimage:@""];
    [btnDelete addTarget:self action:@selector(selectImageView) forControlEvents:UIControlEventTouchUpInside];
    [btnDelete setImage:[UIImage imageNamed:@"ImageBrowserChecked"] forState:UIControlStateSelected];
    [self addSubview:btnDelete];
    
    btnDelete.selected=YES;
    
    
    lblNum_index=[RHMethods labelWithFrame:CGRectMake(20, YH(collectionImages)-(kVersion7?40:60), W(collectionImages)-40, 40) font:fontTitle color:[UIColor whiteColor] text:@"" textAlignment:NSTextAlignmentRight];
    [self addSubview:lblNum_index];
    
    
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self _setup];
    }
    return self;
}



/**
 *浏览图片 多张图片对象
 (NSArray*)images
 
 (UIImage *)DefaultImage   //默认图片（有数据时候优先显示）
 (NSString *)DefaultName   //默认图片
 (nsstring *)cacheUrl      //缓存图片路径（小图路径）
 (NSString *)url           //大图路径
 
 @[@{@"DefaultImage":image,@"DefaultName":@"imageName",@"url":@"http:xxx.jpg"}]
 */

- (void)showWithImageDatas:(NSArray*)images selectedIndex:(NSInteger)index;{
    [mutArrayImageData removeAllObjects];
    [mutArrayImageData addObjectsFromArray:images];
    if (index>=[mutArrayImageData count]) {
        index=0;
    }
    [selectIndexArray removeAllObjects];
    for (int i=0; i<[images count]; i++) {
        [selectIndexArray addObject:[NSString stringWithFormat:@"%d",i]];
    }

    selectIndex=index;
    [self setNumValue:[NSString stringWithFormat:@"%ld/%lu",(long)selectIndex+1,(unsigned long)[mutArrayImageData count]]];
    
    btnDelete.hidden=self.hiddenDeleteButton;
    btnDelete.selected=[selectIndexArray containsObject:[NSString stringWithFormat:@"%ld",(long)selectIndex]];
    
    [self show];
    [collectionImages reloadData];
    [collectionImages scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    
}


-(void)setNumValue:(NSString *)strTitle{
    //    lblNum_index.text=strTitle;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentRight;
    
    //    NSDictionary *dict=@{NSFontAttributeName : BoldFont(16),
    //                         NSParagraphStyleAttributeName : paragraph,
    //                         NSForegroundColorAttributeName : [UIColor whiteColor],
    //                         NSStrokeWidthAttributeName : @-3,
    //                         NSStrokeColorAttributeName : RGBACOLOR(50, 50, 50, 0.8)};
    
    NSShadow *shadow=[[NSShadow alloc] init];
    shadow.shadowBlurRadius=5;//模糊度
    shadow.shadowColor=[UIColor blackColor];
    shadow.shadowOffset=CGSizeMake(1, 3);
    NSDictionary *dict=@{NSFontAttributeName : BoldFont(16),
                         NSParagraphStyleAttributeName : paragraph,
                         NSForegroundColorAttributeName : [UIColor whiteColor],
                         NSShadowAttributeName : shadow,
                         NSVerticalGlyphFormAttributeName : @(0)};
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strTitle attributes:dict];
    lblNum_index.attributedText=attributedString;
    
    
}

#pragma mark button
-(void)selectImageView{
    NSString *strIndex=[NSString stringWithFormat:@"%ld",(long)selectIndex];
    if ([selectIndexArray containsObject:strIndex]) {
        [selectIndexArray removeObject:strIndex];
    }else{
        [selectIndexArray addObject:strIndex];
    }
    btnDelete.selected=[selectIndexArray containsObject:strIndex];
    
}
#pragma mark selector
- (void)tappedScrollView:(UITapGestureRecognizer*)sender
{
    [self hidden];
}



#pragma mark UICollectionViewDataSource,UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
//集合代理-每一部分数据项
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [mutArrayImageData count];
}


//Cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[mutArrayImageData objectAtIndex:indexPath.row];
    ImagesCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImagesCollectionCell" forIndexPath:indexPath];
    [cell setValueDefaultImage:[dic objectForJSONKey:@"DefaultImage"]  DefaultImageName:[dic valueForJSONStrKey:@"DefaultName"] cacheUrl:[dic valueForJSONStrKey:@"cacheUrl"] urlImage:[dic valueForJSONStrKey:@"url"] indexPath:indexPath tapGesture:gesture];
    return cell;
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth, kVersion7?kScreenHeight:kScreenHeight-20);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}
//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}



#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView==collectionImages) {
        
        CGFloat pageWidth = scrollView.frame.size.width;
        selectIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
        
        [self setNumValue:[NSString stringWithFormat:@"%ld/%lu",(long)selectIndex+1,(unsigned long)[mutArrayImageData count]]];
        
        NSString *strIndex=[NSString stringWithFormat:@"%ld",(long)selectIndex];
        btnDelete.selected=[selectIndexArray containsObject:strIndex];
        
        
    }
}


- (void)show
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidden) name:@"push_showLogin" object:nil];
    
    
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:self];
    
    
    self.hidden = NO;
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0f;
                         
                         
                     }
                     completion:^(BOOL finished) {
                         
                         
                     }];
    
}

- (void)hidden
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (!self.hiddenDeleteButton) {
        if([self.delegate respondsToSelector:@selector(imageUrlViewer:deleteArray:remainArray:)]) {
            NSMutableArray *remainArray=[[NSMutableArray alloc]init];
            NSMutableArray *deleteArray=[[NSMutableArray alloc]init];
            for (int i=0; i<[mutArrayImageData count]; i++) {
                NSDictionary *dic=[mutArrayImageData objectAtIndex:i];
                if ([selectIndexArray containsObject:[NSString stringWithFormat:@"%d",i]]) {
                    [remainArray addObject:dic];
                }else{
                    [deleteArray addObject:dic];
                }
            }
            
            [self.delegate imageUrlViewer:self deleteArray:deleteArray remainArray:remainArray];
        }
    }
    
    
    ImagesCollectionCell *cell=(ImagesCollectionCell *)[collectionImages cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]];
    
    XHViewState *state = [XHViewState viewStateForView:cell.tmp.imageView];
    [state setStateWithView:cell.tmp.imageView];
    UIImageView *currentView = cell.tmp.imageView;
    
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect rct = currentView.frame;
    currentView.transform = CGAffineTransformIdentity;
    currentView.frame = [window convertRect:rct fromView:currentView.superview];
    [window addSubview:currentView];
    
    
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         self.alpha = 0.0;
                         currentView.alpha=0.0;
                         currentView.transform = CGAffineTransformScale(currentView.transform, 2.0,2.0);
                     }
                     completion:^(BOOL finished) {
                         [cell removeFromSuperview];
                         XHViewState *state = [XHViewState viewStateForView:currentView];
                         currentView.transform = CGAffineTransformIdentity;
                         currentView.frame = state.frame;
                         currentView.transform = state.transform;
                         currentView.alpha=1.0;
                         [state.superview addSubview:currentView];
                         
                     }];
    
//    
//    [UIView animateWithDuration:0.3
//                          delay:0.0
//                        options:0
//                     animations:^{
//                         self.alpha = 0.0;
//                         
//                     }
//                     completion:^(BOOL finished) {
//                         
//                     }];
    
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
