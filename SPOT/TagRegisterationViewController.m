//
//  TagRegisterationViewController.m
//  SPOT
//
//  Created by framgia on 7/21/14.
//  Copyright (c) 2014 framgia. All rights reserved.
//

#import "TagRegisterationViewController.h"
#import "AppDelegate.h"
#import "Tag.h"

@interface TagRegisterationViewController () <TITokenFieldDelegate, UITextViewDelegate>
{
    BOOL isAllowClick;
}
@end

@implementation TagRegisterationViewController

AppDelegate *appDelegate;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
     NSLog(@"scrollViewWillBeginDragging");
    [self deselectSelectedToken];
}

- (void)deselectSelectedToken {
    [self.tokenFieldView.tokenField deselectSelectedToken];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    appDelegate = [UIApplication sharedApplication].delegate;
    self.tagResultsArray = [[NSMutableArray alloc] init];
    NSArray *tagList = [Tag MR_findAllSortedBy:@"spot_count" ascending:NO];
    [self.tagResultsArray addObjectsFromArray:tagList];
    
    self.tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
	[self.tokenFieldView setSourceArray:tagList];
	[self.tokenFieldContainingView addSubview:self.tokenFieldView];
    [self.tokenFieldView.tokenField setDelegate:self];
	[self.tokenFieldView setShouldSearchInBackground:NO];
	[self.tokenFieldView setShouldSortResults:NO];

    [self.tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameDidChange];
	[self.tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]]; // Default is a comma
    [self.tokenFieldView.tokenField setPromptText:@"Tag:"];
	[self.tokenFieldView.tokenField setPlaceholder:@"Type a tag"];
    
    UIButton * addButton = [UIButton buttonWithType: UIButtonTypeContactAdd];
	[addButton addTarget:self action:@selector(addNewToken) forControlEvents:UIControlEventTouchUpInside];
	[self.tokenFieldView.tokenField setRightView:addButton];
	[self.tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [self.tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];

    self.tokenFieldView.tokenField.font = appDelegate.normalFont;;
    self.tokenFieldView.tokenField.tintColor = [UIColor darkGrayColor];
    
	[self.tokenFieldView becomeFirstResponder];
    
    for (Tag *tag in self.spot.tag.allObjects)
    {
        [self.tokenFieldView.tokenField addTokenWithTitle:tag.tag];
    }
    
    [self updateTokenFieldSize];
    
    [FontHelper setFontFamily:FONT_NAME forView:self.view andSubViews:YES];
    
}

- (void)dealloc {
    self.tagResultsArray = nil;
    self.spot = nil;
    NSLog(@"Tag died");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    isAllowClick = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
     [super viewDidAppear:animated];
    
    // Disable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (IBAction) onDoneButtonClicked:(id)sender
{
    if (isAllowClick) {
        isAllowClick = NO;
        self.navigationItem.rightBarButtonItem.enabled = false;
        
        // only when move to other view controller, self.tokenFieldView.tokenField.text is full text include comma
        NSArray *tokenTitles = self.tokenFieldView.tokenTitles;
        //    [self.tokenFieldView.tokenField.text componentsSeparatedByString:@", "]; //self.tokenFieldView.tokenTitles;
        //    NSLog(@"%@", tokenTitles);
        //    NSLog(@"%@", self.tokenFieldView.tokenTitles);
        //    NSLog(@"%@", self.tokenFieldView.tokenField.text);
        
        for (Tag* tag in self.spot.tag.allObjects)
        {
            [self.spot removeTagObject:tag];
            [tag removeSpotObject:self.spot];
            NSLog(@"TAG NAME: %@, tag count: SPOT COUNT: %@, SPOT: %lu", tag.tag, tag.spot_count, (unsigned long)[tag.spot count]);
            if ([tag.spot count]==0) {
                [tag MR_deleteEntity];
            }
        }
        
        if (self.tokenFieldView.tokenField.tokenTitles.count>0){
            for (NSString* tokenTitle in tokenTitles)
            {
                if (tokenTitle.length>0)
                {
                    Tag *tagObject = [Tag MR_findFirstByAttribute:@"tag" withValue:tokenTitle];
                    if (!tagObject)
                    {
                        tagObject = [Tag MR_createEntity];
                        tagObject.tag = tokenTitle;
                    }
                    
                    [self.spot addTagObject:tagObject];
//                    [tagObject addSpotObject:self.spot];
                }
            }
        }
        
        __weak SPOT *spot = self.spot;
        NSManagedObjectContext *magicalContext = [NSManagedObjectContext MR_defaultContext];
        [magicalContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                SPOT *innerSpot = spot;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    AppDelegate *delegateApp = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delegateApp saveSpotToXMLForSync:innerSpot];
                });
            }
        }];
        
        
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        isAllowClick = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNewToken
{
    NSString *newTokenText = [StringHelpers stringByTrimmingWhitespace:self.tokenFieldView.tokenField.text];
  
    if (newTokenText.length > 1) {
        NSLog(@"Add new token %lu", (unsigned long)newTokenText.length);
        [self addTokenWithTitle:newTokenText];
    }
}

- (void) addTokenWithTitle:(NSString*)title
{
    for (NSString *existTitle in self.tokenFieldView.tokenField.tokenTitles)
    {
        if ([existTitle isEqualToString:title])
        {
            return;
        }
    }
    [self.tokenFieldView.tokenField addTokenWithTitle:title];
//    
//    [self.tagResultsArray removeAllObjects];
//    [self.tagResultsArray addObjectsFromArray:[Tag MR_findAll]];
}
- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
	//return NO;
	return YES;
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
    [self performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
    NSLog(@"tokenFieldChangedEditing");
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField {
    NSLog(@"tokenFieldFrameDidChange");
	
    [self updateTokenFieldSize];
}

- (void)updateTokenFieldSize {
    CGRect newFrame = self.tokenFieldContainingView.frame;
	newFrame.size.height = self.tokenFieldView.tokenField.frame.size.height;
	[self.tokenFieldContainingView setFrame:newFrame];
    
    // update size
    [self.tableView setTableHeaderView:self.tokenFieldContainingView];
}

- (BOOL)tokenField:(TITokenField *)field shouldUseCustomSearchForSearchString:(NSString *)searchString
{
    NSLog(@"%@",searchString);
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *searchKeywords = [StringHelpers stringByTrimmingWhitespace: [textField.text stringByReplacingCharactersInRange:range withString:string]];
    NSLog(@"Keyword = %@", searchKeywords);
    if (searchKeywords.length == 0) {
        [self reloadAllTagsFromDatabase];
        
    }
   NSLog(@"shouldChangeCharactersInRange");
    return YES;
}



- (void)tokenField:(TITokenField *)field performCustomSearchForSearchString:(NSString *)searchString withCompletionHandler:(void (^)(NSArray *))completionHandler
{
    NSLog(@"performCustomSearchForSearchString");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *trimmedSearchString = [StringHelpers stringByTrimmingWhitespace:searchString];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"tag BEGINSWITH[c] %@", trimmedSearchString];
        
        __weak TagRegisterationViewController *weakSelf = self;
        
        NSArray *tagList = [Tag MR_findAllWithPredicate:(trimmedSearchString.length)>0?predicate:nil];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //Finally call the completionHandler with the results array!
            NSLog(@"searchDidFinish");
            [weakSelf.tagResultsArray removeAllObjects];
            [weakSelf.tagResultsArray addObjectsFromArray:tagList];
            [weakSelf.tagResultsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *string1 = [(Tag*)obj1 tag];
                NSString *string2 = [(Tag*)obj2 tag];
                return [string1 localizedCaseInsensitiveCompare:string2];
            }];
            [weakSelf performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
        });
    });
     
}

- (void)reloadAllTagsFromDatabase {
    NSArray *tagList = [Tag MR_findAllSortedBy:@"spot_count" ascending:NO];
    [self.tagResultsArray removeAllObjects];
    [self.tagResultsArray addObjectsFromArray:tagList];
    [self reloadResultsTable];
}

-(void) reloadResultsTable {
    NSLog(@"reloadResultsTable");
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tagResultsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Tag *tag = [self.tagResultsArray objectAtIndex:indexPath.row];
    [(UILabel*)[cell viewWithTag:1] setText:[NSString stringWithFormat:@"%@",[tag tag]]];
    [(UILabel*)[cell viewWithTag:2] setText:[NSString stringWithFormat:@"%d",(int)[[tag spot] count]]];
    
    [(UILabel*)[cell viewWithTag:1] setFont:appDelegate.normalFont];
    
    [(UILabel*)[cell viewWithTag:2] setFont:appDelegate.normalFont];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    [self deselectSelectedToken];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Tag *tag = [self.tagResultsArray objectAtIndex:indexPath.row];
    [self addTokenWithTitle:[tag tag]];
    
}

- (IBAction)back:(id)sender {
    if (isAllowClick) {
        isAllowClick = NO;

        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        isAllowClick = YES;
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - TITokenFieldDelegate

- (void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token {
    NSLog(@"didAddToken");
    [self reloadAllTagsFromDatabase];
    NSLog(@"%f", self.tokenFieldView.frame.size.height);
//    self.tokenFieldContainingView.frame = self.tokenFieldView.frame;
}



@end
