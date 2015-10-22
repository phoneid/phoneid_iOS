//
//  ImageEditViewController.swift
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

public class ImageEditViewController: UIViewController, PhoneIdConsumer, Customizable {

    var sourceImage: UIImage!;
    private(set) var editingImageView: PanZoomImageView!
    private(set) var overlayView: CircleOverlayView!
    private(set) var hintLabel: UILabel!
    private(set) var doneBarButton: UIBarButtonItem!
    private(set) var cancelBarButton: UIBarButtonItem!

    var imageEditingCompleted: ((editedImage:UIImage) -> Void)?
    var imageEditingCancelled: (() -> Void)?

    public var colorScheme: ColorScheme! {
        get {
            return self.phoneIdComponentFactory.colorScheme()
        }
    }

    public var localizationBundle: NSBundle! {
        get {
            return self.phoneIdComponentFactory.localizationBundle()
        }
    }

    public var localizationTableName: String! {
        get {
            return self.phoneIdComponentFactory.localizationTableName()
        }
    }

    required public init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        sourceImage = image
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()

        editingImageView = PanZoomImageView(image: nil)
        overlayView = CircleOverlayView()
        hintLabel = UILabel()
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .Center

        let subviews: [UIView] = [editingImageView, overlayView, hintLabel]
        for (_, element) in subviews.enumerate() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(element)
        }

        var c: [NSLayoutConstraint] = []

        let topPadding: CGFloat = UIScreen.mainScreen().bounds.size.height < 500 ? 20 : 40

        c.append(NSLayoutConstraint(item: editingImageView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: topPadding))

        c.append(NSLayoutConstraint(item: overlayView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: topPadding))

        c.append(NSLayoutConstraint(item: hintLabel, attribute: .Top, relatedBy: .Equal, toItem: self.overlayView, attribute: .Bottom, multiplier: 1, constant: topPadding))
        c.append(NSLayoutConstraint(item: hintLabel, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.8, constant: topPadding))
        c.append(NSLayoutConstraint(item: hintLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))

        self.view.addConstraints(c)

        doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonTapped:")
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonTapped:")

        doneBarButton.tintColor = self.colorScheme.headerButtonText
        cancelBarButton.tintColor = self.colorScheme.headerButtonText
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: self.colorScheme.headerTitleText]
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.barTintColor = self.colorScheme.headerBackground

        self.title = localizedString("title.public.profile")
        self.hintLabel.text = localizedString("profile.hint.about.picture")
        self.hintLabel.textColor = self.colorScheme.profilePictureEditingHintText
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None;
        self.extendedLayoutIncludesOpaqueBars = false;
        self.automaticallyAdjustsScrollViewInsets = false;
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editingImageView.image = sourceImage
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = [cancelBarButton]
        self.navigationItem.rightBarButtonItems = [doneBarButton]
    }

    func doneButtonTapped(sender: UIButton) {
        imageEditingCompleted?(editedImage: self.editingImageView.editedImage())
    }

    func cancelButtonTapped(sender: UIButton) {
        imageEditingCancelled?()
    }

}
