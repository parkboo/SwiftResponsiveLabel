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

final class InteractiveTableViewCell: UITableViewCell {
	@IBOutlet weak var responsiveLabel: SwiftResponsiveLabel!
	static let cellIdentifier = "InteractiveTableViewCellIdentifier"
	var delegate: InteractiveTableViewCellDelegate?
	var collapseToken = "...Read Less"
	var expandToken = "...Read More"
	private var expandAttributedToken = NSMutableAttributedString(string: "")
	private var collapseAttributedToken = NSMutableAttributedString(string: "")

	override func awakeFromNib() {
		super.awakeFromNib()
		
		responsiveLabel.truncationToken = expandToken
		responsiveLabel.isUserInteractionEnabled = true

		// Handle Hashtag Detection
		let hashTagTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnHashTag: tappedString)
		})
		responsiveLabel.enableHashTagDetection(attributes: [
			NSAttributedString.Key.foregroundColor: UIColor.red,
			NSAttributedString.Key.RLHighlightedBackgroundColor: UIColor.orange,
			NSAttributedString.Key.RLTapResponder: hashTagTapAction
		])
		
		// Handle URL Detection
		let urlTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnUrl: tappedString)
		})
		responsiveLabel.enableURLDetection(attributes: [
			NSAttributedString.Key.foregroundColor: UIColor.brown,
			NSAttributedString.Key.RLTapResponder: urlTapAction
		])
		
		// Handle user handle Detection
		let userHandleTapAction = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, didTapOnUserHandle: tappedString)
		})
		responsiveLabel.enableUserHandleDetection(attributes: [
			NSAttributedString.Key.foregroundColor: UIColor.green,
			NSAttributedString.Key.RLHighlightedForegroundColor: UIColor.green,
			NSAttributedString.Key.RLHighlightedBackgroundColor: UIColor.black,
			NSAttributedString.Key.RLTapResponder: userHandleTapAction])

		let tapResponder = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, shouldExpand: true)
		})
		self.expandAttributedToken = NSMutableAttributedString(string: self.expandToken)
		self.expandAttributedToken.addAttributes([
			NSAttributedString.Key.RLTapResponder: tapResponder,
			NSAttributedString.Key.foregroundColor: UIColor.blue,
			NSAttributedString.Key.font : responsiveLabel.font ?? UIFont.systemFont(ofSize: 10)
			],range: NSRange(location: 0, length: self.expandAttributedToken.length))

		self.collapseAttributedToken = NSMutableAttributedString(string: self.collapseToken)
		let collapseTapResponder = PatternTapResponder(currentAction: { (tappedString) -> (Void) in
			self.delegate?.interactiveTableViewCell(self, shouldExpand: false)
		})

		self.collapseAttributedToken.addAttributes([
			NSAttributedString.Key.foregroundColor: UIColor.blue,
			NSAttributedString.Key.font : responsiveLabel.font ?? UIFont.systemFont(ofSize: 10),
			NSAttributedString.Key.RLTapResponder: collapseTapResponder
			], range: NSRange(location: 0, length: self.collapseAttributedToken.length))
	}
	
	func configureText(_ str: String, forExpandedState isExpanded: Bool) {
		if (isExpanded) {
			let	finalString = NSMutableAttributedString(string: str)
			finalString.append(self.collapseAttributedToken)
			finalString.addAttributes([NSAttributedString.Key.font : responsiveLabel.font ?? UIFont.systemFont(ofSize: 10)], range: NSRange(location: 0, length: finalString.length))
			responsiveLabel.numberOfLines = 0
			responsiveLabel.customTruncationEnabled = false
			responsiveLabel.attributedText = finalString
		} else {
			responsiveLabel.customTruncationEnabled = true
			responsiveLabel.attributedTruncationToken = self.expandAttributedToken
			responsiveLabel.numberOfLines = 5
			responsiveLabel.text = str
		}
	}
}
