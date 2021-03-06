//
//  LiveCharmTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/25.
//

#import "LiveCharmTableViewCell.h"
#import "LiveCharmCollectionViewCell.h"
#import "LiveCharmPhotoModel.h"

static NSString *const LIVECHARM_COLLECTIONVIEW_ID = @"livecharm_collectionview_id";
@implementation LiveCharmTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 10;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.showsVerticalScrollIndicator = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"LiveCharmCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:LIVECHARM_COLLECTIONVIEW_ID];
}

- (void)setLiveCharmArray:(NSArray *)liveCharmArray {
    _liveCharmArray = liveCharmArray;
    [self.collectionView reloadData];
}

#pragma mark - collectionDelegate/DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.liveCharmArray.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 10, 15);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 60)/4, (SCREEN_WIDTH - 60)/4);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LiveCharmPhotoModel *model = self.liveCharmArray[indexPath.row];
    LiveCharmCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIVECHARM_COLLECTIONVIEW_ID forIndexPath:indexPath];
    [cell.liveCharmImageView sd_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:[UIImage imageNamed:@"placeholder_anchor_photo"]];
    cell.liveCharmImageView.layer.masksToBounds = YES;
    if (model.is_charge.integerValue == 1) {
        cell.msgLabel.hidden = NO;
        cell.visualEffectView.hidden = NO;
    }
    else {
        cell.visualEffectView.hidden = YES;
        cell.msgLabel.hidden = YES;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectItemBlock) {
        self.didSelectItemBlock(indexPath.row);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
