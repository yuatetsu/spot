#import <UIKit/UIKit.h>

@protocol RSDFDatePickerViewDelegate;
@protocol RSDFDatePickerViewDataSource;

@interface RSDFDatePickerView : UIView

@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDelegate> delegate;
@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDataSource> dataSource;

- (void)reloadData;
- (id)initWithFrame:(CGRect)frame forYear:(NSInteger)year;
- (id)initWithFrame:(CGRect)frame forYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end

@protocol RSDFDatePickerViewDelegate

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date;

@end

@protocol RSDFDatePickerViewDataSource

@optional
- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view;

@end
