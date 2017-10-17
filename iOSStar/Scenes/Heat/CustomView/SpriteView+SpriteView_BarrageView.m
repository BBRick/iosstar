//
//  SpriteView+SpriteView_BarrageView.m
//  BarrageRendererDemo
//
//  Created by J-bb on 17/7/16.
//  Copyright © 2017年 ExBye Inc. All rights reserved.
//

#import "SpriteView+SpriteView_BarrageView.h"
#import <SDWebImage/SDWebImageDownloader.h>
@implementation SpriteView (SpriteView_BarrageView)

- (void)prepareForReuse {
 

}
- (void)configureWithParams:(NSDictionary *)params
{
    NSString *url = params[@"imageUrl"];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL: [NSURL URLWithString:url] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        self.imageView.image = image;
    }];
    NSString *name = params[@"name"];
    NSNumber *price = params[@"price"];
    NSNumber *buySell = params[@"buySell"];
    NSNumber *count = params[@"amount"];
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@%d秒, %.2f/秒",name, [buySell integerValue] == 1 ? @"获取":@"回收", [count intValue], [price floatValue]];
    
    CGRect rect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(0, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil];
    self.titleLabel.width = rect.size.width;
}
@end
