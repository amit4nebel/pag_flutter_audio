import Flutter
import UIKit

public class PagFlutterAudioPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "pag_flutter_audio", binaryMessenger: registrar.messenger())
        let instance = PagFlutterAudioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "extractAudio":
            guard let args = call.arguments as? [String: Any],
                  let pagBytes = args["pagBytes"] as? FlutterStandardTypedData else {
                result(FlutterError(code: "INVALID_ARGS", message: "pagBytes is required", details: nil))
                return
            }
            
            let audioData = extractAudioFromPAG(pagBytes.data)
            if let audioData = audioData {
                result(FlutterStandardTypedData(bytes: audioData))
            } else {
                result(nil)
            }
            
        case "getAudioInfo":
            guard let args = call.arguments as? [String: Any],
                  let pagBytes = args["pagBytes"] as? FlutterStandardTypedData else {
                result(FlutterError(code: "INVALID_ARGS", message: "pagBytes is required", details: nil))
                return
            }
            
            let info = getAudioInfoFromPAG(pagBytes.data)
            result(info)
            
        case "getPlatformVersion":
            result("iOS \(UIDevice.current.systemVersion)")
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func extractAudioFromPAG(_ pagData: Data) -> Data? {
        guard let pagFile = PAGFile.load(pagData.bytes, size: pagData.count) else {
            return nil
        }
        
        let audioBytes = pagFile.audioBytes()
        pagFile.release()
        
        if let audioBytes = audioBytes, audioBytes.count > 0 {
            return audioBytes as Data
        }
        return nil
    }
    
    private func getAudioInfoFromPAG(_ pagData: Data) -> [String: Any] {
        guard let pagFile = PAGFile.load(pagData.bytes, size: pagData.count) else {
            return [
                "hasAudio": false,
                "audioBytes": nil as FlutterStandardTypedData?,
                "audioStartTime": 0,
                "duration": 0
            ]
        }
        
        let audioBytes = pagFile.audioBytes()
        let audioStartTime = pagFile.audioStartTime()
        let duration = pagFile.duration()
        
        pagFile.release()
        
        var audioTypedData: FlutterStandardTypedData? = nil
        var hasAudio = false
        
        if let audioBytes = audioBytes, audioBytes.count > 0 {
            hasAudio = true
            audioTypedData = FlutterStandardTypedData(bytes: audioBytes as Data)
        }
        
        return [
            "hasAudio": hasAudio,
            "audioBytes": audioTypedData as Any,
            "audioStartTime": audioStartTime,
            "duration": duration
        ]
    }
}
