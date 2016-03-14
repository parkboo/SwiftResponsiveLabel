//
//  ViewController.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 27/07/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
	@IBOutlet weak var customLabel: SwiftResponsiveLabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var segmentControl: UISegmentedControl!
	override func viewDidLoad() {
		super.viewDidLoad()
		customLabel.text = "Hello #hashtag @username some more text www.google.com some more text some more text some more text hsusmita4@gmail.com"
		self.customLabel.enableStringDetection("text", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
	}

	@IBAction func enableHashTagButton(sender:UIButton) {
		sender.selected = !sender.selected
		if sender.selected {
			let hashTagTapAction = PatternTapResponder {(tappedString)-> (Void) in
				let messageString = "You have tapped hashTag:"+tappedString
				self.messageLabel.text = messageString
			}
			let dict = [NSForegroundColorAttributeName : UIColor.redColor(),
				NSBackgroundColorAttributeName:UIColor.blackColor()]
			customLabel.enableHashTagDetection([RLHighlightedAttributesDictionary : dict, NSForegroundColorAttributeName: UIColor.cyanColor(),
				RLTapResponderAttributeName:hashTagTapAction])

		}else {
			customLabel.disableHashTagDetection()
		}
	}


	@IBAction func enableUserhandleButton(sender:UIButton) {
		sender.selected = !sender.selected
		if sender.selected {
			let userHandleTapAction = PatternTapResponder{ (tappedString)-> (Void) in
				let messageString = "You have tapped user handle:"+tappedString
				self.messageLabel.text = messageString
			}
			let dict = [NSForegroundColorAttributeName : UIColor.greenColor(),
				NSBackgroundColorAttributeName:UIColor.blackColor()]
			self.customLabel.enableUserHandleDetection([NSForegroundColorAttributeName:UIColor.grayColor(),
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
			self.customLabel.enableURLDetection([NSForegroundColorAttributeName:UIColor.blueColor(), RLTapResponderAttributeName:URLTapAction])
		}else {
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
			let action = PatternTapResponder {(tappedString)-> (Void) in
				let messageString = "You have tapped token string"
				self.messageLabel.text = messageString}
			let imageToken = UIImage(named: "Add-Caption-Plus")
			customLabel.truncationToken = "...Load More"
			//      customLabel.setTruncationIndicatorImage(imageToken!, size: CGSizeMake(20, 20), action: action)

		default:
			break
		}
	}

	@IBAction func enableTruncationUIButton(sender:UIButton) {
		sender.selected = !sender.selected;
		customLabel.customTruncationEnabled = sender.selected
		self.handleSegmentChange(self.segmentControl)
	}
}

