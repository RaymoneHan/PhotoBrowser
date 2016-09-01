//
//  PhotoBrowserPhotos.h
//  HXPhotoBrowser
//
//  Created by hanx on 16/8/29.
//  Copyright © 2016年 hanx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoBrowserPhotos : NSObject

@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic) NSArray<NSString *> *urls;

@property (nonatomic) NSArray<UIImageView *> *parentImageViews;
@end
