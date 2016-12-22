//
//  TextKitStack.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

open class TextKitStack {
	fileprivate var textContainer = NSTextContainer()
	fileprivate var layoutManager = NSLayoutManager()
	fileprivate var textStorage = NSTextStorage()
	fileprivate var currentTextOffset = CGPoint.zero
	
	open var textStorageLength: Int {
		return self.textStorage.length
	}
	
	open var currentAttributedText: NSAttributedString {
		return textStorage
	}
	
	open var numberOflines: Int = 0 {
		didSet {
			self.textContainer.maximumNumberOfLines = self.numberOflines
		}
	}

	init() {
		self.textContainer.widthTracksTextView = true
		self.textContainer.heightTracksTextView = true
		self.layoutManager.addTextContainer(self.textContainer)
		self.textStorage.addLayoutManager(self.layoutManager)
	}

	open func drawText(_ textOffset: CGPoint) {
		self.currentTextOffset = textOffset
		let glyphRange = self.layoutManager.glyphRange(for: self.textContainer)
		self.layoutManager.drawBackground(forGlyphRange: glyphRange, at: textOffset)
		self.layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: textOffset)
	}

	open func resizeTextContainer(_ size: CGSize) {
		self.textContainer.size = size
	}

	open func updateTextStorage(_ attributedText: NSAttributedString) {
		self.textStorage.setAttributedString(attributedText)
	}

	open func characterIndexAtLocation(_ location: CGPoint) -> Int {
		var characterIndex: Int = NSNotFound
		if self.textStorage.string.characters.count > 0 {
			let glyphIndex = self.glyphIndexForLocation(location)
			// If the location is in white space after the last glyph on the line we don't
			// count it as a hit on the text
			let rangePointer: NSRangePointer? = nil
			var lineRect = self.layoutManager.lineFragmentUsedRect(forGlyphAt: glyphIndex, effectiveRange: rangePointer)
			lineRect.size.height = 60.0 //Adjustment to increase tap area
			if lineRect.contains(location) {
				characterIndex = self.layoutManager.characterIndexForGlyph(at: glyphIndex)
			}
		}
		return characterIndex
	}

	open func rangeContainingIndex(_ index: Int) -> NSRange {
		return self.layoutManager.range(ofNominallySpacedGlyphsContaining: index)
	}

	open func boundingRectForCompleteText() -> CGRect {
		let initialSize = self.textContainer.size
		self.textContainer.size = CGSize(width: self.textContainer.size.width, height: CGFloat.greatestFiniteMagnitude)
		let glyphRange = self.layoutManager.glyphRange(for: textContainer)
		self.layoutManager.invalidateDisplay(forCharacterRange: NSMakeRange(0, self.textStorage.length - 1))
		let rect = self.layoutManager.boundingRect(forGlyphRange: glyphRange, in:self.textContainer)
		self.textContainer.size = initialSize
		return rect
	}

	open func rectFittingTextForContainerSize(_ size: CGSize, numberOfLines: Int, font: UIFont) -> CGRect {
		let initialSize = self.textContainer.size
		self.textContainer.size = size
		self.textContainer.maximumNumberOfLines = numberOfLines
		var textBounds = self.layoutManager.boundingRect(forGlyphRange: NSMakeRange(0, self.layoutManager.numberOfGlyphs), in: self.textContainer)
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
		self.textContainer.size = initialSize
		return textBounds;
	}

	open func rangeForTokenInsertion(_ attributedTruncationToken: NSAttributedString) -> NSRange {
		guard self.textStorage.length > 0 else {
			return NSMakeRange(NSNotFound, 0)
		}
		var rangeOfText = NSMakeRange(NSNotFound, 0)
		if textStorage.isNewLinePresent() {
			rangeOfText = self.truncatedRangeForStringWithNewLine()
		} else {
			let glyphIndex = self.layoutManager.glyphIndexForCharacter(at: self.textStorage.length - 1)
			rangeOfText = self.layoutManager.truncatedGlyphRange(inLineFragmentForGlyphAt: glyphIndex)
			var lineRange = NSMakeRange(NSNotFound, 0)
			self.layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &lineRange)
			rangeOfText = lineRange

		}
		if rangeOfText.location != NSNotFound {
			rangeOfText.length += attributedTruncationToken.length + 5
			rangeOfText.location -= attributedTruncationToken.length + 5
		}
		return rangeOfText;
	}

	open func truncatedRangeForStringWithNewLine() -> NSRange {
		let numberOfGlyphs = self.layoutManager.numberOfGlyphs
		var lineRange = NSMakeRange(NSNotFound, 0)
		let font = self.textStorage.attribute(NSFontAttributeName, at: 0, effectiveRange: nil) as! UIFont
		let approximateNumberOfLines = Int(self.layoutManager.usedRect(for: self.textContainer).height / font.lineHeight)
		var index = 0
		var numberOfLines = 0
		while index < numberOfGlyphs {
			self.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
			if numberOfLines == approximateNumberOfLines - 1 {
				break
			}
			index = NSMaxRange(lineRange)
			numberOfLines += 1
		}
		let rangeOfText = NSMakeRange(lineRange.location + lineRange.length - 1, self.textStorage.length - lineRange.location - lineRange.length + 1)
		return rangeOfText
	}

	open func attributeForKey(_ attributeKey: String, atIndex index: Int) -> (AnyObject?, NSRange) {
		var rangeOfTappedText = NSRange()
		let attribute = self.textStorage.attribute(attributeKey, at: index, effectiveRange: &rangeOfTappedText)
		return (attribute as AnyObject?, rangeOfTappedText)
	}
	
	open func attributesAtIndex( _ index: Int) -> ([String : AnyObject]?, NSRange) {
		var rangeOfTappedText = NSRange()
		let attributes = self.textStorage.attributes(at: index, effectiveRange: &rangeOfTappedText)
		return (attributes as [String : AnyObject]?, rangeOfTappedText)
	}
	
	open func addAttribute(_ attribute: AnyObject, forkey key: String, atRange range: NSRange) {
		self.textStorage.addAttribute(key, value: attribute, range: range)
	}
	
	open func removeAttribute(forkey key: String, atRange range: NSRange) {
		self.textStorage.removeAttribute(key, range: range)
	}
	
	open func substringForRange(_ range: NSRange) -> String {
		return (self.textStorage.string as NSString).substring(with: range)
	}
	
	open func rangeOfString(_ string: String) -> NSRange {
		return (self.textStorage.string as NSString).range(of: string)
	}
	
	// MARK: Private Helpers

	fileprivate func glyphIndexForLocation(_ location: CGPoint) -> Int {
		// Use text offset to convert to text cotainer coordinates
		var convertedLocation = location
		convertedLocation.x -= self.currentTextOffset.x
		convertedLocation.y -= self.currentTextOffset.y
		return self.layoutManager.glyphIndex(for: location, in: self.textContainer, fractionOfDistanceThroughGlyph: nil)
	}
}
