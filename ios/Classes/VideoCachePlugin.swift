import Flutter
import UIKit
import KTVHTTPCache

public class VideoCachePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // 注册实现
    LXFVideoCacheHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(), 
      api: LXFVideoCacheHostApiImplementation()
    )
  }
}

class LXFVideoCacheHostApiImplementation: LXFVideoCacheHostApi {
    private var canProxy: Bool?

    func convertToCacheProxyUrl(url: String) throws -> String {
        if self.canProxy == nil {
            self.canProxy = ((try? KTVHTTPCache.proxyStart()) != nil)
            KTVHTTPCache.cacheSetMaxCacheLength(200 * 1024 * 1024)
            print("proxyUrlObj 设置缓存上限为200MB")
        }
        if !self.canProxy! { return url }
        guard let urlObj = URL(string: url) else { return url }
        guard let proxyUrlObj = KTVHTTPCache.proxyURL(withOriginalURL: urlObj) else {
            return url
        }
        return proxyUrlObj.absoluteString
    }

    func getCachedVideoPath(url: String) throws -> String? {
        guard let urlObj = URL(string: url) else { return nil }
        return KTVHTTPCache.cacheFileURL(withOriginalURL: urlObj)?.path
    }
}


