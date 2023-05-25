import PDFKit

class PDFDrawer: DrawingGestureRecognizerDelegate {
  weak var pdfView: PDFView!
  private var path: UIBezierPath?
  private var currentAnnotation : PDFAnnotation?
  private var currentPage: PDFPage?
    
    func gestureRecognizerBegan(_ location: CGPoint) {
      guard let page = pdfView.page(for: location, nearest: true) else { return }
      currentPage = page
      let convertedPoint = pdfView.convert(location, to: currentPage!)
      path = UIBezierPath()
      path?.move(to: convertedPoint)
    }
    
    func gestureRecognizerMoved(_ location: CGPoint) {
      guard let page = currentPage else { return }
      let convertedPoint = pdfView.convert(location, to: page)
      path?.addLine(to: convertedPoint)
      path?.move(to: convertedPoint)
      drawAnnotation(onPage: page)
    }
    
    func gestureRecognizerEnded(_ location: CGPoint) {
      guard let page = currentPage else { return }
      let convertedPoint = pdfView.convert(location, to: page)
      path?.addLine(to: convertedPoint)
      path?.move(to: convertedPoint)
      drawAnnotation(onPage: page)
      currentAnnotation = nil
    }
    
    private func createAnnotation(path: UIBezierPath, page: PDFPage) -> PDFAnnotation {
      let border = PDFBorder()
      border.lineWidth = 5.0 // Set your line width here
      let annotation = PDFAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
      annotation.color = .red
      annotation.border = border
      annotation.add(path)
      return annotation
    }
    private func drawAnnotation(onPage: PDFPage) {
      guard let path = path else { return }
      let annotation = createAnnotation(path: path, page: onPage)
      if let _ = currentAnnotation {
        currentAnnotation!.page?.removeAnnotation(currentAnnotation!)
      }
      onPage.addAnnotation(annotation)
      currentAnnotation = annotation
    }
}
