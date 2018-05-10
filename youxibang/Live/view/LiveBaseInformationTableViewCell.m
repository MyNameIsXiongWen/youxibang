//
//  LiveBaseInformationTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import "LiveBaseInformationTableViewCell.h"

@implementation LiveBaseInformationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentWithDic:(NSDictionary *)dic Type:(NSInteger)type {
    if (dic) {
        self.idLabel.text = [NSString stringWithFormat:@"ID：%@",dic[@"user_id"]];
        if (type == 1){
            self.constellationLabel.text = [NSString stringWithFormat:@"星座：%@",dic[@"constellation"]];
        }else {
            self.constellationLabel.text = [NSString stringWithFormat:@"星座：%@",dic[@"starsign"]];
        }
        self.hobbyLabel.text = [NSString stringWithFormat:@"爱好：%@",dic[@"interest"]];
        self.signLabel.text = [NSString stringWithFormat:@"签名：%@",dic[@"mysign"]];
    }
}

@end
