//
//  DTRuntimeBrowserNode.m
//  DevTools
//
//  Created by Sergey Krotkih on 11/23/12.
//  Copyright (c) 2012 Doctormobile. All rights reserved.
//

#import "DTRuntimeBrowserNode.h"
#import "DTConstants.h"

@implementation DTRuntimeBrowserNode

@synthesize nodeName = _nodeName;
@synthesize parent = _parent;
@synthesize check;
@dynamic isLeaf;
@dynamic children;

- (id) initWithNodeName: (NSString*) aNodeName
{
    if (![super init])
    {
        return nil;
    }

    self.nodeName = aNodeName;
    self.check = 0;
    self.isLeaf = NO; // this will also set the children array to [NSArray array].
    self.parent = nil;

    return self;
}

- (id) initGroup
{
    return [self init];
}

- (id) initLeaf
{
    if (![self init])
    {
        return nil;
    }
    self.isLeaf = YES; // this will set the children array to an NSArray containing self.

    return self;
}

- (id) copyWithZone: (NSZone*) zone
{
    DTRuntimeBrowserNode *copy = [[[self class] allocWithZone: zone] init];

    if (!copy)
    {
        return nil;
    }

    copy.nodeName = self.nodeName;
    copy.isLeaf = self.isLeaf;
    copy.check = self.check;

    if (!self.isLeaf)
    {
        copy.children = self.children;
    }

    return copy;
}

-(id) initWithCoder: (NSCoder *) coder
{
    if (![self init])
    {
        return nil;
    }
    
    for (NSString *key in self.keysForEncoding) 
    {
        [self setValue: [coder decodeObjectForKey: key] forKey: key];
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    for (NSString *key in self.keysForEncoding)
    {
        [coder encodeObject: [self valueForKey: key] forKey: key];
    }
}

- (void) setNilValueForKey: (NSString *) key
{
    if ([key isEqualToString: @"isLeaf"])
    {
        self.isLeaf = NO;
    }
    else
    {
        [super setNilValueForKey: key];
    }
}

#pragma mark Properties

- (void) setIsLeaf: (BOOL) flag;
{
    _isLeaf = flag;

    if (_isLeaf)
    {
        self.children = [NSMutableArray arrayWithObject: self];
    }
    else
    {
        self.children = [NSMutableArray array];
    }
}

- (BOOL) isLeaf
{
    return _isLeaf;
}

- (NSMutableArray*) children
{
    return _children;
}

- (void) setChildren: (NSMutableArray*) newChildren
{
    if (_children == newChildren)
    {
        return;
    }

    [_children release];
    _children = [newChildren mutableCopy];
}

#pragma mark -

- (NSUInteger) countOfChildren
{
    if (self.isLeaf)
    {
        return 0;
    }

    return [self.children count];
}

- (void) insertObject: (id)object inChildrenAtIndex: (NSUInteger) index
{
    if (self.isLeaf)
    {
        return;
    }

    [self.children insertObject: object atIndex: index];
}

- (void) removeObjectFromChildrenAtIndex: (NSUInteger) index
{
    if (self.isLeaf)
    {
        return;
    }

    [self.children removeObjectAtIndex: index];
}

- (id) objectInChildrenAtIndex: (NSUInteger) index
{
    if (self.isLeaf)
    {
        return nil;
    }

    return [self.children objectAtIndex: index];
}

- (void)replaceObjectInChildrenAtIndex: (NSUInteger) index withObject: (id) object
{
    if (self.isLeaf)
    {
        return;
    }

    [self.children replaceObjectAtIndex: index withObject: object];
}

- (NSArray*) descendants
{
    NSMutableArray* descendantsArray = [NSMutableArray array];
    
    for (DTRuntimeBrowserNode* node in self.children) 
    {
        [descendantsArray addObject:node];
        if (!node.isLeaf)
        {
            [descendantsArray addObjectsFromArray:[node descendants]];
        }
    }
    
    return [[descendantsArray copy] autorelease]; // return immutable
}

- (NSArray*) leafDescendants
{
    NSMutableArray* leafsArray = [NSMutableArray array];
    
    for (DTRuntimeBrowserNode* node in self.children) 
    {
        if (node.isLeaf)
        {
            [leafsArray addObject:node];
        }
        else
        {
            [leafsArray addObjectsFromArray: [node leafDescendants]];
        }
    }
    
    return [[leafsArray copy] autorelease]; // return immutable
}

- (NSArray*) groupDescendants
{
    NSMutableArray* groupsArray = [NSMutableArray array];
    
    for (DTRuntimeBrowserNode* node in self.children) 
    {
        if (!node.isLeaf) 
        {
            [groupsArray addObject:node];
            [groupsArray addObject:[node groupDescendants]];
        }
    }
    
    return [[groupsArray copy] autorelease]; // return immutable
}

- (NSArray*) keysForEncoding
{
    return [NSArray arrayWithObjects: @"isLeaf", @"children", @"parent", nil];
}

//- (NSArray *)keysForEncoding
//{
//    return [[super keysForEncoding] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"key1",@"key2",@"key3",nil]];
//}

- (void) setCheck: (NSInteger) aCheck
{
    if (check != aCheck) 
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: CheckNodeOnRunTimeBrowserNotificationId 
                                                            object: _nodeName];
        check = aCheck;
    }
}

@end
