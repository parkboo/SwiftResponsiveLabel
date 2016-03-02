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
			let attributedString = NSAttributedString(string: text ?? "", attributes: self.attributesFromProperties())
			self.textKitStack.updateTextStorage(attributedString)
		}
	}

	override var attributedText: NSAttributedString? {
		didSet {
			self.updateTextStorage()
		}
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

	// MARK - Private Helpers

	private func updateTextStorage() {
		var finalAttributedString = NSAttributedString()
		if let attributedText = attributedText?.wordWrappedAttributedString() {
			finalAttributedString = NSAttributedString(attributedString: attributedText)
		} else {
			finalAttributedString = NSAttributedString(string: text ?? "", attributes: self.attributesFromProperties())
		}
		self.textKitStack.updateTextStorage(finalAttributedString)
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
