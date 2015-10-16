//
//  ViewController.swift
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

public class UserNameViewController: UIViewController, PhoneIdConsumer, UserNameViewDelegate{

    
    private var model: UserInfo!
    
    public var completeEditing: ((model:UserInfo)->Void)?

    // Mark: custom init
    
    init(model: UserInfo){
    
        super.init(nibName: nil, bundle: nil)
        
        self.model = model
        
    }

    
    required public init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private var userNameView:UserNameView!
        {
        get {
            let result = self.view as? UserNameView
            if(result == nil){
                fatalError("self.view expected to be kind of UserNameView")
            }
            return result
        }
    }
    
    // MARK: initialization
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        let result = self.phoneIdComponentFactory.userNameView(self.model.screenName!)
        result.delegate = self
        self.view = result
    }

    public func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func save() {
        self.model.screenName = self.userNameView.userNameField.text
        completeEditing?(model: self.model)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

