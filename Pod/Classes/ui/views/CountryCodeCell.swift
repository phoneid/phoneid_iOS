//
//  CountryCodeCell.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/3/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation

class CountryCodeCell:UITableViewCell{
    
    var model:CountryInfo?
    var prefixLabel:UILabel!
    var countryLabel:UILabel!
    
    static let height:CGFloat = 35.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prefixLabel = UILabel();
        prefixLabel.textAlignment = NSTextAlignment.Center;
        prefixLabel.textColor = UIColor.whiteColor();
        prefixLabel.backgroundColor = UIColor.grayColor();
        prefixLabel.layer.cornerRadius = 3;
        prefixLabel.layer.masksToBounds = true;
        self.prefixLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(prefixLabel);
        
        countryLabel = UILabel();
        self.countryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.countryLabel.font = UIFont.systemFontOfSize(18)
        self.addSubview(countryLabel);
        
        
        setupLayout()
    }
    
    func setupLayout(){
        var c:[NSLayoutConstraint] = []
        let cell = self
        
        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .Left, relatedBy: .Equal, toItem: cell, attribute: .Left, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .CenterY, relatedBy: .Equal, toItem: cell, attribute: .CenterY, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 50))
        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 30))
        
        c.append(NSLayoutConstraint(item: countryLabel, attribute: .CenterY, relatedBy: .Equal, toItem: cell, attribute: .CenterY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: countryLabel, attribute: .Left, relatedBy: .Equal, toItem: prefixLabel, attribute: .Right, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: countryLabel, attribute: .Right, relatedBy: .Equal, toItem: cell, attribute: .Right, multiplier: 1, constant: -10))
        
        self.addConstraints(c)
        
    }
    
    func setupWithModel(model:CountryInfo){
        self.model = model
        prefixLabel.text = model.prefix
        countryLabel.text = model.name
        
        self.needsUpdateConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
