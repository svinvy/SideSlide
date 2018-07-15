//
//  SideSlideParentViewCtrl.h
//  PanGesture
//
//  Created by GJP on 2018/7/14.
//  Copyright © 2018年 svinvy.lnc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideSlideParentViewCtrl : UIViewController


- (instancetype)initWithLeftView:(UIViewController*)leftView mainView:(UIViewController*)mainView;

@property(nonatomic,strong,readonly)UIViewController *leftView;
@property(nonatomic,strong,readonly)UIViewController *mainView;
@property(nonatomic,assign,readonly)CGFloat leftViewCurrentDisplayingWidth;
@property(nonatomic,assign,readonly)BOOL    displayingLeftView;

#pragma mark - Setters
@property(nonatomic,assign)CGFloat leftViewMaxDisplayWidth;//default is 200
@property(nonatomic,assign)CGFloat validDisplayEdgeLeft;//default is 50
@property(nonatomic,assign)CGFloat maxRespondTransaltion;//default is 150
@property(nonatomic,assign)CGFloat minLeftViewHidingVelocity;//default is 500
@end


