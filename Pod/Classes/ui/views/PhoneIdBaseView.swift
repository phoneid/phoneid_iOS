//
//  PhoneIdBaseView.swift
//  phoneid_iOS
//
//  Copyright 2015 Federico Pomi
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


import Foundation

public class PhoneIdBaseView: UIView, Customizable, PhoneIdConsumer{
    
    public var phoneIdModel: NumberInfo!
    public var colorScheme: ColorScheme!
    public var localizationBundle: NSBundle!
    public var localizationTableName: String!
    
    init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        
        super.init(frame: CGRectZero)
        
        phoneIdModel = model
        colorScheme = scheme
        localizationBundle = bundle
        localizationTableName = tableName
        
        doOnInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func doOnInit(){
        setupSubviews()
        setupLayout()
        setupWithModel(self.phoneIdModel)
        localizeAndApplyColorScheme()
    }
    
    func setupSubviews(){
        
    }
    
    func setupLayout(){
 
    }
    
    func setupWithModel(model:NumberInfo){
        self.phoneIdModel = model
    }
    
    func localizeAndApplyColorScheme(){
        
    }
    
    func closeButtonTapped(){
        
    }
    
}

public class PhoneIdBaseFullscreenView: PhoneIdBaseView{
   
    var closeButton: UIButton!
    var backgroundView:UIImageView!
    func backgroundImage() -> UIImage { return phoneIdComponentFactory.defaultBackgroundImage() }
    
    var customConstraints:[NSLayoutConstraint]=[]
    
    override init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        super.init(model: model, scheme:scheme, bundle:bundle, tableName:tableName)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        

    override func setupSubviews(){
        backgroundView = UIImageView(image: backgroundImage())
        closeButton = UIButton(type:.System)
        closeButton.setImage(UIImage(namedInPhoneId: "close"), forState: .Normal)
        closeButton.tintColor = colorScheme.normalText
        closeButton.addTarget(self, action: "closeButtonTapped", forControlEvents: .TouchUpInside)
        
        let views = [backgroundView, closeButton]
        for view in views{
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
    }
    
    override func setupLayout(){
        self.removeConstraints(self.customConstraints)
        self.customConstraints=[]
        
        var c:[NSLayoutConstraint]=[]
        
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: closeButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -10))
        c.append(NSLayoutConstraint(item: closeButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 30))
        c.append(NSLayoutConstraint(item: closeButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 20))
        c.append(NSLayoutConstraint(item: closeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 20))
        
        self.customConstraints=c
        self.addConstraints(c)
    }
    
}