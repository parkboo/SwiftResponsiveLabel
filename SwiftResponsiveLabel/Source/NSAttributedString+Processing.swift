//
//  NSAttributedString+Processing.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString.Key {
	public static let RLTapResponder = NSAttributedString.Key("TapResponder")
	public static let RLHighlightedForegroundColor = NSAttributedString.Key("HighlightedForegroundColor")
	public static let RLHighlightedBackgroundColor = NSAttributedString.Key("HighlightedBackgroundColor")
	public static let RLBackgroundCornerRadius = NSAttributedString.Key("HighlightedBackgroundCornerRadius")
	public static let RLHighlightedAttributesDictionary = NSAttributedString.Key("HighlightedAttributes")
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
		var size = (self.string as NSString).size(withAttributes: fontAttributes)
		self.enumerateAttribute(NSAttributedString.Key.attachment,
								in: NSRange(location: 0, length: self.length),
								options: []) { (value, range, stop) in
									if let attachment = value as? NSTextAttachment {
										size.width += attachment.bounds.width
									}
		}
		return size
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
			if let paragraphStyle: NSParagraphStyle =  self.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: rangePointer) as? NSParagraphStyle,
				let mutableParagraphStyle = paragraphStyle.mutableCopy() as? NSMutableParagraphStyle {

				// Remove the line breaks
				mutableParagraphStyle.lineBreakMode = .byWordWrapping

				// Apply new style
				let restyled = NSMutableAttributedString(attributedString: self)
				restyled.addAttribute(NSAttributedString.Key.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, restyled.length))
				processedString = restyled
			}
		}
		return processedString
	}
}
