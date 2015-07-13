//
//  UIViewControllerExtenstion.swift
//  Pods
//
//  Created by Alyona on 7/11/15.
//
//

import Foundation


extension UIViewController{
    
    func dismissWithCompletion( completion:(()->Void)?){
        
        let parent:UIViewController = (self.presentingViewController as UIViewController?)!
        self.dismissViewControllerAnimated(true, completion: {
            parent.dismissViewControllerAnimated(false, completion: {
                completion?()
            })
        })
        
    }
    
}
