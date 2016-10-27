//
//  PatternHighlighter.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 02/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation

/** This class is reponsible for finding patterns and applying attributes to those patterns
*/

public class PatternHighlighter {
	static let RegexStringForHashTag = "(?<!\\w)#([\\w\\_]+)?"
	static let RegexStringForUserHandle = "(?<!\\w)@([\\w\\_]+)?"
	static let RegexFormatForSearchWord = "(%@)"

	var patternHighlightedText: NSMutableAttributedString?
	private var patternDescriptors: [String: PatternDescriptor] = [:]
	private var attributedText: NSMutableAttributedString?
	
	/** Update current attributed text and apply attributes based on current patternDescriptors
	- parameters:
		- attributedText: NSAttributedString
	*/
	func updateAttributedText(attributedText: NSAttributedString) {
		self.attributedText = NSMutableAttributedString(attributedString: attributedText)
		self.patternHighlightedText = self.attributedText
		for descriptor in self.patternDescriptors {
			self.enablePatternDetection(descriptor.1)
		}
	}
	
	/** Add attributes to the range of strings matching the given regex string
	- parameters:
		- regexString: String
		- dictionary: [String:AnyObject]
	*/
	func highlightPattern(regexString: String, dictionary: [String:AnyObject]) {
		do {
			let regex = try NSRegularExpression(pattern: regexString, options: .CaseInsensitive)
			let descriptor = PatternDescriptor(regularExpression: regex, searchType: PatternSearchType.All, patternAttributes: dictionary)
			self.enablePatternDetection(descriptor)
		} catch let error as NSError {
			print("NSRegularExpression Error: \(error.debugDescription)")
		}
	}

	/** Removes attributes from the range of strings matching the given regex string
	- parameters:
		- regexString: String
	*/
	func unhighlightPattern(regexString regexString: String) {
		if let descriptor = self.patternDescriptors[regexString] {
			self.removePatternAttributes(descriptor)
			self.patternDescriptors.removeValueForKey(regexString)
		}
	}
	
	/** Detects patterns, applies attributes defined as per patternDescriptor and handles touch(If RLTapResponderAttributeName key is added in dictionary)
	- parameters:
		- patternDescriptor: PatternDescriptor
	
		- This object encapsulates the regular expression and attributes to be added to the pattern.
	*/
	func enablePatternDetection(patternDescriptor:PatternDescriptor) {
		let patternKey = patternNameKeyForPatternDescriptor(patternDescriptor)
		patternDescriptors[patternKey] = patternDescriptor
		addPatternAttributes(patternDescriptor)
	}
	
	/** Removes previously applied attributes from all the occurance of pattern dictated by pattern descriptor
	- parameters:
		- patternDescriptor: PatternDescriptor
	*/
	func disablePatternDetection(patternDescriptor:PatternDescriptor) {
		let patternKey = patternNameKeyForPatternDescriptor(patternDescriptor)
		patternDescriptors.removeValueForKey(patternKey)
		removePatternAttributes(patternDescriptor)
	}
	
	// MARK: - Private Helpers
	
	private func patternNameKeyForPatternDescriptor(patternDescriptor:PatternDescriptor)-> String {
		let key:String
		if patternDescriptor.patternExpression.isKindOfClass(NSDataDetector) {
			let types = (patternDescriptor.patternExpression as! NSDataDetector).checkingTypes
			key = String(types)
		}else {
			key = patternDescriptor.patternExpression.pattern;
		}
		return key
	}

	private func removePatternAttributes(patternDescriptor:PatternDescriptor) {
		guard let attributedText = self.attributedText else {
			return
		}
		//Generate ranges for current text of textStorage
		let patternRanges = patternDescriptor.patternRangesForString(attributedText.string)
		for range in patternRanges { //Remove attributes from the ranges conditionally
			if let attributes = patternDescriptor.patternAttributes {
				for (name, _) in attributes {
					attributedText.removeAttribute(name, range: range)
				}
			}
		}
	}

	private func addPatternAttributes(patternDescriptor:PatternDescriptor) {
		guard let attributedText = self.patternHighlightedText else {
			return
		}
		//Generate ranges for attributed text of the label
		let patternRanges = patternDescriptor.patternRangesForString(attributedText.string)
		for range in patternRanges { //Apply attributes to the ranges conditionally
			attributedText.addAttributes(patternDescriptor.patternAttributes!, range: range)
		}
	}
}
