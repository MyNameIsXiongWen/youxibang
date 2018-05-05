//
//  LiveFilterTableViewCell.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/24.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedTypeBlock)(NSInteger index);

@interface LiveFilterTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (assign, nonatomic) NSInteger selectedIndex;
@property (copy, nonatomic) SelectedTypeBlock selectedTypeBlock;
@property (strong, nonatomic) NSArray *typeNameArray;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
