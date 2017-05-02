//
//  WebImagesViewController.m
//  ZhuiKe55like
//
//  Created by junseek on 16/10/11.
//  Copyright © 2016年 五五来客 李江. All rights reserved.
//

#import "WebImagesViewController.h"

#import "XHZoomingImageView.h"


#import "XHViewState.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


typedef void(^SaveImageCompletion)(NSError* error);

#pragma mark cell
@interface WebImagesCollectionCell : UICollectionViewCell<UIActionSheetDelegate>{
    
    UITapGestureRecognizer *tapTwo;
    MKNetworkOperation *opTemp;
    MKNetworkOperation *opTemp_cache;
    
}

@property (nonatomic, strong)XHZoomingImageView *tmp;
- (void)setValueDefaultImage:(UIImage *)tImage DefaultImageName:(NSString *)strImage cacheUrl:(NSString *)cacheUrl urlImage:(NSString *)strUrl indexPath:(NSIndexPath *)indexPath;
@end

@implementation WebImagesCollectionCell
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
- (void)setValueDefaultImage:(UIImage *)tImage DefaultImageName:(NSString *)strImage cacheUrl:(NSString *)cacheUrl urlImage:(NSString *)strUrl indexPath:(NSIndexPath *)indexPath
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
           [self save];
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




@interface WebImagesViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    
    NSInteger selectIndex;
    UILabel *lblNum_index;
    NSMutableArray *mutArrayImageData;
    
    UICollectionView *collectionImages;
    
}

@end

@implementation WebImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setup];
}


- (void)_setup {
    
    mutArrayImageData=[[NSMutableArray alloc]init];
   
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    //设置只能横向滑动
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    collectionImages=[[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth,kContentHeight) collectionViewLayout:flowLayout];
    [collectionImages registerClass:[WebImagesCollectionCell class] forCellWithReuseIdentifier:@"WebImagesCollectionCell"];
    [collectionImages setDelegate:self];
    [collectionImages setDataSource:self];
    [collectionImages setBackgroundColor:[UIColor whiteColor]];
    [collectionImages setPagingEnabled:YES];
    [collectionImages setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:collectionImages];
    collectionImages.backgroundColor=[UIColor blackColor];
    [collectionImages setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin];
        
    
    lblNum_index=[RHMethods labelWithFrame:CGRectMake(20, YH(collectionImages)-(kVersion7?40:60), W(collectionImages)-40, 40) font:fontTitle color:[UIColor whiteColor] text:@"" textAlignment:NSTextAlignmentRight];
    [self.view addSubview:lblNum_index];
    [lblNum_index setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    [self showWithImageDatas:[self.otherInfo objectForKey:@"lookImages"] selectedIndex:[[self.otherInfo valueForJSONStrKey:@"lookSelectIndex"] integerValue]];
    
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
    
    selectIndex=index;
    [self setNumValue:[NSString stringWithFormat:@"%ld/%lu",(long)selectIndex+1,(unsigned long)[mutArrayImageData count]]];
    
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
    WebImagesCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WebImagesCollectionCell" forIndexPath:indexPath];
    [cell setValueDefaultImage:[dic objectForJSONKey:@"DefaultImage"]  DefaultImageName:[dic valueForJSONStrKey:@"DefaultName"] cacheUrl:[dic valueForJSONStrKey:@"cacheUrl"] urlImage:[dic valueForJSONStrKey:@"url"] indexPath:indexPath];
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
        
        
        
    }
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
