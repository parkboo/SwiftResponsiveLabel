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
		self.customLabel.enableStringDetection("text", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
		
		let regexString = "([a-z\\d])\\1\\1"
		do {
			let regex = try NSRegularExpression(pattern: regexString, options: .CaseInsensitive)
			let descriptor = PatternDescriptor(regularExpression: regex, searchType: .First, patternAttributes:
				[NSForegroundColorAttributeName: UIColor.greenColor(),
					RLHighlightedForegroundColorAttributeName: UIColor.greenColor(),
					RLHighlightedBackgroundColorAttributeName: UIColor.blackColor()])
			customLabel.enablePatternDetection(patternDescriptor: descriptor)
		} catch let error as NSError {
			print("NSRegularExpression Error: \(error.debugDescription)")
		}
		
		self.segmentControl.selectedSegmentIndex = 0
		self.handleSegmentChange(segmentControl)
	}

	@IBAction func enableHashTagButton(sender:UIButton) {
		sender.selected = !sender.selected
		if sender.selected {
			let hashTagTapAction = PatternTapResponder {(tappedString)-> (Void) in
				let messageString = "You have tapped hashTag:" + tappedString
				self.messageLabel.text = messageString
			}
			let highlightedAttributes = [NSForegroundColorAttributeName : UIColor.redColor(),
			            NSBackgroundColorAttributeName : UIColor.blackColor()]
			let patternAttributes: [String: AnyObject] = [RLHighlightedAttributesDictionary : highlightedAttributes, NSForegroundColorAttributeName: UIColor.cyanColor(), RLTapResponderAttributeName:hashTagTapAction]
			customLabel.enableHashTagDetection(attributes: patternAttributes)
		} else {
			customLabel.disableHashTagDetection()
		}
	}


	@IBAction func enableUserhandleButton(sender:UIButton) {
		sender.selected = !sender.selected
		if sender.selected {
			let userHandleTapAction = PatternTapResponder{ (tappedString)-> (Void) in
				let messageString = "You have tapped user handle:" + tappedString
				self.messageLabel.text = messageString
			}
			let dict = [NSForegroundColorAttributeName : UIColor.greenColor(),
			            NSBackgroundColorAttributeName:UIColor.blackColor()]
			self.customLabel.enableUserHandleDetection(attributes: [NSForegroundColorAttributeName:UIColor.grayColor(),
				RLHighlightedAttributesDictionary: dict,
				RLTapResponderAttributeName:userHandleTapAction])
		}else {
			customLabel.disableUserHandleDetection()
		}
	}

	@IBAction func enableURLButton(sender:UIButton) {
		sender.selected = !sender.selected
		if sender.selected {
			let URLTapAction = PatternTapResponder{(tappedString)-> (Void) in
				let messageString = "You have tapped URL: " + tappedString
				self.messageLabel.text = messageString
			}
			self.customLabel.enableURLDetection(attributes: [NSForegroundColorAttributeName:UIColor.blueColor(), RLTapResponderAttributeName:URLTapAction])
		} else {
			self.customLabel.disableURLDetection()
		}
	}

	@IBAction func handleSegmentChange(sender:UISegmentedControl) {
		switch(segmentControl.selectedSegmentIndex) {
		case 0:
			let action = PatternTapResponder {(tappedString)-> (Void) in
				let messageString = "You have tapped token string"
				self.messageLabel.text = messageString}
			let dict = [RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
			            RLHighlightedForegroundColorAttributeName:UIColor.greenColor(),RLTapResponderAttributeName:action]

			let token = NSAttributedString(string: "...More",
			                               attributes: [NSFontAttributeName:self.customLabel.font,
											NSForegroundColorAttributeName:UIColor.brownColor(),
											RLHighlightedAttributesDictionary: dict])
			customLabel.attributedTruncationToken = token

		case 1:
			customLabel.truncationToken = "...Load More"
		case 2:
			customLabel.truncationIndicatorImage = UIImage(named: "check")

		default:
			break
		}
	}

	@IBAction func enableTruncationUIButton(sender: UIButton) {
		sender.selected = !sender.selected
		customLabel.customTruncationEnabled = sender.selected
		self.handleSegmentChange(self.segmentControl)
	}
}

