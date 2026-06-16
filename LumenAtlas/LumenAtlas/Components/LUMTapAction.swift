//
//  LUMTapAction.swift
//  LumenAtlas
//
//  A tiny closure-based tap gesture. Lets glass cards act as buttons without a
//  target/action dance or a UIControl subclass at every call site.
//

import UIKit

final class LUMTapAction: UITapGestureRecognizer {
    private let handler: () -> Void

    init(_ handler: @escaping () -> Void) {
        self.handler = handler
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(fire))
    }

    @objc private func fire() { handler() }
}

extension UIView {
    /// Attach a closure-based tap. The recognizer retains the closure; the view
    /// retains the recognizer, so lifetime matches the view.
    func addAction(_ tap: LUMTapAction) {
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
    }
}
