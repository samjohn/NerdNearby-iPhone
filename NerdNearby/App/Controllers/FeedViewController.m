#import "FeedViewController.h"
#import "App.h"
#import "NerdAgent.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface FeedViewController (PrivateInterface)

- (void)startLocationUpdates;

@end

@implementation FeedViewController

@synthesize locationManager = locationManager_;

- (void)dealloc {
    [self setLocationManager:nil];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"Nerd Nearby"];
    }
    return self;
}

#pragma mark - Notification handling

- (void)itemsReceived:(NSNotification *)notification {
    UITableView *tableView = (UITableView *)[self view];
    [tableView reloadData];

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger index = [indexPath row];
    NerdAgent *agent = [[App sharedInstance] nerdAgent];
    NSDictionary *item = [[agent JSONArray] objectAtIndex:index];
    
    NSString *captionText = [item objectForKey:@"text"];
    NSString *nameText = [item objectForKey:@"name"];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:18.f];
    
    CGSize captionSize = [captionText sizeWithFont:font constrainedToSize:CGSizeMake(300.f, 240.f) lineBreakMode:UILineBreakModeWordWrap];
    CGSize nameSize = [nameText sizeWithFont:font constrainedToSize:CGSizeMake(300.f, 240.f) lineBreakMode:UILineBreakModeWordWrap];
    float titleHeight;
    if (nameSize.height > 36.f) {
        titleHeight = nameSize.height;
    } else {
        titleHeight = 36.f;
    }

    
    if ([[item objectForKey:@"feed_item_type"] isEqualToString:@"tweet"]) {
        return 10.f + 48.f + captionSize.height + 10.f;
    } else if ([[item objectForKey:@"feed_item_type"] isEqualToString:@"foursquare"]) {
        return 10.f + captionSize.height + titleHeight + 10.f;
    } else if ([[item objectForKey:@"feed_item_type"] isEqualToString:@"instagram"] || [[item objectForKey:@"feed_item_type"] isEqualToString:@"flickr"]) {
        return 10.f + 320.f + captionSize.height + titleHeight + 10.f;        
    }else {
        return 10.f + 320.f + captionSize.height + nameSize.height + 10.f;
    }
}

#pragma mark - UITableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [indexPath row];
    NerdAgent *agent = [[App sharedInstance] nerdAgent];
    NSDictionary *item = [[agent JSONArray] objectAtIndex:index];
    NSString *cellIdentifier = @"NerdCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    UIImageView *imageView;
    UIImageView *iconView;
    UILabel *captionView;
    UILabel *titleView;

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];

        imageView = [[[UIImageView alloc] init] autorelease];
        imageView.tag = kImageViewTag;
        [cell.contentView addSubview:imageView];
        
        iconView = [[[UIImageView alloc] init] autorelease];
        iconView.tag = kIconViewTag;
        [cell.contentView addSubview:iconView];

        titleView = [[[UILabel alloc] init] autorelease];
        titleView.tag = kTitleViewTag;
        titleView.lineBreakMode = UILineBreakModeWordWrap;
        titleView.numberOfLines = 0;
        titleView.font = [UIFont fontWithName:@"Helvetica" size:18.f];

        [cell.contentView addSubview:titleView];

        captionView = [[[UILabel alloc] init] autorelease];
        captionView.tag = kCaptionViewTag;
        captionView.lineBreakMode = UILineBreakModeWordWrap;
        captionView.numberOfLines = 0;
        captionView.font = [UIFont fontWithName:@"Helvetica" size:18.f];
        [cell.contentView addSubview:captionView];
    } else {
        iconView = (UIImageView *)[cell.contentView viewWithTag:kIconViewTag];
        imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
        captionView = (UILabel *)[cell.contentView viewWithTag:kCaptionViewTag];
        titleView = (UILabel *)[cell.contentView viewWithTag:kTitleViewTag];
    }

    CGRect imageViewFrame;
    CGRect captionViewFrame;
    CGRect titleViewFrame;
    CGRect iconViewFrame;

    NSString *captionText = [item objectForKey:@"text"];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:18.f];
    CGSize captionSize = [captionText sizeWithFont:font constrainedToSize:CGSizeMake(300.f, 240.f) lineBreakMode:UILineBreakModeWordWrap];
    NSString *feedItemType = [item objectForKey:@"feed_item_type"];
    NSString *titleText = @"";

    if ([feedItemType isEqualToString:@"tweet"]) {
        iconViewFrame = CGRectMake(0.f, 0.f, 0.f, 0.f);
        imageViewFrame = CGRectMake(10.f, 0.f, 48.f, 48.f);
        captionViewFrame.origin = CGPointMake(10.f, 48.f + 12.f);
        captionViewFrame.size = captionSize;
        titleViewFrame = CGRectMake(48.f + 10.f + 10.f, 0.f, 320.f - 40.f - 10.f - 10.f - 10.f, 48.f);
        titleText = [item objectForKey:@"user"];
    } else if ([feedItemType isEqualToString:@"foursquare"]) {
        imageViewFrame = CGRectMake(0.f, 0.f, 0.f, 0.f);
        iconViewFrame = CGRectMake(0.f, 10.f, 26.f, 26.f);
        titleText = [item objectForKey:@"name"];
        CGSize titleSize = [titleText sizeWithFont:font constrainedToSize:CGSizeMake(300.f, 240.f) lineBreakMode:UILineBreakModeWordWrap];
        titleViewFrame.origin = CGPointMake(36.f, 10.f);
        titleViewFrame.size = titleSize;
        float titleHeight;
        if (titleSize.height > 36.f) {
            titleHeight = titleSize.height;
        } else {
            titleHeight = 36.f;
        }
        captionViewFrame.origin = CGPointMake(10.f, 10.f + titleHeight);
        captionViewFrame.size = captionSize;
    } else {
        float titleOrigin;
        if ([feedItemType isEqualToString:@"instagram"] || [feedItemType isEqualToString:@"flickr"]) {
            titleOrigin = 36.f;
            iconViewFrame = CGRectMake(0.f, 10.f, 26.f, 26.f);
            titleViewFrame.origin = CGPointMake(titleOrigin, 10.f);
        }else {
            titleOrigin = 10.f;
            iconViewFrame = CGRectMake(0.f, 0.f, 0.f, 0.f);            
            titleViewFrame.origin = CGPointMake(titleOrigin, 10.f);
        }
        titleText = [item objectForKey:@"name"];
        CGSize titleSize = [titleText sizeWithFont:font constrainedToSize:CGSizeMake(300.f, 240.f) lineBreakMode:UILineBreakModeWordWrap];
        titleViewFrame.size = titleSize;
        imageViewFrame = CGRectMake(0.f, titleOrigin + 10.f, 320.f, 320.f);
        captionViewFrame.origin = CGPointMake(10.f, titleOrigin + 10.f + 320.f);
        captionViewFrame.size = captionSize;
    }

    iconView.frame = iconViewFrame;
    imageView.frame = imageViewFrame;
    captionView.frame = captionViewFrame;
    titleView.frame = titleViewFrame;
    NSURL *imageURL = [NSURL URLWithString:[item objectForKey:@"image_tag"]];
    if ([feedItemType isEqualToString:@"foursquare"]) {
        [iconView setImage:[UIImage imageNamed:@"foursquarefavicon.png"]];        
    } else if ([feedItemType isEqualToString:@"instagram"]) {
        [iconView setImage:[UIImage imageNamed:@"instagramfavicon.png"]];                
    } else if ([feedItemType isEqualToString:@"flickr"]) {
        [iconView setImage:[UIImage imageNamed:@"flickrfavicon.png"]];
    }else {
        [iconView setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil];
    }
    [imageView setImageWithURL:imageURL placeholderImage:nil];
    [captionView setText:captionText];
    [titleView setText:titleText];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[[App sharedInstance] nerdAgent] JSONArray] count];
}

#pragma mark - View lifecycle

- (void)loadView {
    UITableView *tableView = [[[UITableView alloc] init] autorelease];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.allowsSelection = NO;
    self.view = tableView;
}

- (void)viewDidLoad {
    [self startLocationUpdates];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemsReceived:) name:@"ItemsReceived" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (oldLocation == nil) {
        [[[App sharedInstance] nerdAgent] fetchWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    }
}

#pragma mark -
#pragma mark - Private methods

- (void)startLocationUpdates {
    if (nil == [self locationManager]) {
        [self setLocationManager:[[[CLLocationManager alloc] init] autorelease]];
    }

    [[self locationManager] setDelegate:self];
    [[self locationManager] startUpdatingLocation];
}

@end
