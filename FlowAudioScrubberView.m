//
//  FlowAudioScrubberView.m
//  iFiles Some Update
//
//  Created by Tom on 11/14/16.
//  Copyright © 2016 Tom Biel, Inc. All rights reserved.
//

#import "FlowAudioScrubberView.h"

//#define FlowAudioScrubberViewShowDebugColors 1

@implementation FlowAudioScrubberView {
   float _currentPosition;
   float _downloadProgress;
   float _duration;
   
   UILabel *_timePlayedLabel;
   UILabel *_timeLeftLabel;
   
   UIView *_backgroundline;
   UIView *_downloadLine;
   UIView *_positionLine;
   UIView *_thumbView;
   UIImageView *_thumbCircleView;
   
   //
   float _lineHeight;
   UIEdgeInsets _lineInset;
   
   CGSize _thumbSize;
   float _thumbFocusedRadius;
   float _thumbUnFocusedRadius;
   float _thumbCirclePadding;
   BOOL _thumbSelected;
   
   UIColor *_positionColor;
   
   float _thumbAnimationDuration;
}

- (instancetype) initWithFrame:(CGRect)frame {
   
   self = [super initWithFrame:frame];
   if(self) {
      
      // default colors
      
      self.activeColor = [UIColor redColor];
      self.labelsColor = [UIColor blackColor];
      
      self.positionColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
      self.backgroundLineColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
      self.downloadLineColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
      
      _lineHeight = 2;
      _lineInset = UIEdgeInsetsMake(15, 30, 0, 30);
      _thumbFocusedRadius = 14;
      _thumbUnFocusedRadius = 4;
      _thumbSize = CGSizeMake(40, 40);
      _thumbCirclePadding = 4;
      
      _thumbAnimationDuration = 0.1;
      
       
      _downloadProgress = 0.0;
      
       
#ifdef AudioScrubberViewShowDebugColors
      self.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
#endif
      _backgroundline = [UIView new];
      _backgroundline.backgroundColor = _backgroundLineColor;
      [self addSubview:_backgroundline];
      
      _downloadLine = [UIView new];
      _downloadLine.backgroundColor = _downloadLineColor;
      [_backgroundline addSubview:_downloadLine];
      
      _positionLine = [UIView new];
      _positionLine.backgroundColor = _positionColor;
      _thumbCircleView.tintColor = _positionColor;
      [_backgroundline addSubview:_positionLine];
      
      _thumbView = [UIView new];
#ifdef AudioScrubberViewShowDebugColors
      _thumbView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
#endif
      [self addSubview:_thumbView];
      
      _thumbCircleView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"audiobar_thumb"]
                                                             imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
      
      [_thumbView addSubview:_thumbCircleView];
      
      UILongPressGestureRecognizer *pressGestureRecognizer;
      pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbPress:)];
      pressGestureRecognizer.minimumPressDuration = 0.0;
      [_thumbView addGestureRecognizer:pressGestureRecognizer];
      
      _timePlayedLabel = [UILabel new];
      _timePlayedLabel.font = [UIFont systemFontOfSize:11];
      //_titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12]; // HelveticaNeue-Medium  Light
      _timePlayedLabel.backgroundColor = [UIColor clearColor];
      _timePlayedLabel.adjustsFontSizeToFitWidth = YES;
      _timePlayedLabel.textAlignment = NSTextAlignmentLeft;
      _timePlayedLabel.minimumScaleFactor = 0.7f;
      _timePlayedLabel.textColor = _labelsColor;
      // _exampleValueLablel.text = @"File name 123 3432423:";
      // HelveticaNeue-Light
      //titleLbl.minimumFontSize = 10;
      [self addSubview:_timePlayedLabel];
      
      _timeLeftLabel = [UILabel new];
      _timeLeftLabel.font = [UIFont systemFontOfSize:11];
      //_titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12]; // HelveticaNeue-Medium  Light
      _timeLeftLabel.backgroundColor = [UIColor clearColor];
      _timeLeftLabel.adjustsFontSizeToFitWidth = YES;
      _timeLeftLabel.textAlignment = NSTextAlignmentRight;
      _timeLeftLabel.minimumScaleFactor = 0.7f;
      _timeLeftLabel.textColor = _labelsColor;
      // _exampleValueLablel.text = @"File name 123 3432423:";
      // HelveticaNeue-Light
      //titleLbl.minimumFontSize = 10;
      [self addSubview:_timeLeftLabel];
      
      [self updateDurationLabels];

   }
   
   return self;
}

- (instancetype) init {
   
   self = [self initWithFrame:CGRectMake(0, 0, 100, 40)];
   return self;
}

#pragma mark - properties

- (void) setProgress:(float)progress  {
   if(!_thumbSelected) {
      _currentPosition = progress;
      [self updateDurationLabels];
      [self layoutThumb];
   }
}

- (float) progress {
   return _currentPosition;
}

- (void) setDownloadProgress:(float)downloadProgress {
   _downloadProgress = downloadProgress;
   [self layoutSlider];
}

- (float) downloadProgress {
   return _downloadProgress;
}

- (void) setDuration:(float)duration {
   _duration = duration;
   
   [self updateDurationLabels];
   [self layoutThumb];
}

- (float) duration {
   return _duration;
}

- (void) setActiveColor:(UIColor *)color {
   _activeColor = color;
}

- (void) setLabelsColor:(UIColor *)color {
   _labelsColor = color;
   _timePlayedLabel.textColor = _labelsColor;
   _timeLeftLabel.textColor = _labelsColor;
}

- (void) setPositionColor:(UIColor *)color {
   _positionColor = color;
   _positionLine.backgroundColor = _positionColor;
   _thumbCircleView.tintColor = _positionColor;
}

- (void) setBackgroundLineColor:(UIColor *)color {
   _backgroundLineColor = color;
   _backgroundline.backgroundColor = _backgroundLineColor;
}

- (void) setDownloadLineColor:(UIColor *)color {
   _downloadLineColor = color;
   _downloadLine.backgroundColor = _downloadLineColor;
}

#pragma mrak -

- (void) updateDurationLabels {
   
   _timePlayedLabel.text = [self getTimeStringFromSeconds:_currentPosition*_duration];
   _timeLeftLabel.text = [self getTimeStringFromSeconds:-(_duration-_currentPosition*_duration)];
}

- (NSString *) getTimeStringFromSeconds:(double)seconds {
   
   NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
   dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
   dcFormatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
   dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
   return [dcFormatter stringFromTimeInterval:seconds];
}

#pragma mark -  layout
- (void) layoutSubviews {
   
   [super layoutSubviews];
   
   [self layoutValueLabels];
   [self layoutSlider];
}

- (void) layoutValueLabels {
   
   float sWidth = self.bounds.size.width;
   float sHeight = self.bounds.size.height;
   
   float playedTopPadding = 0;
   float leftTopPadding = 0;
   
  // if(_thumbSelected && _currentPosition < 0.15)
   if(_thumbSelected && _thumbView.frame.origin.x < 70)
      playedTopPadding += 10;
   
   //if(_thumbSelected && _thumbView.frame.origin.x+_thumbSize.width > 0.85)
   if(_thumbSelected && _thumbView.frame.origin.x+_thumbSize.width > self.frame.size.width-70)
      leftTopPadding += 10;
   
   _timePlayedLabel.frame = CGRectMake(_lineInset.left, _lineInset.top+6+playedTopPadding, 40, 12);
   _timeLeftLabel.frame = CGRectMake(sWidth-40-_lineInset.right, _lineInset.top+6+leftTopPadding, 40, 12);
}

- (void) layoutSlider {
   
   _backgroundline.frame = CGRectMake(_lineInset.left, _lineInset.top,
                                 self.bounds.size.width-_lineInset.left-_lineInset.right, _lineHeight);
   
   _downloadLine.frame = CGRectMake(0, 0, _downloadProgress*_backgroundline.bounds.size.width,
                                    _lineHeight);

  //float sWidth = _backgroundline.bounds.size.width;
  // float sHeight = _backgroundline.bounds.size.height;
   
   [self layoutThumb];
}

- (void) layoutThumb {
   
   // _scrubberCirclePadding
   
   // calculate scrubber movement length
   float scrubberMovLength = _backgroundline.bounds.size.width-_thumbSize.width+_thumbCirclePadding*2;
   
   float leftPosition = (_currentPosition*scrubberMovLength)+_lineInset.left-_thumbCirclePadding;
   
   _thumbView.frame = CGRectMake(leftPosition,
                                 (_lineInset.top+_lineHeight/2)-_thumbSize.height/2,
                                 _thumbSize.width, _thumbSize.height);
   
   CGPoint circlePos = [self scrubberCirclePoistionSelected:_thumbSelected];
   
   if(_thumbSelected) {
      _thumbCircleView.frame = CGRectMake(circlePos.x, circlePos.y, _thumbFocusedRadius*2, _thumbFocusedRadius*2);
   }
   else {
      _thumbCircleView.frame = CGRectMake(circlePos.x, circlePos.y, _thumbUnFocusedRadius*2, _thumbUnFocusedRadius*2);
   }
   _positionLine.frame = CGRectMake(0, 0, _thumbView.frame.origin.x+circlePos.x-_lineInset.left, _lineHeight);
}

#pragma mark - pan

- (void) handleThumbPress:(UILongPressGestureRecognizer*)sender {
   
   static float startingPos;
   float endPos;
   float movedBy;
   float newPos;
   float minXOffset = 0;
   float maxXOffset = _backgroundline.bounds.size.width;
   
   // [sender translationInView:self.view.superview].y;
   movedBy = [sender locationInView:_backgroundline].x;
   CGRect rect = _backgroundline.frame;
   
   if (sender.state == UIGestureRecognizerStateBegan) {
      [self enterPositionAdjustment];
   }
   else if (sender.state == UIGestureRecognizerStateChanged) {
      newPos = startingPos + movedBy;
      
      if(newPos > maxXOffset)
         newPos = maxXOffset;
      else if(newPos < minXOffset)
         newPos = minXOffset;
      
      _currentPosition = newPos/_backgroundline.bounds.size.width;
      
      if(_downloadProgress < 1.0) {
         if(_currentPosition > _downloadProgress-0.05f) {
            _currentPosition = _downloadProgress-0.05f;
            if(_currentPosition < 0)
               _currentPosition = 0;
         }
      }
      
      [UIView animateWithDuration:_thumbAnimationDuration delay:0.0
                          options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                       animations:^{
                          [self layoutThumb];
                          [self layoutValueLabels];
                       } completion:^(BOOL finished) {}];
      
      [self updateDurationLabels];
      
      DLog(@"curPos:%f newPos:%f startingPos:%f, _currentPosition%f", movedBy, newPos, startingPos, _currentPosition);
   }
   else {
      [self leavePositionAdjustment];
      
      if(self.delegate && [self.delegate respondsToSelector:@selector(FlowAudioScrubberViewPositionChanged:)]) {
         [self.delegate FlowAudioScrubberViewPositionChanged:self];
      }
   }
}

- (void) enterPositionAdjustment {
   _thumbSelected = YES;
   
   [UIView animateWithDuration:_thumbAnimationDuration delay:0.0
                       options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
     [self layoutThumb];
      [self layoutValueLabels];
   } completion:^(BOOL finished) {}];
   
   _positionLine.backgroundColor = _activeColor;
   _timePlayedLabel.textColor = _activeColor;
   _thumbCircleView.tintColor = _activeColor;
}

- (void) leavePositionAdjustment {
   
   _thumbSelected = NO;
   
   [UIView animateWithDuration:_thumbAnimationDuration delay:0.0
                       options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
      [self layoutThumb];
      [self layoutValueLabels];
  } completion:^(BOOL finished) {}];
   
   _positionLine.backgroundColor = _positionColor;
   _timePlayedLabel.textColor = _labelsColor;
   _thumbCircleView.tintColor = _positionColor;
}

- (CGPoint) scrubberCirclePoistionSelected:(BOOL)selected {
   
   float radius;
   float positionLength;
   
   if(selected)
      radius = _thumbFocusedRadius;
   else
      radius = _thumbUnFocusedRadius;
   
   positionLength = _thumbSize.width-_thumbCirclePadding*2-radius*2;
   
   CGPoint point =  CGPointMake(positionLength*_currentPosition+_thumbCirclePadding, _thumbSize.height/2-radius);
   
   return point;
}

@end
