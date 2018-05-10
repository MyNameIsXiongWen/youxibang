//
//  LiveInformationTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import "LiveInformationTableViewCell.h"

@implementation LiveInformationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentWithDic:(NSDictionary *)dic IsTalk:(BOOL)istalk {
    if (dic) {
        self.addressLabel.text = [NSString stringWithFormat:@"城市：%@",dic[@"city"]];
        self.parttimeTypeLabel.text = [NSString stringWithFormat:@"主播类型：%@",dic[@"anchor_type"]];
        if ([dic[@"type"] integerValue] == 1) {
            self.liveTypeLabeL.text = @"直播类型：全职";
        }
        else {
            self.liveTypeLabeL.text = @"直播类型：兼职";
        }
        self.companyLabel.text = [NSString stringWithFormat:@"经纪公司：%@",dic[@"brokerage_agency"]];
        self.expectSalaryLabel.text = [NSString stringWithFormat:@"期望薪资：%@",dic[@"wish_salary"]];
        self.liveSpecialtyLabel.text = [NSString stringWithFormat:@"主播特点：%@",dic[@"self_evaluate"]];
        self.liveSpecialtyLabel.numberOfLines = 2;
        self.wechatLabel.text = [NSString stringWithFormat:@"微信：%@",dic[@"wechat"]];
        self.livePlatformLabel.text = [NSString stringWithFormat:@"所属平台：%@",dic[@"platform"]];
        self.liveExperienceLabel.text = [NSString stringWithFormat:@"直播经验：%@",dic[@"exp"]];
        
        NSMutableString *wechat = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"微信：%@",dic[@"wechat"]]];
        [wechat replaceCharactersInRange:NSMakeRange(4, wechat.length-1-4) withString:@"****"];
        self.wechatLabel.text = wechat;
        if (istalk) {
            self.wechatLabel.text = [NSString stringWithFormat:@"微信：%@",dic[@"wechat"]];
            self.lookButton.hidden = YES;
            self.wechatRightConstraint.constant = 15;
            self.wechatLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pastboardSelector)];
            [self.wechatLabel addGestureRecognizer:tap];
        }
        else {
            self.lookButton.hidden = NO;
            self.wechatRightConstraint.constant = 70;
        }
    }
}

- (void)pastboardSelector {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.wechatLabel.text];
    [SVProgressHUD showSuccessWithStatus:@"主播微信已复制到粘贴板"];
}

@end
