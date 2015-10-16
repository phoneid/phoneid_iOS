//
//  EditProfileViewController.swift
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

public class EditProfileViewController: UIViewController, PhoneIdConsumer, EditProfileViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public var user:UserInfo!
    
    lazy private var imagePickerViewController: UIImagePickerController = {
        let result = UIImagePickerController()
        result.delegate = self
        return result
    }()
    
    private var editProfileView:EditProfileView!
        {
        get {
            let result = self.view as? EditProfileView
            if(result == nil){
                fatalError("self.view expected to be kind of NumberInputView")
            }
            return result
        }
    }
    
    public init(model: UserInfo){
        super.init(nibName: nil, bundle: nil)
        self.user = model
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        let result = phoneIdComponentFactory.editProfileView(self.user)
        result.delegate = self
        self.view = result
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeUserNameButtonTapped() {
        let controller = self.phoneIdService.componentFactory.editUserNameViewController(self.user)
        controller.completeEditing = { (user:UserInfo) -> Void in
            self.user = user
            self.editProfileView.setupWithUser(user)
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func changePhotoButtonTapped(){
        
        let bundle = self.phoneIdService.componentFactory.localizationBundle()
        let actionSheet = UIAlertController(title: NSLocalizedString("alert.title.select.image", bundle: bundle, comment:"alert.title.select.image"), message: nil, preferredStyle: .ActionSheet)
        
        if(UIImagePickerController.isSourceTypeAvailable(.Camera)){
            actionSheet.addAction(UIAlertAction(title:NSLocalizedString("alert.button.title.camera", bundle: bundle, comment:"alert.button.title.camera"), style: .Default, handler:{ [unowned self] (action)->Void in
                self.presentImagePicker(.Camera)
                } ));
        }
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.library", bundle: bundle, comment:"alert.button.title.library"), style: .Default, handler: { [unowned self] (action)->Void in
            self.presentImagePicker(.PhotoLibrary)
            } ));
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment:"alert.button.title.dismiss"), style: .Cancel, handler: nil));
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func presentImagePicker(sourceType:UIImagePickerControllerSourceType){
        
        imagePickerViewController.allowsEditing = false
        imagePickerViewController.sourceType = sourceType
        
        self.presentViewController(imagePickerViewController, animated: true, completion: nil)
    }
    
    
    func closeButtonTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveButtonTapped(userInfo:UserInfo) {
        self.phoneIdService.updateUserProfile(userInfo) { (error) -> Void in
            if(error != nil){
                let bundle = self.phoneIdService.componentFactory.localizationBundle()
                let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment:"Error"), message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment:"Dismiss"), style: .Cancel, handler:nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
    
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let editingController = self.phoneIdComponentFactory.imageEditViewController(image)
        
        editingController.imageEditingCancelled = {
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        
        editingController.imageEditingCompleted = { (editedImage:UIImage) in
            self.editProfileView.avatarImage = editedImage
            self.user.updatedImage = editedImage
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        
        picker.pushViewController(editingController, animated: true)
        picker.navigationBarHidden = false
    }

}
