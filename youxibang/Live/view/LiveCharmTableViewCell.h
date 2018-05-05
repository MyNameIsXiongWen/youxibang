//
//  LiveCharmTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import <UIKit/UIKit.h>

typedef void(^DidSelectItemBlock)(NSInteger index);

@interface LiveCharmTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (copy, nonatomic) DidSelectItemBlock didSelectItemBlock;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *liveCharmArray;

@end
