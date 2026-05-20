//
//  NvPublicViewController.swift
//  NvShortVideo
//
//  Created by Mac-Mini on 2025/8/12.
//

import UIKit
import NvShortVideoCore

class NvPublicViewController: UIViewController, NvModuleManagerCompileStateDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveBt: UIButton!
    @IBOutlet weak var compileBt: UIButton!
    @IBOutlet weak var saveCoverBt: UIButton!
    @IBOutlet weak var saveCoverleading: NSLayoutConstraint!
    
    var moduleManager: NvModuleManager!
    
    // 额外属性（原代码中 implied 存在）
    var imagePath: String?
    var videoPath: String?
    var projectId: String?
    var projectDescription: String?
    var hasDraft: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.foregroundColor] = UIColor.white
        attributes[.font] = UIFont.systemFont(ofSize: 16)
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        navigationItem.title = NSLocalizedString("Publish", comment: "Post")
        
        let image = UIImage(named: "navigation_whiteback")
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        backButton.setImage(image, for: .normal)
        backButton.addTarget(self, action: #selector(leftBtClicked), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        moduleManager = NvModuleManager.sharedInstance()
        moduleManager.compileDelegate = self
        
        if let path = imagePath {
            imageView.image = UIImage(contentsOfFile: path)
        }
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 2
        
        saveBt.clipsToBounds = true
        saveBt.layer.cornerRadius = 2
        
        compileBt.clipsToBounds = true
        compileBt.layer.cornerRadius = 2
        
        saveBt.isHidden = !hasDraft
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // 占位符
        let placeHolderLabel = UILabel()
        placeHolderLabel.text = NSLocalizedString("Publish_Info", comment: "Write a headline and use the right topic to reach more people")
        placeHolderLabel.numberOfLines = 0
        placeHolderLabel.textColor = .lightGray
        placeHolderLabel.font = UIFont.systemFont(ofSize: 15)
        placeHolderLabel.sizeToFit()
        textView.addSubview(placeHolderLabel)
        textView.setValue(placeHolderLabel, forKey: "_placeholderLabel")
        
        textView.text = projectDescription
        
        compileBt.setTitle(NSLocalizedString("Save_Local", comment: "Save to album"), for: .normal)
        saveBt.setTitle(NSLocalizedString("Save_Draft", comment: "Save Draft"), for: .normal)
        saveCoverBt.setTitle(NSLocalizedString("Save_Cover", comment: "Save Cover"), for: .normal)
        
        compileBt.layer.cornerRadius = 10
        saveBt.layer.cornerRadius = 10
        saveCoverBt.layer.cornerRadius = 10
        
        saveBt.backgroundColor = UIColor(red: 47/255.0, green: 47/255.0, blue: 47/255.0, alpha: 1)
        compileBt.backgroundColor = UIColor(red: 252/255.0, green: 62/255.0, blue: 90/255.0, alpha: 1)
        saveCoverBt.backgroundColor = UIColor(red: 252/255.0, green: 62/255.0, blue: 90/255.0, alpha: 1)
        
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        let label = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height - 15, width: imageView.frame.size.width, height: 15))
        label.text = NSLocalizedString("Select_Cover", comment: "Select Cover")
        label.font = UIFont.systemFont(ofSize: 10)
        label.backgroundColor = UIColor(white: 0, alpha: 0.7)
        label.textColor = .white
        label.textAlignment = .center
        imageView.addSubview(label)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSelectCover)))
        
        if !hasDraft {
            saveCoverleading.constant = -(2 * saveCoverleading.constant + saveBt.frame.size.width)
        }
        textView.semanticContentAttribute = .forceLeftToRight
        forceLTR(for: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func leftBtClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tapSelectCover() {
        moduleManager.selectCover(with: navigationController) { [weak self] path in
            guard let path = path else { return }
            self?.imagePath = path
            self?.imageView.image = UIImage(contentsOfFile: path)
        }
    }
    
    @IBAction func saveBtClicked(_ sender: UIButton) {
        if moduleManager.saveCurrentDraft(withDraftInfo: textView.text) {
            finish(nil)
        } else {
            NvToast.showToastAction(message: NSLocalizedString("Save_Failed", comment: "Save Failed"))
        }
    }
    
    @IBAction func compileBtClicked(_ sender: UIButton) {
        if moduleManager.isOnlyHaveMultiImage() {
            moduleManager.showSelectDownloadPanel(self) { [weak self] index in
                if index == 0 {
                    if let imagePath = self?.moduleManager.saveImage(), !imagePath.isEmpty {
                        print("saveImage: \(imagePath)")
                        NvToast.showToastAction(message:  NSLocalizedString("Save_Successful", comment: "Save Successful"))
                    } else {
                        NvToast.showToastAction(message:  NSLocalizedString("Save_Failed", comment: "Save Failed"))
                    }
                } else if index == 1 {
                    DispatchQueue.main.async(execute: DispatchWorkItem(block: {
                        NvToast.showToastAction()
                        if self?.moduleManager.compileCurrentTimeline() == false {
                            NvToast.hiddenToastAction()
                            NvToast.showToastAction(message:  NSLocalizedString("Save_Failed", comment: "Save Failed"))
                        }
                    }))
                }
            }
        } else {
            DispatchQueue.main.async(execute: DispatchWorkItem(block: {
                NvToast.showToastCoverAction()
                if self.moduleManager.compileCurrentTimeline() == false {
                    NvToast.hiddenToastAction()
                    NvToast.showToastAction(message: NSLocalizedString("Save_Failed", comment: "Save Failed"))
                }
            }))
        }
    }
    
    @IBAction func saveCoverClicked(_ sender: UIButton) {
        let path = self.moduleManager.saveImage()
        if path.length > 0 {
            NvToast.showToastAction(message: NSLocalizedString("Save_Successful", comment: "Save Successful"))
        } else {
            NvToast.showToastAction(message: NSLocalizedString("Save_Failed", comment: "Save Failed"))
        }
    }
    
    @objc func viewTap(_ tap: UITapGestureRecognizer) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    func finish(_ outputPath: String?) {
        if let path = outputPath {
            try? FileManager.default.removeItem(atPath: path)
        }
        
        if presentingViewController?.presentingViewController != nil {
            presentingViewController?.presentingViewController?.dismiss(animated: true) {
                guard let projectId = self.projectId else { return }
                _ = self.moduleManager.exitVideoEdit(projectId)
            }
        } else {
            navigationController?.dismiss(animated: true) {
                guard let projectId = self.projectId else { return }
                _ = self.moduleManager.exitVideoEdit(projectId)
            }
        }
    }
    
    // MARK: - NvModuleManagerCompileStateDelegate
    func didCompileCompleted(_ outputPath: String?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            NvToast.hiddenToastAction()
            if let _ = error {
                NvToast.showToastAction(message: NSLocalizedString("Save_Failed", comment: "Save Failed"))
            } else {
                self?.videoPath = outputPath
                NvToast.showToastAction(message: NSLocalizedString("Save_Successful", comment: "Save Successful"))
            }
            let publishInfo = self?.moduleManager.publishInfo
            print("publishinfo:\(String(describing: publishInfo?.videoPath))")
        }
    }
    
    func didCompileFloatProgress(_ progress: Float) {
        print("didCompileFloatProgress: \(progress)")
    }
    
    func didGenerateImagesType(_ type: Int32, results result: [String]?, error: (any Error)?) {
        NvToast.showToastAction(message: NSLocalizedString("Save_Successful", comment: "Save Successful"))
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
