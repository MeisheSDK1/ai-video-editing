//
//  NvDraftListViewController.swift
//  NvShortVideo
//
//  Created by Mac-Mini on 2025/8/12.
//

import UIKit
import NvShortVideoCore

class NvDraftCell: UITableViewCell {
    
    var coverImageView: UIImageView!
    var infoLabel: UILabel!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        forceLTR(forView: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        forceLTR(forView: self)
    }
    
    private func setupSubviews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        coverImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        coverImageView.layer.masksToBounds = true
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(coverImageView)
        
        NSLayoutConstraint.activate([
            coverImageView.widthAnchor.constraint(equalToConstant: 70),
            coverImageView.heightAnchor.constraint(equalToConstant: 70),
            coverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coverImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20)
        ])
        coverImageView.backgroundColor = .black
        
        let rect = UIScreen.main.bounds
        infoLabel = UILabel(frame: CGRect(x: 15, y: 0, width: rect.width - 30, height: 40))
        infoLabel.textColor = UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 1.0)
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.leftAnchor.constraint(equalTo: coverImageView.rightAnchor, constant: 15),
            infoLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            infoLabel.topAnchor.constraint(greaterThanOrEqualTo: coverImageView.topAnchor, constant: 0),
            infoLabel.bottomAnchor.constraint(lessThanOrEqualTo: coverImageView.bottomAnchor, constant: 0),
            infoLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func loadDraftModel(_ draftModel: NvEditProjectInfo) {
        if let imagePath = draftModel.coverImagePath, !imagePath.isEmpty {
            coverImageView.image = UIImage(contentsOfFile: imagePath)
        }
        if let desc = draftModel.projectDescription, !desc.isEmpty {
            infoLabel.text = desc
        } else {
            let tempString = NvLocalString("draft_title", comment: "草稿") ?? ""
            infoLabel.text = tempString + (draftModel.defaultProjectDescription ?? "")
        }
    }
}

class NvDraftListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var infoLabel: UILabel!
    var draftArray: [NvEditProjectInfo] = []
    var config: NvVideoConfig?
    
    init(config: NvVideoConfig?) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("DraftList", comment: "Drafts")
        view.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1)
        let rect = UIScreen.main.bounds
        infoLabel = UILabel(frame: CGRect(x: 15, y: 20, width: rect.width - 30, height: 40))
        infoLabel.textColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        infoLabel.font = UIFont.systemFont(ofSize: 13)
        infoLabel.numberOfLines = 0
        infoLabel.text = NSLocalizedString("DraftListTip", comment: "Tips: After uninstalling the application, the draft will also be deleted")
        view.addSubview(infoLabel)
        infoLabel.sizeToFit()
        infoLabel.frame = CGRect(x: infoLabel.frame.origin.x, y: infoLabel.frame.origin.y, width: infoLabel.frame.width, height: infoLabel.frame.height)
        
        let tableY = infoLabel.frame.maxY
        let tableRect = CGRect(x: 0, y: tableY, width: rect.width, height: rect.height - tableY - NvLayout.naviHeight)
        tableView = UITableView(frame: tableRect, style: .plain)
        view.addSubview(tableView)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(NvDraftCell.self, forCellReuseIdentifier: "NvDraftCell")
        draftArray = NvModuleManager.projectList()
        tableView.reloadData()
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(handleDraftListNotification(_:)), name: NvDraftManager_Draft_Save_Notification, object: nil)
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(handleDraftListNotification(_:)),
                name: NvDraftManager_Draft_Delete_Notification,
                object: nil
            )
    }
    
    @objc func handleDraftListNotification(_ notification: Notification) {
        draftArray = NvModuleManager.projectList()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return draftArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NvDraftCell", for: indexPath) as! NvDraftCell
        let draftModel = draftArray[indexPath.row]
        cell.loadDraftModel(draftModel)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let draftModel = draftArray[indexPath.row]
        NvModuleManager.sharedInstance().reeditProject(draftModel, presentViewController: self, config: config)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: NSLocalizedString("DraftDelete", comment: "Confirm Delete"), message: "", preferredStyle: .alert)
            let projectId = draftArray[indexPath.row].projectId
            let okAction = UIAlertAction(title: NSLocalizedString("DraftConfirm", comment: "YES"), style: .default) { [weak self, weak tableView] _ in
                guard let self = self else { return }
                if NvModuleManager.deleteDraft(projectId) {
                    if let idx = self.draftArray.firstIndex(where: { $0.projectId == projectId }) {
                        self.draftArray.remove(at: idx)
                    }
                    DispatchQueue.main.async {
                        tableView?.reloadData()
                    }
                } else {
                    print("删除失败")
                }
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("DraftCancel", comment: "NO"), style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Rotation
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
