//
//  UIViewTestable.swift
//
//  Copyright © 2019 Purgatory Design. Licensed under the MIT License.
//

import UIKit
import XCTest

@nonobjc public extension UIView
{
    /// A description of this view and all of its subviews.
    ///
    var recursiveDescription: String {
        return self.value(forKey: "recursiveDescription") as? String ?? ""
    }

    /// Returns the receiver or one of its subviews with the specified accessibiliity identifier, waiting for the view to appear.
    ///
    /// - Parameters:
    ///   - identifier: The accessibiliity identifier to match.
    ///   - seconds: The time to wait for the view to become available.
    ///   - inclusionTest: An optional test to exclude individual views.
    /// - Returns: The receiver or matching subview (if any).
    ///
    func waitForViewWithAccessibilityIdentifier(_ identifier: String, timeout seconds: TimeInterval, where inclusionTest: ((UIView) -> Bool)? = nil) -> UIView? {
        let finder = TestViewFinder { self.viewWithAccessibilityIdentifier(identifier, where: inclusionTest) }
        return finder.waitForView(timeout: seconds)
    }

    /// Returns the receiver or one of its subviews with the specified accessibiliity label, waiting for the view to appear.
    ///
    /// - Parameters:
    ///   - label: The accessibiliity label to match.
    ///   - seconds: The time to wait for the view to become available.
    ///   - inclusionTest: An optional test to exclude individual views.
    /// - Returns: The receiver or matching subview (if any).
    ///
    func waitForViewWithAccessibilityLabel(_ label: String, timeout seconds: TimeInterval, where inclusionTest: ((UIView) -> Bool)? = nil) -> UIView? {
        let finder = TestViewFinder { self.viewWithAccessibilityLabel(label, where: inclusionTest) }
        return finder.waitForView(timeout: seconds)
    }

    private class TestViewFinder: NSObject {
        private let predicate: () -> UIView?
        private var result: UIView?

        @objc private var viewExists: Bool {
            self.result = self.predicate()
            return self.result != nil
        }

        init(predicate: @escaping () -> UIView?) {
            self.predicate = predicate
        }

        func waitForView(timeout seconds: TimeInterval) -> UIView? {
            let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "viewExists == true"), object: self)
            XCTWaiter().wait(for: [expectation], timeout: seconds)
            return self.result
        }
    }
}
