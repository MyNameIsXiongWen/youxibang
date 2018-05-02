//
//  SigninTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/5/2.
//

#import <UIKit/UIKit.h>

@interface SigninTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UILabel *completeLabel;

@end
