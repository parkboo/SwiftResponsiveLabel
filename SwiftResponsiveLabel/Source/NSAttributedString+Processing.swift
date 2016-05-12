//
//  NSAttributedString+Processing.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

let RLTapResponderAttributeName = "TapResponder"
let RLHighlightedForegroundColorAttributeName = "HighlightedForegroundColor"
let RLHighlightedBackgroundColorAttributeName = "HighlightedBackgroundColor"
let RLBackgroundCornerRadius = "HighlightedBackgroundCornerRadius"
let RLHighlightedAttributesDictionary = "HighlightedAttributes"

public class PatternTapResponder {
	let action: (String) -> Void
	init(currentAction:(tappedString:String) -> (Void)) {
		action = currentAction
	}
	public func perform(string:String) {
		action(string)
	}
}

extension NSAttributedString {
	func isNewLinePresent() -> Bool {
		let newLineRange = self.string.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet())
		return newLineRange?.startIndex != newLineRange?.endIndex
	}

	/** 
	Setup paragraph alignement properly.
	Interface builder applies line break style to the attributed string. This makes text container break at first line of text. So we need to set the line break to wrapping. 
	IB only allows a single paragraph so getting the style of the first character is fine.
 	*/
	func wordWrappedAttributedString() -> NSAttributedString {
		var processedString = self
		if (self.string.characters.count > 0) {
			let rangePointer: NSRangePointer = nil
			if let paragraphStyle =  self.attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange: rangePointer) {

				// Remove the line breaks
				let mutableParagraphStyle = paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
				mutableParagraphStyle.lineBreakMode = .ByWordWrapping

				// Apply new style
				let restyled = NSMutableAttributedString(attributedString: self)
				restyled.addAttribute(NSParagraphStyleAttributeName, value: mutableParagraphStyle, range: NSMakeRange(0, restyled.length))
				processedString = restyled;
			}
		}
		return processedString;
	}

	func touchRange(index: Int) -> NSRange? {
		guard index < self.length  else { return nil }
		var range = NSMakeRange(NSNotFound, 0)
		let attributes = self.attributesAtIndex(index, effectiveRange: &range)
		let touchAttributesSet = attributes.keys.contains(RLHighlightedAttributesDictionary)
		return touchAttributesSet ? range : nil
	}
}
