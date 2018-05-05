//
//  LiveFilterTableViewCell.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/24.
//

#import "LiveFilterTableViewCell.h"
#import "LiveFilterCollectionViewCell.h"

static NSString *const LIVEFILTER_COLLECTIONVIEW_ID = @"livefilter_collectionview_id";
@implementation LiveFilterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 7.5;
    layout.minimumLineSpacing = 16;
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.showsVerticalScrollIndicator = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"LiveFilterCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:LIVEFILTER_COLLECTIONVIEW_ID];
}

#pragma mark - collectionDelegate/DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.typeNameArray.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(19, 15, 11, 15);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 60)/3, 30);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LiveFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LIVEFILTER_COLLECTIONVIEW_ID forIndexPath:indexPath];
    cell.typeName.text = self.typeNameArray[indexPath.row];
    if (self.selectedIndex == indexPath.row) {
        cell.typeName.textColor = [UIColor colorFromHexString:@"457fea"];
        cell.typeName.layer.borderColor = [UIColor colorFromHexString:@"457fea"].CGColor;
    }
    else {
        cell.typeName.textColor = [UIColor colorFromHexString:@"666666"];
        cell.typeName.layer.borderColor = [UIColor colorFromHexString:@"cccccc"].CGColor;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.selectedIndex) {
        self.selectedIndex = indexPath.row;
    }
    else {
        self.selectedIndex = 9999;
    }
    if (self.selectedTypeBlock) {
        self.selectedTypeBlock(self.selectedIndex);
    }
    [collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
