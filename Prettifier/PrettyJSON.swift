import UIKit

private let breakLine = NSAttributedString(string: "\n")

private func emptySpace(forIndentation level: Int) -> String {
    var emptySpace = ""
    (0..<level).forEach { _ in
        emptySpace.append(contentsOf: "    ")
    }
    return emptySpace
}

public struct PrettifyingAttributes {
    let signsAttributes: [NSAttributedString.Key : Any]
    let keysAttributes: [NSAttributedString.Key : Any]
    let valuesAttributes: [NSAttributedString.Key : Any]
}

public let prettyDefault = PrettifyingAttributes(signsAttributes: [NSAttributedString.Key.foregroundColor : UIColor.red],
                                                 keysAttributes: [NSAttributedString.Key.foregroundColor : UIColor.blue],
                                                 valuesAttributes: [NSAttributedString.Key.foregroundColor : UIColor.black])

public func prettyString(fromDictionary dictionary: [String: Any], attributes: PrettifyingAttributes = prettyDefault) -> NSAttributedString {
    return prettyString(fromDictionary: dictionary, indentationLevel: 0, attributes: attributes)
}

private func prettyString(fromDictionary dictionary: [String: Any], indentationLevel: Int, attributes: PrettifyingAttributes) -> NSAttributedString {
    
    let currentIndentationSpace = emptySpace(forIndentation: indentationLevel)
    let nextIndentationSpace = NSAttributedString(string: emptySpace(forIndentation: indentationLevel + 1))
    let openBracket = NSAttributedString(string: "{\n", attributes: attributes.signsAttributes)
    let closeBracket = NSAttributedString(string: "\(currentIndentationSpace)}", attributes: attributes.signsAttributes)
    let colon = NSAttributedString(string: ": ", attributes: attributes.signsAttributes)
    let comma = NSAttributedString(string: ",", attributes: attributes.signsAttributes)
    
    let lines = dictionary.enumerated().map { (offset: Int, element: (key: String, value: Any)) -> NSAttributedString in
        let keyString = NSAttributedString(string: "\"\(element.key)\"", attributes: attributes.keysAttributes)
        
        let valueString = prettyString(fromValue: element.value, indentationLevel: indentationLevel + 1, attributes: attributes)
        
        let result: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        if dictionary.count - 1 == offset {
            [nextIndentationSpace, keyString, colon, valueString, breakLine].forEach { result.append($0) }
        } else {
            [nextIndentationSpace, keyString, colon, valueString, comma, breakLine].forEach { result.append($0) }
        }
        return result
    }
    
    let string: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    string.append(openBracket)
    lines.forEach { string.append($0) }
    string.append(closeBracket)
    
    
    return string
}


private func prettyString(fromArray array: [Any], indentationLevel: Int, attributes: PrettifyingAttributes) -> NSAttributedString {
    let currentIndentationSpace = emptySpace(forIndentation: indentationLevel)
    
    let openBracket = NSAttributedString(string: "[\n", attributes: attributes.signsAttributes)
    let closeBracket = NSAttributedString(string: "\(currentIndentationSpace)]", attributes: attributes.signsAttributes)
    let comma = NSAttributedString(string: ",", attributes: attributes.signsAttributes)
    
    let result: NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    result.append(openBracket)
    
    array.enumerated().forEach { (offset: Int, element: Any) in
        
        let valueString = prettyString(fromValue: element, indentationLevel: indentationLevel + 1, attributes: attributes)
        result.append(NSMutableAttributedString(string: emptySpace(forIndentation: indentationLevel + 1)))
        result.append(valueString)
        if array.count - 1 != offset {
            result.append(comma)
        }
        result.append(breakLine)
    }
    
    result.append(closeBracket)
    
    return result
}

private func prettyString(fromValue value: Any, indentationLevel: Int, attributes: PrettifyingAttributes) -> NSAttributedString {
    let valueString: NSAttributedString
    
    if let string = value as? String {
        valueString = NSAttributedString(string: "\"\(string)\"", attributes: attributes.valuesAttributes)
    } else if let int = value as? Int {
        valueString = NSAttributedString(string: "\(int)", attributes: attributes.valuesAttributes)
    } else if let double = value as? Double {
        valueString = NSAttributedString(string: "\(double)", attributes: attributes.valuesAttributes)
    } else if let array = value as? [Any] {
        valueString = prettyString(fromArray: array, indentationLevel: indentationLevel, attributes: attributes)
    } else if let dictionary = value as? [String: Any] {
        valueString = prettyString(fromDictionary: dictionary, indentationLevel: indentationLevel, attributes: attributes)
    } else {
        valueString = NSAttributedString(string: "\(value)")
    }
    
    return valueString
}
