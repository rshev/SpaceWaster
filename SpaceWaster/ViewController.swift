//
//  ViewController.swift
//  SpaceWaster
//
//  Created by asdfgh1 on 11/11/2017.
//  Copyright © 2017 Roman Shevtsov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var freeSpaceLabel: UILabel! {
        didSet {
            let freeSpaceLabelTemplate = freeSpaceLabel.text ?? "%@\n%@\n%@\n%@"
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.freeSpaceLabel.text = String(
                    format: freeSpaceLabelTemplate,
                    Disk.documentsDirectorySize ?? "?",
                    Disk.urlVolumeAvailableCapacity ?? "?",
                    Disk.urlVolumeAvailableCapacityForImportantUsage ?? "?",
                    Disk.urlVolumeAvailableCapacityForOpportunisticUsage ?? "?"
                )
            }
        }
    }
    @IBOutlet weak var mbytesTextField: UITextField!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func didTapWasteSpaceButton() {
        let fileUrl = Disk.documentsDirectoryUrl.appendingPathComponent(UUID().uuidString, isDirectory: false)

        guard
            let mbytesText = mbytesTextField.text,
            let mbytes = Int(mbytesText),
            let outputStream = OutputStream(url: fileUrl, append: false)
        else {
            return
        }

        let bytesInMbyte = 1_000_000
        let buffer = [UInt8].init(repeating: 0x00, count: bytesInMbyte)

        spinnerView.startAnimating()

        DispatchQueue(label: "diskWrite").async { [weak self] in
            outputStream.open()
            defer {
                outputStream.close()
                DispatchQueue.main.async {
                    self?.spinnerView.stopAnimating()
                }
            }

            for _ in 0..<mbytes {
                let result = outputStream.write(buffer, maxLength: bytesInMbyte)
                if result != bytesInMbyte {
                    DispatchQueue.main.async {
                        self?.displayError(text: "Error writing, bytes written \(result)")
                    }
                    return
                }
            }
        }
    }

    private func displayError(text: String) {
        let alertViewController = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertViewController.addAction(cancelAction)
        present(alertViewController, animated: true, completion: nil)
    }

    @IBAction func didTapResetSandboxButton() {
        Disk.clearDocumentsDirectory()
    }
}
