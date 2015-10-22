//
//  CountryCodeCell.swift
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


import Foundation

class CountryCodeCell: UITableViewCell {

    var model: CountryInfo?
    var prefixLabel: UILabel!
    var countryLabel: UILabel!

    static let height: CGFloat = 35.0

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        prefixLabel = {
            let label = UILabel()
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.whiteColor()
            label.backgroundColor = UIColor.grayColor()
            label.layer.cornerRadius = 3
            label.layer.masksToBounds = true
            return label
        }()

        countryLabel = {
            let label = UILabel()
            label.font = UIFont.systemFontOfSize(18)
            label.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: UILayoutConstraintAxis.Horizontal)
            return label
        }();

        for (_, element) in [prefixLabel, countryLabel].enumerate() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(element)
        }

        setupLayout()
    }

    func setupLayout() {
        var c: [NSLayoutConstraint] = []
        let cell = self.contentView

        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .Left, relatedBy: .Equal, toItem: cell, attribute: .Left, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .CenterY, relatedBy: .Equal, toItem: cell, attribute: .CenterY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 50))
        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 30))

        c.append(NSLayoutConstraint(item: countryLabel, attribute: .CenterY, relatedBy: .Equal, toItem: cell, attribute: .CenterY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: countryLabel, attribute: .Left, relatedBy: .Equal, toItem: prefixLabel, attribute: .Right, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: countryLabel, attribute: .Right, relatedBy: .Equal, toItem: cell, attribute: .Right, multiplier: 1, constant: 0))

        self.addConstraints(c)

    }

    func setupWithModel(model: CountryInfo) {
        self.model = model
        prefixLabel.text = model.prefix
        countryLabel.text = model.name

        self.setNeedsLayout()
    }

    func applyColorScheme(colorScheme: ColorScheme) {
        self.prefixLabel.backgroundColor = colorScheme.labelPrefixBackground
        prefixLabel.textColor = colorScheme.labelPrefixText
        self.countryLabel.textColor = colorScheme.labelCountryNameText
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
