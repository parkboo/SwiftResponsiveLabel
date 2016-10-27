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
	
	/** This boolean determines if custom truncation token should be added
	*/
	
	public var customTruncationEnabled: Bool = true {
		didSet {
			self.updateTextStorage()
			self.setNeedsDisplay()
		}
	}
	
	/** Custom truncation token string. The default value is "..."
	
	If customTruncationEnabled is true, then this text will be seen while truncation in place of default ellipse
	*/
	public var truncationToken: String = "..." {
		didSet {
			self.attributedTruncationToken  = NSAttributedString(string: truncationToken, attributes: self.attributesFromProperties())
		}
	}
	
	/** Custom truncation token atributed string. The default value is "..."
	
	If customTruncationEnabled is true, then this text will be seen while truncation in place of default ellipse
	*/
	public var attributedTruncationToken: NSAttributedString? {
		didSet {
			if let _ = self.attributedTruncationToken {
				self.updateTextStorage()
				self.setNeedsDisplay()
			}
		}
	}

	public var attributedTextToDisplay: NSAttributedString {
		var finalAttributedString = NSAttributedString()
		if let attributedText = attributedText?.wordWrappedAttributedString() {
			finalAttributedString = NSAttributedString(attributedString: attributedText)
		} else {
			finalAttributedString = NSAttributedString(string: text ?? "", attributes: self.attributesFromProperties())
		}
		return finalAttributedString
	}
	
	// MARK: Override methods from Superclass
	
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

	override public func drawTextInRect(rect: CGRect) {
		self.textKitStack.resizeTextContainer(rect.size)
		self.frame.size = self.textKitStack.rectFittingTextForContainerSize(bounds.size, numberOfLines: self.numberOfLines, font: self.font).size
		self.textKitStack.drawText(self.textOffSet())
	}

	override public func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
		self.updateTextStorage()
		return self.textKitStack.rectFittingTextForContainerSize(bounds.size, numberOfLines: self.numberOfLines, font: self.font)
	}

	// MARK: Public methods
	
	/** Add attributes to all the occurences of pattern dictated by pattern descriptor
	- parameters:
		- patternDescriptor: The descriptor for the pattern to be detected
	*/
	public func enablePatternDetection(patternDescriptor: PatternDescriptor) {
		self.patternHighlighter.enablePatternDetection(patternDescriptor)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}
	
	/** Add given attributes to urls
	- parameters:
		- attributes: [String:AnyObject]
	*/
	public func enableURLDetection(attributes:[String: AnyObject]) {
		do {
			let regex = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
			let descriptor = PatternDescriptor(regularExpression: regex, searchType: .All, patternAttributes: attributes)
			self.enablePatternDetection(descriptor)
		} catch let error as NSError {
			print("NSDataDetector Error: \(error.debugDescription)")
		}
	}
	
	/** Add given attributes to user handles
	- parameters:
		- attributes: [String:AnyObject]
	*/
	public func enableUserHandleDetection(attributes: [String: AnyObject]) {
		self.highlightPattern(PatternHighlighter.RegexStringForUserHandle, attributes: attributes)
	}
	
	/** Add given attributes to hastags
	- parameters:
		- attributes: [String:AnyObject]
	*/
	public func enableHashTagDetection(attributes: [String: AnyObject]) {
		self.highlightPattern(PatternHighlighter.RegexStringForHashTag, attributes: attributes)
	}
	
	/** Add given attributes to the occurrences of given string
	- parameters:
		- string: String
		- attributes: [String:AnyObject]
	*/
	public func enableStringDetection(string: String, attributes: [String: AnyObject]) {
		let pattern = String(format: PatternHighlighter.RegexFormatForSearchWord, string)
		self.highlightPattern(pattern, attributes: attributes)
	}
	
	/** Add given attributes to the occurrences of all the strings of given array
	- parameters:
		- stringsArray: [String]
		- attributes: [String:AnyObject]
	*/
	public func enableDetectionForStrings(stringsArray: [String], attributes:[String: AnyObject]) {
		for string in stringsArray {
			enableStringDetection(string, attributes: attributes)
		}
	}
	
	/** Removes previously applied attributes from all the occurences of pattern dictated by pattern descriptor
	- parameters:
		- patternDescriptor: The descriptor for the pattern to be detected
	*/
	public func disablePatternDetection(patternDescriptor: PatternDescriptor) {
		self.patternHighlighter.disablePatternDetection(patternDescriptor)
		self.updateTextStorage()
		self.setNeedsLayout()
	}
	
	/** remove attributes form url
	*/
	public func disableURLDetection() {
		let key = String(NSTextCheckingType.Link.rawValue)
		self.unhighlightPattern(key)
	}
	
	/** remove attributes form user handle
	*/
	public func disableUserHandleDetection() {
		self.unhighlightPattern(PatternHighlighter.RegexStringForUserHandle)
	}
	
	/** remove attributes form hash tags
	*/
	public func disableHashTagDetection() {
		self.unhighlightPattern(PatternHighlighter.RegexStringForHashTag)
	}
	
	/** Remove attributes from all the occurrences of given string
	- parameters:
		- string: String
	*/
	public func disableStringDetection(string: String) {
		let pattern = String(format: PatternHighlighter.RegexFormatForSearchWord, string)
		self.unhighlightPattern(pattern)
	}
	
	/** Remove attributes from all the occurrences of all the strings in the array
	- parameters:
		- string: [String]
	*/
	public func disableDetectionForStrings(stringsArray:[String]) {
		for string in stringsArray {
			disableStringDetection(string)
		}
	}

	// MARK: Private Helpers
	
	private func highlightPattern(pattern: String, attributes:[String:AnyObject]) {
		patternHighlighter.highlightPattern(pattern, dictionary: attributes)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}
	
	private func unhighlightPattern(pattern: String) {
		self.patternHighlighter.unhighlightPattern(regexString: pattern)
		self.updateTextStorage()
		self.setNeedsDisplay()
	}

	private func updateTextStorage() {
		var finalString: NSAttributedString = self.attributedTextToDisplay
		self.textKitStack.updateTextStorage(finalString)

		// Add truncation token if necessary
		if let _ = self.attributedTruncationToken where self.shouldTruncate() && self.customTruncationEnabled {
			if let string = self.stringWithTruncationToken() where self.truncationTokenAppended() == false {
				finalString = string
			}
		}
		// Apply pattern
		self.patternHighlighter.updateAttributedText(finalString)
		if let highlightedString = self.patternHighlighter.patternHighlightedText {
			finalString = highlightedString
		}
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
		let shadow = NSShadow()
		if let shadowColor = self.shadowColor {
			shadow.shadowColor = shadowColor
			shadow.shadowOffset = self.shadowOffset
		} else {
			shadow.shadowOffset = CGSizeMake(0, -1)
			shadow.shadowColor = nil
		}

		var color = self.textColor
		if !self.enabled {
			color = UIColor.lightGrayColor()
		} else if let _ = self.highlightedTextColor where self.highlighted == true {
			color = self.highlightedTextColor;
		}

		let paragraph = NSMutableParagraphStyle()
		paragraph.alignment = self.textAlignment

		return [NSFontAttributeName : self.font,
		        NSForegroundColorAttributeName : color,
		        NSShadowAttributeName: shadow,
		        NSParagraphStyleAttributeName: paragraph]
	}
}
