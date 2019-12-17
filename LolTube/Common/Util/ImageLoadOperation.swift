import Foundation
import SDWebImage
import Async

class ImageLoadOperation: ConcurrentOperation {
    
    fileprivate let url:String?
    fileprivate let replaceImageUrl:String?
    fileprivate let completed:(UIImage) -> Void
    
    fileprivate var webImageOperation:SDWebImageOperation?
    fileprivate var replaceImageImageOperation:SDWebImageOperation?
    
    fileprivate lazy var progressBlock: SDWebImageDownloaderProgressBlock = {
        [weak self]_,_  in
        guard let weakSelf = self else {
            return
        }
        if weakSelf.isCancelled {
            weakSelf.webImageOperation?.cancel()
            weakSelf.replaceImageImageOperation?.cancel()
            weakSelf.state = .finished
        }
    }
    
    fileprivate lazy var placeHolderImage:UIImage = {
        return UIImage.defaultImage
        }()
    
    init(url:String?,replaceImageUrl:String? = nil,completed:@escaping (UIImage)-> Void) {
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
    
    fileprivate func loadMainImageImage(){
        state = .executing
        guard let url = self.url else {
            self.completeOperation(placeHolderImage)
            return
        }
        
        webImageOperation = loadImage(url){
            [weak self]image in
            if let image = image {
                self?.completeOperation(image)
            } else {
                self?.loadReplaceImage()
            }
        }
        
    }
    
    fileprivate func completeOperation(_ image:UIImage){
        Async.main{
            [weak self] in
            self?.completed(image)
            self?.state = .finished
        }
    }
    
    
    
    fileprivate func loadReplaceImage(){
        guard let replaceImageUrl = replaceImageUrl else {
            completeOperation(placeHolderImage)
            return
        }
        
        replaceImageImageOperation = loadImage(replaceImageUrl){
            [weak self]image in
            guard let weakSelf = self else {
                return
            }
            
            guard let image = image else {
                weakSelf.completeOperation((weakSelf.placeHolderImage))
                return
            }
            
            weakSelf.completeOperation(image)
        }
    }
    
    fileprivate func loadImage(_ url:String,completed:@escaping (UIImage?) -> Void) -> SDWebImageOperation? {
        if isCancelled {
            state = .finished
            return nil
        }
        
        let completedBlock: SDWebImageCompletionWithFinishedBlock = {
            [weak self](image , _ ,_ ,_ ,_ ) in
            guard !(self?.isCancelled ?? false) else {
                self?.state = .finished
                return
            }
            
            completed(image)
        }
        
        return SDWebImageManager.shared().downloadImage(with: URL(string:url), options: SDWebImageOptions(rawValue: 0), progress: progressBlock, completed: completedBlock)
    }
}
