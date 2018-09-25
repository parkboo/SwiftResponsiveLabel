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
		self.customLabel.enableStringDetection("text", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
		
		let regexString = "([a-z\\d])\\1\\1"
		do {
			let regex = try NSRegularExpression(pattern: regexString, options: .caseInsensitive)
			let descriptor = PatternDescriptor(regularExpression: regex, searchType: .first, patternAttributes:
				[NSAttributedStringKey.foregroundColor: UIColor.green,
				 NSAttributedStringKey.RLHighlightedForegroundColor: UIColor.green,
				 NSAttributedStringKey.RLHighlightedBackgroundColor: UIColor.black
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
			let highlightedAttributes = [NSAttributedStringKey.foregroundColor : UIColor.red,
			            NSAttributedStringKey.backgroundColor : UIColor.black]
			let patternAttributes: AttributesDictionary = [
				NSAttributedStringKey.RLHighlightedAttributesDictionary : highlightedAttributes,
				NSAttributedStringKey.foregroundColor: UIColor.cyan,
				NSAttributedStringKey.RLTapResponder: hashTagTapAction]
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
			let dict = [NSAttributedStringKey.foregroundColor : UIColor.green,
			            NSAttributedStringKey.backgroundColor:UIColor.black]
			self.customLabel.enableUserHandleDetection(attributes: [
				NSAttributedStringKey.foregroundColor: UIColor.gray,
				NSAttributedStringKey.RLHighlightedAttributesDictionary: dict,
				NSAttributedStringKey.RLTapResponder:userHandleTapAction
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
				NSAttributedStringKey.foregroundColor: UIColor.blue,
				NSAttributedStringKey.RLTapResponder: URLTapAction
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
				NSAttributedStringKey.RLHighlightedBackgroundColor:UIColor.black,
				NSAttributedStringKey.RLHighlightedForegroundColor:UIColor.green,
				NSAttributedStringKey.RLTapResponder:action
			]
			let token = NSAttributedString(string: "...More",
			                               attributes: [NSAttributedStringKey.font:self.customLabel.font,
											NSAttributedStringKey.foregroundColor:UIColor.brown,
											NSAttributedStringKey.RLHighlightedAttributesDictionary: dict])
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

