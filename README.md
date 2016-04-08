# EtsyClient

Welcome to my EtsyClient.  This app pulls listing from the Etsy listings API and displays them in a tableview. Additionally, it supports search and unlimitted scroll.

## Optimizations

- Debounce: Search results are debounced to prevent user's typing from sending multiple requests to the backend.  Additionally, all searches are performed on a serial queue.  In the event that multiple searches get passed the debounce, old queued searches are canceled.

  An interesting approach was taken to make each search run serially.  By default, NSOperationQueues don't support serial asynchronous operations.  To solve this, I used a semaphore to block the NSOperationQueue until each search operation completed asynchronously.  

  Another means of solving this would be to subclass NSOperation into RDAsynchronousOperation.  This async operation could track the progress of a block and set the operation's state to finished when the asynchronous block completes.

- Image Caching: Each tableview cell shows an image.  Image urls are returned from the API for each record.  As each row appears on the table, `RDEtsyListingTableViewController` utilized `RDThumbnailImageCache` to retrieve and cache remote images.  If a remote image has been cached, it is reused.  If a cached version is not found, it is downloaded from the remote and cached.

## Implementation details due to time constraints

- NSLog: I wouldn't use NSLog in a production app.  A better approach would be to use a logger that doesn't execute log statements when a build is in `Release` mode.  [XCGLogger](https://github.com/DaveWoodCom/XCGLogge) comes to mind as one logger that solves this well.

- RDEtsySearchResultItem: this model only stores fields needed to complete this assignment.  Depending on requirements, it may be nice to extract additional fields from the API.  Additionally, `RDEtsySearchResultItem` defines a property `imageURL`.  The API returns multiple images but only one imageURL is extracted.  This could be changed if multiple images were required.

- Some unit tests actually hit the internet for test data.  If more time allotted, something like [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) could be utilized to mock the web requests.  This makes tests both run faster and more reliably.

- The initial loading state of the table is empty.  It would be nice to have some design shown when their has not yet been data loaded.

- There are no spinners on the tableView. Depending on network lag, it would be nice to see a spinner whenever the user has submitted a search and is no longer typing.  I normally manage this with a state machine.  When states change, the UI updates to hide/show spinners.
