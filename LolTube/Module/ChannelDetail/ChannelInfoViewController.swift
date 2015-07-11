import Foundation

class ChannelInfoViewController: UIViewController {
    
    @IBOutlet private weak var descriptionTextView:UITextView!
    
    var channelDescription:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = channelDescription
    }
}