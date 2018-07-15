//
//  SideSlideParentViewCtrl.m
//  PanGesture
//
//  Created by GJP on 2018/7/14.
//  Copyright © 2018年 svinvy.lnc. All rights reserved.
//

#import "SideSlideParentViewCtrl.h"

@interface SideSlideParentViewCtrl ()<UIGestureRecognizerDelegate>
{
    CGPoint _paningVelocity;//update when paning
    
    UIView *_maskForMainView;
    
    BOOL _tryingToDisplayLeftView;
}
@property(nonatomic,assign,readonly)CGFloat leftViewMaxDisplayingOriginX;
@property(nonatomic,assign,readonly)CGFloat leftViewMinDisplayingOriginX;
@end

@implementation SideSlideParentViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:_leftView];
    [self addChildViewController:_mainView];
    
    [self.view addSubview:_leftView.view];
    [self.view addSubview:_mainView.view];
    [_mainView.view addSubview:_maskForMainView];
    
    //initial layout
    [self _changeLeftViewPositionX:self.leftViewMinDisplayingOriginX];
    // Do any additional setup after loading the view.
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint startPoint = [gestureRecognizer locationInView:self.view];
    if ((startPoint.x>self.validDisplayEdgeLeft&&!self.displayingLeftView)||(self.displayingLeftView&&startPoint.x<self.leftViewMaxDisplayingOriginX)) {
        return NO;
    }
    _tryingToDisplayLeftView = startPoint.x<=self.validDisplayEdgeLeft;
    return YES;
}
#pragma mark - PanGesture
- (void)handleLeftViewDisplaying:(UIPanGestureRecognizer*)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
        {
            [self handleGestureMoving:sender];
        }
        break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            [self handleGestureEndingEvent:sender];
        }
        break;
        default:break;
    }
}
#pragma mark - ToucheHandles

-(void)handleGestureEndingEvent:(UIPanGestureRecognizer*)sender
{
    if (self.leftView.view.frame.origin.x==self.leftViewMinDisplayingOriginX||self.leftView.view.frame.origin.x==self.leftViewMaxDisplayingOriginX) {
        return;//hiding or displaying max
    }
    BOOL shouldDisplay = [self _shouldFinishDisplayingWhenTouchEnding:sender];
    //continue changing layout
    [UIView animateWithDuration:0.2 animations:^{
        [self _changeLeftViewPositionX: shouldDisplay?self.leftViewMaxDisplayingOriginX:self.leftViewMinDisplayingOriginX];
    }];
}
- (void)handleGestureMoving:(UIPanGestureRecognizer*)sender
{
    _paningVelocity = [sender velocityInView:self.view];
    
    //reLayout leftView and mainView
    CGPoint point =[sender translationInView:self.view];
    CGFloat maxTranslation = self.maxRespondTransaltion;
    CGFloat maxWidth = self.leftViewMaxDisplayWidth;
    CGFloat displayWidth =  point.x*(maxWidth/maxTranslation);
    CGFloat targetOriginX = 0;
    if (!_tryingToDisplayLeftView) {//try to close
        displayWidth = self.leftViewMaxDisplayWidth+displayWidth;
    }
    targetOriginX = displayWidth-_leftView.view.bounds.size.width;
    
    if(targetOriginX<self.leftViewMinDisplayingOriginX){return;}
    else if (targetOriginX>self.leftViewMaxDisplayingOriginX){return;}
    else{
        /** change the layout of leftView&mainView **/
        [self _changeLeftViewPositionX:targetOriginX];
    }
}
#pragma mark - Helps
- (void)_changeLeftViewPositionX:(CGFloat)positionX
{
    CGRect frame = _leftView.view.frame;
    frame.origin.x = positionX;
    _leftView.view.frame = frame;
    
    //mainView should change as well
    CGRect mainFrame = _mainView.view.frame;
    mainFrame.origin.x = CGRectGetMaxX(frame);
    _mainView.view.frame = mainFrame;
    
    //see if we need display maskView
    CGFloat maxChangedAlpha = 1;
    CGFloat needChangedAlpha = maxChangedAlpha*(mainFrame.origin.x/mainFrame.size.width);
    _maskForMainView.alpha = needChangedAlpha;
    if (needChangedAlpha==1) {
        _maskForMainView.hidden = YES;
    }else{_maskForMainView.hidden = NO;}
}

- (void)_injectPanGestureOnMainView
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftViewDisplaying:)];
    recognizer.delegate = self;
    [_mainView.view addGestureRecognizer:recognizer];
}
-(UIView*)_createMaskViewForMainView
{
    UIView*view = [[UIView alloc] initWithFrame:_mainView.view.bounds];
    view.backgroundColor = [UIColor blackColor];
    view.hidden = YES;
    return view;
}
- (BOOL)_shouldFinishDisplayingWhenTouchEnding:(UIPanGestureRecognizer *)sender
{
    //decide finish displaying leftView of hide it.
    
    CGPoint velocity = [sender velocityInView:self.view];
     //see if we need close fastly?
    if (velocity.x<0&&(ABS(velocity.x)>self.minLeftViewHidingVelocity)) {
        return NO;
    }
    return self.leftViewCurrentDisplayingWidth>(self.leftViewMaxDisplayWidth/2);
}
#pragma mark - Getters
-(CGFloat)leftViewMaxDisplayingOriginX
{
    return _leftViewMaxDisplayWidth- _leftView.view.bounds.size.width;
}
-(CGFloat)leftViewMinDisplayingOriginX
{
    return -_leftView.view.bounds.size.width;
}
-(CGFloat)leftViewCurrentDisplayingWidth
{
    return _leftView.view.bounds.size.width+_leftView.view.frame.origin.x;
}
-(BOOL)displayingLeftView
{
    return _leftView.view.frame.origin.x==self.leftViewMaxDisplayingOriginX;
}
#pragma mark - LifeCycle
-(instancetype)initWithLeftView:(UIViewController *)leftView mainView:(UIViewController *)mainView
{
    if (self = [super init]) {
        _leftViewMaxDisplayWidth = 200;
        _validDisplayEdgeLeft = 50;
        _maxRespondTransaltion = 150;
        _minLeftViewHidingVelocity = 500;
        
        _leftView = leftView;
        _mainView = mainView;
        _maskForMainView = [self _createMaskViewForMainView];
        [self _injectPanGestureOnMainView];
    }return self;
}
@end
