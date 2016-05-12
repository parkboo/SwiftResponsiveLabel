//
//  SwiftResponsiveLabel.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

public class SwiftResponsiveLabel: UILabel {
	var textKitStack = TextKitStack()
	var touchHandler: TouchHandler?
	var patternHighlighter = PatternHighlighter()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.attributedTruncationToken = NSAttributedString(string: truncationToken, attributes: self.attributesFromProperties())
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.attributedTruncationToken = NSAttributedString(string: truncationToken, attributes: self.attributesFromProperties())
	}

	override public var frame: CGRect {
		didSet {
			self.textKitStack.resizeTextContainer(frame.size)
		}
	}

	override public var bounds: CGRect {
		didSet {
			self.textKitStack.resizeTextContainer(frame.size)
		}
	}

	override public var preferredMaxLayoutWidth: CGFloat {
		didSet {
			self.textKitStack.resizeTextContainer(frame.size)
		}
	}

	override public var text: String? {
		didSet {
			updateTextStorage()
			setNeedsDisplay()
		}
	}

	override public var attributedText: NSAttributedString? {
		didSet {
			updateTextStorage()
			setNeedsDisplay()
		}
	}

	private var customTruncationEnabled: Bool = true {
		didSet {
			self.updateTextStorage()
			self.setNeedsDisplay()
		}
	}

	public var truncationToken: String = "..." {
		didSet {
			self.attributedTruncationToken  = NSAttributedString(string: truncationToken, attributes: self.attributesFromProperties())
		}
	}

	public var attributedTruncationToken: NSAttributedString? {
		didSet {
			if let _ = self.attributedTruncationToken {
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

	override public func drawTextInRect(rect: CGRect) {
		self.textKitStack.resizeTextContainer(rect.size)
		self.frame.size = self.textKitStack.rectFittingTextForContainerSize(bounds.size, numberOfLines: self.numberOfLines, font: self.font).size
		self.textKitStack.drawText(self.textOffSet())
	}

	override public func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
		self.updateTextStorage()
		return self.textKitStack.rectFittingTextForContainerSize(bounds.size, numberOfLines: self.numberOfLines, font: self.font)
	}

	override public func awakeFromNib() {
		super.awakeFromNib()
		self.initialTextConfiguration()
		if userInteractionEnabled {
			self.touchHandler = TouchHandler(responsiveLabel: self)
		}
	}

	override public func layoutSubviews() {
		super.layoutSubviews()
		self.textKitStack.resizeTextContainer(self.bounds.size)
	}

	// MARK: Public methods

	public func enableHashTagDetection(attributes: [String:AnyObject]) {
		self.patternHighlighter.highlightPattern(PatternHighlighter.RegexStringForHashTag, dictionary: attributes)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	public func disableHashTagDetection() {
		self.patternHighlighter.unhighlightPattern(PatternHighlighter.RegexStringForHashTag)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	public func enableUserHandleDetection(attributes:[String:AnyObject]) {
		self.patternHighlighter.highlightPattern(PatternHighlighter.RegexStringForUserHandle, dictionary: attributes)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	public func disableUserHandleDetection() {
		self.patternHighlighter.unhighlightPattern(PatternHighlighter.RegexStringForUserHandle)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	public func enableURLDetection(attributes:[String:AnyObject]) {
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

	public func disableURLDetection() {
		let key = String(NSTextCheckingType.Link.rawValue)
		self.patternHighlighter.unhighlightPattern(key)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	public func enableStringDetection(string:String, attributes:[String:AnyObject]) {
		let pattern = String(format: PatternHighlighter.RegexFormatForSearchWord,string)
		self.patternHighlighter.highlightPattern(pattern, dictionary: attributes)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	public func disableStringDetection(string:String) {
		let pattern = String(format: PatternHighlighter.RegexFormatForSearchWord,string)
		self.patternHighlighter.unhighlightPattern(pattern)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	public func enableDetectionForStrings(stringsArray:[String], attributes:[String:AnyObject]) {
		for string in stringsArray {
			enableStringDetection(string, attributes: attributes)
		}
	}

	public func disableDetectionForStrings(stringsArray:[String]) {
		for string in stringsArray {
			disableStringDetection(string)
		}
	}

	// MARK: Private Helpers

	private func updateTextStorage() {
		var finalString: NSAttributedString = self.attributedTextToDisplay
		self.textKitStack.updateTextStorage(finalString)

		// Add truncation token if necessary
		if let _ = self.attributedTruncationToken where self.shouldTruncate() {
			if let string = self.stringWithTruncationToken() where self.truncationTokenAppended() == false {
				finalString = string
			}
		}

		// Apply pattern
		self.patternHighlighter.updateAttributeText(finalString)
		finalString = self.patternHighlighter.patternHighlightedText!
		self.textKitStack.updateTextStorage(finalString)
	}

	private func shouldTruncate() -> Bool {
		guard numberOfLines > 0 else {
			return false
		}
		let range = self.textKitStack.rangeForTokenInsertion(self.attributedTextToDisplay)
		return (range.location + range.length <= self.attributedTextToDisplay.length)
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
