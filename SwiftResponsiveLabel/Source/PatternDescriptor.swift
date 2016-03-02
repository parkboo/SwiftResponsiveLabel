//
//  PatternDescriptor.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 02/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
/**
Specifies the type of Pattern Search
*/
public enum PatternSearchType:Int {
	case All,First,Last
}

/**
PatternDescriptor Struct encapsulates following information regarding pattern to be matched

1. Regular Expression for the pattern : NSRegularExpression
2. Attributes for the pattern : [String:NSObject]
3. Type of pattern search : PatternSearchType

*/

public struct PatternDescriptor {
	let searchType : PatternSearchType
	let patternAttributes : [String:AnyObject]?
	let patternExpression : NSRegularExpression

	public init(regularExpression: NSRegularExpression, searchType: PatternSearchType, patternAttributes: [String:AnyObject]?) {
		self.patternExpression = regularExpression
		self.searchType = searchType
		self.patternAttributes = patternAttributes
	}

	public init(dataDetector: NSDataDetector, searchType: PatternSearchType, patternAttributes: [String:AnyObject]?) {
		self.patternExpression = dataDetector
		self.searchType = searchType
		self.patternAttributes = patternAttributes
	}

	/**
	Generates array of ranges for the matches found in given string
	*/
	public func patternRangesForString(string:String) -> [NSRange] {
		switch(self.searchType) {

		case .All:
			return allMatchingPattern(string)

		case .First:
			return [firstMatchingPattern(string)]

		case .Last:
			return [allMatchingPattern(string)].last!
		}
	}

	/**
	Returns array of ranges for the matches found in given string
	*/
	func allMatchingPattern(string:String) -> [NSRange] {
		var generatedRanges = [NSRange]()
		self.patternExpression.enumerateMatchesInString(string, options: .ReportCompletion, range: NSMakeRange(0, string.characters.count)){
		 (result, flag, stop) -> Void in
			if let result = result {
				generatedRanges.append(result.range)
			}
		}

		return generatedRanges
	}

	/**
	Returns range of first match found in given string
	*/
	func firstMatchingPattern(string:String) -> NSRange {
		return self.patternExpression.rangeOfFirstMatchInString(string, options: .ReportProgress, range: NSMakeRange(0, string.characters.count))
	}
}