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

open class EditProfileViewController: UIViewController, PhoneIdConsumer, EditProfileViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    open var user: UserInfo!

    lazy fileprivate var imagePickerViewController: UIImagePickerController = {
        let result = UIImagePickerController()
        result.delegate = self
        return result
    }()

    fileprivate var editProfileView: EditProfileView! {
        get {
            let result = self.view as? EditProfileView
            if (result == nil) {
                fatalError("self.view expected to be kind of NumberInputView")
            }
            return result
        }
    }

    public init(model: UserInfo) {
        super.init(nibName: nil, bundle: nil)
        self.user = model
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadView() {
        let result = phoneIdComponentFactory.editProfileView(user)
        result.delegate = self
        self.view = result
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func changeUserNameButtonTapped() {
        let controller = self.phoneIdService.componentFactory.editUserNameViewController(self.user)
        controller.completeEditing = {
            (user: UserInfo) -> Void in
            self.user = user
            self.editProfileView.setupWithUser(user)
        }
        self.present(controller, animated: true, completion: nil)
    }

    func changePhotoButtonTapped() {

        let bundle = self.phoneIdService.componentFactory.localizationBundle
        let actionSheet = UIAlertController(title: NSLocalizedString("alert.title.select.image", bundle: bundle, comment: "alert.title.select.image"), message: nil, preferredStyle: .actionSheet)

        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.camera", bundle: bundle, comment: "alert.button.title.camera"), style: .default, handler: {
                [unowned self] (action) -> Void in
                self.presentImagePicker(.camera)
            }));
        }

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.library", bundle: bundle, comment: "alert.button.title.library"), style: .default, handler: {
            [unowned self] (action) -> Void in
            self.presentImagePicker(.photoLibrary)
        }));

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment: "alert.button.title.dismiss"), style: .cancel, handler: nil));

        self.present(actionSheet, animated: true, completion: nil)
    }

    func presentImagePicker(_ sourceType: UIImagePickerControllerSourceType) {

        imagePickerViewController.allowsEditing = false
        imagePickerViewController.sourceType = sourceType
        let colorScheme = self.phoneIdComponentFactory.colorScheme
        imagePickerViewController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colorScheme.headerTitleText]
        imagePickerViewController.navigationBar.isTranslucent = false
        imagePickerViewController.navigationBar.barStyle = UIBarStyle.default
        imagePickerViewController.navigationBar.barTintColor = colorScheme.headerBackground
        imagePickerViewController.navigationBar.tintColor = colorScheme.headerButtonText

        self.present(imagePickerViewController, animated: true, completion: nil)
    }


    func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    func saveButtonTapped(_ userInfo: UserInfo) {
        self.editProfileView.activityIndicator.startAnimating()
        self.phoneIdService.updateUserProfile(userInfo) {
            (error) -> Void in
            self.editProfileView.activityIndicator.stopAnimating()
            if (error != nil) {
                let bundle = self.phoneIdService.componentFactory.localizationBundle
                let alert = UIAlertController(title: NSLocalizedString("alert.title.error", bundle: bundle, comment: "Error"), message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)

                alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.title.dismiss", bundle: bundle, comment: "Dismiss"), style: .cancel, handler: nil))

                self.present(alert, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {

        let image = info[UIImagePickerControllerOriginalImage] as! UIImage

        let editingController = self.phoneIdComponentFactory.imageEditViewController(image)

        editingController.imageEditingCancelled = {
            picker.dismiss(animated: true, completion: nil)
        }

        editingController.imageEditingCompleted = {
            (editedImage: UIImage) in
            self.editProfileView.avatarImage = editedImage
            self.user.updatedImage = editedImage
            picker.dismiss(animated: true, completion: nil)
        }

        picker.pushViewController(editingController, animated: true)
        picker.isNavigationBarHidden = false
    }

}
