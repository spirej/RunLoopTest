//
//  MyTableViewCell.h
//  RunLoopTest
//
//  Created by JackMa on 2019/11/8.
//  Copyright © 2019 fire. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const cellID = @"MyTableViewCellID";

@interface MyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon1;
@property (weak, nonatomic) IBOutlet UIImageView *icon2;
@property (weak, nonatomic) IBOutlet UIImageView *icon3;

@end

NS_ASSUME_NONNULL_END
