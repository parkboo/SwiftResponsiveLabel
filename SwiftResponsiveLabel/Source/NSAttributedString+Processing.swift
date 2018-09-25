//
//  NSAttributedString+Processing.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedStringKey {
	public static let RLTapResponder = NSAttributedStringKey("TapResponder")
	public static let RLHighlightedForegroundColor = NSAttributedStringKey("HighlightedForegroundColor")
	public static let RLHighlightedBackgroundColor = NSAttributedStringKey("HighlightedBackgroundColor")
	public static let RLBackgroundCornerRadius = NSAttributedStringKey("HighlightedBackgroundCornerRadius")
	public static let RLHighlightedAttributesDictionary = NSAttributedStringKey("HighlightedAttributes")
}

open class PatternTapResponder {
	let action: (String) -> Void
	
	public init(currentAction: @escaping (_ tappedString: String) -> (Void)) {
		action = currentAction
	}
	
	open func perform(_ string: String) {
		action(string)
	}
}

extension NSAttributedString {
	
	func sizeOfText() -> CGSize {
		var range = NSMakeRange(NSNotFound, 0)
		let fontAttributes = self.attributes(at: 0, longestEffectiveRange: &range,
		in: NSRange(location: 0, length: self.length))
		return (self.string as NSString).size(withAttributes: fontAttributes)
	}
	
	func isNewLinePresent() -> Bool {
		let newLineRange = self.string.rangeOfCharacter(from: CharacterSet.newlines)
		return newLineRange?.lowerBound != newLineRange?.upperBound
	}

	/**
	Setup paragraph alignement properly.
	Interface builder applies line break style to the attributed string. This makes text container break at first line of text. So we need to set the line break to wrapping.
	IB only allows a single paragraph so getting the style of the first character is fine.
	*/
	func wordWrappedAttributedString() -> NSAttributedString {
		var processedString = self
		if (self.string.count > 0) {
			let rangePointer: NSRangePointer? = nil
			if let paragraphStyle: NSParagraphStyle =  self.attribute(NSAttributedStringKey.paragraphStyle, at: 0, effectiveRange: rangePointer) as? NSParagraphStyle,
				let mutableParagraphStyle = paragraphStyle.mutableCopy() as? NSMutableParagraphStyle {

				// Remove the line breaks
				mutableParagraphStyle.lineBreakMode = .byWordWrapping

				// Apply new style
				let restyled = NSMutableAttributedString(attributedString: self)
				restyled.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, restyled.length))
				processedString = restyled
			}
		}
		return processedString
	}
}
