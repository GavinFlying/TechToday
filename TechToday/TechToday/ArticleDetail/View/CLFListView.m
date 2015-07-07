//
//  CLFListView.m
//  TechToday
//
//  Created by CaiGavin on 7/7/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#define CLFNumberOfSections (1)
#define CLFNumberOfRowsInSection (2)

#import "CLFListView.h"
#import "CLFCommonHeader.h"

@interface CLFListView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *list;

@end

@implementation CLFListView

- (instancetype)init {
    if (self = [super init]) {
        UITableView *listView = [[UITableView alloc] init];
        listView.backgroundColor = [UIColor whiteColor];
        listView.nightBackgroundColor = CLFNightViewColor;
        [self addSubview:listView];
        self.list = listView;
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(1, 2);
        self.layer.shadowOpacity = 0.6;
        
        self.alpha = 0.95;
    }
    return self;
}

- (void)layoutSubviews {
    self.list.delegate = self;
    self.list.dataSource = self;
    self.list.frame = self.bounds;
    self.list.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.list.contentMode = UIViewContentModeCenter;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return CLFNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CLFNumberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"moreOptions";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"字号调整";
            break;
        }
        case 1: {
            cell.textLabel.text = @"回到顶部";
            break;
        }
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.nightTextColor = CLFNightTextColor;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(self.frame) / CLFNumberOfRowsInSection;
}

@end
