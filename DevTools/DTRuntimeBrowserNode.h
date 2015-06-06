//
//  DTRuntimeBrowserNode.h
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTRuntimeBrowserNode : NSObject  
{
@protected
    DTRuntimeBrowserNode* _parent;
    NSString* _nodeName;
    NSInteger check;
    NSMutableArray* _children;
    BOOL _isLeaf;
}

@property (nonatomic, readwrite, assign) NSInteger check;
@property (nonatomic, copy) NSString* nodeName;
@property (nonatomic, copy) NSMutableArray* children;
@property (nonatomic, assign) DTRuntimeBrowserNode* parent;
@property (nonatomic, assign) BOOL isLeaf;

- (id) initWithNodeName: (NSString*) aNodeName;
- (id) initGroup;
- (id) initLeaf;

@end
