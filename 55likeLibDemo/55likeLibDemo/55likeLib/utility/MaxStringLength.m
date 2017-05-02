

#import "MaxStringLength.h"


@implementation MaxStringLength
@synthesize 
curOffset,
curTextView,
curScrollerView,
delegate=_delegate;

static MaxStringLength *_instance=nil;

+ (id)Share
{
    @synchronized(self) {
        if (_instance==nil) {
            _instance = [[self alloc] init];
        }
    }
	return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        isEndingField = NO;
        isEndingText = NO;
	}
    
    return self;
}


#pragma UITextLabel
- (void)setObject:(id)curObject MaxInputNumber:(NSInteger)maxNum
{
    ((UIView *)curObject).tag = maxNum;
    if ([curObject isKindOfClass:[UITextField class]]) {
        ((UITextField *)curObject).delegate = self;
    }
    else if([curObject isKindOfClass:[UITextView class]]){
        ((UITextView *)curObject).delegate = self;
    }
}

#pragma UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //DLog(@"length:%d\n[string length]:%d\nrange.location:%d;range.length:%d\nstring:%@",[textField.text length],[string length],range.location,range.length,string);
    NSInteger afterChangeLength=[textField.text length] + [string length] - range.length;
    //DLog(@"afterChangeLength:%d",afterChangeLength);
	if(afterChangeLength> textField.tag)
    {
        if ([string isEqual:@""]) {
            return YES;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MaxStringLengthOverBorder" object:textField];
		return NO;
    }
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(schaduleEndEditing) object:nil];
    curTextView = textField;
    float y = textField.frame.origin.y;
    id pView = textField.superview;
    if ([pView isKindOfClass:[UIScrollView class]] || [pView isKindOfClass:[UITableView class]]) {
        [(UIScrollView *)pView setContentOffset:CGPointMake(0,MAX(y-100, 0)) animated:YES];
        curScrollerView = pView;
        curOffset =  ((UIScrollView *)pView).contentOffset.y - MAX(y-100, 0);
    }
    else
    {
        UIView *cView = pView;
        for (int i = 0; i < 6; i++) {
            y += cView.frame.origin.y;
            pView = ((UIView *)pView).superview;
            if ([pView isKindOfClass:[UIScrollView class]] || [pView isKindOfClass:[UITableView class]]) {
                [(UIScrollView *)pView setContentOffset:CGPointMake(0,MAX(y-100, 0)) animated:YES];
                curOffset =  ((UIScrollView *)pView).contentOffset.y - MAX(y-100, 0);
                curScrollerView = pView;
                break;
            }
            cView = pView;
            if (i == 5) {
                curScrollerView = nil;
                curOffset = 0;
            }
        }
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
        
        //DLog(@"%@",curTextView);
        [curTextView resignFirstResponder];
        [self performSelector:@selector(schaduleEndEditing) withObject:nil afterDelay:.0];
    return YES;
}
- (void)schaduleEndEditing
{
    @autoreleasepool {
        [self performSelectorOnMainThread:@selector(endEditing) withObject:nil waitUntilDone:NO];
    }
}
- (void)endEditing
{
    if (curScrollerView&&[curScrollerView superview]) {
        float originY = curOffset + ((UIScrollView *)curScrollerView).contentOffset.y;
        float maxY = ((UIScrollView *)curScrollerView).contentSize.height;
        // DLog(@"curOffset:%f;originY:%f;maxY:%f",curOffset,originY,maxY);
        originY = MAX(MIN(originY, maxY), 0);
        
        if (originY > 150) {
            [curScrollerView setContentOffset:CGPointMake(0,originY) animated:YES];
        }
        else
            [curScrollerView setContentOffset:CGPointZero animated:YES];
        
        curOffset = 0;
    }
    curScrollerView = nil;
    curOffset = 0;
    curTextView = nil;
    isEndingField = NO;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_delegate&&[(NSObject*)_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate textFieldDidEndEditing:textField];
    }
}
#pragma UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //DLog(@"length:%d\n[string length]:%d\nrange.location:%d;range.length:%d\nstring:%@",[textView.text length],[text length],range.location,range.length,text);
    NSInteger afterChangeLength=[textView.text length] + [text length] - range.length;
    //DLog(@"afterChangeLength:%d",afterChangeLength);
	if(afterChangeLength> textView.tag)
    {
        if ([text isEqual:@""]) {
            return YES;
        }
		return NO;
    }
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    curTextView = textView;
    float y = textView.frame.origin.y;
    id pView = textView.superview;
    if ([pView isKindOfClass:[UIScrollView class]] || [pView isKindOfClass:[UITableView class]]) {
        [(UIScrollView *)pView setContentOffset:CGPointMake(0,y - 100 > 0? y - 100 : 0) animated:NO];
        curScrollerView = pView;
        curOffset =  ((UIScrollView *)pView).contentOffset.y - (y - 100 > 0? y - 100 : 0);
    }
    else
    {
        UIView *cView = pView;
        for (int i = 0; i < 6; i++) {
            y += cView.frame.origin.y;
            pView = ((UIView *)pView).superview;
            if ([pView isKindOfClass:[UIScrollView class]] || [pView isKindOfClass:[UITableView class]]) {
                curOffset =  ((UIScrollView *)pView).contentOffset.y - (y - 100 > 0? y - 100 : 0);
                [(UIScrollView *)pView setContentOffset:CGPointMake(0,y - 100 > 0? y - 100 : 0) animated:NO];
                curScrollerView = pView;
                break;
            }
            cView = pView;
            
            if (i == 5) {
                curScrollerView = nil;
                curOffset = 0;
            }
        }
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (!isEndingText) {
        isEndingText = YES;
        
        //DLog(@"%@",curTextView);
        [curTextView resignFirstResponder];
        
        if (curScrollerView) {
            float originY = curOffset + ((UIScrollView *)curScrollerView).contentOffset.y;
            float maxY = ((UIScrollView *)curScrollerView).contentSize.height;
            //DLog(@"curOffset:%f;originY:%f;maxY:%f",curOffset,originY,maxY);
            originY = originY > maxY?maxY:originY;
            [curScrollerView setContentOffset:CGPointMake(0,originY) animated:NO];
            curOffset = 0;
        }
        curScrollerView = nil;
        curOffset = 0;
        curTextView = nil;
        isEndingText = NO;
    }
    
    return YES;
}

- (void)resignAllTextField
{
    NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
    [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
        [window endEditing:YES];
    }];
    //[curTextView resignFirstResponder];
}

@end
