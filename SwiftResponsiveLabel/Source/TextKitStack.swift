//
//  TextKitStack.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

public class TextKitStack {
	private var textContainer = NSTextContainer()
	private var layoutManager = NSLayoutManager()
	private var textStorage = NSTextStorage()
	private var currentTextOffset = CGPointZero
	
	public var textStorageLength: Int {
		return self.textStorage.length
	}
	
	public var currentAttributedText: NSAttributedString {
		return textStorage
	}

	init() {
		self.textContainer.lineFragmentPadding = 0
		self.textContainer.widthTracksTextView = true
		self.layoutManager.addTextContainer(self.textContainer)
		self.textContainer.layoutManager = self.layoutManager
		self.textStorage.addLayoutManager(self.layoutManager)
		self.layoutManager.textStorage = self.textStorage
	}

	func drawText(textOffset: CGPoint) {
		self.currentTextOffset = textOffset
		let glyphRange = self.layoutManager.glyphRangeForTextContainer(self.textContainer)
		self.layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: textOffset)
		self.layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: textOffset)
	}

	func resizeTextContainer(size: CGSize) {
		self.textContainer.size = size
	}

	func updateTextStorage(attributedText: NSAttributedString) {
		self.textStorage.setAttributedString(attributedText)
	}

	func characterIndexAtLocation(location: CGPoint) -> Int {
		var characterIndex: Int = NSNotFound
		if self.textStorage.string.characters.count > 0 {
			let glyphIndex = self.glyphIndexForLocation(location)
			// If the location is in white space after the last glyph on the line we don't
			// count it as a hit on the text
			let rangePointer: NSRangePointer = nil
			var lineRect = self.layoutManager.lineFragmentUsedRectForGlyphAtIndex(glyphIndex, effectiveRange: rangePointer)
			lineRect.size.height = 60.0 //Adjustment to increase tap area
			if CGRectContainsPoint(lineRect, location) {
				characterIndex = self.layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
			}
		}
		return characterIndex
	}

	func rangeContainingIndex(index: Int) -> NSRange {
		return self.layoutManager.rangeOfNominallySpacedGlyphsContainingIndex(index)
	}

	func boundingRectForCompleteText() -> CGRect {
		self.textContainer.size = CGSizeMake(self.textContainer.size.width, CGFloat.max)
		let glyphRange = self.layoutManager.glyphRangeForTextContainer(textContainer)
		self.layoutManager.invalidateDisplayForCharacterRange(NSMakeRange(0, self.textStorage.length - 1))
		return self.layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer:self.textContainer)
	}

	func rectFittingTextForContainerSize(size: CGSize, numberOfLines: Int, font: UIFont) -> CGRect {
		self.textContainer.size = size
		self.textContainer.maximumNumberOfLines = numberOfLines
		var textBounds = self.layoutManager.boundingRectForGlyphRange(NSMakeRange(0, self.layoutManager.numberOfGlyphs), inTextContainer: self.textContainer)
		let totalLines = Int(textBounds.size.height / font.lineHeight)
		if numberOfLines > 0 {
			if numberOfLines < totalLines {
				textBounds.size.height -= CGFloat(totalLines - numberOfLines) * font.lineHeight
			} else if numberOfLines > totalLines {
				textBounds.size.height += CGFloat(numberOfLines - totalLines) * font.lineHeight
			}
		}
		textBounds.size.width = ceil(textBounds.size.width)
		textBounds.size.height = ceil(textBounds.size.height)
		self.textContainer.size = textBounds.size
		return textBounds;
	}

	func rangeForTokenInsertion(attributedTruncationToken: NSAttributedString) -> NSRange {
		guard self.textStorage.length > 0 else {
			return NSMakeRange(NSNotFound, 0)
		}
		var rangeOfText = NSMakeRange(NSNotFound, 0)
		if textStorage.isNewLinePresent() {
			rangeOfText = self.truncatedRangeForStringWithNewLine()
		} else {
			let glyphIndex = self.layoutManager.glyphIndexForCharacterAtIndex(self.textStorage.length - 1)
			rangeOfText = self.layoutManager.truncatedGlyphRangeInLineFragmentForGlyphAtIndex(glyphIndex)
			var lineRange = NSMakeRange(NSNotFound, 0)
			self.layoutManager.lineFragmentRectForGlyphAtIndex(glyphIndex, effectiveRange: &lineRange)
			rangeOfText = lineRange

		}
		if rangeOfText.location != NSNotFound {
			rangeOfText.length += attributedTruncationToken.length
			rangeOfText.location -= attributedTruncationToken.length
		}
		return rangeOfText;
	}

	func truncatedRangeForStringWithNewLine() -> NSRange {
		let numberOfGlyphs = self.layoutManager.numberOfGlyphs
		var lineRange = NSMakeRange(NSNotFound, 0)
		let font = self.textStorage.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as! UIFont
		let approximateNumberOfLines = Int(CGRectGetHeight(self.layoutManager.usedRectForTextContainer(self.textContainer)) / font.lineHeight)
		var index = 0
		var numberOfLines = 0
		while index < numberOfGlyphs {
			self.layoutManager.lineFragmentRectForGlyphAtIndex(index, effectiveRange: &lineRange)
			if numberOfLines == approximateNumberOfLines - 1 {
				break
			}
			index = NSMaxRange(lineRange)
			numberOfLines += 1
		}
		let rangeOfText = NSMakeRange(lineRange.location + lineRange.length - 1, self.textStorage.length - lineRange.location - lineRange.length + 1)
		return rangeOfText
	}

	func attributeForKey(attributeKey: String, atIndex index: Int) -> (AnyObject?, NSRange) {
		var rangeOfTappedText = NSRange()
		let attribute = self.textStorage.attribute(attributeKey, atIndex: index, effectiveRange: &rangeOfTappedText)
		return (attribute, rangeOfTappedText)
	}
	
	func attributesAtIndex( index: Int) -> ([String : AnyObject]?, NSRange) {
		var rangeOfTappedText = NSRange()
		let attributes = self.textStorage.attributesAtIndex(index, effectiveRange: &rangeOfTappedText)
		return (attributes, rangeOfTappedText)
	}
	
	func addAttribute(attribute: AnyObject, forkey key: String, atRange range: NSRange) {
		self.textStorage.addAttribute(key, value: attribute, range: range)
	}
	
	func removeAttribute(forkey key: String, atRange range: NSRange) {
		self.textStorage.removeAttribute(key, range: range)
	}
	
	func substringForRange(range: NSRange) -> String {
		return (self.textStorage.string as NSString).substringWithRange(range)
	}
	
	func rangeOfString(string: String) -> NSRange {
		return (self.textStorage.string as NSString).rangeOfString(string)
	}
	
	// MARK: Private Helpers

	private func glyphIndexForLocation(location: CGPoint) -> Int {
		// Use text offset to convert to text cotainer coordinates
		var convertedLocation = location
		convertedLocation.x -= self.currentTextOffset.x
		convertedLocation.y -= self.currentTextOffset.y
		return self.layoutManager.glyphIndexForPoint(location, inTextContainer: self.textContainer, fractionOfDistanceThroughGlyph: nil)
	}
}