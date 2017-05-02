

#import <UIKit/UIKit.h>
#import <SVProgressHUD.h>
#import "NetEngine.h"

@protocol LJCollectionViewDelegate;


typedef id (^LJCollectionDataBlock)(NSInteger page);
typedef id (^LJCollectionDataOfflineBlock)(NSInteger page);
typedef void (^LJCollectionLoadedDataBlock)(NSArray *array,BOOL cache);


@interface LJCollectionView : UICollectionView


@property(nonatomic, assign) id<LJCollectionViewDelegate> delegateCollectionView;


@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *strNullTitle;//没有数据时候提醒语句
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) SVProgressHUDMaskType progressHUDMask;
@property (nonatomic, assign) BOOL isNeedRefresh;
@property (nonatomic, assign) BOOL isNeedLoadMore;
@property (nonatomic, assign) BOOL isSoapDomain;
@property (nonatomic, assign) NSInteger defaultPageSize;//
////没有数据的时候提示语句偏移位置表中心
@property (nonatomic, assign) float floatOffset;
@property (nonatomic, assign) BOOL isHiddenNull;//是否隐藏没有数据的提示

@property (nonatomic,copy) LJCollectionLoadedDataBlock bk_loaded;

- (void)refresh;
- (void)loadmore;
- (void)stopRefresh;
- (void)stopLoadmore;
- (void)cancelDownload;

- (void)showRefresh:(BOOL)showRefresh LoadMore:(BOOL)showLoadmore;

- (void)loadUrl:(NSString*)url;
- (void)loadBlock:(LJCollectionDataBlock)data_bk;
- (void)loadBlock:(LJCollectionDataBlock)data_bk offline:(LJCollectionDataOfflineBlock)offline_bk withMask:(SVProgressHUDMaskType)mask;

- (void)loadWithRefresh:(BOOL)showRefresh withLoadmore:(BOOL)showLoadmore withMask:(SVProgressHUDMaskType)mask   Url:(NSString*)url withParam:(NSDictionary*)params data:(LJCollectionDataBlock)data_bk offline:(LJCollectionDataOfflineBlock)offline_bk loaded:(LJCollectionLoadedDataBlock)loaded_bk;

- (void)loadUrl:(NSString*)url withMask:(SVProgressHUDMaskType)mask;
- (void)loadBlock:(LJCollectionDataBlock)data_bk withMask:(SVProgressHUDMaskType)mask;

@end



@protocol LJCollectionViewDelegate <NSObject>

@optional  //可选
-(void)refreshData:(LJCollectionView *)view;
-(void)refreshDataFinished:(LJCollectionView *)view;

@end

