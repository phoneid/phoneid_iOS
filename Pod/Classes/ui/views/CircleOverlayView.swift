//
//  CircleOverlayView.swift
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

class CircleOverlayView: UIView {

    var inset: CGFloat = 5 {
        didSet {
            self.layoutSubviews()
        }
    }

    let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.isUserInteractionEnabled = false
        shapeLayer.isOpaque = false
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.borderWidth = 1.0
        self.layer.addSublayer(shapeLayer)
    }

    override func layoutSubviews() {
        let frame = self.layer.bounds
        shapeLayer.frame = frame
        let smallest = min(frame.size.height, frame.size.width) - inset
        let square = CGRect(
        x: (frame.size.width - smallest) / 2.0,
                y: (frame.size.height - smallest) / 2.0,
                width: smallest,
                height: smallest)
        let path = UIBezierPath(rect: frame)
        path.append(UIBezierPath(ovalIn: square))
        path.close()
        shapeLayer.path = path.cgPath
    }

}
