//
//  LiveInformationTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import <UIKit/UIKit.h>

@interface LiveInformationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *parttimeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveTypeLabeL;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectSalaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveSpecialtyLabel;
@property (weak, nonatomic) IBOutlet UILabel *wechatLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wechatRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *livePlatformLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveExperienceLabel;
@property (weak, nonatomic) IBOutlet UIButton *lookButton;
- (void)setContentWithDic:(NSDictionary *)dic IsTalk:(BOOL)istalk;

@end
