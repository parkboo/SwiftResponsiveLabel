//
//  MainViewController.swift
//  SwiftResponsiveLabel
//
//  Created by hsusmita on 02/03/16.
//  Copyright (c) 2016 hsusmita.com. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
	@IBOutlet weak var customLabel: SwiftResponsiveLabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var segmentControl: UISegmentedControl!
	override func viewDidLoad() {
		super.viewDidLoad()
		customLabel.text = "Hello #hashtag @username some aaa more text www.google.com some more text some more text some more text hsusmita4@gmail.com"
		self.customLabel.enableStringDetection("text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
		
		let regexString = "([a-z\\d])\\1\\1"
		do {
			let regex = try NSRegularExpression(pattern: regexString, options: .caseInsensitive)
			let descriptor = PatternDescriptor(regularExpression: regex, searchType: .first, patternAttributes:
				[NSAttributedString.Key.foregroundColor: UIColor.green,
				 NSAttributedString.Key.RLHighlightedForegroundColor: UIColor.green,
				 NSAttributedString.Key.RLHighlightedBackgroundColor: UIColor.black
				])
			customLabel.enablePatternDetection(patternDescriptor: descriptor)
		} catch let error as NSError {
			print("NSRegularExpression Error: \(error.debugDescription)")
		}
		
		self.segmentControl.selectedSegmentIndex = 0
		self.handleSegmentChange(segmentControl)
	}

	@IBAction func enableHashTagButton(_ sender:UIButton) {
		sender.isSelected = !sender.isSelected
		if sender.isSelected {
			let hashTagTapAction = PatternTapResponder {(tappedString)-> (Void) in
				let messageString = "You have tapped hashTag:" + tappedString
				self.messageLabel.text = messageString
			}
			let highlightedAttributes = [NSAttributedString.Key.foregroundColor : UIColor.red,
			            NSAttributedString.Key.backgroundColor : UIColor.black]
			let patternAttributes: AttributesDictionary = [
                NSAttributedString.Key.RLHighlightedAttributesDictionary : highlightedAttributes,
				NSAttributedString.Key.foregroundColor: UIColor.cyan,
				NSAttributedString.Key.RLTapResponder: hashTagTapAction]
			customLabel.enableHashTagDetection(attributes: patternAttributes)
		} else {
			customLabel.disableHashTagDetection()
		}
	}


	@IBAction func enableUserhandleButton(_ sender:UIButton) {
		sender.isSelected = !sender.isSelected
		if sender.isSelected {
			let userHandleTapAction = PatternTapResponder{ (tappedString)-> (Void) in
				let messageString = "You have tapped user handle:" + tappedString
				self.messageLabel.text = messageString
			}
			let dict = [NSAttributedString.Key.foregroundColor : UIColor.green,
			            NSAttributedString.Key.backgroundColor:UIColor.black]
			self.customLabel.enableUserHandleDetection(attributes: [
				NSAttributedString.Key.foregroundColor: UIColor.gray,
				NSAttributedString.Key.RLHighlightedAttributesDictionary: dict,
				NSAttributedString.Key.RLTapResponder:userHandleTapAction
			])
		}else {
			customLabel.disableUserHandleDetection()
		}
	}

	@IBAction func enableURLButton(_ sender:UIButton) {
		sender.isSelected = !sender.isSelected
		if sender.isSelected {
			let URLTapAction = PatternTapResponder{(tappedString)-> (Void) in
				let messageString = "You have tapped URL: " + tappedString
				self.messageLabel.text = messageString
			}
			self.customLabel.enableURLDetection(attributes: [
				NSAttributedString.Key.foregroundColor: UIColor.blue,
				NSAttributedString.Key.RLTapResponder: URLTapAction
			])
		} else {
			self.customLabel.disableURLDetection()
		}
	}

	@IBAction func handleSegmentChange(_ sender:UISegmentedControl) {
		switch(segmentControl.selectedSegmentIndex) {
		case 0:
			let action = PatternTapResponder {(tappedString)-> (Void) in
				let messageString = "You have tapped token string"
				self.messageLabel.text = messageString}
			let dict: AttributesDictionary = [
                NSAttributedString.Key.RLHighlightedBackgroundColor:UIColor.black,
				NSAttributedString.Key.RLHighlightedForegroundColor:UIColor.green,
				NSAttributedString.Key.RLTapResponder:action
			]
			let token = NSAttributedString(string: "...More",
                                           attributes: [NSAttributedString.Key.font:self.customLabel.font ?? UIFont.systemFont(ofSize: 10),
											NSAttributedString.Key.foregroundColor:UIColor.brown,
											NSAttributedString.Key.RLHighlightedAttributesDictionary: dict])
			customLabel.attributedTruncationToken = token

		case 1:
			customLabel.truncationToken = "...Load More"
		case 2:
			customLabel.truncationIndicatorImage = UIImage(named: "check")

		default:
			break
		}
	}

	@IBAction func enableTruncationUIButton(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		customLabel.customTruncationEnabled = sender.isSelected
		self.handleSegmentChange(self.segmentControl)
	}
}

