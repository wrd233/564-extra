//
//  DownloadManager.swift
//  Rundong
//
//  Created by MAC on 2025/2/14.
//

import Foundation

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    private var progressHandler: ((Float) -> Void)?
    private var completionHandler: ((Result<Data, Error>) -> Void)?
    
    // 注：session在初始化过程中就引用了 self ，如果不设置lazy，则会在self还未完全构建的时刻引用它，而 lazy 属性在第一次访问时才会执行闭包，此时 self 已经完全初始化好了。
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }()
    
    /// 绑定传入的progressHandler和completionHandler两个闭包
    func download(with request: URLRequest,
                  progress: @escaping (Float) -> Void,
                  completion: @escaping (Result<Data, Error>) -> Void) {
        self.progressHandler = progress
        self.completionHandler = completion
        
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    /// 此方法会在下载过程中被多次调用，用于更新下载进度
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        // 当前下载进度（0.0 ~ 1.0）
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let progressText = "Downloaded \(Int(progress * 100))%"
        print(progressText)
        // 调用该闭包通知上层下载进度变化
        progressHandler?(progress)
    }
    
    /// 下载完成后调用此方法，可将临时文件位置传递出去处理数据
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            // 调用 completionHandler 并传递成功结果
            completionHandler?(.success(data))
        } catch {
            // 如果发生错误，调用 completionHandler 并传递错误信息
            completionHandler?(.failure(error))
        }
    }
}
