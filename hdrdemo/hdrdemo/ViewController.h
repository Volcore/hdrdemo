//
//  ViewController.h
//  hdrdemo
//
//  Created by Volker Schoenefeld on 8/8/11.
//  Copyright (c) 2011 Volker Schoenefeld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#define HISTOGRAM_SIZE 256

@interface ViewController : GLKViewController {
 @private
  IBOutlet UISwitch *_hdrButton;
  // Histogram stuff
  IBOutlet UISwitch *_histogramButton;
  IBOutlet UIView *_histogramView;
  IBOutlet UILabel *_histogramMin;
  IBOutlet UILabel *_histogramMax;
  IBOutlet UILabel *_histogramBinMax;
  IBOutlet UILabel *_histogramUpperBound;
  IBOutlet UISwitch *_filterTextures;
  IBOutlet UISlider *_scaleSlider;
  IBOutlet UISlider *_biasSlider;
  IBOutlet UISwitch *_linearSwitch;
}

- (IBAction) toggleHDR;
- (IBAction) toggleHistogram;
- (IBAction) toggleFilterTextures;
@end
