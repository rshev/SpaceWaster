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
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.freeSpaceLabel.text = """
                FileManager System Free Size: \(Disk.fileManagerSystemFreeSize ?? "?")
                URL Volume Available Capacity: \(Disk.urlVolumeAvailableCapacity ?? "?")
                ... for Important Usage: \(Disk.urlVolumeAvailableCapacityForImportantUsage ?? "?")
                ... for Opportunistic Usage: \(Disk.urlVolumeAvailableCapacityForOpportunisticUsage ?? "?")
                """
            }
        }
    }
    @IBOutlet weak var mbytesTextField: UITextField!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private var documentsDirectory: String {
        return "\(NSHomeDirectory())/Documents"
    }

    private var documentsDirectoryUrl: URL {
        return URL.init(fileURLWithPath: documentsDirectory, isDirectory: true)
    }

    @IBAction func didTapWasteSpaceButton() {
        let fileUrl = documentsDirectoryUrl.appendingPathComponent(UUID().uuidString, isDirectory: false)

        guard
            let mbytesText = mbytesTextField.text,
            let mbytes = Int(mbytesText),
            let outputStream = OutputStream(url: fileUrl, append: false)
        else {
            return
        }

        let bytesInMbyte = 1_048_576
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
        do {
            try FileManager.default.contentsOfDirectory(at: documentsDirectoryUrl, includingPropertiesForKeys: nil).forEach({
                try FileManager.default.removeItem(at: $0)
            })
        }
        catch {}
    }
}
