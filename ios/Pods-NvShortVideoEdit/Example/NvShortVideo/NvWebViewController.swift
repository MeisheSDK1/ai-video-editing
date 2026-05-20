//
//  NvWebViewController.swift
//  NvShortVideo
//
//  Created by Mac-Mini on 2025/8/13.
//

import UIKit
import WebKit

class NvWebViewController: UIViewController {
    var urlString: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        v.backgroundColor = .clear
        view.addSubview(v)
        let webView = WKWebView()
        view.addSubview(webView)
        guard let urlString = urlString else { return }
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        forceLTR(for: self)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
