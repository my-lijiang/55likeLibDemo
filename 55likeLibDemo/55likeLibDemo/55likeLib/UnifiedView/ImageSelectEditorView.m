//
//  ImageSelectEditorView.m
//  XinKaiFa55like
//
//  Created by junseek on 2017/3/23.
//  Copyright © 2017年 55like lj. All rights reserved.
//

#import "ImageSelectEditorView.h"
#import <Photos/Photos.h>
//#import <ZYQAssetPickerController.h>
#import "XHImageUrlViewer.h"
#import "LFImagePickerController.h"
@interface ImageSelectEditorView()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,XHImageUrlViewerDelegate,LFImagePickerControllerDelegate>//ZYQAssetPickerControllerDelegate,
{
    XHImageUrlViewer *imageViewer;
    UIImagePickerController *ipc;
//    UIButton *btnAddImage;/
    NSArray *arrayUrlImage;
}


@end
@implementation ImageSelectEditorView


-(instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        [self addview];
        _arrayDeleteIds=[NSMutableArray new];
    }
    return self;
}
-(NSMutableArray *)imageViewArray{
    if (_imageViewArray==nil) {
        _imageViewArray =[NSMutableArray new];
    }
    return _imageViewArray;
}

-(void)addview{
    
//    UIButton*btn=[UIButton new];
//    [btn setBackgroundImage:[UIImage imageNamed:@"upadd"] forState:UIControlStateNormal];
//    //    btn.backgroundColor=[UIColor grayColor];
//    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    btnAddImage=btn;
//    [self addSubview:btn];
}

#pragma mark   获取请求参数
-(NSMutableArray*)getRequsetArrywithkey:(NSString*)key removeServer:(BOOL)abool{
    NSMutableArray *marry=  [NSMutableArray array];
    
    for (int i=0; i<self.imageViewArray.count; i++) {
        UIImageView *image=self.imageViewArray[i];
        //    NSMutableArray *marry;
        if (abool && image.tag>0) {
            continue;
        }
        NSMutableDictionary*dic=[NSMutableDictionary dictionary];
        [dic setValue:[NSString stringWithFormat:@"name%d.jpeg",i] forKey:@"fileName"];
        [dic setValue:[NSString stringWithFormat:@"%@[]",key] forKey:@"fileKey"];
        NSData *imgData=UIImageJPEGRepresentation(image.image, 1.0);
        [dic setObject:imgData forKey:@"fileData"];
        [dic setValue:@"image" forKey:@"fileType"];
        [marry addObject:dic];
    }
    return marry;
    
}
/**
 设置网络或得的图片数组
 
 @param array @[@{@"url":@"",@"id":@"1"}]
 */
-(void)setImageUrlArray:(NSArray *)array imageChange:(ImageSelectEditorViewBlock)imgChange{
    self.imageChange=imgChange;
    arrayUrlImage=array;
    for (NSDictionary *dic in arrayUrlImage) {
        [self addImageViews:nil dataUrl:dic];
    }
    [self loadRefrshImageViewData];
}
-(void)imageAddButtonClicked{
    [[self supViewController].view endEditing:YES];
    if ((self.maxNumber- self.imageViewArray.count)<1) {
        [SVProgressHUD showImage:nil status:[NSString stringWithFormat:@"您最多只能选择%d张",self.maxNumber]];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *CameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            [[Utility Share] showAccessPermissionsAlertViewMessage:[NSString stringWithFormat:@"‘%@’没有访问相机的权限，请前往【设置】允许‘%@’访问",app_Name,app_Name]];
            return;
        }
        
        if (!ipc) {
            ipc=[[UIImagePickerController alloc]init];
        }
        //判断当前相机是否可用
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {// 打开相机
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            //设置是否可编辑
            ipc.allowsEditing = NO;
            ipc.delegate=self;
            //打开
            [[self supViewController] presentViewController:ipc animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
            }];
        }else
        {
            //如果不可用
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"设备相机不能使用..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil ];
            [alert show];
        }
    }];
    UIAlertAction *PhotoLibraryAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        LFImagePickerController *imagePicker = [[LFImagePickerController alloc] initWithMaxImagesCount:(self.maxNumber- self.imageViewArray.count)>0?(self.maxNumber- self.imageViewArray.count):9 delegate:self];
        imagePicker.allowTakePicture = NO;
        imagePicker.allowPickingVideo = NO;
        imagePicker.doneBtnTitleStr = @"完成";
        imagePicker.allowEditting = NO;
        [[self supViewController] presentViewController:imagePicker animated:YES completion:nil];
//        ZYQAssetPickerController *ZYQPicker = [[ZYQAssetPickerController alloc] init];
//        ZYQPicker.maximumNumberOfSelection =(self.maxNumber- self.imageViewArray.count)>0?(self.maxNumber- self.imageViewArray.count):9;
//        ZYQPicker.minimumNumberOfSelection=1;
//        ZYQPicker.showEmptyGroups=NO;
//        ZYQPicker.showEditImageView=NO;
//        ZYQPicker.delegate=self;
//        //        SendNotify(ZKHiddenAudioPlayBtton, nil)
//        [[self supViewController] presentViewController:ZYQPicker animated:YES completion:^{
//            [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
//        }];
        
    }];
    [alertController addAction:CameraAction];
    [alertController addAction:PhotoLibraryAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [[self supViewController] presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 选择照片
//设备协议
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    DLog(@"_____info:%@",info);
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGSize size =  image.size ;
    CGFloat fullW = kScreenWidth*2;
    CGFloat fullH = kScreenHeight*2;
    CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
    ratio = ratio>1?1:ratio;
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    
    //处理图片
    UIImage *logo=[[Utility Share] imageWithImageSimple:image scaledToSize:CGSizeMake(W, H)];
    // NSData *imgData=UIImageJPEGRepresentation(logo, 1.0);
    
    [self addImageViews:logo dataUrl:nil];
    [self loadRefrshImageViewData];
    [[self supViewController] dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [[self supViewController] dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

//#pragma mark - ZYQAssetPickerController Delegate
//-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
//   
//    NSMutableArray *array_tempImage=[[NSMutableArray alloc] initWithArray:_imageViewArray];
//    NSMutableArray *tempImageData=[[NSMutableArray alloc] init];
//    CGSize targetSize = CGSizeMake(kScreenWidth*2,kScreenHeight*2);
//    PHImageRequestOptions *operation = [[PHImageRequestOptions alloc] init];
//    operation.resizeMode = PHImageRequestOptionsResizeModeFast;
//    
//    for (NSString *localIdentifier in assets) {
//        
//        PHCachingImageManager *manager = [[PHCachingImageManager alloc] init];
//        NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
//        [manager startCachingImagesForAssets:assets targetSize:targetSize contentMode:PHImageContentModeDefault options:nil];//PHImageManagerMaximumSize
//        PHFetchResult *saveAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
//        [saveAsset enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[PHAsset class]]) {
//                [assets addObject:obj];
//            }
//            //PHImageManagerMaximumSize
//            [manager requestImageForAsset:obj targetSize:targetSize contentMode:PHImageContentModeDefault options:operation resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            
//                if (result) {
//                    NSString *strRequestID=[[info objectForKey:PHImageResultRequestIDKey] stringValue];
//                    BOOL abool=YES;
//                    int i=0;
//                    for (i=0;i<[tempImageData count];i++) {
//                        NSDictionary *dic = [tempImageData objectAtIndex:i];
//                        if ([[dic valueForKey:@"IDkey"]isEqualToString:strRequestID]) {
//                            abool=NO;
//                            break;
//                        }
//                    }
//                    NSMutableDictionary *dt=[[NSMutableDictionary alloc] init];
//                    [dt setValue:strRequestID forKey:@"IDkey"];
//                    [dt setObject:result forKey:@"imageData"];
//                    if (abool) {
//                        //添加
//                        [tempImageData addObject:dt];
//                    }else{
//                        //替换
//                        [tempImageData replaceObjectAtIndex:i withObject:dt];
//                    }
//                    
//                    [_imageViewArray removeAllObjects];
//                    [_imageViewArray addObjectsFromArray:array_tempImage];
//                    for (NSDictionary *dic in tempImageData) {
//                        [self addImageViews:[dic objectForKey:@"imageData"] dataUrl:nil];
//                    }
//                    [self loadRefrshImageViewData];
//                }
//                
//            }];
//        }];
//    }
//    
//}
//-(void)assetPickerControllerDidMaximum:(ZYQAssetPickerController *)picker{
//    [SVProgressHUD showImage:nil status:[NSString stringWithFormat:@"您只能选择%ld张",(long)picker.maximumNumberOfSelection]];
//}
#pragma mark LFImagePickerControllerDelegate
- (void)lf_imagePickerController:(LFImagePickerController *)picker didFinishPickingThumbnailImages:(NSArray<UIImage *> *)thumbnailImages originalImages:(NSArray<UIImage *> *)originalImages infos:(NSArray<NSDictionary *> *)infos
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *thumbnailFilePath = [documentPath stringByAppendingPathComponent:@"thumbnail"];
    NSString *originalFilePath = [documentPath stringByAppendingPathComponent:@"original"];
    
    NSFileManager *fileManager = [NSFileManager new];
    if (![fileManager fileExistsAtPath:thumbnailFilePath])
    {
        [fileManager createDirectoryAtPath:thumbnailFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:originalFilePath])
    {
        [fileManager createDirectoryAtPath:originalFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    for (NSInteger i = 0; i < originalImages.count; i++) {
//        UIImage *thumbnailImage = thumbnailImages[i];
        UIImage *image = originalImages[i];
//        NSDictionary *info = infos[i];
//        NSString *name = [NSString stringWithFormat:@"%@.jpeg", info[kImageInfoFileName]];
        [self addImageViews:image dataUrl:nil];
    }
    [self loadRefrshImageViewData];
}


-(void)loadRefrshImageViewData{
    
    for (UIView *vi in [self subviews]) {
        [vi removeFromSuperview];
    }
    float fw=65;
    float fjg=10;
    NSInteger count1=_imageViewArray.count;//数组长度
    NSInteger numT=(W(self)-fjg*2)/(fw+fjg);//每排个数
    //  DLog(@"count_image:%d_______count1j=%d",count_image,count1);
    float rm_y=0;
    for (int i=0; i<=count1; i+=numT)   //根据数组添加图片
    {
        rm_y=(fw+fjg)*(i/numT)+fjg;
        DLog(@"__I:%d______rm_y:%f",i,rm_y);
        
        for (int j=0; j<numT; j++)
        {
            if (i+j==count1) {
                UIButton *btnImage=[RHMethods buttonWithFrame:CGRectMake(j*(fw+fjg) +fjg, rm_y, fw, fw) title:@"" image:@"08sch" bgimage:@""];
                btnImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
                btnImage.tag=i+j;
                [btnImage addTarget:self action:@selector(imageAddButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btnImage];
                break;
            }else if (i+j>count1-1)
            {
                break;
            }else{//70 77
                DLog(@"i+j=%d",i+j);
                
                UIImageView *ImageView=[_imageViewArray objectAtIndex:i+j];
                ImageView.frame=CGRectMake(j*(fw+10)+10, rm_y, fw, fw);
                [self addSubview:ImageView];
                
            }
        }
        rm_y=(fw+10)*(i/numT+1);
    }
    self.frameHeight=rm_y+10;
    
    self.imageChange?self.imageChange(1):nil;
}

-(void)addImageViews:(UIImage *)image dataUrl:(NSDictionary *)dic{
    UIImageView *imageV=[[UIImageView alloc]initWithImage:image];
    [imageV setContentMode:UIViewContentModeScaleAspectFill];
    imageV.clipsToBounds=YES;
    imageV.userInteractionEnabled=YES;
    if (dic && [[dic valueForJSONStrKey:@"id"] notEmptyOrNull]) {
        imageV.tag=[[dic valueForJSONStrKey:@"id"] integerValue];
        [imageV imageWithURL:[dic valueForJSONStrKey:@"path"] useProgress:NO useActivity:NO];
    }else{
        imageV.tag=0;
    }
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageButtonClicked:)];
    [imageV addGestureRecognizer:tap];
    [self.imageViewArray addObject:imageV];
}


//放大图片
-(void)imageButtonClicked:(UITapGestureRecognizer *)tap{
    [[self supViewController].view endEditing:YES];
    //放大图片
    if (!imageViewer) {
        imageViewer = [[XHImageUrlViewer alloc] init];
    }
    imageViewer.delegate=self;
    imageViewer.hiddenDeleteButton=NO;
    
    NSInteger index=0;
    NSInteger selectIndex = 0;
    NSMutableArray *array=[[NSMutableArray alloc] init];
    for (UIImageView *imageT in _imageViewArray) {
        if (imageT==tap.view) {
            selectIndex=index;
        }
        index++;
        NSMutableDictionary *dt=[[NSMutableDictionary alloc] init];
        [dt setValue:imageT.image forKey:@"DefaultImage"];
        if (imageT.tag!=0) {
            for (NSDictionary *dic in arrayUrlImage) {
                if (imageT.tag==[[dic valueForJSONStrKey:@"id"] integerValue]) {
                    [dt setValue:[dic valueForJSONStrKey:@"url"] forKey:@"url"];
                    [dt setValue:[dic valueForJSONStrKey:@"id"] forKey:@"id"];
                    break;
                }
            }
        }
        [dt setValue:imageT forKey:@"view"];
        [array addObject:dt];
    }
    [imageViewer showWithImageDatas:array selectedIndex:selectIndex];
    
}


#pragma mark XHImageViewerDelegate
//删除操作后剩下的imageArray
- (void)imageUrlViewer:(XHImageUrlViewer *)view deleteArray:(NSArray*)deleteArray remainArray:(NSArray *)remainArray{
    DLog(@"deleteArray:%@____________remainArray:_%@",deleteArray,remainArray);
    for (NSDictionary *dic in deleteArray) {
        [_imageViewArray removeObject:[dic valueForJSONStrKey:@"view"]];
        if ([[dic valueForJSONStrKey:@"id"] notEmptyOrNull] && [[dic valueForJSONStrKey:@"id"] integerValue]!=0) {
            [_arrayDeleteIds addObject:[dic valueForJSONStrKey:@"id"]];
        }
    }
    if ([deleteArray count]) {
        [self loadRefrshImageViewData];
    }
    
}
-(void)dealloc{
    self.imageChange=nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
