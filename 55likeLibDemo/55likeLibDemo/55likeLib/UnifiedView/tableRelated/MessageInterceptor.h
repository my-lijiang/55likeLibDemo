
#import <Foundation/Foundation.h>

@interface MessageInterceptor : NSObject
//change strong to  assign  2013.06.21
@property (nonatomic, strong) id receiver;
@property (nonatomic, strong) id middleMan;
@end
