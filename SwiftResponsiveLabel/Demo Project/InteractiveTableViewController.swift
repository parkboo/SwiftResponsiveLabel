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
	var arrayOfTexts: [String] = ["We show our solutions to problems we find while building Swift projects. Enjoy a new episode of Swift Talk every week, packed with live-coding and discussions about the pros and cons of our decisions. We show our solutions to problems we find while building Swift projects. Enjoy a new episode of Swift Talk every week, packed with live-coding and discussions about the pros and cons of our decisions. Enjoy a new episode of Swift Talk every week, packed with live-coding and discussions about the pros and cons of our decisions.Enjoy a new episode of Swift Talk every week, packed with live-coding and discussions about the pros and cons of our decisions."]
//	,
//	"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."]
//	
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
//		cell.label.text = arrayOfTexts[indexPath.row]
		cell.configureText(arrayOfTexts[indexPath.row], forExpandedState: true)
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
		
		cell.configureText(arrayOfTexts[indexPath.row], forExpandedState: expand)
	}
}
