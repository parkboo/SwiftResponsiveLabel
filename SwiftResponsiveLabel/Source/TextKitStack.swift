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
	var textStorage = NSTextStorage()
	private var currentTextOffset = CGPointZero

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
			let rangePointer = NSRangePointer()
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
		let glyphRange = self.layoutManager.glyphRangeForTextContainer(textContainer)
		return self.layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer:self.textContainer)
	}
	
	func rectFittingTextForContainerSize(size: CGSize, numberOfLines: Int, font: UIFont) -> CGRect {
		self.textContainer.size = size
		self.textContainer.maximumNumberOfLines = numberOfLines
		var textBounds = self.layoutManager.boundingRectForGlyphRange(NSMakeRange(0, self.layoutManager.numberOfGlyphs), inTextContainer: self.textContainer)
		let totalLines = Int(textBounds.size.height / font.lineHeight)

		if (numberOfLines > 0 && (numberOfLines < totalLines)) {
			textBounds.size.height -= CGFloat(totalLines - numberOfLines) * font.lineHeight
		}else if (numberOfLines > 0 && (numberOfLines) > totalLines) {
			textBounds.size.height += CGFloat(numberOfLines - totalLines) * font.lineHeight
		}
		textBounds.size.width = ceil(textBounds.size.width)
		textBounds.size.height = ceil(textBounds.size.height)
		self.textContainer.size = textBounds.size
		return textBounds;
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