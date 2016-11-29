//
//  InteractiveTableViewCell.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 21/11/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import UIKit

protocol InteractiveTableViewCellDelegate {
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnHashTag string: String)
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnUrl string: String)
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnUserHandle string: String)
	func interactiveTableViewCell(cell: InteractiveTableViewCell, shouldExpand expand: Bool)
}

extension InteractiveTableViewCellDelegate {
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnHashTag string: String){}
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnUrl string: String){}
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnUserHandle string: String){}
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
		responsiveLabel.userInteractionEnabled = true

		// Handle Hashtag Detection
		let hashTagTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnHashTag: tappedString)
		})
		responsiveLabel.enableHashTagDetection([NSForegroundColorAttributeName: UIColor.redColor(),
			RLHighlightedBackgroundColorAttributeName: UIColor.orangeColor(),
			RLTapResponderAttributeName: hashTagTapAction])
		
		// Handle URL Detection
		let urlTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnUrl: tappedString)
		})
		responsiveLabel.enableURLDetection([NSForegroundColorAttributeName: UIColor.cyanColor(),
			RLTapResponderAttributeName: urlTapAction])
		
		// Handle user handle Detection
		let userHandleTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnUserHandle: tappedString)
		})
		responsiveLabel.enableUserHandleDetection([NSForegroundColorAttributeName: UIColor.grayColor(),
			RLHighlightedForegroundColorAttributeName: UIColor.greenColor(),
			RLHighlightedBackgroundColorAttributeName: UIColor.blackColor(),
			RLTapResponderAttributeName: userHandleTapAction])
	}
	
	func configureText(str: String, forExpandedState isExpanded: Bool) {
		if (isExpanded) {
			let	finalString = NSMutableAttributedString(string:  str + collapseToken)
			let tapResponder = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
				self.configureText(str, forExpandedState: false)
				self.delegate?.interactiveTableViewCell(self, shouldExpand: false)
			})
			let rangeOfToken = NSRange(location: str.characters.count, length: collapseToken.characters.count)
			finalString.addAttributes([NSForegroundColorAttributeName: UIColor.blueColor(), NSFontAttributeName : responsiveLabel.font, RLTapResponderAttributeName: tapResponder], range: rangeOfToken)
			finalString.addAttributes([NSFontAttributeName : responsiveLabel.font], range: NSRange(location: 0, length: finalString.length))
			responsiveLabel.numberOfLines = 0
			responsiveLabel.customTruncationEnabled = false
			responsiveLabel.attributedText = finalString
		} else {
			let truncationToken = NSMutableAttributedString(string: expandToken)
			let tapResponder = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
				self.configureText(str, forExpandedState: true)
				self.delegate?.interactiveTableViewCell(self, shouldExpand: false)
			})
			truncationToken.addAttributes([RLTapResponderAttributeName: tapResponder,
				NSForegroundColorAttributeName: UIColor.blueColor(),
				NSFontAttributeName : responsiveLabel.font],
				range: NSRange(location: 0, length: truncationToken.length))
			responsiveLabel.customTruncationEnabled = true
			responsiveLabel.attributedTruncationToken = truncationToken
			responsiveLabel.numberOfLines = 5
			responsiveLabel.text = str
		}
	}
}
