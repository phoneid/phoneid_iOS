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

class ImageEditViewController: UIViewController {

    var sourceImage:UIImage!;
    private(set) var editingImageView:PanZoomImageView!
    private(set) var overlayView:CircleOverlayView!
    private(set) var doneBarButton:UIBarButtonItem!
    private(set) var cancelBarButton:UIBarButtonItem!
    
    var imageEditingCompleted: ((editedImage:UIImage)->Void)?
    var imageEditingCancelled: (()->Void)?
    
    required init(image:UIImage){
        super.init(nibName: nil, bundle: nil)
        sourceImage = image        
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        editingImageView = PanZoomImageView(image: nil)
        editingImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(editingImageView)
        
        overlayView = CircleOverlayView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(overlayView)
        
        var c:[NSLayoutConstraint]=[]
        
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: editingImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0))
        
        c.append(NSLayoutConstraint(item: overlayView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: overlayView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0))
        
        self.view.addConstraints(c)
        
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action:  "doneButtonTapped:")
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action:  "cancelButtonTapped:")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None;
        self.extendedLayoutIncludesOpaqueBars=false;
        self.automaticallyAdjustsScrollViewInsets=false;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editingImageView.image = sourceImage
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = [cancelBarButton]
        self.navigationItem.rightBarButtonItems = [doneBarButton]
    }
    
    func doneButtonTapped(sender:UIButton){
        imageEditingCompleted?(editedImage: self.editingImageView.editedImage())
    }
    
    func cancelButtonTapped(sender:UIButton){
        imageEditingCancelled?()
    }

}
