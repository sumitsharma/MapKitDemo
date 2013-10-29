//
//  AppDelegate.h
//  MapRouteKP
//
//  Created by Sumit Sharma on 11/12/12.
//  Copyright (c) 2013 Flip Infotech. All rights reserved.
//
@interface UITextView(HTML)
- (void)setContentToHTMLString:(id)fp8;
@end
#import "MapDirectionsViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)
#define kBaseUrl @"http://maps.googleapis.com/maps/api/directions/json?"
@implementation MapDirectionsViewController
@synthesize theMapView;
@synthesize startPoint=_startPoint;
@synthesize endPoint = _endPoint;
@synthesize wayPoints = _wayPoints;
@synthesize travelMode = _travelMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *currentLocationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reticle.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveToCurrentLocation:)] ;
	
	UIBarButtonItem *routesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showRouteListView:)] ;
	self.toolbarItems = [NSArray arrayWithObjects:currentLocationButton, space, routesButton, nil];
	[self.navigationController setToolbarHidden:NO animated:NO];
    
    dispatch_async(kBgQueue, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *strUrl;
        
        if (_wayPoints.count>0) {
            strUrl= [NSString stringWithFormat:@"%@origin=%@&destination=%@&sensor=true&waypoints=optimize:true",kBaseUrl,_startPoint,_endPoint];
            for (NSString *strViaPoint in _wayPoints) {
                strUrl=[strUrl stringByAppendingFormat:@"|via:%@",strViaPoint];
            }
        }
        else
        {
            strUrl=[NSString stringWithFormat:@"%@origin=%@&destination=%@&sensor=true",kBaseUrl,_startPoint,_endPoint];
        }
        
        if (_travelMode==UICGTravelModeWalking) {
            strUrl=[strUrl stringByAppendingFormat:@"&mode=walking"];
//            strUrl=[NSString stringWithFormat:@"%@origin=%@&destination=%@&sensor=true&mode=walking",kBaseUrl,_startPoint,_endPoint];
        }
        NSLog(@"%@",strUrl);
        strUrl=[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
        
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}
- (void)moveToCurrentLocation:(id)sender 
{
    [theMapView setCenterCoordinate:theMapView.userLocation.coordinate];
}
- (void)showRouteListView:(id)sender 
{
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)] ;
    [self.navigationItem setRightBarButtonItem:btnCancel animated:YES];
    if (!isVisible) {
        tblView = [[UITableView alloc]initWithFrame:theMapView.frame style:UITableViewStyleGrouped];
        self.navigationController.navigationItem.title=@"Driving directions";
        
        
        theMapView.hidden=YES;
        tblView.delegate=self;
        tblView.dataSource=self;
        
        [self.view addSubview:tblView];
        isVisible=YES;
    }
    else
    {
        tblView.hidden=NO;
        theMapView.hidden=YES;
    }
    [tblView reloadData];


}
-(void)onCancel
{
    tblView.hidden=YES;
    theMapView.hidden=NO;
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

#pragma mark - table view data source and delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    else 
        return [[dictRouteInfo objectForKey:@"distance"] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"Driving directions Summary", nil);
	} else 
		return NSLocalizedString(@"Driving directions Detail", nil);
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellIdentifier1=@"cellIdentifire1";
    static NSString *strCellIdentifier2=@"cellIdentifire2";
    
    UITableViewCell *cell =nil;
    if (indexPath.section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier1];
    }
    else if(indexPath.section==1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier2];
    }
    if (cell==nil) {
        if (indexPath.section==0) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier1];
        }
        else
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier2];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (indexPath.section==0&&indexPath.row==0) {
            UILabel *lblSrcDest = [[UILabel alloc]init];
            lblSrcDest.tag=100000;
            
            lblSrcDest.backgroundColor=[UIColor clearColor];
            lblSrcDest.font=[UIFont fontWithName:@"helvetica" size:15];
            lblSrcDest.lineBreakMode=UILineBreakModeWordWrap;

            lblSrcDest.frame=CGRectMake(20, 2, 290, 100);
            lblSrcDest.numberOfLines=5;

            [cell addSubview:lblSrcDest];

        }
        else if(indexPath.section==1)
        {
            UILabel *lblDistance = [[UILabel alloc]initWithFrame:CGRectMake(30, 2, 260, 20)];
            lblDistance.backgroundColor=[UIColor clearColor];
            [cell addSubview:lblDistance];
            lblDistance.tag=1;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 30.0f, 280.0f, 56.0f)];
            textView.editable = NO;
            textView.scrollEnabled = NO;
            textView.opaque = YES;
            textView.backgroundColor = [UIColor clearColor];
            textView.tag = 2;
            [cell addSubview:textView];
        }
    }
    if (indexPath.section==0&&indexPath.row==0) {
        UILabel *lblSrcDest=(UILabel*)[cell viewWithTag:100000];
        lblSrcDest.text=[NSString stringWithFormat:@"Driving directions from %@ to %@  \ntotal Distace = %@ \ntotal Duration =%@",_startPoint,_endPoint,[dictRouteInfo objectForKey:@"totalDistance"],[dictRouteInfo objectForKey:@"totalDuration"]];

    }
    else if(indexPath.section==1){
        UILabel *lblDist = (UILabel *)[cell viewWithTag:1];
        lblDist.text=[[dictRouteInfo objectForKey:@"distance"]objectAtIndex:indexPath.row];
        UITextView *textView = (UITextView *)[cell viewWithTag:2];
        [textView setContentToHTMLString:[[dictRouteInfo objectForKey:@"description"]objectAtIndex:indexPath.row]];
        
//        NSLog(@"index row==%i ,%@ , %@",indexPath.row,lblDist.text , [[dictRouteInfo objectForKey:@"distance"]objectAtIndex:indexPath.row]);

    }
    
    return cell;
}

#pragma mark - json parser

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    NSArray *arrRouts=[json objectForKey:@"routes"];
    if ([arrRouts isKindOfClass:[NSArray class]]&&arrRouts.count==0) {
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"didn't find direction" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alrt show];
        return; 
    }
    NSArray *arrDistance =[[[json valueForKeyPath:@"routes.legs.steps.distance.text"] objectAtIndex:0]objectAtIndex:0];
    NSString *totalDuration = [[[json valueForKeyPath:@"routes.legs.duration.text"] objectAtIndex:0]objectAtIndex:0];
    NSString *totalDistance = [[[json valueForKeyPath:@"routes.legs.distance.text"] objectAtIndex:0]objectAtIndex:0];
    NSArray *arrDescription =[[[json valueForKeyPath:@"routes.legs.steps.html_instructions"] objectAtIndex:0] objectAtIndex:0];
    dictRouteInfo=[NSDictionary dictionaryWithObjectsAndKeys:totalDistance,@"totalDistance",totalDuration,@"totalDuration",arrDistance ,@"distance",arrDescription,@"description", nil];
    
    NSArray* arrpolyline = [[[json valueForKeyPath:@"routes.legs.steps.polyline.points"] objectAtIndex:0] objectAtIndex:0]; //2
    double srcLat=[[[[json valueForKeyPath:@"routes.legs.start_location.lat"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    double srcLong=[[[[json valueForKeyPath:@"routes.legs.start_location.lng"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    double destLat=[[[[json valueForKeyPath:@"routes.legs.end_location.lat"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    double destLong=[[[[json valueForKeyPath:@"routes.legs.end_location.lng"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    CLLocationCoordinate2D sourceCordinate = CLLocationCoordinate2DMake(srcLat, srcLong);
    CLLocationCoordinate2D destCordinate = CLLocationCoordinate2DMake(destLat, destLong);
   
    [self addAnnotationSrcAndDestination:sourceCordinate :destCordinate];
//    NSArray *steps=[[aary objectAtIndex:0]valueForKey:@"steps"];   
    
//    replace lines with this may work
    
    NSMutableArray *polyLinesArray =[[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i = 0; i < [arrpolyline count]; i++)
    {
        NSString* encodedPoints = [arrpolyline objectAtIndex:i] ;
        MKPolyline *route = [self polylineWithEncodedString:encodedPoints];
        [polyLinesArray addObject:route];
    }
    
    [theMapView addOverlays:polyLinesArray];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - add annotation on source and destination

-(void)addAnnotationSrcAndDestination :(CLLocationCoordinate2D )srcCord :(CLLocationCoordinate2D)destCord
{
    MKPointAnnotation *sourceAnnotation = [[MKPointAnnotation alloc]init];
    MKPointAnnotation *destAnnotation = [[MKPointAnnotation alloc]init];
    sourceAnnotation.coordinate=srcCord;
    destAnnotation.coordinate=destCord;
    sourceAnnotation.title=_startPoint;
    
    destAnnotation.title=_endPoint;
    
    [theMapView addAnnotation:sourceAnnotation];
    [theMapView addAnnotation:destAnnotation];
    
    MKCoordinateRegion region;
    
    MKCoordinateSpan span;
    span.latitudeDelta=2;
    span.latitudeDelta=2;
    region.center=srcCord;
    region.span=span;
    CLGeocoder *geocoder= [[CLGeocoder alloc]init];
    for (NSString *strVia in _wayPoints) {
        [geocoder geocodeAddressString:strVia completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                CLLocation *location = placemark.location;
//                CLLocationCoordinate2D coordinate = location.coordinate;
                MKPointAnnotation *viaAnnotation = [[MKPointAnnotation alloc]init];
                viaAnnotation.coordinate=location.coordinate;
                [theMapView addAnnotation:viaAnnotation];
//                NSLog(@"%@",placemarks);
            }
            
        }];
    }
    
    theMapView.region=region;
}

#pragma mark - decode map polyline

- (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}
#pragma mark - map overlay 
- (MKOverlayView *)mapView:(MKMapView *)mapView
            viewForOverlay:(id<MKOverlay>)overlay {

    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithOverlay:overlay];
    overlayView.lineWidth = 2;
    overlayView.strokeColor = [UIColor purpleColor];
    overlayView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1f];
    return overlayView;
    
}

#pragma mark - map annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation==theMapView.userLocation) {
        return nil;
    }
    static NSString *annotaionIdentifier=@"annotationIdentifier";
    MKPinAnnotationView *aView=(MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotaionIdentifier ];
    if (aView==nil) {
        
        aView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotaionIdentifier];
        aView.pinColor = MKPinAnnotationColorRed;
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //        aView.image=[UIImage imageNamed:@"arrow"];
        aView.animatesDrop=TRUE;
        aView.canShowCallout = YES;
        aView.calloutOffset = CGPointMake(-5, 5);
    }
	
	return aView;
}
- (void)viewDidUnload
{
    [self setTheMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
