//
//  NumericTextField.swift
//  phoneid_iOS
//
//  Copyright 2015 Federico Pomi
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

class NumericTextFieldDelegate: NSObject, UITextFieldDelegate{
    var maxLength = NSIntegerMax
    
    
    init(maxLength: Int) {
        self.maxLength = maxLength
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > textField.text?.characters.count )
        {
            return false;
        }
        
        let disallowedCharacterSet = NSCharacterSet(charactersInString: "0123456789").invertedSet
        let replacementStringIsLegal = string.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
        
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= maxLength && replacementStringIsLegal
    }
    
}

class NumericTextField: UITextField{
    var numericDelegate:NumericTextFieldDelegate!
    
    init(maxLength:Int){
        super.init(frame: CGRectZero)
        numericDelegate = NumericTextFieldDelegate(maxLength:maxLength)
        self.delegate = numericDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        UIMenuController.sharedMenuController().menuVisible = false
        return false
    }
    
    deinit{
       numericDelegate = nil
    }
}
