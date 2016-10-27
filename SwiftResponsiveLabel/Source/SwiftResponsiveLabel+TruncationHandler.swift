//
//  TruncationHandler.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 03/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit

class InlineTextAttachment : NSTextAttachment {
	var fontDescender: CGFloat?
	
	override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
		var superRect = super.attachmentBoundsForTextContainer(textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
		superRect.origin.y = self.fontDescender ?? 0
		return superRect
	}
}

extension SwiftResponsiveLabel {
	func stringWithTruncationToken() -> NSAttributedString? {
		let currentText = self.attributedTextToDisplay
		guard let truncationToken = self.attributedTruncationToken where currentText.string.isEmpty == false else {
			return nil
		}
		let range = self.textKitStack.rangeForTokenInsertion(truncationToken)
		guard range.location != NSNotFound && range.location > 0 && (range.location + range.length) <= currentText.length else {
			return nil
		}
		var attributedString = NSMutableAttributedString()
		attributedString = NSMutableAttributedString(attributedString: currentText)
		attributedString.replaceCharactersInRange(range, withAttributedString: truncationToken)
		return attributedString
	}

	func truncationTokenAppended() -> Bool {
		guard let token = self.attributedTruncationToken else {
			return false
		}
		return self.textKitStack.rangeOfString(token.string).location != NSNotFound
	}
	
	func attributedStringWithImage(image: UIImage, withSize size: CGSize, andAction action: PatternTapResponder?) -> NSAttributedString {
		let textAttachment = InlineTextAttachment()
		textAttachment.image = image
		textAttachment.fontDescender = self.font.descender;
		textAttachment.bounds = CGRectMake(0, -self.font.descender - self.font.lineHeight/2, size.width, size.height)
		let imageAttributedString = NSAttributedString(attachment: textAttachment)
		let paddingString = NSAttributedString(string: " ")
		let finalString = NSMutableAttributedString(attributedString: paddingString)
		finalString.appendAttributedString(imageAttributedString)
		finalString.appendAttributedString(paddingString)
		if let action = action {
			finalString.addAttribute(RLTapResponderAttributeName, value: action, range: NSMakeRange(0, finalString.length))
		}
		return finalString
	}
}

