//
//  ViewController.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 29/02/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var customLabel: SwiftResponsiveLabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		let attributedText = NSMutableAttributedString(string: "Hello #hashtag @username some more text www.google.com some more text some more textsome more text hsusmita4@gmail.com",
			attributes: [NSForegroundColorAttributeName: UIColor.blueColor()])
		let attributes = [NSForegroundColorAttributeName : UIColor.greenColor(), NSBackgroundColorAttributeName : UIColor.blackColor()]
		attributedText.addAttribute(RLHighlightedAttributesDictionary, value: attributes,
		 range: (attributedText.string as NSString).rangeOfString("www.google.com"))
		attributedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.grayColor(),
		 range: (attributedText.string as NSString).rangeOfString("www.google.com"))
		let tapResponder = PatternTapResponder { (tappedString) -> (Void) in
			print("tapped on = \(tappedString)")
		}
		attributedText.addAttribute(RLTapResponderAttributeName, value: tapResponder, range: (attributedText.string as NSString).rangeOfString("www.google.com"))
		self.customLabel.attributedText = attributedText
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

