//
//  NSString+JSONCategories.h
//  YunDong55like
//
//  Created by junseek on 15/9/25.
//  Copyright © 2015年 五五来客 lj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSONCategories)
/////将NSString转化为NSArray或者NSDictionary
-(id)JSONValue;
/////将NSString转化为NSArray或者NSDictionary
-(id)objectFromJSONString;

@end
