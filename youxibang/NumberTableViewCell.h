//
//  NumberTableViewCell.h
//  youxibang
//
//  Created by y on 2018/1/26.
//

#import <UIKit/UIKit.h>

@interface NumberTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *reduce;
@property (weak, nonatomic) IBOutlet UIButton *add;

@end
