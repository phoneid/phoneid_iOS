//
//  WebImageView.swift
//  phoneid_iOS
//
//  Copyright 2015 phone.id - 73 knots, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.cachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
        
        let dataTask = urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            completion(data: data != nil ? NSData(data: data!) : nil )
        }
        dataTask.resume()
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
