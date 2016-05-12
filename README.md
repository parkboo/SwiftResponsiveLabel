# SwiftResponsiveLabel

A UILabel subclass which responds to touch on specified patterns. It has the following features:

1. It can detect pattern specified by regular expression and apply style such as font, color etc.
2. It allows to replace default ellipse with tappable attributed string to mark truncation
3. Convenience methods are provided to detect hashtags, username handler and URLs

#Installation

Add following lines in your pod file  
```
pod 'SwiftResponsiveLabel', '~> 1.1'
```

#Usage

The following snippets explain the usage of public methods. These snippets assume an instance of ResponsiveLabel named "customLabel". 
```objc
import SwiftResponsiveLabel
```

In interface builder, set the custom class of your UILabel to SwiftResponsiveLabel. 

#### Username Handle Detection

```
let userHandleTapAction = PatternTapResponder{ (tappedString)-> (Void) in
let messageString = "You have tapped user handle:" + tappedString
self.messageLabel.text = messageString
}
let dict = [NSForegroundColorAttributeName: UIColor.greenColor(), 
NSBackgroundColorAttributeName: UIColor.blackColor()]
self.customLabel.enableUserHandleDetection([NSForegroundColorAttributeName:UIColor.grayColor(),
RLHighlightedAttributesDictionary: dict, RLTapResponderAttributeName:userHandleTapAction])
```   

#### URL Detection 

```
let URLTapAction = PatternTapResponder{(tappedString)-> (Void) in
let messageString = "You have tapped URL: " + tappedString
self.messageLabel.text = messageString
}
self.customLabel.enableURLDetection([NSForegroundColorAttributeName:UIColor.blueColor(), RLTapResponderAttributeName:URLTapAction])
```

#### HashTag Detection 

```
let hashTagTapAction = PatternTapResponder { (tappedString)-> (Void) in
let messageString = "You have tapped hashTag:" + tappedString
self.messageLabel.text = messageString
}
let dict = [NSForegroundColorAttributeName: UIColor.redColor(), NSBackgroundColorAttributeName: UIColor.blackColor()]
customLabel.enableHashTagDetection([RLHighlightedAttributesDictionary : dict, NSForegroundColorAttributeName: UIColor.cyanColor(), RLTapResponderAttributeName:hashTagTapAction])
```
#### Custom Truncation Token
##### Set attributed string as truncation token

```objc
let action = PatternTapResponder {(tappedString)-> (Void) in
print("You have tapped token string")
}
let dict = [RLHighlightedBackgroundColorAttributeName:UIColor.blackColor(),
RLHighlightedForegroundColorAttributeName:UIColor.greenColor(), RLTapResponderAttributeName:action]
let token = NSAttributedString(string: "...More", attributes: [NSFontAttributeName: customLabel.font, NSForegroundColorAttributeName:UIColor.brownColor(), RLHighlightedAttributesDictionary: dict])
customLabel.attributedTruncationToken = token
```