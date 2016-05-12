//
//  TouchHandler.swift
//  SwiftResponsiveLabel
//
//  Created by Susmita Horrow on 01/03/16.
//  Copyright © 2016 hsusmita.com. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class TouchGestureRecognizer: UIGestureRecognizer {

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
		super.touchesBegan(touches, withEvent: event)
		self.state = .Began
	}

	override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
		super.touchesCancelled(touches, withEvent: event)
		self.state = .Cancelled
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
		super.touchesEnded(touches, withEvent: event)
		self.state = .Ended
	}
}

class TouchHandler: NSObject {
	private var responsiveLabel: SwiftResponsiveLabel?

	var touchIndex: Int?
	var selectedRange: NSRange?
	private var defaultAttributes: [String: AnyObject]?
	private var highlightAttributes: [String: AnyObject]?
	
	init(responsiveLabel: SwiftResponsiveLabel) {
		super.init()
		self.responsiveLabel = responsiveLabel
		let gestureRecognizer = TouchGestureRecognizer(target: self, action: #selector(TouchHandler.handleTouch(_:)))
		self.responsiveLabel?.addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.delegate = self
	}

	@objc private func handleTouch(gesture: UIGestureRecognizer) {
		let touchLocation = gesture.locationInView(self.responsiveLabel)
		let index = self.responsiveLabel?.textKitStack.characterIndexAtLocation(touchLocation)
		self.touchIndex = index

		switch gesture.state {
		case .Began:
			self.beginSession()
		case .Cancelled:
			self.cancelSession()
		case .Ended:
			self.endSession()
		default:
			return
		}
	}

	private func beginSession() {
		guard let textkitStack = self.responsiveLabel?.textKitStack,
			  let touchIndex = self.touchIndex where self.touchIndex < textkitStack.textStorage.length  else { return }

		var rangeOfTappedText = NSRange()
		self.highlightAttributes = textkitStack.textStorage.attribute(RLHighlightedAttributesDictionary, atIndex: touchIndex, effectiveRange: &rangeOfTappedText) as? [String : AnyObject]

		if let attributes = self.highlightAttributes {
			self.selectedRange = rangeOfTappedText
			self.defaultAttributes = [String : AnyObject]()
			for (key, value) in attributes {
				self.defaultAttributes![key] = textkitStack.textStorage.attribute(key, atIndex: touchIndex, effectiveRange: nil)
				textkitStack.textStorage.addAttribute(key, value: value, range: rangeOfTappedText)
			}
			self.responsiveLabel?.setNeedsDisplay()
		}
		if self.selectedRange == nil {
			if let _ = textkitStack.textStorage.attribute(RLTapResponderAttributeName, atIndex: touchIndex, effectiveRange: nil) as? PatternTapResponder {
				self.selectedRange = rangeOfTappedText
			}
		}
	}

	private func cancelSession() {
		self.removeHighlight()
	}

	private func endSession() {
		self.performActionOnSelection()
		self.removeHighlight()
	}

	private func removeHighlight() {
		guard let textkitStack = self.responsiveLabel?.textKitStack,
			let selectedRange = self.selectedRange,
			let highlightAttributes = self.highlightAttributes,
			let defaultAttributes = self.defaultAttributes
			else { return }

		for (key, _) in highlightAttributes {
			textkitStack.textStorage.removeAttribute(key, range: selectedRange)
			if let defaultValue = defaultAttributes[key] {
				textkitStack.textStorage.addAttribute(key, value: defaultValue, range: selectedRange)
			}
		}

		//Clear global variables
		self.responsiveLabel?.setNeedsDisplay()
		self.selectedRange = nil
		self.defaultAttributes = nil
		self.highlightAttributes = nil
	}

	private func performActionOnSelection() {
		guard let textkitStack = self.responsiveLabel?.textKitStack, let selectedRange = self.selectedRange else { return }
		if let tapResponder = textkitStack.textStorage.attribute(RLTapResponderAttributeName, atIndex: selectedRange.location, effectiveRange: nil) as? PatternTapResponder  {
		let tappedString = (textkitStack.textStorage.string as NSString).substringWithRange(selectedRange)
			tapResponder.perform(tappedString)
		}
	}
}

extension TouchHandler : UIGestureRecognizerDelegate {
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}

	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		let touchLocation = touch.locationInView(self.responsiveLabel)
		guard let textkitStack = self.responsiveLabel?.textKitStack,
			let index = self.responsiveLabel?.textKitStack.characterIndexAtLocation(touchLocation) where index < textkitStack.textStorage.length
		 else {
		 	return false
		}
		let attributes = textkitStack.textStorage.attributesAtIndex(index, effectiveRange: nil)
		return attributes.keys.contains(RLHighlightedAttributesDictionary) || attributes.keys.contains(RLTapResponderAttributeName)
	}
}