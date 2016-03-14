//
//  TruncationHandler.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 03/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation

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
		return self.textKitStack.textStorage.string.rangeOfString(token.string) != nil
	}
}

