//
//  WaitBrick.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@class Formula;

@interface Waitbrick : Brick

@property (nonatomic, strong) Formula *timeToWaitInSeconds;

@end