//
//  PDFViewController.swift
//  Runner
//
//  Created by Andrei E. Carvajal Brito on 08/05/23.
//

import UIKit
import PDFKit
import PDFFreedraw
import CryptoKit
import Security
import MobileCoreServices

class PDFViewController: UIViewController, UIGestureRecognizerDelegate, PDFFreedrawGestureRecognizerDelegate, UIDocumentPickerDelegate {
    
    private var path: String = ""
    private let pdfView = PDFView()
    private var pdfFreedraw: PDFFreedrawGestureRecognizer!
    
    init(_ path: String) {
        super.init(nibName: nil, bundle: nil)
        self.path = path
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func addHighlight() {
        // Get an array of selections where each selection corresponds to a single line of the selected text
         guard let selections = pdfView.currentSelection?.selectionsByLine()
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
    
    @objc func removeHighlight() {
        guard let selections = pdfView.currentSelection?.selectionsByLine()
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
    
    @objc func save() {
        //Save to file
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
                //Call Delegate
                documentPicker.delegate = self
                self.present(documentPicker, animated: true)
        
    }
    
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Create an empty Data object
        guard let fileUrl = urls.first else { return }
        do {
            var hexData = try Data(contentsOf: fileUrl)
                do {
                    let xd = try extractCertificatesAndPrivateKey(fromP12: hexData, passphrase: "")
                } catch {
                    return
                }
            } catch {
                return
            }
        }
    
    func extractCertificatesAndPrivateKey(fromP12 p12Data: Data, passphrase: String) throws -> (certificates: [SecCertificate], privateKey: SecKey) {
        var importedItems: CFArray?
        
        // Prepare the options dictionary with the passphrase
        let options: [String: Any] = [
            kSecImportExportPassphrase as String: passphrase
        ]
        
        // Import the P12 data
        let importStatus = SecPKCS12Import(p12Data as CFData, options as CFDictionary, &importedItems)
        
        guard importStatus == errSecSuccess,
              let importedItemsArray = importedItems as? [[String: Any]],
              let identityDict = importedItemsArray.first
        else {
            // Handle the case where certificate extraction fails
            throw CertificateExtractionError.extractionFailed
        }
        
        guard let cfIdentity = identityDict[kSecImportItemIdentity as String] as CFTypeRef?,
            CFGetTypeID(cfIdentity) == SecIdentityGetTypeID() else {
                throw CertificateExtractionError.extractionFailed
        }
        
        let identity = cfIdentity as! SecIdentity
        
        var privateKey: SecKey?
        let status = SecIdentityCopyPrivateKey(identity, &privateKey)
        
        guard status == errSecSuccess,
              let unwrappedPrivateKey = privateKey
        else {
            // Handle the case where private key extraction fails
            throw CertificateExtractionError.extractionFailed
        }
        
        // Extract the identity certificate and create the certificates array
        var identityCertificate: SecCertificate?
        let statusCert = SecIdentityCopyCertificate(identity, &identityCertificate)
        
        guard statusCert == errSecSuccess,
                  let unwrappedIdentityCertificate = identityCertificate
            else {
                // Handle the case where identity certificate extraction fails
                throw CertificateExtractionError.extractionFailed
            }
        
        let certificates = [unwrappedIdentityCertificate]
        
        return (certificates, unwrappedPrivateKey)
    }

    // Define a custom error type for certificate extraction failures
    enum CertificateExtractionError: Error {
        case extractionFailed
    }
    
    var toggleFreedrawOutlet: UIButton!
    var blueLineOutlet: UIButton!
    var redHighlightOutlet: UIButton!
    var eraserOutlet: UIButton!
    var perfectOvalsOutlet: UIButton!
    var undoOutlet: UIButton!
    var redoOutlet: UIButton!
    var drawingOutlet: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = UIView()
        
        // Prepare the example PDF document and PDF view
        let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path))
        
        // Layout: should be done on the main thread
        DispatchQueue.main.async {
            
            let pdfView = self.pdfView // Spares us the need to explicitly refer to "self" each time
            
            pdfView.frame = self.view.frame
            container.addSubview(pdfView)
            container.sendSubviewToBack(pdfView) // Allow the UIButtons to be on top
            
            // The following block adjusts the view and its contents in an optimal way for display and annotation
            // First - layout options necessary to ensure consistent results for all documents
            pdfView.displayMode = .singlePage
            pdfView.translatesAutoresizingMaskIntoConstraints = true
            pdfView.contentMode = .scaleAspectFit
            
            // A few additional options that can be useful
            pdfView.usePageViewController(true, withViewOptions: [:]) // Necessary if you wish to use the pdfView's internal swipe recognizers to flip pages
            pdfView.autoresizesSubviews = true
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
            
            // From here - options that should probably be set, and by this order, including the repeats
            // This ensures the proper scaling of the PDF page
            pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
            pdfView.maxScaleFactor = pdfView.scaleFactorForSizeToFit
            pdfView.sizeToFit()
            pdfView.layoutDocumentView()
            pdfView.maxScaleFactor = 5.0
            
            // Deal with the page shadows that appear by default
            if #available(iOS 12.0, *) {
                pdfView.pageShadowsEnabled = false
            } else {
                pdfView.layer.borderWidth = 15 // iOS 11: hide the d*** shadow
                pdfView.layer.borderColor = UIColor.white.cgColor
            }
            
            // For iOS 11-12, the document should be loaded only after the view is in the stack. If this is called outside the DispatchQueue block, it may be executed too early
            pdfView.document = pdfDocument
            // autoScales must be set to true, otherwise the swipe motion will drag the canvas instead of drawing. This should be done AFTER loading the document.
            pdfView.autoScales = true
        }
        
        pdfFreedraw = PDFFreedrawGestureRecognizer(color: UIColor.blue, width: 3, type: .pen)
        pdfFreedraw.delegate = self // This is for the UIGestureRecognizer delegate
        pdfFreedraw.freedrawDelegate = self // This is for undo history notifications, to inform button states
        pdfFreedraw.isEnabled = true // Not necessary by default. The simplest way to turn drawing on and off, but don't forget to turn the pdfView's isUserInteractionEnabled if you wish to restore all of its default gesture recognizers
        
        // Set the allowed number of undo actions per page. The default is 10
        // Choosing the number 0 will take that limit off, for as long as the class instance is allocated
        pdfFreedraw.maxUndoNumber = 5
        
        // Choose whether ink annotations will be erased as a whole, or by splitting their UIBezierPaths. The second option provides a more intuitive UX, but may have unpredictable results at times.
        // NB: This option only applies to ink-type annotations. Stamps, widgets, etc. will be deleted as a whole in any case.
        pdfFreedraw.eraseInkBySplittingPaths = true
        
        // Choose a factor for the stroke width of the eraser. The default is 1.
        pdfFreedraw.eraserStrokeWidthFactor = 1.0
        
        // Choose the alpha component of the highlighter type of the ink annotation
        pdfFreedraw.highlighterAlphaComponent = 0.3
        
        // Set the pdfView's isUserInteractionEnabled property to false, otherwise you'll end up swiping pages instead of drawing. This is also one of the conditions used by the PDFFreeDrawGestureRecognizer to take over the touches recognition. Below you'll see that the "Enable/Disable" button uses this property.
        pdfView.isUserInteractionEnabled = false

        // Add the gesture recognizer to the *superview* of the PDF view - another condition
        container.addGestureRecognizer(pdfFreedraw)
        
        let highlightButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            highlightButton.setImage(UIImage(systemName: "highlighter"), for: .normal)
        }
        highlightButton.addTarget(self, action: #selector(addHighlight), for: .touchUpInside)
        
        let deHighlightButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            deHighlightButton.setImage(UIImage(systemName: "trash"), for: .normal)
        }
        deHighlightButton.addTarget(self, action: #selector(removeHighlight), for: .touchUpInside)
        
        let saveButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            saveButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        }
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        toggleFreedrawOutlet = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            toggleFreedrawOutlet.setImage(UIImage(systemName: "pencil"), for: .normal)
            toggleFreedrawOutlet.addTarget(self, action: #selector(toggleFreedrawAction), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
        
        blueLineOutlet = UIButton(type: .system)
        blueLineOutlet.addTarget(self, action: #selector(blueLineAction), for: .touchUpInside)
        
        redHighlightOutlet = UIButton(type: .system)
        redHighlightOutlet.addTarget(self, action: #selector(redHighlightAction), for: .touchUpInside)
        
        eraserOutlet = UIButton(type: .system)
        eraserOutlet.addTarget(self, action: #selector(eraserAction), for: .touchUpInside)
        
        perfectOvalsOutlet = UIButton(type: .system)
        perfectOvalsOutlet.addTarget(self, action: #selector(drawPerfectOvals), for: .touchUpInside)
        
        undoOutlet = UIButton(type: .system)
        undoOutlet.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        
        redoOutlet = UIButton(type: .system)
        redoOutlet.addTarget(self, action: #selector(redoAction), for: .touchUpInside)
        
        drawingOutlet = UILabel(frame: view.bounds)
        
        // Set up the buttons
        redHighlightOutlet.tintColor = UIColor.red
        eraserOutlet.tintColor = UIColor.systemGreen
        perfectOvalsOutlet.tintColor = UIColor.darkGray
        undoOutlet.setTitleColor(UIColor.lightGray, for: .disabled)
        redoOutlet.setTitleColor(UIColor.lightGray, for: .disabled)
        perfectOvalsOutlet.setTitleColor(UIColor.lightGray, for: .disabled)
        
        let controlStackView = UIStackView(arrangedSubviews: [highlightButton, deHighlightButton, blueLineOutlet, toggleFreedrawOutlet, eraserOutlet, saveButton])
        controlStackView.axis = .horizontal
        controlStackView.alignment = .center
        controlStackView.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [container, controlStackView])
        stackView.frame = view.bounds
        stackView.axis = .vertical
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        stackView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor)
            .isActive = true
        stackView.trailingAnchor
            .constraint(equalTo: view.trailingAnchor)
            .isActive = true
        stackView.topAnchor
            .constraint(equalTo: view.topAnchor)
            .isActive = true
        stackView.bottomAnchor
            .constraint(equalTo: view.bottomAnchor)
            .isActive = true
        
        freedrawUndoStateChanged()
        updateButtonsState()
        
        // Set up a notification for PDF page changes, that will in turn trigger checking the undo and redo states for button updates. This is a recommended practice, if you wish to use the undo manager.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pdfPageChanged),
            name: NSNotification.Name.PDFViewPageChanged,
            object: nil)
    }
    
    // Update the undo and redo histories from notification above
    @objc func pdfPageChanged() {
        pdfFreedraw.updateUndoRedoState()
    }
    
    // This function makes sure you can control gestures aimed at UIButtons
    // NB: This does not work on Mac Catalyst - seems to be a bug in Catalyst
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Don't handle button taps
        return !(touch.view is UIButton)
    }
    
    // This function allows for multiple gesture recognizers to coexist
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            if gestureRecognizer is PDFFreedrawGestureRecognizer {
            return true
        }
        return false
    }
    
    
    func updateButtonsState() {
        if !pdfView.isUserInteractionEnabled { // Show controls when pdfView has no user interaction
            view.subviews.filter({$0 is UIButton && $0 != toggleFreedrawOutlet}).forEach({$0.isHidden = false})
            switch pdfFreedraw.inkType {
            case .highlighter:
                blueLineOutlet.isSelected = false
                redHighlightOutlet.isSelected = true
                eraserOutlet.isSelected = false
                if pdfFreedraw.convertClosedCurvesToOvals {
                    perfectOvalsOutlet.isSelected = true
                } else {
                    perfectOvalsOutlet.isSelected = false
                }
                perfectOvalsOutlet.isEnabled = true
                
            case .eraser:
                blueLineOutlet.isSelected = false
                redHighlightOutlet.isSelected = false
                eraserOutlet.isSelected = true
                perfectOvalsOutlet.isSelected = false
                perfectOvalsOutlet.isEnabled = false
                
            default: // .pen
                blueLineOutlet.isSelected = true
                redHighlightOutlet.isSelected = false
                eraserOutlet.isSelected = false
                if pdfFreedraw.convertClosedCurvesToOvals {
                    perfectOvalsOutlet.isSelected = true
                } else {
                    perfectOvalsOutlet.isSelected = false
                }
                perfectOvalsOutlet.isEnabled = true
            }
        } else {
            // Hide controls when pdfView has user interaction
            view.subviews.filter({$0 is UIButton && $0 != toggleFreedrawOutlet}).forEach({$0.isHidden = true})
        }
    }
    
    // This is an optional protocol stub of PDFFreedrawGestureRecognizerDelegate, which is triggered whenever a drawing or erasing action of the PDFFreedrawGestureRecognizer class starts or stops
    func freedrawStateChanged(isDrawing: Bool) {
        switch isDrawing {
        case true:
            DispatchQueue.main.async { self.drawingOutlet.isHidden = false }
        case false:
            DispatchQueue.main.async { self.drawingOutlet.isHidden = true }
        }
    }
    
    // MARK: Button States
    
    // This is the protocol stub of PDFFreedrawGestureRecognizerDelegate, which is triggered whenever there is a change in canUndo or canRedo properties of the PDFFreedrawGestureRecognizer class
    func freedrawUndoStateChanged() {
        if pdfFreedraw.canUndo {
            undoOutlet.isEnabled = true
        } else {
            undoOutlet.isEnabled = false
        }
        if pdfFreedraw.canRedo {
            redoOutlet.isEnabled = true
        } else {
            redoOutlet.isEnabled = false
        }
    }

    // MARK: Button Actions
    @available(iOS 13.0, *)
    @objc func toggleFreedrawAction(_ sender: UIButton) {
        // Toggle the drawing function
        pdfView.isUserInteractionEnabled = !pdfView.isUserInteractionEnabled
        if !pdfView.isUserInteractionEnabled {
            toggleFreedrawOutlet.setImage(UIImage(systemName: "pencil"), for: .normal)
        } else {
            toggleFreedrawOutlet.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
        }
        updateButtonsState()
    }
    
    @objc func blueLineAction(_ sender: UIButton) {
        pdfFreedraw.color = UIColor.blue
        pdfFreedraw.width = 3
        pdfFreedraw.inkType = .pen
        updateButtonsState()
    }
    
    @objc func redHighlightAction(_ sender: UIButton) {
        pdfFreedraw.color = UIColor.red
        pdfFreedraw.width = 20
        pdfFreedraw.inkType = .highlighter
        updateButtonsState()
    }
    
    @objc func eraserAction(_ sender: UIButton) {
        pdfFreedraw.inkType = .eraser
        updateButtonsState()
    }
    
    @objc func undoAction(_ sender: UIButton) {
        pdfFreedraw.undoAnnotation()
    }
    
    @objc func redoAction(_ sender: UIButton) {
        pdfFreedraw.redoAnnotation()
    }
    
    @objc func drawPerfectOvals(_ sender: UIButton) {
        pdfFreedraw.convertClosedCurvesToOvals = !pdfFreedraw.convertClosedCurvesToOvals
        updateButtonsState()
    }
}
