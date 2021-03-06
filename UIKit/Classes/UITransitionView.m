/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UITransitionView.h"

@implementation UITransitionView
@synthesize view=_view, transition=_transition, delegate=_delegate;

- (id)initWithFrame:(CGRect)frame view:(UIView *)aView
{
    if ((self=[super initWithFrame:frame])) {
        self.view = aView;
    }
    return self;
}

- (void)dealloc
{
    [_view release];
    [super dealloc];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _view.frame = self.bounds;
}

- (CGRect)_rectForIncomingView
{
    switch (_transition) {
        case UITransitionPushRight:
        case UITransitionFromLeft:		return CGRectOffset(self.bounds,-self.bounds.size.width,0);
        case UITransitionPushLeft:
        case UITransitionFromRight:		return CGRectOffset(self.bounds,self.bounds.size.width,0);
        case UITransitionPushDown:
        case UITransitionFromTop:		return CGRectOffset(self.bounds,0,-self.bounds.size.height);
        case UITransitionPushUp:
        case UITransitionFromBottom:	return CGRectOffset(self.bounds,0,self.bounds.size.height);
        default:						return self.bounds;
    }
}

- (CGRect)_rectForOutgoingView
{
    switch (_transition) {
        case UITransitionPushLeft:		return CGRectOffset(self.bounds,-self.bounds.size.width,0);
        case UITransitionPushRight:		return CGRectOffset(self.bounds,self.bounds.size.width,0);
        case UITransitionPushDown:		return CGRectOffset(self.bounds,0,self.bounds.size.height);
        case UITransitionPushUp:		return CGRectOffset(self.bounds,0,-self.bounds.size.height);
        default:						return self.bounds;
    }
}

- (void)setView:(UIView *)view
{
    if (view != _view) {
        view.frame = [self _rectForIncomingView];
        [self addSubview:view];

        if (_transition == UITransitionFadeOut) {
            [self sendSubviewToBack:view];
        } else if (_transition == UITransitionFadeIn) {
            view.alpha = 0;
        }
        
        [UIView animateWithDuration:0.33 
            animations:^{
                if (_transition != UITransitionNone) {
                    _view.frame = [self _rectForOutgoingView];
                    view.frame = self.bounds;
                    
                    if (_transition == UITransitionFadeOut || _transition == UITransitionCrossFade) {
                        _view.alpha = 0;
                    }
                    
                    if (_transition == UITransitionFadeIn || _transition == UITransitionCrossFade) {
                        view.alpha = 1;
                    }
                }
            }

            completion:^(BOOL finished){
                [_view removeFromSuperview];
                [_delegate transitionView:self didTransitionFromView:_view toView:view withTransition:_transition];
            }
        ];
        
        [_view release], _view = [view retain];
    }
}

@end
