//
//  ObjectWithMethodsViewController.m
//  RuntimeBrowser
//
//  Created by Nicolas Seriot on 11.06.09.
//  Copyright 2009 Sen:te. All rights reserved.
//

#import "ObjectWithMethodsViewController.h"
#import "ClassDisplay.h"
#import "MethodCell.h"

static ObjectWithMethodsViewController* _sharedInstance; 

@implementation ObjectWithMethodsViewController

@dynamic object;
@synthesize methods;

+ (ObjectWithMethodsViewController*) sharedInstance
{
    if (_sharedInstance == nil) 
    {
		_sharedInstance = [[ObjectWithMethodsViewController alloc] initWithNibName: @"ObjectsTableViewController"
                                                                            bundle: gDevToolsClientResBundle];
    }
    
    return _sharedInstance;
}

- (void)dealloc 
{
	[object release];
	[methods release];
    [super dealloc];
}

- (void)setObject: (id)o 
{
	@try
    {
        NSLog(@"-- setObject: %@", [o description]);
	}
    @catch (NSException* e)
    {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle: [e name]
														message: [e reason]
													   delegate: nil
											  cancelButtonTitle: @"OK"
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
    @finally
    {
        return;
	}
	
	[object autorelease];
	[o retain];
	object = o;
	
	self.methods = [[NSArray array] mutableCopy];
	[self.tableView reloadData];

	if(object == nil) 
        return;
	
	@try 
    {
		NSArray* m = nil;
	
		ClassDisplay* cd = [ClassDisplay createForClass: [object class]];

		if(object == [object class]) 
        {
			m = [cd methodLinesWithSign: '+'];
		} 
        else 
        {
			m = [cd methodLinesWithSign: '-'];
		}
		
		self.methods = [NSMutableArray arrayWithArray: [[m lastObject] componentsSeparatedByString: @"\n"]];
		
		if ([[methods lastObject] isEqualToString: @""]) 
        {
			[methods removeObjectAtIndex:[methods count]-1];
		}		
	} 
    @catch (NSException * e) 
    {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle: [e name]
														message: [e reason]
													   delegate: nil 
											  cancelButtonTitle: @"OK"
											  otherButtonTitles: nil]; 
		[alert show]; 
		[alert release];
	} 
    @finally 
    {
		[self.tableView reloadData];
	}

	self.title = [object description];	
}

- (id)object 
{
	return object;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section 
{
	return [methods count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath 
{
	
	static NSString* CellIdentifier = @"MethodCell";
	
	MethodCell* cell = (MethodCell *)[tableView dequeueReusableCellWithIdentifier: CellIdentifier];
	if(cell == nil) 
    {
		[MethodCell class];
        
        cell = (MethodCell *)[[gDevToolsClientResBundle loadNibNamed: @"MethodCell"
                                                               owner: self 
                                                             options: nil] lastObject];
	}
	
	// Set up the cell
	NSString* method = [methods objectAtIndex: indexPath.row];
	cell.textLabel.text = [method substringToIndex: [method length]-1]; // remove terminating ';'
	BOOL hasParameters = [method rangeOfString: @":"].location != NSNotFound;
    if (hasParameters == YES) 
    {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else 
    {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
	
	if(indexPath.row > ([methods count]-1) ) 
        return;
	
	NSString *method = [methods objectAtIndex: indexPath.row];

	BOOL hasParameters = [method rangeOfString: @":"].location != NSNotFound;

	if(hasParameters) 
        return;
	
	NSRange range = [method rangeOfString: @")"]; // return type
	
	if(range.location == NSNotFound) 
        return;
	
	NSString *t = [method substringWithRange:NSMakeRange(3, range.location-3)];
	
	range = NSMakeRange(range.location+1, [method length]-range.location-2);
	
	method = [method substringWithRange:range];
	
	if([method isEqualToString: @"dealloc"]) 
    {
		[self.navigationController popViewControllerAnimated:YES];
	}

	ObjectWithMethodsViewController* ovc = [[ObjectWithMethodsViewController alloc] init];
	
	SEL selector = NSSelectorFromString(method);
	
	if(![object respondsToSelector:selector]) 
    {
		return;
	}
		
	if([t hasPrefix: @"struct"]) 
        return;

	id o = nil;
	
	@try 
    {
		o = [object performSelector:selector];
	} 
    @catch (NSException * e) 
    {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[e name]
														message:[e reason]
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil]; 
		[alert show]; 
		[alert release];
	} 
    @finally 
    {
		
	}

	if ([t isEqualToString: @"void"]) 
        return;
	
	if(![t isEqualToString: @"id"]) 
    {
		if([t isEqualToString: @"NSInteger"] || [t hasSuffix: @"int"])
        {
			o = [NSString stringWithFormat: @"%d", [o intValue]];
		}
		else if([t isEqualToString: @"NSUInteger"])
        {
			o = [NSString stringWithFormat: @"%d", [o intValue]];
		} 
        else if([t isEqualToString: @"double"] || [t isEqualToString: @"float"]) 
        {
			o = [NSString stringWithFormat: @"%f", [o floatValue]];
		} 
        else if([t isEqualToString: @"BOOL"]) 
        {
			o = o ? @"YES" : @"NO";			
		} 
        else 
        {
			o = [NSString stringWithFormat: @"%d", [o intValue]]; // default
		}
	}		
	
	if([o isKindOfClass: [NSString class]] || 
       [o isKindOfClass: [NSArray class]] || 
       [o isKindOfClass: [NSDictionary class]] || 
       [o isKindOfClass: [NSSet class]]) 
    {
		NSLog(@"-- %@", o);
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" 
														message: [o description] 
													   delegate: nil 
											  cancelButtonTitle: @"OK" 
											  otherButtonTitles: nil]; 
		[alert show]; 
		[alert release]; 
		
		return;
	}
	
	ovc.object = o;
	
	[self.navigationController pushViewController: ovc animated: YES];
	[ovc release];
}

@end
