//
//  SelectAddressView.m
//  JXGGWWLiKe
//
//  Created by junseek on 15-1-22.
//  Copyright (c) 2015年 五五来客 李江. All rights reserved.
//

#import "SelectAddressView.h"
//#import "AnalysisStringsGdataXml.h"
#import "NSString+expanded.h"

@interface SelectAddressView()<UIPickerViewDataSource,UIPickerViewDelegate>{
    
    UIView *view_userContact;
    UIPickerView *pickerViewD;
    NSArray *pickerData1;
    NSArray *pickerData2;
    NSArray *pickerData3;
}

@end
@implementation SelectAddressView
@synthesize dicP1,dicP2,dicP3;

-(instancetype)init{
    self=[super init];
    if (self) {
        self.backgroundColor=RGBACOLOR(50, 50, 50, 0.4);
        self.frame=[UIScreen mainScreen].bounds;
        
        UIControl *closeC=[[UIControl alloc]initWithFrame:self.bounds];
        [closeC addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeC];
        
        view_userContact=[[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-260, kScreenWidth, 260)];
        [view_userContact setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:view_userContact];
        
        UIImageView *im=[RHMethods imageviewWithFrame:CGRectMake(0, 0, kScreenWidth, 44) defaultimage:@""];
        im.backgroundColor=rgbGray;
        [view_userContact addSubview:im];
        [view_userContact addSubview:[RHMethods imageviewWithFrame:CGRectMake(0, YH(im)-0.5, kScreenHeight, 0.5) defaultimage:@"userLine"]];
        UIButton *closeBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn1.frame=CGRectMake(20,  Y(im), 120, 44);
        [closeBtn1 setTitle:@"取消" forState:UIControlStateNormal];
        [closeBtn1 setTitleColor:rgbpublicColor forState:UIControlStateNormal];
        [closeBtn1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [closeBtn1 addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [view_userContact addSubview:closeBtn1];
        
        UIButton *OKBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
        OKBtn1.frame=CGRectMake(kScreenWidth-140,  Y(im), 120, 44);
        [OKBtn1 setTitle:@"确定" forState:UIControlStateNormal];
        [OKBtn1 setTitleColor:rgbpublicColor forState:UIControlStateNormal];
        [OKBtn1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [OKBtn1 addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [view_userContact addSubview:OKBtn1];
        
        pickerViewD = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, W(view_userContact), 216)];
        //    指定Delegate
        pickerViewD.delegate=self;
        //    显示选中框
        pickerViewD.showsSelectionIndicator=YES;
        [view_userContact addSubview:pickerViewD];
        
      
       
        
//        NSInteger row =[pickerView selectedRowInComponent:0];
//        NSString *selected = [pickerData objectAtIndex:row];
//        NSString *message = [[NSString alloc] initWithFormat:@"你选择的是:%@",selected];
    }
    return self;
}

-(NSArray *)selectCity:(NSString *)strId{
    NSMutableArray *arrayT=[[NSMutableArray alloc]init];
    for (NSDictionary *dit in self.arrayAddress) {
        if ([strId isEqualToString:[dit valueForJSONStrKey:@"parentid"]]) {
            [arrayT addObject:dit];
        }
    }
    return arrayT;
}
-(void)closeButtonClicked{
    [self hidden];
}

#pragma mark Picker Date Source Methods
//返回显示的列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}
//返回当前列显示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component==0) {
        return [pickerData1 count];
    }else if (component==1){
        
        return [pickerData2 count];
    }else{
        
        return [pickerData3 count];
    }
}

#pragma mark Picker Delegate Methods
//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==0) {
        return [[pickerData1 objectAtIndex:row] objectForJSONKey:@"name"];
    }else if (component==1){
        return [[pickerData2 objectAtIndex:row] objectForJSONKey:@"name"];
    }else{
        return [[pickerData3 objectAtIndex:row] objectForJSONKey:@"name"];
    }
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    switch (component) {
        case 0:
            pickerData2=[self selectCity:[[pickerData1 objectAtIndex:row] objectForKey:@"areaid"]];
            
            [pickerView reloadComponent:1];
            
            
            pickerData3=[self selectCity:[[pickerData2 objectAtIndex:0] objectForKey:@"areaid"]];
            
            [pickerView reloadComponent:2];
            
            
            
            dicP1=[pickerData1 objectAtIndex:row];
            dicP2=[pickerData2 objectAtIndex:0];
            if ([pickerData3 count]) {
                dicP3=[pickerData3 objectAtIndex:0];
            }else{
                dicP3=nil;
            }
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
            break;
        case 1:
            pickerData3=[self selectCity:[[pickerData2 objectAtIndex:row] objectForKey:@"areaid"]];
           
            [pickerView reloadComponent:2];
            
            
            
            dicP2=[pickerData2 objectAtIndex:row];
            if ([pickerData3 count]) {
                dicP3=[pickerData3 objectAtIndex:0];
            }else{
                dicP3=nil;
            }
            [pickerView selectRow:0 inComponent:2 animated:YES];
            break;
        case 2:
            if ([pickerData3 count]) {
                dicP3=[pickerData3 objectAtIndex:row];
            }else{
                dicP3=nil;
            }
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(selectPicker:address1:address2:address3:)]) {
        [self.delegate selectPicker:self address1:dicP1 address2:dicP2 address3:dicP3];
    }
    
    
}


- (void)show
{
    if (!pickerData1) {
        
        pickerData1=[self selectCity:@"0"];
        pickerData2=[self selectCity:[[pickerData1 objectAtIndex:0] objectForKey:@"areaid"]];
        pickerData3=[self selectCity:[[pickerData2 objectAtIndex:0] objectForKey:@"areaid"]];
        
        dicP1=[pickerData1 objectAtIndex:0];
        dicP2=[pickerData2 objectAtIndex:0];
        dicP3=[pickerData3 objectAtIndex:0];
        
        [pickerViewD reloadAllComponents];
    }else{
        
        int index_p1=0;
        if (dicP1) {
            //有数据
            for (int i=0;i<[pickerData1 count];i++) {
                NSDictionary *dic = [pickerData1 objectAtIndex:i];
                NSString *strId=[dic objectForKey:@"areaid"];
                if ([strId isEqualToString:[dicP1 objectForKey:@"areaid"]]) {
                    
                    [pickerViewD selectRow:i inComponent:0 animated:YES];
                    index_p1=i;
                    break;
                }
                
            }
        }
        int index_p2=0;
        if (dicP2) {
            pickerData2=[self selectCity:[[pickerData1 objectAtIndex:index_p1] objectForKey:@"areaid"]];
            [pickerViewD reloadComponent:1];
            //有数据
            for (int i=0;i<[pickerData2 count];i++) {
                NSDictionary *dic = [pickerData2 objectAtIndex:i];
                NSString *strId=[dic objectForKey:@"areaid"];
                if ([strId isEqualToString:[dicP2 objectForKey:@"areaid"]]) {
                    
                    [pickerViewD selectRow:i inComponent:1 animated:YES];
                    index_p2=i;
                    break;
                }
                
            }
        }
        if (dicP3) {
            pickerData3=[self selectCity:[[pickerData2 objectAtIndex:index_p2] objectForKey:@"areaid"]];
            [pickerViewD reloadComponent:2];
            //有数据
            for (int i=0;i<[pickerData3 count];i++) {
                NSDictionary *dic = [pickerData3 objectAtIndex:i];
                NSString *strId=[dic objectForKey:@"areaid"];
                if ([strId isEqualToString:[dicP3 objectForKey:@"areaid"]]) {
                    
                    [pickerViewD selectRow:i inComponent:2 animated:YES];
                    
                    break;
                }
                
            }
        }

    }
    
    
    
    [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:self];
    [view_userContact setFrame:CGRectMake(X(view_userContact), kScreenHeight, W(view_userContact), H(view_userContact))];
    self.hidden = NO;
    self.alpha = 0.0f;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.alpha = 1.0f;
                             [view_userContact setFrame:CGRectMake(X(view_userContact), (kScreenHeight-H(view_userContact)), W(view_userContact), H(view_userContact))];
                             
                         }
                         completion:^(BOOL finished) {
                             if (dicP1) {                                 
                                 if ([self.delegate respondsToSelector:@selector(selectPicker:address1:address2:address3:)]) {
                                     [self.delegate selectPicker:self address1:dicP1 address2:dicP2 address3:dicP3];
                                 }
                             }
                         }];
    
}

- (void)hidden
{
    
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:0
                         animations:^{
                             self.alpha = 0.0;
                             [view_userContact setFrame:CGRectMake(X(view_userContact), kScreenHeight, W(view_userContact), H(view_userContact))];
                         }
                         completion:^(BOOL finished) {
                             
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
