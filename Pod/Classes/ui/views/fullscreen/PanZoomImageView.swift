//
//  PanZoomImageView.swift
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

class PanZoomImageView: UIScrollView, UIScrollViewDelegate {

    private(set) var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        prep(nil)

    }

    init(image: UIImage?) {
        super.init(frame: CGRectZero)

        prep(image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prep(nil)
    }

    var image: UIImage? {
        set {
            self.imageView.image = newValue
            if let newValue = newValue {

                self.imageView.frame = CGRect(x: 0, y: 0, width: newValue.size.width, height: newValue.size.height)
                self.contentSize = CGSizeMake(self.imageView.bounds.width, self.imageView.bounds.height)
                self.layoutSubviews()
                self.contentOffset = imageView.center
                self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            }

        }
        get {
            return self.imageView.image
        }
    }

    func prep(image: UIImage?) {

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)

        imageView.userInteractionEnabled = true
        imageView.contentMode = .Center

        self.image = image
        self.delegate = self;

        self.minimumZoomScale = 0.1;

        self.maximumZoomScale = 8.0;

    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func centerFrame() -> CGRect {

        let boundsSize = self.bounds.size;
        var frameToCenter = self.imageView.frame;


        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        return frameToCenter
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = centerFrame()
    }


    func editedImage() -> UIImage {

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)

        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)

        let offset = self.contentOffset

        CGContextTranslateCTM(UIGraphicsGetCurrentContext()!, -offset.x, -offset.y)

        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)

        let visibleScrollViewImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return visibleScrollViewImage!
    }
}
