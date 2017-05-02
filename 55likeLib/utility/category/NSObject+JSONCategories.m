//
//  NSObject+JSONCategories.m
//  YunDong55like
//
//  Created by junseek on 15/9/25.
//  Copyright © 2015年 五五来客 lj. All rights reserved.
//

#import "NSObject+JSONCategories.h"

@implementation NSObject (JSONCategories)


///将NSArray或者NSDictionary转化为NSString
-(NSString *)JSONString
{
    NSError* error = nil;
    id data = [NSJSONSerialization dataWithJSONObject:self
                                              options:kNilOptions
                                                error:&error];
    if (error != nil){
        DLog(@"JSON Parsing Error: %@", error);
        return nil ;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];;
}
@end
