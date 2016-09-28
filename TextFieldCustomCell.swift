//
//  TextFieldCustomCell.swift
//  DKE
//
//  Created by Romain Boudet on 11/08/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit

class TextFieldCustomCell: UITableViewCell {
    
    func configure(text: String, placeholder : String){
        CellTextField.text = text
        CellTextField.placeholder = placeholder
        
    }
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var CellTextField: UITextField!

}
