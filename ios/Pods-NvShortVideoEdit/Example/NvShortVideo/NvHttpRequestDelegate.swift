//
//  NvHttpRequestDelegate.swift
//  NvShortVideo
//
//  Created by Mac-Mini on 2025/8/15.
//

import Foundation
import NvShortVideoCore
import SDWebImageWebPCoder
#if canImport(SSZipArchive)
import SSZipArchive
#else
import ZipArchive
#endif
import SDWebImage
import NvStreamingSdkCore
import CommonCrypto

let DownloadMaterialZIP = true

class NvHttpRequestDelegate: NSObject, NvDependencyDelegate {
    
    // MARK: - Zip
    func unzip(withPath path: String, destination: String) -> Bool {
        var unpackError: NSError?
        let ret = SSZipArchive.unzipFile(atPath: path,
                                         toDestination: destination, preserveAttributes: true,
                                         overwrite: true,
                                         password: nil,
                                         error: &unpackError, delegate: nil)
        if let error = unpackError {
            print("unzip error: \(error)")
        }
        return ret
    }
    
    func configWebPInit() {
        // Add coder
        let webPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(webPCoder)
    }
    
    // MARK: - NvWebImageDelegate
    func fetchImage(for imageView: UIImageView,
                    url: URL,
                    placeholder: UIImage? = nil,
                    completion: ((UIImage?) -> Void)? = nil) {
        let options: SDWebImageOptions = .avoidAutoSetImage // !!!: -- 非常重要
        imageView.sd_setImage(with: url,
                              placeholderImage: placeholder,
                              options: options) { image, error, _, _ in
            if let completion = completion {
                completion(image)
            }
            // 2002是取消
            if let error = error, (error as NSError).code != 2002 {
                print("❌ Image loading failed: \(error)")
            }
        }
    }
    
    func webImageCancel(_ imageView: UIImageView) {
        imageView.sd_cancelCurrentImageLoad()
    }
}
