//
//  TextKitStack.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

public struct RangeAttribute {
	let key: NSAttributedString.Key
	let attribute: Any?
	let range: NSRange
}

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
	
	/** Draws text in textStorage starting at point specified by textOffset
	- parameters:
		- textOffset: CGPoint
	*/
	open func drawText(_ textOffset: CGPoint) {
		self.currentTextOffset = textOffset
		let glyphRange = self.layoutManager.glyphRange(for: self.textContainer)
		self.layoutManager.drawBackground(forGlyphRange: glyphRange, at: textOffset)
		self.layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: textOffset)
	}
	
	/** Resizes textContainer
	- parameters:
		- size: CGSize
	*/
	open func resizeTextContainer(_ size: CGSize) {
		self.textContainer.size = size
	}
	
	/** Updates textStorage
	- parameters:
		- attributedText: NSAttributedString
	*/
	open func updateTextStorage(_ attributedText: NSAttributedString) {
		self.textStorage.setAttributedString(attributedText)
	}
	
	/** Returns character index at a particular location
	- parameters:
		- location: CGPoint
	*/
	open func characterIndexAtLocation(_ location: CGPoint) -> Int {
		var characterIndex: Int = NSNotFound
		if self.textStorage.string.count > 0 {
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
	
	/** Returns the range which contains the index
	- parameters:
		- index: Int
	*/
	open func rangeContainingIndex(_ index: Int) -> NSRange {
		return self.layoutManager.range(ofNominallySpacedGlyphsContaining: index)
	}
	
	/** Returns bounding rectangle which encloses all the glyphs corresponding to textStorage
	*/
	open func boundingRectForCompleteText() -> CGRect {
		let initialSize = self.textContainer.size
		self.textContainer.size = CGSize(width: self.textContainer.size.width, height: CGFloat.greatestFiniteMagnitude)
		let glyphRange = self.layoutManager.glyphRange(for: textContainer)
		self.layoutManager.invalidateDisplay(forCharacterRange: NSMakeRange(0, self.textStorage.length - 1))
		let rect = self.layoutManager.boundingRect(forGlyphRange: glyphRange, in:self.textContainer)
		self.textContainer.size = initialSize
		return rect
	}
	
	/** Returns bounding rectangle based on containerSize, number of lines and font of text
	- parameters:
		- size: CGSize
		- numberOfLines: Int
		- font: UIFont
	*/
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
	
	/** Returns range at which given attributedTruncationToken can be appended
	- parameters:
		- attributedTruncationToken: NSAttributedString
	*/
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
		let completeRect = boundingRectForCompleteText()
		let sizeOfToken = attributedTruncationToken.sizeOfText()
		var rectOfToken = CGRect.zero
		rectOfToken.size = sizeOfToken
		rectOfToken.origin.x = completeRect.maxX - sizeOfToken.width
		rectOfToken.origin.y = completeRect.maxY - sizeOfToken.height
		let index = self.characterIndexAtLocation(rectOfToken.origin)
		if rangeOfText.location != NSNotFound && index != NSNotFound {
			rangeOfText.length += (rangeOfText.location - index)
			rangeOfText.location = index
		}
		return rangeOfText;
	}
	
	/** Returns range at which new line appears
	*/
	open func truncatedRangeForStringWithNewLine() -> NSRange {
		let numberOfGlyphs = self.layoutManager.numberOfGlyphs
		var lineRange = NSMakeRange(NSNotFound, 0)
		let font = self.textStorage.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as! UIFont
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

	/** Returns the array of RangeAttribute instances for a given index
	- parameters:
		- attributeKey: NSAttributedStringKey
		- index: Int
	*/
	open func rangeAttributeForKey(_ attributeKey: NSAttributedString.Key, atIndex index: Int) -> RangeAttribute {
		var rangeOfTappedText = NSRange()
		let attribute = self.textStorage.attribute(attributeKey, at: index, effectiveRange: &rangeOfTappedText)
		return RangeAttribute(key: attributeKey, attribute: attribute, range: rangeOfTappedText)
	}
	
	/** Returns the array of RangeAttribute instances for a given index
		- parameters:
			- index: Int
	*/
	open func rangeAttributesAtIndex( _ index: Int) -> [RangeAttribute] {
		var rangeOfTappedText = NSRange()
		var rangeAttributes: [RangeAttribute] = []
		self.textStorage.attributes(at: index, effectiveRange: &rangeOfTappedText).forEach { (arg) in
			
			let (key, value) = arg
			rangeAttributes.append(RangeAttribute(key: key, attribute: value, range: rangeOfTappedText))
		}
		return rangeAttributes
	}
	
	/** Adds given attribute to the textStorage for the given key at the given range
	- parameters:
		- attribute: Any
		- key: NSAttributedStringKey
		- range: NSRange
	*/
	open func addAttribute(_ attribute: Any, forkey key: NSAttributedString.Key, atRange range: NSRange) {
		self.textStorage.addAttribute(key, value: attribute, range: range)
	}
	
	/** Removes attribute from the textStorage for the given key at the given range
	- parameters:
		- key: NSAttributedStringKey
		- range: NSRange
	*/
	open func removeAttribute(forkey key: NSAttributedString.Key, atRange range: NSRange) {
		self.textStorage.removeAttribute(key, range: range)
	}
	
	/** Returns the substring present in given range of the current textStorage
	- parameters:
		- range: NSRange
	*/
	open func substringForRange(_ range: NSRange) -> String {
		return (self.textStorage.string as NSString).substring(with: range)
	}
	
	/** Returns the range of string in the current textStorage
	- parameters:
		- string: String
	*/
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
