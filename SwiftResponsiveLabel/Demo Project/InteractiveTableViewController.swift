//
//  InteractiveTableViewController.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 21/11/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import UIKit

class InteractiveTableViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	var expandedPaths: [NSIndexPath] = []
	var arrayOfTexts: [String] = ["An example of very long text having #hashtags with @username and URL http://www.google.com. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."]

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.estimatedRowHeight = 200.0
		tableView.rowHeight = UITableViewAutomaticDimension
	}
}

extension InteractiveTableViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrayOfTexts.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(InteractiveTableViewCell.cellIdentifier, forIndexPath: indexPath) as! InteractiveTableViewCell
		cell.configureText(arrayOfTexts[indexPath.row], forExpandedState: !expandedPaths.contains(indexPath))
		cell.delegate = self
		return cell
	}
}

extension InteractiveTableViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}

extension InteractiveTableViewController: InteractiveTableViewCellDelegate {
	func interactiveTableViewCell(cell: InteractiveTableViewCell, shouldExpand expand: Bool) {
		guard let indexPath = tableView.indexPathForCell(cell) else {
			return
		}
		if expandedPaths.contains(indexPath) {
			expandedPaths.removeAtIndex(indexPath.row)
		} else {
			expandedPaths.append(indexPath)
		}
		self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
	}
	
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnHashTag string: String) {
		showAlertWithMessage("You have tapped on \(string)")
	}
	
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnUrl string: String) {
		showAlertWithMessage("You have tapped on \(string)")
	}
	
	func interactiveTableViewCell(cell: InteractiveTableViewCell, didTapOnUserHandle string: String) {
		showAlertWithMessage("You have tapped on \(string)")
	}
	
	func showAlertWithMessage(message: String) {
		let alertVC = UIAlertController(title: "", message: message, preferredStyle: .Alert)
		let action = UIAlertAction(title: "OK", style: .Default) { _ in
			alertVC.dismissViewControllerAnimated(true, completion: nil)
		}
		alertVC.addAction(action)
		presentViewController(alertVC, animated: true, completion: nil)
	}
}
