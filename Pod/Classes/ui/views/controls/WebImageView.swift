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
       super.init(frame:CGRect.zero)
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
        
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant:0))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant:0))
    }
    
    func getDataFromUrl(_ url:String, completion: @escaping ((_ data: Data?) -> Void)) {
        if let urlSession = PhoneIdService.sharedInstance.urlSession {
            var request = URLRequest(url: URL(string: url)!)
            
            request.cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
            
            let dataTask = urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
                completion(data)
            })
            
            dataTask.resume()
        }
    }
    
    func downloadImage(_ url:String?){
        
        guard url != nil else {
            return
        }
        self.activityIndicator.startAnimating()
        getDataFromUrl(url!) { data in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.image = data != nil ? UIImage(data: data!) : nil
            }
        }
    }

}
