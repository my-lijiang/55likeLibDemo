

#import "RHTableView.h"
#import "MessageInterceptor.h"
//#import "NetEngine.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"
#import "Utility.h"
#import "Foundation.h"
@interface RHTableView()<EGORefreshTableHeaderDelegate,LoadMoreTableFooterDelegate>{
    BOOL refreshing;
    UIView *bgView;
    UIControl *closeC;
    UILabel *labelNull;
    UIImageView *imageNull;
    NSMutableArray *allArrayData;
    
    BOOL boolNull;
}
@property (nonatomic, assign) NSInteger curPage;
@property (nonatomic, assign) NSInteger dataCount;
@property (nonatomic, strong) NSDictionary *postParams;

@property (nonatomic, strong) EGORefreshTableHeaderView *refreshView;
@property (nonatomic, strong) LoadMoreTableFooterView *loadMoreView;

@property (nonatomic, strong) MKNetworkOperation *networkOperation;
//@property (nonatomic, assign) SVProgressHUDMaskType progressHUDMask;
@property (nonatomic, strong) MessageInterceptor *delegateInterceptor;

@property (nonatomic,copy) RHTableDataBlock bk_data;
@property (nonatomic,copy) RHTableDataOfflineBlock bk_offline;

@end

@implementation RHTableView
@synthesize delegate2;
@synthesize refreshView = _refreshView,loadMoreView = _loadMoreView,delegateInterceptor = _delegateInterceptor,curPage,dataCount,urlString = _urlString,dataArray = _dataArray,networkOperation= _networkOperation,progressHUDMask,isNeedLoadMore = _isNeedLoadMore,isNeedRefresh = _isNeedRefresh;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initComponents];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initComponents];
    }
    
    return self;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if(_delegateInterceptor) {
        super.delegate = nil;
        _delegateInterceptor.receiver = delegate;
        super.delegate = (id)_delegateInterceptor;
    } else {
        super.delegate = delegate;
    }
}

- (void)setDataCount:(NSInteger)t_dataCount
{
    dataCount = t_dataCount;
    if (dataCount < _defaultPageSize) {
        _loadMoreView.delegate?[_loadMoreView setHidden:YES]:nil;
    }
    else
        _loadMoreView.delegate?[_loadMoreView setHidden:NO]:nil;
}

- (void)dealloc
{
    self.bk_data = nil;
    [self cancelDownload];
    _loadMoreView=nil;
    _refreshView=nil;
    //[super dealloc];
}

- (void)initComponents
{
    _defaultPageSize=default_PageSize;
    _isShowHUDMask=YES;
    _dataDic=[NSMutableDictionary new];
    _dataArray=[NSMutableArray new];
    progressHUDMask = SVProgressHUDMaskTypeNone;//SVProgressHUDMaskTypeClear
    
    _delegateInterceptor = [[MessageInterceptor alloc] init];
    _delegateInterceptor.middleMan = self;
    _delegateInterceptor.receiver = self.delegate;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    CGRect loadMoreFrame = _loadMoreView.frame;
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    _loadMoreView.frame = loadMoreFrame;
}

- (void)setIsNeedRefresh:(BOOL)isNeedRefresh
{
    _isNeedRefresh = isNeedRefresh;
    if (!_refreshView && isNeedRefresh) {
        _refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -50, self.frame.size.width, 50)];
        _refreshView.delegate = self;
        [self addSubview:_refreshView];
        [_refreshView refreshLastUpdatedDate];
    }
    isNeedRefresh?[self showRefreshHeader]:[self hiddenRefreshHeader];
}

- (void)setIsNeedLoadMore:(BOOL)isNeedLoadMore
{
    _isNeedLoadMore = isNeedLoadMore;
    if (!_loadMoreView && isNeedLoadMore) {
        _loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
        _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _loadMoreView.delegate = self;
        [_loadMoreView setBackgroundColor:[UIColor clearColor] textColor:nil arrowImage:nil];
        [self addSubview:_loadMoreView];
    }
    isNeedLoadMore?[self showLoadmoreFooter]:[self hiddenLoadmoreFooter];
}

- (void)showRefreshHeader
{
    _refreshView.hidden = NO;
    _refreshView.delegate = self;
}
- (void)hiddenRefreshHeader
{
    _refreshView.hidden = YES;
    _refreshView.delegate = nil;
}
- (void)showLoadmoreFooter
{
    _loadMoreView.hidden = NO;
    _loadMoreView.delegate = self;
}
- (void)hiddenLoadmoreFooter
{
    _loadMoreView.hidden = YES;
    _loadMoreView.delegate = nil;
}

- (void)stopRefresh
{
    refreshing = NO;
    if (_refreshView) {
        [_refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
    }
    
     //endRefresh];
}

- (void)stopLoadmore
{
    if (_loadMoreView) {
        [_loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
    }
    
}

- (void)cancelDownload
{
    self.bk_data = nil;
//    self.delegate2=nil;
    if (self.networkOperation) {
        [self.networkOperation cancel];
    }
    [self stopRefresh];
    [self stopLoadmore];
    
    [SVProgressHUD dismiss];
}
- (void)loadData:(NSInteger)page
{
    curPage = page;
    SVProgressHUDMaskType masktype = self.progressHUDMask;
    if(masktype && _isShowHUDMask){
        if (masktype != SVProgressHUDMaskTypeNil) {
            [SVProgressHUD showWithStatus:@"正在加载..." maskType:masktype];
        }
    }
    
    
    //离线、刷新、加载更多数据加载完成处理。
    void(^block)(NSArray* array, BOOL isCache) = ^(NSArray* array, BOOL isCache){
        DLog(@"\n__________\n%@:\n%@\n__________\n",isCache?@"Cache":@"Sever",array)
        [allArrayData removeAllObjects];
        allArrayData=[NSMutableArray arrayWithArray:self.dataArray];
        if (array.count || curPage==1) {
            if (masktype != SVProgressHUDMaskTypeNil  && _isShowHUDMask) {
                [SVProgressHUD dismiss];
            }
            if (curPage <= default_StartPage) {
                allArrayData = [NSMutableArray arrayWithArray:array];
            }else{
                [allArrayData addObjectsFromArray:array];
            }
        }else{
            if (curPage > default_StartPage+1&&!isCache) {
                curPage --;
            }
            if (curPage <= default_StartPage) {
                [allArrayData removeAllObjects];
            }
            if(masktype && _isShowHUDMask){
                if (masktype != SVProgressHUDMaskTypeNil) {
                    if(curPage>default_StartPage){
                        [SVProgressHUD showImage:nil status:@"亲！没有更多数据了"];
                    }else{
                        [SVProgressHUD showImage:nil status:@"暂无数据"];
                    }
                    
                }
            }
        }
        if (allArrayData.count==0) {
            if (boolNull) {
                self.backgroundView=[self tipsView:YES];
            }else{
                self.backgroundView=[self tipsView:NO];
                closeC.userInteractionEnabled=NO;
            }
            
        }else{
            self.backgroundView=nil;
            closeC.userInteractionEnabled=NO;
        }
        
        if (allArrayData.count >= _defaultPageSize) {
            if (_isNeedLoadMore) {
                [self showLoadmoreFooter];
            }
        }else{
            [self hiddenLoadmoreFooter];
        }
        if (delegate2 && [delegate2 respondsToSelector:@selector(refreshData:)]){
            [delegate2 refreshData:self];
        }
        
        //数据加载成功
        if (self.bk_loaded) {
            self.bk_loaded(allArrayData,isCache);
        }
        [self stopLoadmore];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataArray removeAllObjects];
            self.dataArray=[NSMutableArray arrayWithArray:allArrayData];
            [self reloadData];
            if ([self.delegate2 respondsToSelector:@selector(refreshDataFinished:)]) {
                [self.delegate2 refreshDataFinished:self];
            }
        });
        
        
        isCache?nil:[self stopRefresh];
    };
    if ([[Utility Share] offline]&&self.bk_offline) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 耗时的操作
            NSArray *array =self.bk_offline(curPage);
            dispatch_async(dispatch_get_main_queue(), ^{
                block(array,NO);
            });
        });
        
        return;
    }

  //数据加载器：离线、同步（例如：hessian）、异步（NKNetwork）、test
    if (self.bk_data) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 耗时的操作
            NSArray *array = [[Utility Share] offline]?(self.bk_offline?self.bk_offline(curPage):nil):self.bk_data(curPage);
            dispatch_async(dispatch_get_main_queue(), ^{
                block(array,NO);
            });
        });
    }else if(self.urlString.length){
     /*  self.networkOperation = [NetEngine createSoapAction:[NSString stringWithFormat:self.urlString,[NSNumber numberWithInteger:curPage]] onCompletion:^(id resData, BOOL isCache) {
          DLog(@"resData666:%@",resData);
          if ([[resData valueForJSONStrKey:@"status"] isEqualToString:@"200"]) {
              //数据成功
              self.dataDic=[NSMutableDictionary dictionaryWithDictionary:[resData objectForJSONKey:@"data"]];
              if (delegate2 && [delegate2 respondsToSelector:@selector(refreshData:)]){
                  [delegate2 refreshData:self];
              }
              block([[resData objectForJSONKey:@"data"] objectForJSONKey:@"list"],isCache);
          }else{
              block([NSArray array],isCache);
              [SVProgressHUD showErrorWithStatus:[resData valueForJSONKey:@"msg"] ];
          }
        } onError:^(NSError *error) {
           
        } useCache:YES useMask:progressHUDMask];
        
      
         self.networkOperation = [NetEngine createHttpAction:[NSString stringWithFormat:self.urlString,[NSNumber numberWithInteger:curPage]]
                                                  withCache:YES
                                                 withParams:self.postParams
                                                   withMask:self.progressHUDMask
                                               onCompletion:^(id resData, BOOL isCache){
                                                   DLog(@"Operation____resData:%@",resData );
                                                   if (resData && [resData count] > 0) {
                                                       block(resData ,isCache);
                                                   }else{
                                                      // block([NSArray array],isCache);
                                                   }
                                               }
                                                    onError:^(NSError *error) {
                                                        if (curPage > default_StartPage+1) {
                                                            curPage --;
                                                        }
                                                        [self stopRefresh];
                                                        [self stopLoadmore];
                                                    }];
       */
        if (self.isSoapDomain) {
            //[[NetEngine Share] createAction:NETypeHttpGet withUrl:url withParams:nil withFile:nil withCache:NO withMask:SVProgressHUDMaskTypeNil onCompletion:completion onError:nil];
            if (self.networkOperation) {
                [self.networkOperation cancel];
            }
            self.networkOperation=[[NetEngine soapShare] createAction:NETypeHttpGet
                                                              withUrl:[NSString stringWithFormat:self.urlString,[NSNumber numberWithInteger:curPage]]
                                                           withParams:nil
                                                             withFile:nil
                                                            withCache:NO
                                                             withMask:SVProgressHUDMaskTypeNone
                                                         onCompletion:^(id resData, BOOL isCache) {
                DLog(@"resData666:%@",resData);
                if (masktype != SVProgressHUDMaskTypeNil && _isShowHUDMask) {
                    [SVProgressHUD dismiss];
                }
                if ([[resData valueForJSONStrKey:@"status"] isEqualToString:@"200"]) {
                    //数据成功
                    boolNull=NO;
                    self.dataDic=[NSMutableDictionary dictionaryWithDictionary:[resData objectForJSONKey:@"data"]];
                    if (delegate2 && [delegate2 respondsToSelector:@selector(refreshDataWillAppear:)]){
                        [delegate2 refreshDataWillAppear:self];
                    }
                    block([[resData objectForJSONKey:@"data"] objectForJSONKey:@"list"],isCache);
                }else{
                    boolNull=YES;
                    block([NSArray array],isCache);
                    
                    if ([self.delegate2 respondsToSelector:@selector(refreshDataError:)]) {
                        [self.delegate2 refreshDataError:self];
                    }
                    if (masktype != SVProgressHUDMaskTypeNil && _isShowHUDMask) {
                        [SVProgressHUD showImage:nil status:[resData valueForJSONKey:@"msg"] ];
                    }
                }

            } onError:^(NSError *error) {
                boolNull=YES;
                if ([self.delegate2 respondsToSelector:@selector(refreshDataError:)]) {
                    [self.delegate2 refreshDataError:self];
                }
                block([NSArray array],NO);
                if (masktype != SVProgressHUDMaskTypeNil && _isShowHUDMask) {
                    [SVProgressHUD showErrorWithStatus:alertErrorTxt];
                }
            }];
        }else{
            if (self.networkOperation) {
                [self.networkOperation cancel];
            }
            self.networkOperation=[NetEngine createGetAction_LJ_two:[NSString stringWithFormat:self.urlString,[NSNumber numberWithInteger:curPage]] onCompletion:^(id resData, BOOL isCache) {
                DLog(@"resData666:%@",resData);
                if (masktype != SVProgressHUDMaskTypeNil && _isShowHUDMask) {
                    [SVProgressHUD dismiss];
                }
                if ([[resData valueForJSONStrKey:@"status"] isEqualToString:@"200"]) {
                    self.backgroundView=nil;
                    boolNull=NO;
                    //数据成功
                    self.dataDic=[NSMutableDictionary dictionaryWithDictionary:[resData objectForJSONKey:@"data"]];
                    if (delegate2 && [delegate2 respondsToSelector:@selector(refreshDataWillAppear:)]){
                        [delegate2 refreshDataWillAppear:self];
                    }
//                    if (delegate2 && [delegate2 respondsToSelector:@selector(refreshData:)]){
//                        [delegate2 refreshData:self];
//                    }
                    block([[resData objectForJSONKey:@"data"] objectForJSONKey:@"list"],isCache);
                }else{
                    boolNull=YES;
                    block([NSArray array],isCache);
                    if (masktype != SVProgressHUDMaskTypeNil && _isShowHUDMask) {
                        [SVProgressHUD showImage:nil status:[resData valueForJSONKey:@"msg"] ];
                    }
                    if ([self.delegate2 respondsToSelector:@selector(refreshDataError:)]) {
                        [self.delegate2 refreshDataError:self];
                    }
                }
            } onError:^(NSError *error) {
                boolNull=YES;
                block([NSArray array],NO);
                if (masktype != SVProgressHUDMaskTypeNil && _isShowHUDMask) {
                    [SVProgressHUD showErrorWithStatus:alertErrorTxt];
                }
                if ([self.delegate2 respondsToSelector:@selector(refreshDataError:)]) {
                    [self.delegate2 refreshDataError:self];
                }
            }];
        }
       
        
       
        
    }
    else{
        //JUST for test
        block([NSArray array],YES);
    }

}
- (void)refresh
{
    refreshing = YES;
    [self stopLoadmore];
    [self loadData:default_StartPage];
}

- (void)loadmore
{
    curPage ++;
    [self stopRefresh];
    [self loadData:curPage];
}

#pragma mark - scrollView delegate
//this is dataSource!!
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if ([_delegateInterceptor.receiver respondsToSelector:_cmd]) {
//       return [_delegateInterceptor.receiver tableView:tableView numberOfRowsInSection:section];
//    }
//    return self.dataArray.count;
//}
//- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_delegateInterceptor.receiver respondsToSelector:_cmd]) {
//        return [_delegateInterceptor.receiver tableView:tableView cellForRowAtIndexPath:indexPath];
//    }else{        
//        static NSString *identify = @"cell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
//        if (!cell) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
//        }
//        cell.textLabel.text = [[self.dataArray[indexPath.row] allValues] componentsJoinedByString:@","];
//        return cell;
//    }
//}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _refreshView.delegate?[_refreshView egoRefreshScrollViewDidScroll:scrollView]:nil;
    _loadMoreView.delegate?[_loadMoreView egoRefreshScrollViewDidScroll:scrollView]:nil;
    if (_delegateInterceptor !=nil && [_delegateInterceptor.receiver respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _refreshView.delegate?[_refreshView egoRefreshScrollViewDidEndDragging:scrollView]:nil;
    _loadMoreView.delegate?[_loadMoreView egoRefreshScrollViewDidEndDragging:scrollView]:nil;
    if (_delegateInterceptor !=nil && [_delegateInterceptor.receiver respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_delegateInterceptor.receiver scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate];
    }
}
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self performSelector:@selector(refresh) withObject:nil afterDelay:.1];
    if ([self.delegate2 respondsToSelector:@selector(tableViewWillRefresh:)]) {
        [self.delegate2 tableViewWillRefresh:self];
    }
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];

}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return refreshing; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
#pragma mark - slimeRefresh delegate

/*- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    //    [_refreshView performSelector:@selector(endRefresh)
    //                     withObject:nil afterDelay:3
    //                        inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        [self refresh];
}*/

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{
    //    [_loadMoreView performSelector:@selector(egoRefreshScrollViewDataSourceDidFinishedLoading:)
    //                     withObject:self afterDelay:3
    //                        inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    if (self.dataArray.count >= _defaultPageSize) {
        [self loadmore];
    }
}
#pragma mark - Extends

- (void)loadUrl:(NSString*)url
{
    [self loadWithRefresh:YES withLoadmore:YES withMask:self.progressHUDMask Url:url withParam:nil data:nil offline:nil loaded:nil];
}
- (void)loadUrl:(NSString*)url withMask:(SVProgressHUDMaskType)mask
{
    self.progressHUDMask = mask;
    [self loadWithRefresh:YES withLoadmore:YES withMask:mask Url:url withParam:nil data:nil offline:nil loaded:nil];
}
- (void)loadBlock:(RHTableDataBlock)data_bk
{
    [self loadWithRefresh:YES withLoadmore:YES withMask:self.progressHUDMask Url:nil withParam:nil data:data_bk offline:nil loaded:nil];
}
- (void)loadBlock:(RHTableDataBlock)data_bk offline:(RHTableDataOfflineBlock)offline_bk withMask:(SVProgressHUDMaskType)mask
{
    self.progressHUDMask = mask;
    [self loadWithRefresh:YES withLoadmore:YES withMask:self.progressHUDMask Url:nil withParam:nil data:data_bk offline:offline_bk loaded:nil];
}
- (void)loadBlock:(RHTableDataBlock)data_bk withMask:(SVProgressHUDMaskType)mask
{
    self.progressHUDMask = mask;
    [self loadWithRefresh:YES withLoadmore:YES withMask:self.progressHUDMask Url:nil withParam:nil data:data_bk offline:nil loaded:nil];
}
- (void)showRefresh:(BOOL)showRefresh LoadMore:(BOOL)showLoadmore
{
    self.isNeedRefresh = showRefresh;
    self.isNeedLoadMore = showLoadmore;
}
/**
 @method
 @abstract 表格数据加载模型
 @discussion 通过url 以及参数 params
 @param url 数据来源  params 参数列表
 @result JSON数组
 */

- (void)loadWithRefresh:(BOOL)showRefresh withLoadmore:(BOOL)showLoadmore withMask:(SVProgressHUDMaskType)mask   Url:(NSString*)url withParam:(NSDictionary*)params data:(RHTableDataBlock)data_bk offline:(RHTableDataOfflineBlock)offline_bk loaded:(RHTableLoadedDataBlock)loaded_bk
{
    [self showRefresh:showRefresh LoadMore:showLoadmore];
    self.progressHUDMask = mask;
    self.urlString = url;
    self.postParams = params;
    self.bk_data = data_bk;
    self.bk_offline = offline_bk;
    self.bk_loaded = loaded_bk;
    [self refresh];
}


/**
 
    背景view
 */

- (UIView*)tipsView:(BOOL)refreshBool;
{
    if (!bgView) {
        bgView = [[UIView alloc] initWithFrame:self.bounds];
        closeC=[[UIControl alloc]initWithFrame:self.bounds];
        [closeC addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeC];
        
        labelNull = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.bounds.size.height-60)/2, W(self)-20,0)];
        labelNull.font = [UIFont systemFontOfSize:15];
        labelNull.textColor = [UIColor lightGrayColor];
        labelNull.backgroundColor = [UIColor clearColor];
        labelNull.textAlignment = NSTextAlignmentCenter;
        labelNull.numberOfLines = 3;
        
        [bgView addSubview:labelNull];
        
        imageNull = [RHMethods imageviewWithFrame:CGRectMake((W(self)-100)/2, Y(labelNull)-70, 100, 70) defaultimage:@"smile" contentMode:UIViewContentModeCenter];
        [bgView addSubview:imageNull];
    }
    
    if (refreshBool) {
        closeC.userInteractionEnabled=YES;
        imageNull.hidden=YES;
        labelNull.hidden=NO;
    }else{
        closeC.userInteractionEnabled=NO;
        imageNull.hidden=_isHiddenNull;
        labelNull.hidden=_isHiddenNull;
    }
    
    NSString *strTitle=self.strNullTitle?self.strNullTitle:@"暂无数据";
    labelNull.text = refreshBool?@"数据获取失败，请点击屏幕重新获取数据\n(请检查网络环境是否正常)":strTitle;
    labelNull.frameHeight=[labelNull sizeThatFits:CGSizeMake(W(labelNull), MAXFLOAT)].height;
    
    imageNull.frameY=H(self)/2-30-H(imageNull)+_floatOffset;
    labelNull.frameY=YH(imageNull);
    
    return bgView;
}

-(void)showNullHint:(BOOL)abool{
    _isHiddenNull=!abool;
    self.backgroundView=[self tipsView:NO];
}



@end
