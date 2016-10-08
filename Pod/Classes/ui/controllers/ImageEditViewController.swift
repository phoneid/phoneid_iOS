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

open class ImageEditViewController: UIViewController, PhoneIdConsumer, Customizable {

    var sourceImage: UIImage!;
    fileprivate(set) var editingImageView: PanZoomImageView!
    fileprivate(set) var overlayView: CircleOverlayView!
    fileprivate(set) var hintLabel: UILabel!
    fileprivate(set) var doneBarButton: UIBarButtonItem!
    fileprivate(set) var cancelBarButton: UIBarButtonItem!

    var imageEditingCompleted: ((_ editedImage:UIImage) -> Void)?
    var imageEditingCancelled: (() -> Void)?

    open var colorScheme: ColorScheme! {
        get {
            return self.phoneIdComponentFactory.colorScheme
        }
    }

    open var localizationBundle: Bundle! {
        get {
            return self.phoneIdComponentFactory.localizationBundle
        }
    }

    open var localizationTableName: String! {
        get {
            return self.phoneIdComponentFactory.localizationTableName      }
    }

    required public init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        sourceImage = image
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadView() {
        super.loadView()

        editingImageView = PanZoomImageView(image: nil)
        overlayView = CircleOverlayView()
        hintLabel = UILabel()
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center

        let subviews: [UIView] = [editingImageView, overlayView, hintLabel]
        for (_, element) in subviews.enumerated() {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(element)
        }

        var c: [NSLayoutConstraint] = []

        let topPadding: CGFloat = UIScreen.main.bounds.size.height < 500 ? 20 : 40

        c.append(NSLayoutConstraint(item: editingImageView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.95, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.95, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: topPadding))

        c.append(NSLayoutConstraint(item: overlayView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.95, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.95, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: topPadding))

        c.append(NSLayoutConstraint(item: hintLabel, attribute: .top, relatedBy: .equal, toItem: self.overlayView, attribute: .bottom, multiplier: 1, constant: topPadding))
        c.append(NSLayoutConstraint(item: hintLabel, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.8, constant: topPadding))
        c.append(NSLayoutConstraint(item: hintLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))

        self.view.addConstraints(c)

        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ImageEditViewController.doneButtonTapped(_:)))
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ImageEditViewController.cancelButtonTapped(_:)))

        doneBarButton.tintColor = self.colorScheme.headerButtonText
        cancelBarButton.tintColor = self.colorScheme.headerButtonText
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: self.colorScheme.headerTitleText]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        self.navigationController?.navigationBar.barTintColor = self.colorScheme.headerBackground

        self.title = localizedString("title.public.profile")
        self.hintLabel.text = localizedString("profile.hint.about.picture")
        self.hintLabel.textColor = self.colorScheme.profilePictureEditingHintText
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge();
        self.extendedLayoutIncludesOpaqueBars = false;
        self.automaticallyAdjustsScrollViewInsets = false;
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editingImageView.image = sourceImage
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = [cancelBarButton]
        self.navigationItem.rightBarButtonItems = [doneBarButton]
    }

    func doneButtonTapped(_ sender: UIButton) {
        imageEditingCompleted?(self.editingImageView.editedImage())
    }

    func cancelButtonTapped(_ sender: UIButton) {
        imageEditingCancelled?()
    }

}
