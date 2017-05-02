//
//  SelectTypeView.m
//  JiuSheng55like
//
//  Created by junseek on 2016/11/9.
//  Copyright © 2016年 55like lj. All rights reserved.
//

#import "SelectTypeView.h"

#import "RHTableView.h"

@interface SelectTypeView ()<UITableViewDataSource,UITableViewDelegate,RHTableViewDelegate>{
    //
    UIView *view_userContact;
    
    RHTableView *tableViewT;
    UIImageView *imageBG;
    
    NSMutableArray *arrayAllData;
    UIImageView *sj;
//    UIImageView *imageVBG;
    NSMutableArray *selectArray;
}

@end
@implementation SelectTypeView

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.frame=[UIScreen mainScreen].bounds;
        
        self.backgroundColor=[UIColor clearColor];
        _floatTypeY=148;
        arrayAllData =[[NSMutableArray alloc] init];
        selectArray =[[NSMutableArray alloc] init];
        UIControl *closeC=[[UIControl alloc]initWithFrame:self.bounds];
        [closeC addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeC];
        
        view_userContact=[[UIView alloc] initWithFrame:CGRectMake(0, _floatTypeY, kScreenWidth, kScreenHeight-_floatTypeY)];
        [view_userContact setBackgroundColor:RGBACOLOR(50, 50, 50, 0.6)];
        [self addSubview:view_userContact];
        UIControl *closeBG=[[UIControl alloc]initWithFrame:view_userContact.bounds];
        [closeBG addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [view_userContact addSubview:closeBG];
        
//        imageVBG=[RHMethods imageviewWithFrame:view_userContact.bounds defaultimage:@"selectUserBG" stretchW:8 stretchH:8];
//        [view_userContact addSubview:imageVBG];
        
        
        sj=[RHMethods imageviewWithFrame:CGRectMake(kScreenWidth-44, Y(view_userContact)-8, 44, 8) defaultimage:@"sanJiao1201" contentMode:UIViewContentModeCenter];
        //        sj.image=[[UIImage imageNamed:@"sanJiao1201"] imageWithOverlayColor:RGBACOLOR(0, 0, 0, 0.8)];
        [self addSubview:sj];
        
        
        tableViewT=[[RHTableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, H(view_userContact))];
        [tableViewT showRefresh:NO LoadMore:NO];
        tableViewT.delegate = self;
        tableViewT.dataSource = self;
        tableViewT.delegate2=self;
        [tableViewT setBackgroundColor:[UIColor whiteColor]];
        [tableViewT setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [view_userContact addSubview:tableViewT];
        
    }
    return self;
}

#pragma mark tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayAllData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic= [arrayAllData objectAtIndex:indexPath.row];
    
//    DLog(@"_____%@",dic);
    static NSString *identifier =@"cell_identifier";// dic.description.md5;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIView *BGV=[[UIView alloc]initWithFrame:cell.bounds];
        [BGV setBackgroundColor:[UIColor whiteColor]];
        [cell setBackgroundView: BGV];
        
        
        
        
        UILabel *lblName=[RHMethods labelWithFrame:CGRectMake(20, 12, kScreenWidth-70, 20) font:fontTitle color:rgbTitleColor text:[dic valueForJSONStrKey:@"name"]];//
        lblName.tag=101;
        [cell addSubview:lblName];
        
        UIImageView *imageV=[RHMethods imageviewWithFrame:CGRectMake(kScreenWidth-60, 0, 60, 44) defaultimage:@"check" contentMode:UIViewContentModeCenter];
        imageV.tag=102;
        [cell addSubview:imageV];
        
        
        [cell addSubview:[RHMethods lineViewWithFrame:CGRectMake(10, 43.5, kScreenWidth-20, 0.5)]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    UILabel *lblName=(UILabel *)[cell viewWithTag:101];
    lblName.text=[dic valueForJSONStrKey:@"name"];
    UIImageView *imageV=(UIImageView *)[cell viewWithTag:102];
    if ([selectArray containsObject:[dic valueForJSONStrKey:@"value"]]) {
        imageV.hidden=NO;
        lblName.textColor=rgbpublicColor;
    }else{
        lblName.textColor=rgbTitleColor;
        imageV.hidden=YES;
    }
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic= [arrayAllData objectAtIndex:indexPath.row];
    [selectArray removeAllObjects];
    [selectArray addObject:[dic valueForJSONStrKey:@"value"]];
    [tableViewT reloadData];
    [self hidden];
    if ([self.delegate respondsToSelector:@selector(selectTypeView:object:)]) {
        [self.delegate selectTypeView:self object:dic];
    }
}


-(void)closeButtonClicked{
    [self hidden];
}

- (void)showAllArray:(NSArray *)typeArray selectDic:(NSDictionary *)selectDic
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidden) name:@"push_showLogin" object:nil];
    
    
    view_userContact.frame=CGRectMake(X(view_userContact), _floatTypeY, W(view_userContact), kScreenHeight-_floatTypeY);
    sj.frameY=Y(view_userContact)-8;
//    imageVBG.frame=view_userContact.bounds;
    
    [arrayAllData removeAllObjects];
    if (typeArray) {
        [arrayAllData addObjectsFromArray:typeArray];
    }
    float fh=[arrayAllData count]*44;
    fh=fh>H(view_userContact)?H(view_userContact):fh;
    tableViewT.frameHeight=fh;
    
    [selectArray removeAllObjects];
    if (selectDic) {//[[selectDic valueForJSONStrKey:@"id"] notEmptyOrNull]
        [selectArray addObject:[selectDic valueForJSONStrKey:@"value"]];
    }
    [tableViewT reloadData];
    
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:self];
    
    self.hidden = NO;
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hidden
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([self.delegate respondsToSelector:@selector(selectTypeViewHidden:)]) {
        [self.delegate selectTypeViewHidden:self];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
