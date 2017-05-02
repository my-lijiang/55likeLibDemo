//
//  LFAlbumCell.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/13.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFAlbumCell.h"
#import "LFImagePickerHeader.h"
#import "UIView+LFFrame.h"
#import "LFAlbum.h"
#import "LFAsset.h"

@interface LFAlbumCell ()
@property (nonatomic, weak) UIImageView *posterImageView;
//@property (nonatomic, weak) UIImageView *selectImageView;
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation LFAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(LFAlbum *)model {
    _model = model;
    _titleLabel.text = nil;
    _posterImageView.image = nil;
//    _selectImageView.image = bundleImageNamed(@"photo_number_icon");
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
//    _selectImageView.hidden=YES;
//    for (LFAsset *t_a in _model.models) {
//        if (t_a.isSelected) {
//            _selectImageView.hidden=NO;
//            break;
//        }        
//    }
    
}

- (void)setPosterImage:(UIImage *)posterImage
{
    [self.posterImageView setImage:posterImage];
}

/// For fitting iOS6
- (void)layoutSubviews {
    if (iOS7Later) [super layoutSubviews];
    
    /** 居中 */
    _posterImageView.centerY = self.contentView.height/2;
    _titleLabel.centerY = self.contentView.height/2;
//    [self.selectImageView setX:50];
}

+ (CGFloat)cellHeight
{
    return 70.f;
}

#pragma mark - Lazy load

- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        posterImageView.frame = CGRectMake(0, 0, 70, 70);
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}
//- (UIImageView *)selectImageView {
//    if (_selectImageView == nil) {
//        UIImageView *posterImageView = [[UIImageView alloc] init];
//        posterImageView.contentMode = UIViewContentModeCenter;
//        posterImageView.clipsToBounds = YES;
//        posterImageView.frame = CGRectMake(40, 0, 30, 30);
//        [self.contentView addSubview:posterImageView];
//        _selectImageView = posterImageView;
//    }
//    return _selectImageView;
//}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.frame = CGRectMake(80, 0, self.width - 80 - 50, self.height);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

@end
