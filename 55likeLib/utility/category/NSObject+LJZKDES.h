//
//  NSObject+LJZKDES.h
//  ZhuiKe55like
//
//  Created by junseek on 16/7/5.
//  Copyright © 2016年 五五来客 李江. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LJZKDES)
/*字符串加密
 *参数
 *plainText : 加密明文
 *key        : 密钥 64位
 */
-(NSString *) encryptUseDESkey:(NSString *)key;

///解密
- (NSString *) decryptUseDESkey:(NSString*)key;
@end
