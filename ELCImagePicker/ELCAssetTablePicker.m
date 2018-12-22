//
//  ELCAssetTablePicker.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface ELCAssetTablePicker ()<ELCAssetCellTimeLineDelegate>

@property (nonatomic, assign) int columns;

@property (strong, nonatomic) ELCAssetCell *cellTimeLine;

@end

@implementation ELCAssetTablePicker

AppDelegate *appDelegate;
//Using auto synthesizers

- (id)init
{
    self = [super init];
    if (self) {
        //Sets a reasonable default bigger then 0 for columns
        //So that we don't have a divide by 0 scenario
        self.columns = 4;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    self.elcNonPreselectedAssets = [[NSMutableArray alloc] init];
    
    if (self.immediateReturn) {
        
    } else {
        UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [rightButton setTitle:@"Done" forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont fontWithName:FONT_NAME  size:FONT_LARGE_SIZE];
        [rightButton addTarget:self action:@selector(doneAction:) forControlEvents:  UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        [doneButtonItem setTintColor:[UIColor whiteColor]];
        [self.navigationItem setRightBarButtonItem:doneButtonItem];
        [self.navigationItem setTitle:@"Loading..."];
        
        UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 21)];
        [leftButton setImage:[UIImage  imageNamed:@"Slice_icon_82"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(back:) forControlEvents:  UIControlEventTouchUpInside];
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [doneButtonItem setTintColor:[UIColor whiteColor]];
        [self.navigationItem setLeftBarButtonItem:backButtonItem];
    }
    
    [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:FONT_NAME  size:FONT_LARGE_SIZE];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    [label sizeToFit];
}


-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.columns = self.view.bounds.size.width / 80;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = self.view.bounds.size.width / 80;
    [self.tableView reloadData];
}

- (void)preparePhotos
{
    @autoreleasepool {
        
        __block NSMutableArray *tempNonselectedImageArray =[NSMutableArray new];
        __block int SameCount = self.preSelectedNameCardArray.count + self.preSelectedPhotoArray.count;
        //        __block NSMutableArray *tempSelectedPhotoArray =[NSMutableArray new];
        //        __block NSMutableArray *tempSelectedNameCard =[NSMutableArray new];
        __weak ELCAssetTablePicker *selfPointer = self;
        
        [self.assetGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result == nil) {
                return;
            }
            
            ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result];
            NSLog(@"AssetImage:%@",[[result defaultRepresentation] filename]);
            if(SameCount>0){
                for (NSMutableArray *InfoImage in selfPointer.preSelectedPhotoArray)
                {
                    if ([[[result defaultRepresentation] filename] isEqualToString:[InfoImage objectAtIndex:1]])
                    {
                        NSUInteger preSelectOriginalSize = [((NSNumber*) InfoImage[2]) unsignedIntegerValue];
                        NSUInteger originalImageInStorageSize =UIImageJPEGRepresentation([UIImage imageWithCGImage: result.defaultRepresentation.fullScreenImage], 1.0).length;
                        
                        if(preSelectOriginalSize == originalImageInStorageSize){
                            
                            elcAsset.selected = true;
                            elcAsset.typeSelected = TypeSelectedPhoto;
                            SameCount --;
                        }
                    }
                }
                
                for (NSMutableArray *InfoImage in selfPointer.preSelectedNameCardArray)
                {
                    if ([[[result defaultRepresentation] filename] isEqualToString:[InfoImage objectAtIndex:1]])
                    {
                        NSUInteger preSelectOriginalSize = [((NSNumber*) InfoImage[2]) unsignedIntegerValue];
                        NSUInteger originalImageInStorageSize =UIImageJPEGRepresentation([UIImage imageWithCGImage: result.defaultRepresentation.fullScreenImage], 1.0).length;
                        
                        if(preSelectOriginalSize == originalImageInStorageSize){
                            
                            elcAsset.selected = true;
                            elcAsset.typeSelected = TypeSelectedNameCard;
                            SameCount --;
                        }
                    }
                }
            }
            [elcAsset setParent:selfPointer];
            
            BOOL isAssetFiltered = NO;
            if (selfPointer.assetPickerFilterDelegate &&
                [selfPointer.assetPickerFilterDelegate respondsToSelector:@selector(assetTablePicker:isAssetFilteredOut:)])
            {
                isAssetFiltered = [selfPointer.assetPickerFilterDelegate assetTablePicker:selfPointer isAssetFilteredOut:(ELCAsset*)elcAsset];
            }
            
            if (!isAssetFiltered) {
                
                if (!elcAsset.selected) {
                    //
                    //                    if (elcAsset.typeSelected == TypeSelectedPhoto) {
                    //
                    //                        [tempSelectedPhotoArray addObject:elcAsset];
                    //                    }
                    //                    else{
                    //
                    //                        [tempSelectedNameCard addObject:elcAsset];
                    //                    }
                    //                }
                    //                else
                    //                {
                    [tempNonselectedImageArray addObject:elcAsset];
                }
            }
            
        }];
        
        [self creatPreSelectImages];
        
        
        [self.elcNonPreselectedAssets addObjectsFromArray:tempNonselectedImageArray];
        
        NSLog(@"%@",self.elcAssets);
        //Edit by nguyen hai dang
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:selfPointer.view animated:YES];
            [self.tableView reloadData];
            // scroll to bottom
            //            long section = [self numberOfSectionsInTableView:self.tableView] - 1;
            //            long row = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
            //            if (section >= 0 && row >= 0) {
            //                NSIndexPath *ip = [NSIndexPath indexPathForRow:row
            //                                                     inSection:section];
            //                [self.tableView scrollToRowAtIndexPath:ip
            //                                      atScrollPosition:UITableViewScrollPositionBottom
            //                                              animated:NO];
            //            }
            
        });
    }
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


-(void)creatPreSelectImages{
    
    if (self.typeTable == TypeSelectedPhoto) {
        
        for (int i=0; i<self.preSelectedPhotoArray.count; i++) {
            
            ELCAsset *asset = [[ELCAsset alloc]initWithAsset:[ALAsset new]];
            asset.parent = self;
            asset.selected = YES;
            asset.isPreSelectedImage = YES;
            asset.typeSelected = TypeSelectedPhoto;
            asset.preSelectedImageFileName = [[self.preSelectedPhotoArray objectAtIndex:i]firstObject];
            UIImage *image = [[self.preSelectedPhotoArray objectAtIndex:i]lastObject];
            asset.preSelectedImage = image.CGImage;
            asset.isTimelineImage = [[[self.preSelectedPhotoArray objectAtIndex:i]objectAtIndex:3]boolValue];
            NSLog(@"%f:%f",image.size.height,image.size.width);
            [self.elcAssets addObject:asset];
            
        }
        
        for (int i=0; i<self.preSelectedNameCardArray.count; i++) {
            
            ELCAsset *asset = [[ELCAsset alloc]initWithAsset:[ALAsset new]];
            asset.selected = YES;
            asset.parent = self;
            asset.isPreSelectedImage = YES;
            asset.typeSelected = TypeSelectedNameCard;
            asset.preSelectedImageFileName = [[self.preSelectedNameCardArray objectAtIndex:i]firstObject];
            NSLog(@"%d",i);
            asset.isTimelineImage = [[[self.preSelectedNameCardArray objectAtIndex:i]objectAtIndex:3]boolValue];
            UIImage *image = [[self.preSelectedNameCardArray objectAtIndex:i]lastObject];
            asset.preSelectedImage = image.CGImage;
            
            [self.elcAssets addObject:asset];
        }
    }
    else {
        
        for (int i=0; i<self.preSelectedNameCardArray.count; i++) {
            
            ELCAsset *asset = [[ELCAsset alloc]initWithAsset:[ALAsset new]];
            asset.selected = YES;
            asset.parent = self;
            asset.isPreSelectedImage = YES;
            asset.typeSelected = TypeSelectedNameCard;
            asset.preSelectedImageFileName = [[self.preSelectedNameCardArray objectAtIndex:i]firstObject];
            UIImage *image = [[self.preSelectedNameCardArray objectAtIndex:i]lastObject];
            asset.isTimelineImage = [[[self.preSelectedNameCardArray objectAtIndex:i]objectAtIndex:3]boolValue];
            asset.preSelectedImage = image.CGImage;
            [self.elcAssets addObject:asset];
        }
        for (int i=0; i<self.preSelectedPhotoArray.count; i++) {
            
            ELCAsset *asset = [[ELCAsset alloc]initWithAsset:[ALAsset new]];
            asset.selected = YES;
            asset.parent = self;
            asset.isPreSelectedImage = YES;
            asset.typeSelected = TypeSelectedPhoto;
            asset.preSelectedImageFileName = [[self.preSelectedPhotoArray objectAtIndex:i]firstObject];
            UIImage *image = [[self.preSelectedPhotoArray objectAtIndex:i]lastObject];
            asset.isTimelineImage = [[[self.preSelectedPhotoArray objectAtIndex:i]objectAtIndex:3]boolValue];
            asset.preSelectedImage = image.CGImage;
            [self.elcAssets addObject:asset];
        }
        
    }
}


- (void)doneAction:(id)sender
{
    
    if(_cellTimeLine){
        
        ELCAsset *asset = _cellTimeLine.rowAssets [ _cellTimeLine.timeLineIndex];
        
        if(asset.isPreSelectedImage){
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"ChoosedTimeLineImage" object:nil userInfo:@{@"time_line_image":asset.preSelectedImageFileName}];

        }
        else{
            
             [[NSNotificationCenter defaultCenter]postNotificationName:@"ChoosedTimeLineImage" object:nil userInfo:@{@"time_line_image":@"not_random_image"}];
        }
        
    }
    else{
        
          [[NSNotificationCenter defaultCenter]postNotificationName:@"ChoosedTimeLineImage" object:nil userInfo:@{@"time_line_image":@"random_image"}];
    }
    
    
    NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
    
    [selectedAssetsImages addObjectsFromArray:self.elcAssets];
    
    for (ELCAsset *elcAsset in self.elcNonPreselectedAssets) {
        if ([elcAsset selected]) {
            
            [selectedAssetsImages addObject:elcAsset ];
        }
    }
    
    [self.parent selectedAssets:selectedAssetsImages];
    
}


- (BOOL)shouldSelectAsset:(ELCAsset *)asset
{
    NSUInteger selectionCount = 0;
    NSMutableArray *countAssets = [NSMutableArray new];
    [countAssets addObjectsFromArray:self.elcAssets];
    [countAssets addObjectsFromArray:self.elcNonPreselectedAssets];
    
    for (ELCAsset *elcAsset in countAssets) {
        if (elcAsset.selected) selectionCount++;
    }
    BOOL shouldSelect = YES;
    if ([self.parent respondsToSelector:@selector(shouldSelectAsset:previousCount:)]) {
        shouldSelect = [self.parent shouldSelectAsset:asset previousCount:selectionCount];
    }
    return shouldSelect;
}

- (void)assetSelected:(ELCAsset *)asset
{
    NSMutableArray *totalAssets = [NSMutableArray new];
    [totalAssets addObject:self.elcAssets];
    [totalAssets addObject:self.elcNonPreselectedAssets];
    
    if (self.singleSelection) {
        
        for (ELCAsset *elcAsset in totalAssets ) {
            if (asset != elcAsset) {
                elcAsset.selected = NO;
            }
        }
    }
    if (self.immediateReturn) {
        NSArray *singleAssetArray = @[asset.asset];
        [(NSObject *)self.parent performSelector:@selector(selectedAssets:) withObject:singleAssetArray afterDelay:0];
    }
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section ==1&&self.elcAssets.count>0) {
        
        UIImage *myImage = [UIImage imageNamed:@"Slice_icon_59"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
        imageView.frame = CGRectMake(10,10,self.tableView.bounds.size.width,10);
        
        return imageView;
    }
    
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        
        return 0;
    }
    else if (section ==1 &self.elcAssets.count>0 ) {
        
        return 22;
    }
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    if(section==0){
        
        if (self.columns <= 0) { //Sometimes called before we know how many columns we have
            self.columns = 4;
        }
        numRows = ceil([self.elcAssets count] / (float)self.columns);
    }
    else{
        if (self.columns <= 0) { //Sometimes called before we know how many columns we have
            self.columns = 4;
        }
        numRows = ceil([self.elcNonPreselectedAssets count] / (float)self.columns);
    }
    return numRows;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path
{
    NSLog(@"%d",path.section);
    
    if(path.section==0){
        
        long index = path.row * self.columns;
        long length = MIN(self.columns, [self.elcAssets count] - index);
        return [self.elcAssets subarrayWithRange:NSMakeRange(index, length)];
    }
    else{
        
        long index = path.row * self.columns;
        long length = MIN(self.columns, [self.elcNonPreselectedAssets count] - index);
        return [self.elcNonPreselectedAssets subarrayWithRange:NSMakeRange(index, length)];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString *CellIdentifier = [NSString stringWithFormat:@"CellAtRow:%dAndSection:%d",indexPath.row,indexPath.section];
    
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ELCAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.delegate = self;
    cell.typeCell = self.typeTable;
    [cell setAssets:[self assetsForIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79;
}

- (int)totalSelectedAssets
{
    int count = 0;
    
    for (ELCAsset *asset in self.elcAssets) {
        if (asset.selected) {
            count++;
        }
    }
    
    return count;
}

#pragma mark - ELCAssetTimeLineDelegate

-(void)elcAssetCell:(ELCAssetCell *)cell chooseTimeLineImageAtIndex:(NSUInteger)index{
    
    if(_cellTimeLine){
        
        if (([_cellTimeLine isEqual:cell]&&(index!=_cellTimeLine.timeLineIndex))||![_cellTimeLine isEqual:cell]) {
            
            ELCAsset *asset = [_cellTimeLine.rowAssets objectAtIndex:_cellTimeLine.timeLineIndex];
            asset.isTimelineImage = NO;
            UIImageView *imageView = _cellTimeLine.overlayViewArray[_cellTimeLine.timeLineIndex];
            //Tra ve anh photo hoac name card ko time line
            if (asset.typeSelected==TypeSelectedPhoto) {
                
                imageView.image = [UIImage imageNamed:@"image_nontimeline.png"];
                
            }else{
                
                imageView.image = [UIImage imageNamed:@"namecard_nontimeline.png"];
            }
            
            _cellTimeLine = cell;
        }
        
    }
    else{
        
        _cellTimeLine = cell;
    }
}

- (void) disableTimeLineIndex{
    
    _cellTimeLine = nil;
}

- (void) elcAssetCell:(ELCAssetCell *)cell preTimeLineImageAtIndex:(NSUInteger)index{
    
    _cellTimeLine = cell;
}

@end
