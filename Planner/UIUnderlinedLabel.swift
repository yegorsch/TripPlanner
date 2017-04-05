//
//  UIUnderlinedLabel.swift
//  Planner
//
//  Created by Егор on 3/29/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit

class UIUnderlinedLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSMakeRange(0, text.characters.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatWhite , range: textRange)
            // Add other attributes if needed
            self.attributedText = attributedText
        
        }
    }
}
