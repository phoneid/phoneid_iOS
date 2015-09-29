//
//  WebImageView.swift
//  Pods
//
//  Created by Alyona on 9/28/15.
//
//

import UIKit

class WebImageView: UIImageView {
    
    var activityIndicator:UIActivityIndicatorView!
    
    init(){
       super.init(frame:CGRectZero)
       setupSubviews()
    }
    
    override init(frame:CGRect)
    {
        super.init(frame:frame)
        setupSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupSubviews()
    }
    
    func setupSubviews(){
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant:0))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant:0))
    }
    
    func getDataFromUrl(url:String, completion: ((data: NSData?) -> Void)) {
        let urlSession = PhoneIdService.sharedInstance.urlSession
        
        urlSession.dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
            completion(data: data != nil ? NSData(data: data!) : nil )
        }.resume()
    }
    
    func downloadImage(url:String?){
        
        guard url != nil else {
            return
        }
        self.activityIndicator.startAnimating()
        getDataFromUrl(url!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                self.image = UIImage(data: data!)
            }
        }
    }

}
