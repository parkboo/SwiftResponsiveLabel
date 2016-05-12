//
//  PatternHighlighter.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 02/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation

public class PatternHighlighter {
	static let RegexStringForHashTag = "(?<!\\w)#([\\w\\_]+)?"
	static let RegexStringForUserHandle = "(?<!\\w)@([\\w\\_]+)?"
	static let RegexFormatForSearchWord = "(%@)"

	var patternHighlightedText: NSMutableAttributedString?
	private var patternDescriptors = [String: PatternDescriptor]()
	private var attributedText: NSMutableAttributedString?

	func updateAttributeText(attributedText: NSAttributedString) {
		self.attributedText = NSMutableAttributedString(attributedString: attributedText)
		self.patternHighlightedText = self.attributedText
		for descriptor in self.patternDescriptors {
			self.enablePatternDetection(descriptor.1)
		}
	}

	func highlightPattern(pattern: String, dictionary: [String:AnyObject]) {
		do {
			let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
			let descriptor = PatternDescriptor(regularExpression: regex, searchType: PatternSearchType.All, patternAttributes: dictionary)
			self.enablePatternDetection(descriptor)
		} catch let error as NSError {
			print("NSRegularExpression Error: \(error.debugDescription)")
		}
	}

	func unhighlightPattern(pattern: String) {
		if let descriptor = self.patternDescriptors[pattern] {
			removePatternAttributes(descriptor)
			self.patternDescriptors.removeValueForKey(pattern)
		}
	}

	func enablePatternDetection(patternDescriptor:PatternDescriptor) {
		let patternKey = patternNameKeyForPatternDescriptor(patternDescriptor)
		patternDescriptors[patternKey] = patternDescriptor
		addPatternAttributes(patternDescriptor)
	}

	func disablePatternDetection(patternDescriptor:PatternDescriptor) {
		let patternKey = patternNameKeyForPatternDescriptor(patternDescriptor)
		patternDescriptors.removeValueForKey(patternKey)
		removePatternAttributes(patternDescriptor)
	}

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
