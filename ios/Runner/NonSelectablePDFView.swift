//
//  NonSelectablePDFView.swift
//  Runner
//
//  Created by Andrei E. Carvajal Brito on 08/05/23.
//

import Foundation

import UIKit
import PDFKit
class NonSelectablePDFView: PDFView {
// Disable selection
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return false
  }
  override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
    if gestureRecognizer is UILongPressGestureRecognizer {
      gestureRecognizer.isEnabled = false
    }
    super.addGestureRecognizer(gestureRecognizer)
  }
}
