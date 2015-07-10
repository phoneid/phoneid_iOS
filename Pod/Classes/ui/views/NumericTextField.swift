//
//  NumericTextField.swift
//  PhoneIdSDK
//
//  Created by Alyona on 7/3/15.
//  Copyright © 2015 phoneId. All rights reserved.
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
