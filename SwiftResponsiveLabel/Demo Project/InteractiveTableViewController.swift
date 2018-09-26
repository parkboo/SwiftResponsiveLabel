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
	var expandedPaths: [IndexPath] = []
	var arrayOfTexts: [String] = ["An example of very long text having #hashtags with @username and URL http://www.google.com. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."]
//	var arrayOfTexts: [String] = ["a\nb\nc\nd\n\\e\n\\f\n"]

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.estimatedRowHeight = 200.0
		tableView.rowHeight = UITableViewAutomaticDimension
	}
}

extension InteractiveTableViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrayOfTexts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: InteractiveTableViewCell.cellIdentifier, for: indexPath) as! InteractiveTableViewCell
		cell.configureText(arrayOfTexts[indexPath.row], forExpandedState: expandedPaths.contains(indexPath))
		cell.delegate = self
		return cell
	}
}

extension InteractiveTableViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}

extension InteractiveTableViewController: InteractiveTableViewCellDelegate {
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, shouldExpand expand: Bool) {
		guard let indexPath = tableView.indexPath(for: cell) else {
			return
		}
		if expandedPaths.contains(indexPath) {
			expandedPaths.remove(at: indexPath.row)
		} else {
			expandedPaths.append(indexPath)
		}
//		self.tableView.reloadRows(at: [indexPath], with: .none)
		self.tableView.reloadData()
	}
	
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnHashTag string: String) {
		showAlertWithMessage("You have tapped on \(string)")
	}
	
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnUrl string: String) {
		showAlertWithMessage("You have tapped on \(string)")
	}
	
	func interactiveTableViewCell(_ cell: InteractiveTableViewCell, didTapOnUserHandle string: String) {
		showAlertWithMessage("You have tapped on \(string)")
	}
	
	func showAlertWithMessage(_ message: String) {
		let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default) { _ in
			alertVC.dismiss(animated: true, completion: nil)
		}
		alertVC.addAction(action)
		present(alertVC, animated: true, completion: nil)
	}
}
