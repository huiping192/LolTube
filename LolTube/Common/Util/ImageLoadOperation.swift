import Foundation
import SDWebImage
import AsyncSwift

class ImageLoadOperation: ConcurrentOperation {
    
    private let url:String?
    private let replaceImageUrl:String?
    private let completed:UIImage -> Void
    
    private var webImageOperation:SDWebImageOperation?
    private var replaceImageImageOperation:SDWebImageOperation?
    
    private lazy var progressBlock: SDWebImageDownloaderProgressBlock = {
        [weak self]_ in
        guard let weakSelf = self else {
            return
        }
        if weakSelf.cancelled {
            weakSelf.webImageOperation?.cancel()
            weakSelf.replaceImageImageOperation?.cancel()
            weakSelf.state = .Finished
        }
    }
    
    private lazy var placeHolderImage:UIImage = {
        return UIImage.defaultImage
        }()
    
    init(url:String?,replaceImageUrl:String? = nil,completed:(UIImage)-> Void) {
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
    
    private func completeOperation(image:UIImage){
        Async.main{
            [weak self] in
            self?.completed(image)
            self?.state = .Finished
        }
    }
    
    
    
    private func loadReplaceImage(){
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
    
    private func loadImage(url:String,completed:UIImage? -> Void) -> SDWebImageOperation? {
        if cancelled {
            state = .Finished
            return nil
        }
        
        let completedBlock: SDWebImageCompletionWithFinishedBlock = {
            [weak self](image , _ ,_ ,_ ,_ ) in
            guard !(self?.cancelled ?? false) else {
                self?.state = .Finished
                return
            }
            
            completed(image)
        }
        
        return SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:url), options: SDWebImageOptions(rawValue: 0), progress: progressBlock, completed: completedBlock)
    }
}