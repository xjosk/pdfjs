import Flutter
import UIKit
import PDFKit

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
              return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _vc: UIViewController

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        let argTest = args as? [String: Any]
        let path = argTest?["path"] as? String ?? ""
        _vc = PDFViewController(path)
        super.init()
        // iOS views can be created here
        // createNativeView(view: _view)
    }

    func view() -> UIView {
        return _vc.view
    }
    
    /* @objc func highlightButtonTapped() {
        // Get an array of selections where each selection corresponds to a single line of the selected text
         guard let selections = _pdfView.currentSelection?.selectionsByLine()
             else { return }

         // Loop over the selections line by line
         selections.forEach({ selection in
             // Loop over the pages encompassed by each selection
             selection.pages.forEach({ page in
                 page.annotations.forEach({ annotation in
                     if(annotation.isHighlighted) {
                         page.removeAnnotation(annotation)
                     }
                 })
                 // Create a new highlight annotation with the selection's bounds and add it to the page
                 let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)
                 highlight.color = .yellow
                 page.addAnnotation(highlight)
             })
         })
    }
    
    @objc func removeAnnotation() {
        guard let selections = _pdfView.currentSelection?.selectionsByLine()
            else { return }
        selections.forEach({ selection in
            // Loop over the pages encompassed by each selection
            selection.pages.forEach({ page in
                page.annotations.forEach({ annotation in
                    if(annotation.markupType == .highlight) {
                        page.removeAnnotation(annotation)
                    }
                })
            })
        })
    }
    
    @objc func addAnnotation() {
        // Get the current page
        guard let page = _pdfView.currentPage else {return}
        // Create a rectangular path
        // Note that in PDF page coordinate space, (0,0) is the bottom left corner of the page
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 100, height: 100))
        let inkAnnotation = PDFAnnotation(bounds: page.bounds(for: _pdfView.displayBox), forType: .ink, withProperties: nil)
        inkAnnotation.add(path)
        page.addAnnotation(inkAnnotation)
    }
    
    private let pdfDrawer = PDFDrawer()
    private var canDraw = false
    private let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
    
    
    @objc func draw() {
        canDraw = !canDraw
        if(canDraw) {
            _pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
            pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
            pdfDrawer.pdfView = _pdfView
        } else {
            _pdfView.removeGestureRecognizer(pdfDrawingGestureRecognizer)
        }
    } */

    func createNativeView(view _view: UIView){
        
        
        
        /* let stackView = UIStackView(frame: _view.bounds)
        
        stackView.axis = .vertical
        
        _pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _pdfView.autoScales = true
        
        stackView.addArrangedSubview(_pdfView)
        
        
        
        let fileURL = URL(fileURLWithPath: _path)
        _pdfView.document = PDFDocument(url: fileURL)
        
        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.alignment = .center
        hStackView.distribution = .fillEqually
        stackView.addArrangedSubview(hStackView)
        
        let highlightButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            highlightButton.setImage(UIImage(systemName: "highlighter"), for: .normal)
        }
        highlightButton.addTarget(self, action: #selector(highlightButtonTapped), for: .touchUpInside)
        hStackView.addArrangedSubview(highlightButton)
        
        let addAnnotationButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            addAnnotationButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        }
        addAnnotationButton.addTarget(self, action: #selector(addAnnotation), for: .touchUpInside)
        hStackView.addArrangedSubview(addAnnotationButton)
        
        let removeHighlightButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            removeHighlightButton.setImage(UIImage(systemName: "eraser"), for: .normal)
        }
        removeHighlightButton.addTarget(self, action: #selector(removeAnnotation), for: .touchUpInside)
        hStackView.addArrangedSubview(removeHighlightButton)
        
        let drawButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            drawButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
        drawButton.addTarget(self, action: #selector(draw), for: .touchUpInside)
        drawButton.setNeedsDisplay()
        hStackView.addArrangedSubview(drawButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        _view.addSubview(stackView)
        
        stackView.leadingAnchor
            .constraint(equalTo: _view.leadingAnchor)
            .isActive = true
        stackView.trailingAnchor
            .constraint(equalTo: _view.trailingAnchor)
            .isActive = true
        stackView.topAnchor
            .constraint(equalTo: _view.topAnchor)
            .isActive = true
        stackView.bottomAnchor
            .constraint(equalTo: _view.bottomAnchor)
            .isActive = true */
    }
}
