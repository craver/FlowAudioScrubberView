//
//  FlowAudioScrubberView.h
//  iFiles
//
//  Created by Tom on 11/14/16.
//  Copyright © 2016 Tom Biel, Inc. All rights reserved.
//

@import UIKit;

@class FlowAudioScrubberView;

@protocol FlowAudioScrubberViewDelegate <NSObject>
@required
- (void) FlowAudioScrubberViewPositionChanged:(nonnull FlowAudioScrubberView*)audioBar;
@end

@interface FlowAudioScrubberView : UIView
@property(assign, nonatomic) float progress;
@property(assign, nonatomic) float downloadProgress;
@property(assign, nonatomic) float duration;
@property(weak, nullable, nonatomic) id<FlowAudioScrubberViewDelegate> delegate;

@property(strong, nonnull, nonatomic) UIColor *activeColor;
@property(strong, nonnull, nonatomic) UIColor *labelsColor;
@property(strong, nonnull, nonatomic) UIColor *positionColor;
@property(strong, nonnull, nonatomic) UIColor *backgroundLineColor;
@property(strong, nonnull, nonatomic) UIColor *downloadLineColor;
@end
