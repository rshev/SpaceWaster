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
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.freeSpaceLabel.text = "FM: \(Disk.fileManagerSystemFreeSize ?? "?"), A: \(Disk.urlVolumeAvailableCapacity ?? "?"), AfIU: \(Disk.urlVolumeAvailableCapacityForImportantUsage ?? "?"), AfOU: \(Disk.urlVolumeAvailableCapacityForOpportunisticUsage ?? "?")"
            }
        }
    }
    @IBOutlet weak var mbytesTextField: UITextField!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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
