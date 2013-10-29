//
//  ViewController.m
//  MapRouteKP
//
//  Created by kushal on 11/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MapDirectionsViewController.h"
@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - tool and navigation bar button click method

- (void)addRow:(id)sender {
	[wayPointFields addObject:[[UITextField alloc] initWithFrame:CGRectMake(66.0f, 11.0f, 236.0f, 22.0f)] ];
	[theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[wayPointFields count] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    
    removeButton.enabled = YES;
}

- (void)removeRow:(id)sender {
	if ([wayPointFields count] <= 0) {
		return;
	}
	[wayPointFields removeLastObject];
	[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[wayPointFields count] + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    
    if ([wayPointFields count] == 0) {
        removeButton.enabled = NO;
    }
}
- (void)done:(id)sender {
	if ([startField canResignFirstResponder]) {
		[startField resignFirstResponder];
	}
	if ([endField canResignFirstResponder]) {
		[endField resignFirstResponder];
	}
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    wayPointFields = [[NSMutableArray alloc] init];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ;
	addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addRow:)] ;
	removeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"remove.png"] style:UIBarButtonItemStylePlain target:self action:@selector(removeRow:)] ;
    removeButton.enabled = NO;
	self.toolbarItems = [NSArray arrayWithObjects:space, addButton, removeButton, nil];
	[self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title=@"Map Direction";
    [[self navigationController ]setToolbarHidden:NO];
//    [self.navigationController.toolbar setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
									initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] ;
	[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag==5000) {
        strSource=textField.text;
    }
    if (textField.tag==5001) {
        strDest=textField.text;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if ([textField resignFirstResponder] && textField == startField) {
		[endField becomeFirstResponder];
	}
    
	return YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 2 + [wayPointFields count];
	} else if (section == 1) {
		return 1;
	} else {
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"Directions", nil);
	} else if (section == 1) {
		return NSLocalizedString(@"Travel Mode", nil);
	} else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    
	if (indexPath.section == 0 && indexPath.row == 0) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 13.0f, 40.0f, 20.0f)];
		[cell addSubview:textLabel];

		textLabel.text = NSLocalizedString(@"Start:", nil);
		textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		textLabel.textAlignment = UITextAlignmentRight;
		textLabel.textColor = [UIColor lightGrayColor];
		
		UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(66.0f, 11.0f, 236.0f, 22.0f)];
		inputField.delegate = self;
		[cell addSubview:inputField];

		
		[inputField setBorderStyle:UITextBorderStyleNone];
		[inputField setAdjustsFontSizeToFitWidth:NO];
		[inputField setClearButtonMode:UITextFieldViewModeWhileEditing];
		[inputField setClearsOnBeginEditing:NO];
		[inputField setPlaceholder:nil];
		[inputField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[inputField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[inputField setEnablesReturnKeyAutomatically:YES];
		[inputField setKeyboardType:UIKeyboardTypeDefault];
		[inputField setReturnKeyType:UIReturnKeyNext];
		[inputField setEnablesReturnKeyAutomatically:YES];
		
		[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
		[inputField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		
		[inputField setText:[NSString stringWithUTF8String:"Enter Source"]];
		inputField.tag=5000;
		startField = inputField;
	} else if (indexPath.section == 0 && indexPath.row == 1 + [wayPointFields count]) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 13.0f, 40.0f, 20.0f)];
		[cell addSubview:textLabel];

		textLabel.text = NSLocalizedString(@"End:", nil);
		textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		textLabel.textAlignment = UITextAlignmentRight;
		textLabel.textColor = [UIColor lightGrayColor];
		
		UITextField *inputField = [[UITextField alloc] initWithFrame:CGRectMake(66.0f, 11.0f, 236.0f, 22.0f)];
		inputField.delegate = self;
		[cell addSubview:inputField];

		
		[inputField setBorderStyle:UITextBorderStyleNone];
		[inputField setAdjustsFontSizeToFitWidth:NO];
		[inputField setClearButtonMode:UITextFieldViewModeWhileEditing];
		[inputField setClearsOnBeginEditing:NO];
		[inputField setPlaceholder:nil];
		[inputField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[inputField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[inputField setEnablesReturnKeyAutomatically:YES];
		[inputField setKeyboardType:UIKeyboardTypeDefault];
		[inputField setReturnKeyType:UIReturnKeyDone];
		[inputField setEnablesReturnKeyAutomatically:YES];
		
		[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
		[inputField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		
		[inputField setText:[NSString stringWithUTF8String:"Enter destination"]];
		inputField.tag=5001;
		endField = inputField;
	} else if (indexPath.section == 0) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 13.0f, 40.0f, 20.0f)];
		[cell addSubview:textLabel];

		textLabel.text = NSLocalizedString(@"via:", nil);
		textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		textLabel.textAlignment = UITextAlignmentRight;
		textLabel.textColor = [UIColor lightGrayColor];
		
		UITextField *inputField = [wayPointFields objectAtIndex:indexPath.row - 1];
		inputField.delegate = self;
		[cell addSubview:inputField];
		
		[inputField setBorderStyle:UITextBorderStyleNone];
		[inputField setAdjustsFontSizeToFitWidth:NO];
		[inputField setClearButtonMode:UITextFieldViewModeWhileEditing];
		[inputField setClearsOnBeginEditing:NO];
		[inputField setPlaceholder:nil];
		[inputField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[inputField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[inputField setEnablesReturnKeyAutomatically:YES];
		[inputField setKeyboardType:UIKeyboardTypeDefault];
		[inputField setReturnKeyType:UIReturnKeyDone];
		[inputField setEnablesReturnKeyAutomatically:YES];
		
		[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
		[inputField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	} else if (indexPath.section == 1 && indexPath.row == 0) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		travelModeSegment = [[UISegmentedControl alloc] initWithItems:
							 [NSArray arrayWithObjects:NSLocalizedString(@"Driving", nil), 
							  /*NSLocalizedString(@"Train", nil), */
							  NSLocalizedString(@"Walking", nil), nil]];
		[travelModeSegment setFrame:CGRectMake(9.0f, 0.0f, 302.0f, 45.0f)];
		travelModeSegment.selectedSegmentIndex = 0;
		[cell addSubview:travelModeSegment];

	} else {
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.text = NSLocalizedString(@"Search", nil);
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor colorWithRed:0.20f green:0.30f blue:0.49f alpha:1.0f];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2 && indexPath.row == 0) {
		MapDirectionsViewController *controller = [[MapDirectionsViewController alloc] init];
		
		controller.startPoint = strSource;
		controller.endPoint = strDest;
		NSMutableArray *wayPoints = [NSMutableArray arrayWithCapacity:[wayPointFields count]];
		for (UITextField *pointField in wayPointFields) {
            if ([pointField.text length] > 0) {
                [wayPoints addObject:pointField.text];
            }
		}
		controller.wayPoints = wayPoints;
		
		if (travelModeSegment.selectedSegmentIndex == 0) {
			controller.travelMode = UICGTravelModeDriving;
		} else {
			controller.travelMode = UICGTravelModeWalking;
		}
		
		[self.navigationController pushViewController:controller animated:YES];

		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}



@end
