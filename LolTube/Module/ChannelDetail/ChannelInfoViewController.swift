import Foundation

class ChannelInfoViewController: UIViewController {
    
    @IBOutlet fileprivate weak var descriptionTextView:UITextView!
    
    var channelId:String!
    var channelTitle:String!
    var channelDescription:String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName: "Channel Info", viewType: ChannelInfoViewController.self, viewId: channelTitle)

        descriptionTextView.text = channelDescription
    }
}
