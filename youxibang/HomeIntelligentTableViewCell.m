//
//  HomeIntelligentTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/23.
//

#import "HomeIntelligentTableViewCell.h"
#import "IntelligentView.h"
#import "ContentModel.h"
#import "LiveView.h"

#define MAXSHOW 6

@implementation HomeIntelligentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createScrollViewWithIntelligent:(NSMutableArray *)intelligentArray {
    CGFloat viewHeight = 0;
    if (self.type == ContentTypeIntelligent) {
        viewHeight = 180;
    }
    else if (self.type == ContentTypeLive) {
        viewHeight = 135;
    }
    for (int i=0; i<intelligentArray.count; i++) {
        if (i < MAXSHOW) {
            if (self.type == ContentTypeIntelligent) {
                IntelligentModel *model = intelligentArray[i];
                IntelligentView *intView = [[IntelligentView alloc] initWithFrame:CGRectMake(15+145*i, 0, 135, viewHeight)];
                [intView.imageView sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[UIImage imageNamed:@"ico_tx_l"]];
                intView.nameLabel.text = model.nickname;
                intView.priceLabel.text = [NSString stringWithFormat:@"¥%@",model.price];
                intView.timeLabel.text = model.last_login;
                [self.contentScrollView addSubview:intView];
                UIButton *btn = [EBUtility btnfrome:intView.frame andText:@"" andColor:nil andimg:nil andView:self.contentScrollView];
                btn.tag = i;
                [btn addTarget:self action:@selector(clickIntView:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (self.type == ContentTypeLive) {
                IntelligentModel *model = intelligentArray[i];
                LiveView *intView = [[LiveView alloc] initWithFrame:CGRectMake(15+145*i, 0, 135, viewHeight)];
                [intView.imageView sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[UIImage imageNamed:@"ico_tx_l"]];
                [self.contentScrollView addSubview:intView];
                UIButton *btn = [EBUtility btnfrome:intView.frame andText:@"" andColor:nil andimg:nil andView:self.contentScrollView];
                btn.tag = i;
                [btn addTarget:self action:@selector(clickIntView:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else if (i == MAXSHOW) {
            NSString *imageStr = @"";
            if (self.type == ContentTypeIntelligent) {
                imageStr = @"home_intelligent_more";
            }
            else if (self.type == ContentTypeLive) {
                imageStr = @"home_live_more";
            }
            UIButton *btn = [EBUtility btnfrome:CGRectMake(15+145*i, 0, 100, viewHeight) andText:@"" andColor:nil andimg:[UIImage imageNamed:imageStr] andView:self.contentScrollView];
            [btn addTarget:self action:@selector(clickMore:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)clickIntView:(UIButton *)btn {
    if (self.clickInformationBlock) {
        self.clickInformationBlock(btn.tag);
    }
}

- (void)clickMore:(UIButton *)btn {
    if (self.clickLookMoreBlock) {
        self.clickLookMoreBlock();
    }
}

@end
