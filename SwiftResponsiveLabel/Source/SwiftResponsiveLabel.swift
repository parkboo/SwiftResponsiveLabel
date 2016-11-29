//
//  SwiftResponsiveLabel.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
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
			self.textKitStack.resizeTextContainer(bounds.size)
		}
	}

	override public var preferredMaxLayoutWidth: CGFloat {
		didSet {
			self.textKitStack.resizeTextContainer(frame.size)
		}
	}

	override public var text: String? {
		didSet {
			self.textKitStack.updateTextStorage(self.attributedTextToDisplay)
			setNeedsDisplay()
		}
	}

	override public var attributedText: NSAttributedString? {
		didSet {
			self.textKitStack.updateTextStorage(self.attributedTextToDisplay)
			setNeedsDisplay()
		}
	}
	
	override public var numberOfLines: Int {
		didSet {
			let rect = self.textKitStack.rectFittingTextForContainerSize(self.bounds.size, numberOfLines: self.numberOfLines, font: self.font)
			self.textKitStack.resizeTextContainer(rect.size)
		}
	}
	
	
	/** This boolean determines if custom truncation token should be added
	*/
	
	@IBInspectable public var customTruncationEnabled: Bool = true {
		didSet {
			self.textKitStack.updateTextStorage(self.attributedTextToDisplay)
			self.setNeedsDisplay()
		}
	}
	
	/** Custom truncation token string. The default value is "..."
	
	If customTruncationEnabled is true, then this text will be seen while truncation in place of default ellipse
	*/
	@IBInspectable public var truncationToken: String = "..." {
		didSet {
			self.attributedTruncationToken = NSAttributedString(string: truncationToken, attributes: self.attributesFromProperties())
		}
	}
	
	/** Custom truncation token atributed string. The default value is "..."
	
	If customTruncationEnabled is true, then this text will be seen while truncation in place of default ellipse
	*/
	@IBInspectable public var attributedTruncationToken: NSAttributedString? {
		didSet {
			if let _ = self.attributedTruncationToken {
				self.textKitStack.updateTextStorage(self.attributedTextToDisplay)
				self.setNeedsDisplay()
			}
		}
	}
	
	@IBInspectable public var truncationIndicatorImage: UIImage? {
		didSet {
			if let image = truncationIndicatorImage {
				self.attributedTruncationToken = self.attributedStringWithImage(image, withSize: CGSize(width: 20.0, height: 20.0), andAction: nil)
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
	
	override public func drawTextInRect(rect: CGRect) {
		// Add truncation token if necessary
		var finalString: NSAttributedString = textKitStack.currentAttributedText
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
		textKitStack.updateTextStorage(finalString)
		self.textKitStack.drawText(self.textOffSet(rect))
	}

	override public func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
		let rect = self.textKitStack.rectFittingTextForContainerSize(bounds.size, numberOfLines: self.numberOfLines, font: self.font)
		self.textKitStack.resizeTextContainer(rect.size)
		return rect
	}

	// MARK: Public methods
	
	/** Method to set an image as truncation indicator
	- parameters:
		- image: UIImage
		- size: CGSize : The height of image size should be approximately equal to or less than the font height. Otherwise the image will not be rendered properly
		- action: PatternTapResponder action to be performed on tap on the image
	*/
	func setTruncationIndicatorImage(image: UIImage, withSize size: CGSize, andAction action: PatternTapResponder?) {
		let attributedString = self.attributedStringWithImage(image, withSize: size, andAction: action)
		self.attributedTruncationToken = attributedString
	}
	
	/** Add attributes to all the occurences of pattern dictated by pattern descriptor
	- parameters:
		- patternDescriptor: The descriptor for the pattern to be detected
	*/
	public func enablePatternDetection(patternDescriptor: PatternDescriptor) {
		self.patternHighlighter.enablePatternDetection(patternDescriptor)
		self.textKitStack.updateTextStorage(self.attributedTextToDisplay)
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
		self.textKitStack.updateTextStorage(self.attributedTextToDisplay)
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
		self.textKitStack.updateTextStorage(self.attributedTextToDisplay)
		self.setNeedsDisplay()
	}
	
	private func unhighlightPattern(pattern: String) {
		self.patternHighlighter.unhighlightPattern(regexString: pattern)
		self.textKitStack.updateTextStorage(self.attributedTextToDisplay)
		self.setNeedsDisplay()
	}

	internal func shouldTruncate() -> Bool {
		guard numberOfLines > 0 else {
			return false
		}
		let range = self.textKitStack.rangeForTokenInsertion(self.attributedTextToDisplay)
		return (range.location + range.length <= self.attributedTextToDisplay.length)
	}

	private func textOffSet(rect: CGRect) -> CGPoint {
		var textOffset = CGPointZero
		let textBounds = self.textKitStack.boundingRectForCompleteText()
		let paddingHeight = (rect.size.height - textBounds.size.height) / 2.0
		if paddingHeight > 0 {
			textOffset.y = paddingHeight
		} else {
			textOffset.y = 0
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
