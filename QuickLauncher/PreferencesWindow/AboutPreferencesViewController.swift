//
//  AboutPreferencesViewController.swift
//  QuickLauncher
//
//  Created by Jianing Wang on 2019/5/1.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa

class AboutPreferencesViewController: PreferencesViewController {

    @IBOutlet weak var versionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let versionObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        versionLabel.stringValue = versionObject as? String ?? ""
    }
    
    @IBAction func githubButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/tekintian/QuickLauncher") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func contactButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "mailto:tekintian@gmail.com?subject=QuickLauncher%20Feedback") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func twitterButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://twitter.com/tekintian") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func githubSponsorsButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://dev.tekin.cn/contactus.html") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func paypalButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://dev.tekin.cn") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func alipayButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/tekintian/QuickLauncher/blob/master/Resources/alipay.jpg") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func weChatPayButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/tekintian/QuickLauncher/blob/master/Resources/weChatPay.jpg") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func camji55ButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "http://github.com/tekintian/QuickLauncher/") else { return }
        NSWorkspace.shared.open(url)   
    }
}

class LinkButton: NSButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func resetCursorRects() {
        addCursorRect(self.bounds, cursor: .pointingHand)
    }
}
