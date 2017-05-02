
#import "MessageInterceptor.h"

@implementation MessageInterceptor
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([_middleMan respondsToSelector:aSelector]) { return _middleMan; }
    if ([_receiver respondsToSelector:aSelector]) { return _receiver; }
    
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_middleMan respondsToSelector:aSelector]) { return YES; }
    if ([_receiver respondsToSelector:aSelector]) { return YES; }
   
    return [super respondsToSelector:aSelector];
}

@end
