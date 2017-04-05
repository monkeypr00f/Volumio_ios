//
//  Optional+Unwrap.swift
//
//  Created by Michael Baumgärtner on 26.09.16.
//  Copyright © 2016 Michael Baumgärtner. All rights reserved.
//

/**
 Operator to unwrap an Optional to a String.

 **Example**
 ````
 let a: Int? = 5
 a ~? "is nil"  // "5"
 let b: Float? = nil
 b ~? "is nil"  // "is nil"
 ````
 */
public func ~?<X: Unwrapable>(unwrapable: X, stringForNil: String) -> String {
    return unwrapable.unwrap(else: stringForNil)
}
infix operator ~? : NilCoalescingPrecedence

/**
	Operator to unwrap an Optional to a String.

	**Example**
	````
 let a: Int? = 5
 a~?  // "5"
 let b: Float? = nil
 b~?  // "none"
	````
 */
public postfix func ~?<X: Unwrapable>(unwrapable: X) -> String {
    return unwrapable.unwrap(else: "none")
}
postfix operator ~?

public protocol Unwrapable {
    func unwrap(else stringForNil: String) -> String
}

extension Optional: Unwrapable {

    public func unwrap(else stringForNil: String) -> String {
        switch self {
        case .some(let wrapped as Unwrapable):
            return wrapped.unwrap(else: stringForNil)
        case .some(let wrapped):
            return String(describing: wrapped)
        case .none:
            return stringForNil
        }
    }

}
