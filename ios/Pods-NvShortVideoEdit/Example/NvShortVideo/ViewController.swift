//
//  ViewController.swift
//  NvShortVideo
//
//  Created by Mac-Mini on 2025/8/12.
//

import UIKit
import Network
import NvShortVideoCore

class ViewController: UIViewController {
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var versionLayoutY: NSLayoutConstraint!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var draftView: UIView!
    @IBOutlet weak var dualView: UIView!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var service: UILabel!
    @IBOutlet weak var privacy: UILabel!
    var videoConfig: NvVideoConfig?
    let dependencyDelegate = NvHttpRequestDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVersionLabel()
        setupServicePrivacy()
        setupGradientBackground()
        setupRoundedViews()
        setupContentViewGradient()
        adjustLayoutForStatusBar()
        setupModuleManager()
        
        //web config
        setWebConfig()
        forceLTR(for: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func sendertapCapture(_ bt: UIButton) {
        bt.isEnabled = false
        let moduleManager = NvModuleManager.sharedInstance()
        moduleManager.downloadPrefabricatedMaterialCompletion(nil)
        guard let navigationController = navigationController else { return }
        moduleManager.startCapture(
            withPresent: navigationController,
            config: videoConfig,
            music: nil
        ) { isFinish in
            bt.isEnabled = true
        }
    }
    
    @IBAction func tapDualCapture(_ bt: UIButton) {
        bt.isEnabled = false
        let moduleManager = NvModuleManager.sharedInstance()
        guard let navigationController = navigationController else { return }
        moduleManager.downloadPrefabricatedMaterialCompletion(nil)
        moduleManager.startDualCapture(
            withPresent: navigationController,
            config: videoConfig
        ) { isFinish in
            bt.isEnabled = true
        }
    }

    @IBAction func editBtClicked(_ bt: UIButton) {
        bt.isEnabled = false
        let moduleManager = NvModuleManager.sharedInstance()
        guard let navigationController = navigationController else { return }
        moduleManager.downloadPrefabricatedMaterialCompletion(nil)
        moduleManager.startEdit(
            withPresent: navigationController,
            config: videoConfig
        ) { isFinish in
            bt.isEnabled = true
        }
    }

    @IBAction func draftBtClicked(_ bt: UIButton) {
        bt.isEnabled = false
        let draftListVc = NvDraftListViewController(config: videoConfig)
        self.navigationController?.pushViewController(draftListVc, animated: true)
        bt.isEnabled = true
    }

    @IBAction func settingsBtClicked(_ bt: UIButton) {
        bt.isEnabled = false
        bt.isEnabled = true
    }

    @IBAction func serviceClick(_ sender: UITapGestureRecognizer) {
        let webVC = NvWebViewController()
        webVC.title = NSLocalizedString("Service", comment: "Service")
        if isCurrentLanguageNoChinese() {
            webVC.urlString = "https://vsapi.meishesdk.com/app/privacy/flapShortVideo/Flap-ShortVideo-User-Service-Agreement-V1.html"
        } else {
            webVC.urlString = "https://vsapi.meishesdk.com/app/privacy/shortVideo/userService.html"
        }
        
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @IBAction func pravicyClick(_ sender: UITapGestureRecognizer) {
        let webVC = NvWebViewController()
        webVC.title = NSLocalizedString("Pravicy", comment: "Pravicy")
        if isCurrentLanguageNoChinese() {
            webVC.urlString = "https://vsapi.meishesdk.com/app/privacy/flapShortVideo/Flap-ShortVideo-Privacy-Statement-V1.html"
        } else {
            webVC.urlString = "https://vsapi.meishesdk.com/app/privacy/shortVideo/privacy.html"
        }
        
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    func setupServicePrivacy() {
        let color = UIColor(red: 0.4, green: 0.8, blue: 0.9, alpha: 1.0)
        let serviceText = NSMutableAttributedString(string: NSLocalizedString("Service", comment: "Service"))
        serviceText.addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: serviceText.length)
        )
        serviceText.addAttribute(
            .underlineColor,
            value: color,
            range: NSRange(location: 0, length: serviceText.length)
        )
        service.textColor = color
        service.attributedText = serviceText
        let privacyText = NSMutableAttributedString(string: NSLocalizedString("Privacy", comment: "Privacy"))
        privacyText.addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: privacyText.length)
        )
        privacyText.addAttribute(
            .underlineColor,
            value: color,
            range: NSRange(location: 0, length: privacyText.length)
        )
        privacy.textColor = color
        privacy.attributedText = privacyText
    }
    // 这里配置你自己的服务器
    // Here you configure your own server
    private func setWebConfig() {
        let moduleManager = NvModuleManager.sharedInstance()
        let request = moduleManager.netDelegate!
        request.dependencyDelegate = dependencyDelegate
        request.setHost("https://mall.meishesdk.com/api/shortvideo/v1")
        request.assetAutoCutUrl = "https://creative.meishesdk.com/api/app/aivideo/asset/all/1"
        
        if isCurrentLanguageNoChinese() {
            request.isAbroad = 1
        }
        _ = moduleManager.prepareDownloadFolders()
        networkState()
    }
    
    func isCurrentLanguageNoChinese() -> Bool {
        guard let language = Locale.preferredLanguages.first else {
            return false
        }
        return !language.hasPrefix("zh")
    }
    
    func networkState() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // 网络可用
                DispatchQueue.main.async {
                    let moduleManager = NvModuleManager.sharedInstance()
                    moduleManager.preloadedResource()
                }
                monitor.cancel()
            } else {
                // 网络不可用
                print("Network not reachable")
            }
        }
        monitor.start(queue: queue)
    }
    
    private func setupVersionLabel() {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let versionString = infoDictionary["CFBundleShortVersionString"] as? String else {
            return
        }
        
        print("Version: \(versionString)")
        
        if let currentText = versionLbl.text {
            versionLbl.text = "\(currentText) v\(versionString)"
        } else {
            versionLbl.text = "v\(versionString)"
        }
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        gradientLayer.colors = [
            UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 42/255.0, green: 49/255.0, blue: 61/255.0, alpha: 1.0).cgColor
        ]
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupRoundedViews() {
        let views = [editView, draftView, dualView, captureView]
        
        views.forEach { view in
            view?.clipsToBounds = true
            view?.layer.cornerRadius = (view?.frame.height ?? 0) * 0.5
        }
    }
    
    private func setupContentViewGradient() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 9
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.bounds
        
        gradientLayer.colors = [
            UIColor(red: 33/255.0, green: 39/255.0, blue: 41/255.0, alpha: 1.0).cgColor,
            UIColor(red: 40/255.0, green: 47/255.0, blue: 59/255.0, alpha: 1.0).cgColor
        ]
        
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func adjustLayoutForStatusBar() {
        if UIApplication.shared.statusBarFrame.height < 20.1 {
            versionLayoutY.constant = 20
        }
    }
    
    private func setupModuleManager() {
        let moduleManager = NvModuleManager.sharedInstance()
        moduleManager.delegate = self
    }
    // 如果你不配置功能和UI，这里的代码你不用关心
    // If you don't configure the functionality and UI, you don't care about the code here
    private func test() {
        videoConfig = NvVideoConfig()
        guard let videoConfig = videoConfig else { return }
        videoConfig.captureConfig.recordConfiguration = ["video encoder name": "hevc","gopsize":10]
        videoConfig.primaryColor = UIColor.color(withHex: "#0000FF")
        videoConfig.backgroundColor = UIColor.color(withHex: "#00FA9A")
        videoConfig.panelBackgroundColor = UIColor.color(withHex: "#000080")
        videoConfig.textColor = UIColor.color(withHex: "#FFA500")
        videoConfig.secondaryTextColor = UIColor.color(withHex: "#8A2BE2")
        videoConfig.enableLocalMusic = false

        // 相册配置 albumConfig
        videoConfig.albumConfig.type = 1
        videoConfig.albumConfig.maxSelectCount = 5
        videoConfig.albumConfig.useAutoCut = false

        // 拍摄配置 captureConfig
        videoConfig.captureConfig.captureMenuItems = [
            NvCaptureMenu.device,
            NvCaptureMenu.speed,
            NvCaptureMenu.beauty,
            NvCaptureMenu.original,
            NvCaptureMenu.filter,
            NvCaptureMenu.matting
        ]
        videoConfig.captureConfig.defaultBottomMenuSelectItem = NvCaptureBottomMenu.video
        videoConfig.captureConfig.captureBottomMenuItems = [
            NvCaptureBottomMenu.image,
            NvCaptureBottomMenu.video,
            NvCaptureBottomMenu.smart,
            NvCaptureBottomMenu.template
        ]
        videoConfig.captureConfig.fps = 30
        videoConfig.captureConfig.captureDeviceIndex = 0
        videoConfig.captureConfig.resolution = .resolution720
        videoConfig.captureConfig.ignoreVideoRotation = false
        videoConfig.captureConfig.imageDuration = 6 * 1000
        videoConfig.captureConfig.autoSavePhotograph = true

        let pair1 = NvTimePair()
        pair1.minDuration = 1 * 1000
        pair1.maxDuration = 10 * 1000

        let pair2 = NvTimePair()
        pair2.minDuration = 0
        pair2.maxDuration = 50 * 1000
        videoConfig.captureConfig.timeRanges = [pair2]

        let pair3 = NvTimePair()
        pair3.minDuration = 0
        pair3.maxDuration = 30 * 1000
        videoConfig.captureConfig.smartTimeRange = pair3

        videoConfig.captureConfig.beautyConfig = NvBeautyConfig()
        videoConfig.captureConfig.beautyConfig.categoricalArray = [
            NvBeautyCategoricalItem.skin,
            NvBeautyCategoricalItem.microShape
        ]
        videoConfig.captureConfig.beautyConfig.beautyEffectArray = [
            NvBeautyEffectItem.standard,
            NvBeautyEffectItem.whiteA,
            NvBeautyEffectItem.rosy
        ]

        videoConfig.captureConfig.dualMenuItems = [
            NvCaptureMenu.device,
            NvCaptureMenu.dualType,
            NvCaptureMenu.original
        ]
        videoConfig.captureConfig.dualConfig = NvDualConfig()
        videoConfig.captureConfig.dualConfig.left = 50.0 / 375.0
        videoConfig.captureConfig.dualConfig.top = 50.0 / 666.67
        videoConfig.captureConfig.dualConfig.limitWidth = 200 / 375.0
        videoConfig.captureConfig.dualConfig.defaultType = .topDown
        let types = Int(NvDualType.topDown.rawValue) | Int(NvDualType.leftRight.rawValue)
        videoConfig.captureConfig.dualConfig.supportedTypes = types
        videoConfig.captureConfig.dualConfig.autoDisablesMic = true

        videoConfig.captureConfig.filterDefaultValue = 1.0
        videoConfig.captureConfig.enableCaptureAlbum = true
        videoConfig.captureConfig.autoDisablesMic = true

        // 编辑配置 editConfig
        videoConfig.editConfig.editMenuItems = [
            NvEditMenuItemConstants.text,
            NvEditMenuItemConstants.filter,
            NvEditMenuItemConstants.effect
        ]
        videoConfig.editConfig.resolution = .resolution1080
        videoConfig.editConfig.fps = 25
        videoConfig.editConfig.minEffectDuration = 1000
        videoConfig.editConfig.minAudioDuration = 3000
        videoConfig.editConfig.captionColor = "#FFA500"
        videoConfig.editConfig.captionColorList = [
            "#FFFFFF",
            "#000000",
            "#0099F6",
            "#50C23B"
        ]
        videoConfig.editConfig.supportedCaptionStyles = 9
        videoConfig.editConfig.editModeSource = .firstAsset
        videoConfig.editConfig.editMode = .mode9v16
        let models = Int32(NvEditMode.mode16v9.rawValue) |
        Int32(NvEditMode.mode9v16.rawValue) |
        Int32(NvEditMode.mode3v4.rawValue) |
        Int32(NvEditMode.mode4v3.rawValue) |
        Int32(NvEditMode.mode1v1.rawValue) |
        Int32(NvEditMode.mode18v9.rawValue) |
        Int32(NvEditMode.mode9v18.rawValue) |
        Int32(NvEditMode.mode8v9.rawValue) |
        Int32(NvEditMode.mode9v8.rawValue)
            
        videoConfig.editConfig.supportedEditModes = Int(models)
        videoConfig.editConfig.bubbleConfig = NvBubbleConfig()
        videoConfig.editConfig.bubbleConfig.titleTheme = NvLabelTheme()
        videoConfig.editConfig.bubbleConfig.titleTheme?.textColor = UIColor.color(withHex: "#0000FF")
        videoConfig.editConfig.bubbleConfig.backgroundBlurStyle = NvBubbleBgBlurStyle.light

        videoConfig.editConfig.filterDefaultValue = 1.0
        videoConfig.editConfig.maxVolume = 1

        // 导出配置 compileConfig
        videoConfig.compileConfig.configure = ["video encoder name": "hevc","gopsize":10]
        videoConfig.compileConfig.resolution = .resolution720
        videoConfig.compileConfig.fps = 25
        videoConfig.compileConfig.bitrateGrade = NvsCompileBitrateGradeHigh
        videoConfig.compileConfig.bitrate = -1
        videoConfig.compileConfig.autoSaveVideo = true

        // 模版配置 templateConfig
        videoConfig.templateConfig.maxSelectCount = 5
        videoConfig.templateConfig.useAutoCut = false

        // 模型配置 modelConfig
        // videoConfig.modelConfig.use240 = true
        // videoConfig.modelConfig.face240 = "ms_face240_v2.0.8.model"

        // 自定义主题示例

        // “capture_capture_close_bt”
        let buttonTheme = NvButtonTheme()
        buttonTheme.imageName = "homepage_logo"
        videoConfig.captureConfig.customTheme[NvThemeElementKey.captureCloseBtKey] = buttonTheme

        // “capture_duration_label”
        let labelTheme = NvLabelTheme()
        labelTheme.textColor = .red
        videoConfig.captureConfig.customTheme[NvThemeElementKey.captureDurationLabelKey] = labelTheme

        // “capture_music_menu_view”
        let viewTheme = NvViewTheme()
        viewTheme.backgroundColor = .red
        videoConfig.captureConfig.customTheme[NvThemeElementKey.captureMusicMenuViewKey] = viewTheme

        // “capture_capture_record_bt_set”
        let record = NvRecordBtTheme()
        record.minimumTrackTintColor = .green
        record.smartImageName = "capture_next"
        videoConfig.captureConfig.customTheme[NvThemeElementKey.captureRecordBtSetKey] = record

        let sliderTheme = NvSliderTheme()
        sliderTheme.minimumTrackTintColor = .red
        sliderTheme.maximumTrackTintColor = .green
        sliderTheme.thumbTintColor = .orange
        videoConfig.editConfig.customTheme[NvThemeElementKey.editBottomSliderKey] = sliderTheme
        
        //videoConfig = NvVideoConfig()
        //guard let videoConfig = videoConfig else { return }
        let configuration = NvWatermarkConfig()
        configuration.watermark = NvImageConfig(name: "homepage_logo")
        configuration.width = 150
        configuration.height = 150
        configuration.position = .topRight
        configuration.offsetX = 40
        configuration.offsetY = 40
        videoConfig.compileConfig.watermarkConfig = configuration
        let coverConfiguration = NvWatermarkConfig()
        coverConfiguration.watermark = NvImageConfig(name: "homepage_tip")
        coverConfiguration.width = 150
        coverConfiguration.height = 150
        coverConfiguration.position = .bottomLeft
        coverConfiguration.offsetX = 40
        coverConfiguration.offsetY = 40
        videoConfig.compileConfig.coverWatermarkConfig = coverConfiguration
        // shadow
        videoConfig.shadowColor = UIColor(white: 0, alpha: 0.5)
        videoConfig.shadowOffset = CGSizeMake(0, 0.5)
    }
}

extension ViewController: NvModuleManagerDelegate {
    func publish(
        withProjectId projectId: String,
        coverImagePath: String?,
        hasDraft: Bool,
        videoPath: String?,
        description: String?,
        videoEdit videoEditNavigationController: UINavigationController
    ) {
        guard let publicVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NvPublicViewController") as? NvPublicViewController else {
            print("无法实例化 NvPublicViewController")
            return
        }
        publicVc.imagePath = coverImagePath
        publicVc.hasDraft = hasDraft
        publicVc.projectDescription = description
        publicVc.projectId = projectId
        publicVc.videoPath = videoPath
        videoEditNavigationController.pushViewController(publicVc, animated: true)
    }
}

func forceLTR(forView view: UIView) {
    view.semanticContentAttribute = .forceLeftToRight
    view.subviews.forEach { subview in
        forceLTR(forView: subview)
    }
}

func forceLTR(for viewController: UIViewController) {
    viewController.view.semanticContentAttribute = .forceLeftToRight
    forceLTR(forView: viewController.view)
    if let nav = viewController.navigationController {
        nav.view.semanticContentAttribute = .forceLeftToRight
        nav.navigationBar.semanticContentAttribute = .forceLeftToRight
    } else {
        return
    }
}
