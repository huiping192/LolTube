import Foundation

class ChannelInfoViewController: UIViewController {
    
    @IBOutlet private weak var descriptionTextView:UITextView!
    
    var channelId:String!
    var channelTitle:String!
    var channelDescription:String!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName: "Channel Info", viewType: ChannelInfoViewController.self, viewId: channelTitle)

        descriptionTextView.text = channelDescription
    }
}