//
//  SwiftResponsiveLabel.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

class SwiftResponsiveLabel: UILabel {
	var textKitStack = TextKitStack()
	var touchHandler: TouchHandler?
	var patternHighlighter = PatternHighlighter()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.attributedTruncationToken = NSAttributedString(string: truncationToken, attributes: self.attributesFromProperties())
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.attributedTruncationToken = NSAttributedString(string: truncationToken, attributes: self.attributesFromProperties())
	}

	override var frame: CGRect {
		didSet {
			var size = CGSizeZero
			size.width = min(frame.size.width, self.preferredMaxLayoutWidth)
			self.textKitStack.resizeTextContainer(size)
		}
	}

	override var bounds: CGRect {
		didSet {
			var size = CGSizeZero
			size.width = min(frame.size.width, self.preferredMaxLayoutWidth)
			self.textKitStack.resizeTextContainer(size)
		}
	}

	override var preferredMaxLayoutWidth: CGFloat {
		didSet {
			var size = CGSizeZero
			size.width = min(frame.size.width, self.preferredMaxLayoutWidth)
			self.textKitStack.resizeTextContainer(size)
		}
	}

	override var text: String? {
		didSet {
			updateTextStorage()
			setNeedsDisplay()
		}
	}

	override var attributedText: NSAttributedString? {
		didSet {
			updateTextStorage()
			setNeedsDisplay()
		}
	}

	 var customTruncationEnabled: Bool = false {
		didSet {
			self.updateTextStorage()
			self.setNeedsDisplay()
		}
	}

	 var truncationToken: String = "..." {
		didSet {
			self.attributedTruncationToken  = NSAttributedString(string: truncationToken, attributes: self.attributesFromProperties())
		}
	}

	 var attributedTruncationToken: NSAttributedString? {
		didSet {
			if customTruncationEnabled, let _ = self.attributedTruncationToken {
				self.updateTextStorage()
				self.setNeedsDisplay()
			}
		}
	}

	var attributedTextToDisplay: NSAttributedString {
		var finalAttributedString = NSAttributedString()
		if let attributedText = attributedText?.wordWrappedAttributedString() {
			finalAttributedString = NSAttributedString(attributedString: attributedText)
		} else {
			finalAttributedString = NSAttributedString(string: text ?? "", attributes: self.attributesFromProperties())
		}
		return finalAttributedString
	}

	override func drawTextInRect(rect: CGRect) {
		self.textKitStack.resizeTextContainer(rect.size)
		self.textKitStack.drawText(self.textOffSet())
	}

	override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
		self.updateTextStorage()
		return self.textKitStack.rectFittingTextForContainerSize(bounds.size, numberOfLines: self.numberOfLines, font: self.font)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.initialTextConfiguration()
		if userInteractionEnabled {
			self.touchHandler = TouchHandler(responsiveLabel: self)
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.textKitStack.resizeTextContainer(self.bounds.size)
	}

	// MARK: Public methods
	
	func enableHashTagDetection(attributes: [String:AnyObject]) {
		self.patternHighlighter.highlightPattern(PatternHighlighter.RegexStringForHashTag, dictionary: attributes)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	func disableHashTagDetection() {
		self.patternHighlighter.unhighlightPattern(PatternHighlighter.RegexStringForHashTag)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	func enableUserHandleDetection(attributes:[String:AnyObject]) {
		self.patternHighlighter.highlightPattern(PatternHighlighter.RegexStringForUserHandle, dictionary: attributes)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	func disableUserHandleDetection() {
		self.patternHighlighter.unhighlightPattern(PatternHighlighter.RegexStringForUserHandle)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	func enableURLDetection(attributes:[String:AnyObject]) {
		do {
			let regex = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
			let descriptor = PatternDescriptor(regularExpression: regex, searchType: .All, patternAttributes: attributes)
			self.patternHighlighter.enablePatternDetection(descriptor)
			self.updateTextStorage()
			self.setNeedsDisplay()
			} catch let error as NSError {
				print("NSDataDetector Error: \(error.debugDescription)")
		}
	}

	func disableURLDetection() {
		let key = String(NSTextCheckingType.Link.rawValue)
		self.patternHighlighter.unhighlightPattern(key)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	func enableStringDetection(string:String, attributes:[String:AnyObject]) {
		let pattern = String(format: PatternHighlighter.RegexFormatForSearchWord,string)
		self.patternHighlighter.highlightPattern(pattern, dictionary: attributes)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	func disableStringDetection(string:String) {
		let pattern = String(format: PatternHighlighter.RegexFormatForSearchWord,string)
		self.patternHighlighter.unhighlightPattern(pattern)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	func enableDetectionForStrings(stringsArray:[String], attributes:[String:AnyObject]) {
		for string in stringsArray {
			enableStringDetection(string, attributes: attributes)
		}
	}

	func disableDetectionForStrings(stringsArray:[String]) {
		for string in stringsArray {
			disableStringDetection(string)
		}
	}

	// MARK: Private Helpers

	private func updateTextStorage() {
		var finalString: NSAttributedString = self.attributedTextToDisplay
		self.textKitStack.updateTextStorage(finalString)

		// Add truncation token if necessary
		if let _ = self.attributedTruncationToken where customTruncationEnabled {
			if let string = self.stringWithTruncationToken() where self.truncationTokenAppended() == false {
				finalString = string
			}
		}

		// Apply pattern
		self.patternHighlighter.updateAttributeText(finalString)
		finalString = self.patternHighlighter.patternHighlightedText!
		self.textKitStack.updateTextStorage(finalString)
	}

	private func textOffSet() -> CGPoint {
		var textOffset = CGPointZero
		let textBounds = self.textKitStack.boundingRectForCompleteText()
		let paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0
		if paddingHeight > 0 {
			textOffset.y = paddingHeight
		}
		return textOffset
	}

	private func initialTextConfiguration() {
		var currentText = NSAttributedString()
		if let attributedText = self.attributedText {
			currentText = attributedText.wordWrappedAttributedString()
		} else if let text = self.text {
			currentText = NSAttributedString(string: text, attributes: self.attributesFromProperties())
		}
		self.textKitStack.updateTextStorage(currentText)
	}

	private func attributesFromProperties() -> [String: AnyObject] {
		// Setup shadow attributes
		let shadow = NSShadow()
		if let shadowColor = self.shadowColor {
			shadow.shadowColor = shadowColor
			shadow.shadowOffset = self.shadowOffset
		} else {
			shadow.shadowOffset = CGSizeMake(0, -1)
			shadow.shadowColor = nil
		}

		// Setup color attributes
		var color = self.textColor
		if !self.enabled {
			color = UIColor.lightGrayColor()
		} else if let _ = self.highlightedTextColor where self.highlighted == true {
			color = self.highlightedTextColor;
		}

		// Setup paragraph attributes
		let paragraph = NSMutableParagraphStyle()
		paragraph.alignment = self.textAlignment

		// Create the dictionary
		return [NSFontAttributeName : self.font,
			NSForegroundColorAttributeName : color,
			NSShadowAttributeName: shadow,
			NSParagraphStyleAttributeName: paragraph]
	}
}
