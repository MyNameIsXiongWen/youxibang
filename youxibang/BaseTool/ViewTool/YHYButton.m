//
//  YHYButton.m
//  deshanglouyu
//
//  Created by y on 2017/11/13.
//

#import "YHYButton.h"

@implementation YHYButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}
- (instancetype)initWithFrame:(CGRect)frame ImageFrame:(CGSize)imgSize TextFont:(NSInteger)fontSize AndType:(YHYButtonType)type{
    if (self = [super initWithFrame:frame]) {
        _imgSize = imgSize;
        _fontSize = fontSize;
        _type = type;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.type == YHYButtonTypeBottom){
        self.imageView.size = self.imgSize;
        self.imageView.y = 5;
        self.imageView.centerX = self.width * 0.5;
        
        self.titleLabel.x = 0;
        self.titleLabel.y = self.imageView.y + self.imageView.height+5;
        self.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        CGSize textSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
        self.titleLabel.height = textSize.height;
//        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.width = self.width;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }else if (self.type == YHYButtonTypeRight){
        self.imageView.size = self.imgSize;
        self.imageView.x = 5;
        self.imageView.centerY = self.height * 0.5;
        
        self.titleLabel.y = 0;
        self.titleLabel.x = self.imageView.x + self.imageView.width+5;
        self.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        CGSize textSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
        self.titleLabel.height = self.height;
//        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.width = textSize.width;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }else if (self.type == YHYButtonTypeLeft){
        
        self.titleLabel.y = 0;
        
        self.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        CGSize textSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
        self.titleLabel.height = self.height;
//        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.width = textSize.width;
        self.titleLabel.x = self.width/2 - textSize.width/2;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.imageView.size = self.imgSize;
        self.imageView.x = self.titleLabel.x + self.titleLabel.width + 5;
        self.imageView.centerY = self.height * 0.5 + 1;
    }
    
}
@end
