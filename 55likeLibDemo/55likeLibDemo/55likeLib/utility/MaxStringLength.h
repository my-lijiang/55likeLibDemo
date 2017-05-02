

#import <Foundation/Foundation.h>


@interface MaxStringLength : NSObject <UITextFieldDelegate,UITextViewDelegate>{
    id curTextView;
    id curScrollerView;
    float curOffset;
    
    BOOL isEndingField;
    BOOL isEndingText;
}
@property (nonatomic, strong) id curTextView;
@property (nonatomic, strong) id curScrollerView;
@property (nonatomic, assign) float curOffset;
@property(strong,nonatomic) id delegate;

+ (id)Share;
- (void)setObject:(id)curObject MaxInputNumber:(NSInteger)maxNum;

@end
