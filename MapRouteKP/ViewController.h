//
//  ViewController.h
//  MapRouteKP
//
//  Created by kushal on 11/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate ,UITableViewDelegate,UITableViewDataSource>
{
    UITextField *startField;
	UITextField *endField;
	NSMutableArray *wayPointFields;
	UISegmentedControl *travelModeSegment;
    UIBarButtonItem *addButton;
    UIBarButtonItem *removeButton;
    NSString *strSource,*strDest;
    IBOutlet UITableView *theTableView;
}
@end
