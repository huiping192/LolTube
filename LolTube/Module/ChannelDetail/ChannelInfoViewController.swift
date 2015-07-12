import Foundation

class ChannelInfoViewController: UIViewController {
    
    @IBOutlet private weak var descriptionTextView:UITextView!
    
    var channelDescription:String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        descriptionTextView.text = channelDescription
    }
}