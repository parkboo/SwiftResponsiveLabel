//
//  InteractiveTableViewCell.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 21/11/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import UIKit

protocol InteractiveTableViewCellDelegate {
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnHashTag string: String)
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnUrl string: String)
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnUserHandle string: String)
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, shouldExpand expand: Bool)
}

extension InteractiveTableViewCellDelegate {
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnHashTag string: String){}
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnUrl string: String){}
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnUserHandle string: String){}
}

class InteractiveTableViewCell: UITableViewCell {
	@IBOutlet weak var responsiveLabel: SwiftResponsiveLabel!
	static let cellIdentifier = "InteractiveTableViewCellIdentifier"
	var delegate: InteractiveTableViewCellDelegate?
	var collapseToken = "...Read Less"
	var expandToken = "...Read More"
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		responsiveLabel.truncationToken = expandToken
		responsiveLabel.isUserInteractionEnabled = true

		// Handle Hashtag Detection
		let hashTagTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnHashTag: tappedString)
		})
		responsiveLabel.enableHashTagDetection(attributes: [
			NSAttributedStringKey.foregroundColor: UIColor.red,
			NSAttributedStringKey.RLHighlightedBackgroundColor: UIColor.orange,
			NSAttributedStringKey.RLTapResponder: hashTagTapAction
		])
		
		// Handle URL Detection
		let urlTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnUrl: tappedString)
		})
		responsiveLabel.enableURLDetection(attributes: [
			NSAttributedStringKey.foregroundColor: UIColor.brown,
			NSAttributedStringKey.RLTapResponder: urlTapAction
		])
		
		// Handle user handle Detection
		let userHandleTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnUserHandle: tappedString)
		})
		responsiveLabel.enableUserHandleDetection(attributes: [
			NSAttributedStringKey.foregroundColor: UIColor.green,
			NSAttributedStringKey.RLHighlightedForegroundColor: UIColor.green,
			NSAttributedStringKey.RLHighlightedBackgroundColor: UIColor.black,
			NSAttributedStringKey.RLTapResponder: userHandleTapAction])
	}
	
	func configureText(_ str: String, forExpandedState isExpanded: Bool) {
		if (isExpanded) {
			let	finalString = NSMutableAttributedString(string:  str + collapseToken)
			let tapResponder = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
				self.configureText(str, forExpandedState: false)
				self.delegate?.interactiveTableViewCell(self, shouldExpand: false)
			})
			let rangeOfToken = NSRange(location: str.count, length: collapseToken.count)
			finalString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font : responsiveLabel.font, NSAttributedStringKey.RLTapResponder: tapResponder], range: rangeOfToken)
			finalString.addAttributes([NSAttributedStringKey.font : responsiveLabel.font], range: NSRange(location: 0, length: finalString.length))
			responsiveLabel.numberOfLines = 0
			responsiveLabel.customTruncationEnabled = false
			responsiveLabel.attributedText = finalString
		} else {
			let truncationToken = NSMutableAttributedString(string: expandToken)
			let tapResponder = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
				self.configureText(str, forExpandedState: true)
				self.delegate?.interactiveTableViewCell(self, shouldExpand: false)
			})
			truncationToken.addAttributes([
				NSAttributedStringKey.RLTapResponder: tapResponder,
				NSAttributedStringKey.foregroundColor: UIColor.blue,
				NSAttributedStringKey.font : responsiveLabel.font
			],
				range: NSRange(location: 0, length: truncationToken.length))
			responsiveLabel.customTruncationEnabled = true
			responsiveLabel.attributedTruncationToken = truncationToken
			responsiveLabel.numberOfLines = 5
			responsiveLabel.text = str
		}
	}
}
