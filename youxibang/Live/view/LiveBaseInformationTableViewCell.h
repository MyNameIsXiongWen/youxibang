//
//  LiveBaseInformationTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import <UIKit/UIKit.h>

@interface LiveBaseInformationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *constellationLabel;
@property (weak, nonatomic) IBOutlet UILabel *hobbyLabel;
@property (weak, nonatomic) IBOutlet UILabel *signLabel;
- (void)setContentWithDic:(NSDictionary *)dic Type:(NSInteger)type;

@end
