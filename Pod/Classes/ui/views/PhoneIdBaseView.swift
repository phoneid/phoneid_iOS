//
//  PhoneIdBaseView.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/2/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

public class PhoneIdBaseView: UIView, Customizable, PhoneIdConsumer{
    
    public var phoneIdModel:NumberInfo!
    public var colorScheme: ColorScheme!
    public var localizationBundle:NSBundle!
    public var localizationTableName:String!

    
    public var backgroundView:UIImageView!
    public func backgroundImage() -> UIImage { return phoneIdComponentFactory.defaultBackgroundImage() }
    
    internal var customContraints:[NSLayoutConstraint]=[]
    
    public init(model:NumberInfo, scheme:ColorScheme, bundle:NSBundle, tableName:String){
        
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
        backgroundView = UIImageView(image: backgroundImage())
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(backgroundView)
    }
    
    func setupLayout(){
        self.removeConstraints(self.customContraints)
        self.customContraints=[]
        
        var c:[NSLayoutConstraint]=[]
        
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        self.customContraints=c
        self.addConstraints(c)
    }
    
    public func setupWithModel(model:NumberInfo){
       self.phoneIdModel = model
    }
    
    func localizeAndApplyColorScheme(){
        
    }
    
    
}