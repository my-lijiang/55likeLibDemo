

#import <Foundation/Foundation.h>


@interface NSDictionary (expanded)

- (id)objectForJSONKey:(id)aKey;
- (id)valueForJSONKey:(NSString *)key;
- (id)valueForJSONKeys:(NSString *)key,...NS_REQUIRES_NIL_TERMINATION;
- (void)setObjects:(id)objects forKey:(id)aKey;

- (NSString*)valueForJSONStrKey:(NSString *)key;
/**
 将当前对象转换为get字符串
 
 @return get请求字符串前面有问号
 */
-(NSString *)wgetParamStr;
@end
