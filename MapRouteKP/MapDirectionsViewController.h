//
//  AppDelegate.h
//  MapRouteKP
//
//  Created by Sumit Sharma on 11/12/12.
//  Copyright (c) 2013 Flip Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
typedef enum UICGTravelModes {
	UICGTravelModeDriving, // G_TRAVEL_MODE_DRIVING
	UICGTravelModeWalking  // G_TRAVEL_MODE_WALKING
} UICGTravelModes;
@interface MapDirectionsViewController : UIViewController<MKMapViewDelegate ,MKAnnotation ,MKOverlay,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tblView;
    NSDictionary *dictRouteInfo;
    BOOL isVisible;
}
-(MKPolyline *)polylineWithEncodedString:(NSString *)encodedString ;
-(void)addAnnotationSrcAndDestination :(CLLocationCoordinate2D )srcCord :(CLLocationCoordinate2D)destCord;
@property (strong, nonatomic) IBOutlet MKMapView *theMapView;
@property (nonatomic, retain) NSString *startPoint;
@property (nonatomic, retain) NSString *endPoint;
@property (nonatomic, retain) NSArray *wayPoints;
@property (nonatomic) UICGTravelModes travelMode;
@end
