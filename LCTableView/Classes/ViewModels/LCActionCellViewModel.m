//
//  LCActionCellViewModel.m
//  1haiiPhone
//
//  Created by LuckyCat on 2018/7/31.
//  Copyright © 2018年 EHi. All rights reserved.
//

#import "LCActionCellViewModel.h"
#import "LCDefines.h"

@implementation LCActionCellViewModel

SetCellClass(LCActionCell);

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认设置
        _cellHeight = 44;
        
        // 间距
        _iconEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
        _textEdgeInsets = UIEdgeInsetsMake(16, 16, 0, 0);
        _detailTextEdgeInsets = UIEdgeInsetsMake(8, 16, 16, 0);
        _valueTextEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 16);
        _accessoryEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 16);
        
        // 标题
        _textColor = [UIColor blackColor];
        _textFont = [UIFont systemFontOfSize:15];
        _textAlignment = NSTextAlignmentLeft;
        _textNumberOfLines = 1;
        
        // 详情
        _detailTextColor = [UIColor lightGrayColor];
        _detailTextFont = [UIFont systemFontOfSize:12];
        _detailTextAlignment = NSTextAlignmentLeft;
        _detailTextNumberOfLines = 1;

        // 右侧提示文字/图片
        _valueTextColor = [UIColor lightGrayColor];
        _valueTextFont = [UIFont systemFontOfSize:12];
        
        // 箭头图片/开关
        _accessoryImage = [UIImage imageNamed:@"arrow_right"];
        
        // 分割线
        _lineColor = [UIColor lightGrayColor];
        _lineWidth = kLCLineWidth;
        _showTopLine = NO;
        _showBottomLine = NO;
    }
    return self;
}

/**
 固定高度：自适应布局(不调用的话cell中会调用)
 */
- (void)calculateLayout {
    [self updateUIWithCalculateCellHeight:NO];
}

/**
 计算高度：所有设置完成后,调用
 */
- (void)calculateCellHeight {
    [self updateUIWithCalculateCellHeight:YES];
}

/** 计算布局 */
- (void)updateUIWithCalculateCellHeight:(BOOL)needCalculateCellHeight {
    // 箭头
    CGFloat valueRight = kLCScreenWidth - self.valueTextEdgeInsets.right;
    CGFloat textRight = kLCScreenWidth - self.accessoryEdgeInsets.right;
    CGFloat detailRight = kLCScreenWidth - self.accessoryEdgeInsets.right;
    if (self.accessoryType != UITableViewCellAccessoryNone) {
        CGFloat accessoryWidth = self.accessoryImage.size.width;
        CGFloat accessoryHeight = self.accessoryImage.size.height;
        if (self.accessoryType == LCActionCellAccessoryTypeSwitch) {
            accessoryWidth = 51;
            accessoryHeight = 31;
        }
        self.accessoryFrame = CGRectMake(textRight - accessoryWidth, 0, accessoryWidth, accessoryHeight);
        
        valueRight = CGRectGetMinX(self.accessoryFrame) - self.valueTextEdgeInsets.right;
        textRight = CGRectGetMinX(self.accessoryFrame) - self.accessoryEdgeInsets.left;
        detailRight = CGRectGetMinX(self.accessoryFrame) - self.accessoryEdgeInsets.left;
    }
    
    // 右侧提示文字/图片
    if (self.valueImage || self.valueTextStr.length || self.valueTextAttrStr.length) {
        CGFloat valueWidth = 0;
        if (self.valueImage) {
            if (self.valueSize.width == 0 || self.valueSize.height == 0) {
                self.valueSize = self.valueImage.size;
            }
            valueWidth = self.valueSize.width;
            self.valueFrame = CGRectMake(0, 0, self.valueSize.width, self.valueSize.height);
        } else {
            CGSize valueSize = [self calculateValueSize];
            valueWidth = valueSize.width;
            if (valueWidth > kLCScreenWidth / 2) {
                valueWidth = kLCScreenWidth / 2;
            }
            self.valueFrame = CGRectMake(0, 0, valueWidth, valueSize.height);
        }
        CGRect tmpValue = self.valueFrame;
        tmpValue.origin.x = valueRight - valueWidth;
        self.valueFrame = tmpValue;
        
        textRight = CGRectGetMinX(self.valueFrame) - self.valueTextEdgeInsets.left;
        detailRight = valueRight;
    }
    
    // icon
    CGFloat textPointX = self.textEdgeInsets.left, detailPointX = self.detailTextEdgeInsets.left;
    if (self.iconImage) {
        if (self.iconSize.width == 0 || self.iconSize.height == 0) {
            self.iconSize = self.iconImage.size;
        }
        self.iconFrame = CGRectMake(self.iconEdgeInsets.left, 0, self.iconSize.width, self.iconSize.height);

        textPointX = CGRectGetMaxX(self.iconFrame) + self.textEdgeInsets.left;
        detailPointX = CGRectGetMaxX(self.iconFrame) + self.detailTextEdgeInsets.left;
    }
    
    // 标题
    CGFloat textWidth = textRight - textPointX;
    CGSize textSize = [self calculateTextSize:textWidth];
    
    // 详情
    if (self.detailTextStr.length || self.detailTextAttrStr.length) {
        CGFloat detailWidth = detailRight - detailPointX;
        CGSize detailSize = [self calculateDetailTextSize:detailWidth];
        
        CGFloat totalHeight = self.textEdgeInsets.top + textSize.height + (self.textEdgeInsets.bottom + self.detailTextEdgeInsets.top) + detailSize.height + self.detailTextEdgeInsets.bottom;
        if (needCalculateCellHeight) {
            self.cellHeight = totalHeight;
        } else {
            // 自适应布局
            if (ABS(totalHeight - self.cellHeight) > 5) {
                CGFloat space = (self.cellHeight - textSize.height - detailSize.height) / 3;
                CGFloat diff = space / 3;
                if (self.cellHeight < (textSize.height + detailSize.height)) {
                    self.textNumberOfLines = 1;
                    self.detailTextNumberOfLines = 1;
                    textSize = [self calculateTextSize:textWidth];
                    detailSize = [self calculateDetailTextSize:detailWidth];
                    
                    space = (self.cellHeight - textSize.height - detailSize.height) / 3;
                    diff = 0;
                }
                UIEdgeInsets tmpText = self.textEdgeInsets;
                UIEdgeInsets tmpDetail = self.detailTextEdgeInsets;
                tmpText.top = tmpDetail.bottom = space + diff;
                tmpText.bottom = tmpDetail.top = (space - diff * 2) / 2;
                self.textEdgeInsets = tmpText;
                self.detailTextEdgeInsets = tmpDetail;
            }
        }
        self.textFrame = CGRectMake(textPointX, self.textEdgeInsets.top, textSize.width, textSize.height);
        self.detailFrame = CGRectMake(detailPointX, CGRectGetMaxY(self.textFrame) + (self.textEdgeInsets.bottom + self.detailTextEdgeInsets.top), detailSize.width, detailSize.height);
    } else {
        if (needCalculateCellHeight) {
            self.cellHeight = self.textEdgeInsets.top + textSize.height + self.detailTextEdgeInsets.bottom;
        }
        // 自适应布局
        if (textSize.height > self.cellHeight) {
            self.textNumberOfLines = 1;
        }
        self.textFrame = CGRectMake(textPointX, 0, textSize.width, self.cellHeight);
    }
    
    // 垂直居中布局
    CGRect tmpAccessory = self.accessoryFrame;
    tmpAccessory.origin.y = (self.cellHeight - CGRectGetHeight(self.accessoryFrame)) / 2;
    self.accessoryFrame = tmpAccessory;
    
    CGRect tmpIcon = self.iconFrame;
    tmpIcon.origin.y = CGRectGetMinY(self.textFrame) + (CGRectGetHeight(self.textFrame) - CGRectGetHeight(self.iconFrame)) / 2;
    self.iconFrame = tmpIcon;
    
    CGRect tmpValue = self.valueFrame;
    if (self.detailTextStr.length || self.detailTextAttrStr.length) {
        tmpValue.origin.y = CGRectGetMinY(self.textFrame) + (CGRectGetHeight(self.textFrame) - CGRectGetHeight(self.valueFrame)) / 2;
    } else {
        tmpValue.origin.y = CGRectGetMinY(self.accessoryFrame) + (CGRectGetHeight(self.accessoryFrame) - CGRectGetHeight(self.valueFrame)) / 2;
    }
    self.valueFrame = tmpValue;
    
    // 上/下线
    self.topLineFrame = CGRectMake(self.topLineInsets.left, self.topLineInsets.top, kLCScreenWidth - self.topLineInsets.left - self.topLineInsets.right, self.lineWidth);
    
    self.bottomLineFrame = CGRectMake(self.bottomLineInsets.left, self.cellHeight - self.lineWidth - self.bottomLineInsets.bottom, kLCScreenWidth - self.bottomLineInsets.left - self.bottomLineInsets.right, self.lineWidth);
}

- (CGSize)calculateValueSize {
    CGSize valueSize;
    if (self.valueTextAttrStr) {
        valueSize = [self attrTextSize:self.valueTextAttrStr height:self.valueTextFont.pointSize];
    } else {
        valueSize = [self textSize:self.valueTextStr font:self.valueTextFont height:self.valueTextFont.pointSize];
    }
    return valueSize;
}

- (CGSize)calculateTextSize:(CGFloat)width {
    CGSize textSize;
    if (self.textAttrStr) {
        textSize = [self attrTextSize:self.textAttrStr width:width numberOfLines:self.textNumberOfLines];
    } else {
        textSize = [self textSize:self.textStr font:self.textFont width:width numberOfLines:self.textNumberOfLines];
    }
    if (textSize.width > width) {
        textSize.width = width;
    }
    return textSize;
}

- (CGSize)calculateDetailTextSize:(CGFloat)width {
    CGSize detailSize;
    if (self.detailTextAttrStr) {
        detailSize = [self attrTextSize:self.detailTextAttrStr width:width numberOfLines:self.detailTextNumberOfLines];
    } else {
        detailSize = [self textSize:self.detailTextStr font:self.detailTextFont width:width numberOfLines:self.detailTextNumberOfLines];
    }
    if (detailSize.width > width) {
        detailSize.width = width;
    }
    return detailSize;
}

#pragma mark - Tool Methods

/** NSString：固定高度 */
- (CGSize)textSize:(NSString *)string font:(UIFont *)font height:(CGFloat)height {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, CGFLOAT_MAX, height);
    label.font = font;
    label.text = string;
    [label sizeToFit];
    return label.frame.size;
}

/** NSAttributedString：固定高度 */
- (CGSize)attrTextSize:(NSAttributedString *)attrString height:(CGFloat)height {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, CGFLOAT_MAX, height);
    label.attributedText = attrString;
    [label sizeToFit];
    return label.frame.size;
}

/** NSString：固定宽度 */
- (CGSize)textSize:(NSString *)string font:(UIFont *)font width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
    label.font = font;
    label.numberOfLines = numberOfLines;
    label.text = string;
    [label sizeToFit];
    return label.frame.size;
}

/** NSAttributedString：固定宽度 */
- (CGSize)attrTextSize:(NSAttributedString *)attrString width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
    label.numberOfLines = numberOfLines;
    label.attributedText = attrString;
    [label sizeToFit];
    return label.frame.size;
}

@end
