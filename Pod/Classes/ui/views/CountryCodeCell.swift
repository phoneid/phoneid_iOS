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
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.gray
            label.layer.cornerRadius = 3
            label.layer.masksToBounds = true
            return label
        }()

        countryLabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18)
            label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: UILayoutConstraintAxis.horizontal)
            return label
        }();

        for (_, element) in [prefixLabel, countryLabel].enumerated() {
            element?.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(element!)
        }

        setupLayout()
    }

    func setupLayout() {
        var c: [NSLayoutConstraint] = []
        let cell = self.contentView

        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50))
        c.append(NSLayoutConstraint(item: prefixLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30))

        c.append(NSLayoutConstraint(item: countryLabel, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: countryLabel, attribute: .left, relatedBy: .equal, toItem: prefixLabel, attribute: .right, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: countryLabel, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: 0))

        self.addConstraints(c)

    }

    func setupWithModel(_ model: CountryInfo) {
        self.model = model
        prefixLabel.text = model.prefix
        countryLabel.text = model.name

        self.setNeedsLayout()
    }

    func applyColorScheme(_ colorScheme: ColorScheme) {
        self.prefixLabel.backgroundColor = colorScheme.labelPrefixBackground
        prefixLabel.textColor = colorScheme.labelPrefixText
        self.countryLabel.textColor = colorScheme.labelCountryNameText
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
