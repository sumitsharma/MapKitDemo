//
//  AppDelegate.h
//  MapRouteKP
//
//  Created by Sumit Sharma on 11/12/12.
//  Copyright (c) 2013 Flip Infotech. All rights reserved.
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
