//
//  NSString+JSONCategories.m
//  YunDong55like
//
//  Created by junseek on 15/9/25.
//  Copyright © 2015年 五五来客 lj. All rights reserved.
//

#import "NSString+JSONCategories.h"

@implementation NSString (JSONCategories)

////将NSString转化为NSArray或者NSDictionary
-(id)JSONValue
{
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
-(id)objectFromJSONString
{
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
@end
