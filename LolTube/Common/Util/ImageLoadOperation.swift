import Foundation
import SDWebImage

class ImageLoadOperation: ConcurrentOperation {
    
    private let url:String
    private let replaceImageUrl:String?
    private let completed:UIImage -> Void
    
    private var webImageOperation:SDWebImageOperation?
    private var replaceImageImageOperation:SDWebImageOperation?
    
    private lazy var progressBlock: SDWebImageDownloaderProgressBlock = {
        [unowned self]_ in
        if self.cancelled {
            self.webImageOperation?.cancel()
            self.replaceImageImageOperation?.cancel()
            self.state = .Finished
        }
    }
    
    private lazy var placeHolderImage:UIImage = {
        return UIImage(named: "DefaultThumbnail")!
        }()
    
    init(url:String,replaceImageUrl:String? = nil,completed:(UIImage)-> Void) {
        self.url = url
        self.replaceImageUrl = replaceImageUrl
        self.completed = completed
    }
    
    deinit{
        webImageOperation?.cancel()
        replaceImageImageOperation?.cancel()
    }
    
    override func start() {
        loadMainImageImage()
    }
    
    override func cancel() {
        super.cancel()
        
        webImageOperation?.cancel()
        replaceImageImageOperation?.cancel()
    }
    
    private func loadMainImageImage(){
        state = .Executing
        webImageOperation = loadImage(url){
            [unowned self]image in
            if let image = image {
                self.completeOperation(image)
            } else {
                self.loadReplaceImage()
            }
        }
        
    }
    
    private func completeOperation(image:UIImage){
        completed(image)
        state = .Finished
    }
    
    
    
    private func loadReplaceImage(){
        guard let replaceImageUrl = replaceImageUrl else {
            completeOperation(placeHolderImage)
            return
        }
        
        replaceImageImageOperation = loadImage(replaceImageUrl){
            [unowned self]image in
            
            guard let image = image else {
                self.completeOperation(self.placeHolderImage)
                return
            }
            
            self.completeOperation(image)
        }
    }
    
    private func loadImage(url:String,completed:UIImage? -> Void) -> SDWebImageOperation? {
        if cancelled {
            state = .Finished
            return nil
        }
        
        let completedBlock: SDWebImageCompletionWithFinishedBlock = {
            [unowned self](image , _ ,_ ,_ ,_ ) in
            guard !self.cancelled else {
                self.state = .Finished
                return
            }
            
            completed(image)
        }
        
        return SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:url), options: SDWebImageOptions(rawValue: 0), progress: progressBlock, completed: completedBlock)
    }
}