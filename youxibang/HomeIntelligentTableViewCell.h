//
//  HomeIntelligentTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/23.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ContentTypeIntelligent = 0,//技能
    ContentTypeLive = 1//直播
} ContentType;

typedef void(^ClickLookMoreBlock)(void);
typedef void(^ClickInformationBlock)(NSInteger index, ContentType type);

@interface HomeIntelligentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightAllBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (assign, nonatomic) ContentType type;
@property (copy, nonatomic) ClickLookMoreBlock clickLookMoreBlock;
@property (copy, nonatomic) ClickInformationBlock clickInformationBlock;

- (void)createScrollViewWithIntelligent:(NSMutableArray *)intelligentArray;
@end
