import AVKit
import Combine
class YiVideoEditorData {
    var asset: AVAsset
    var composition: 
    var assetVideoTrack: AVAssetTrack?
    var assetAudioTrack: AVAssetTrack?
    var videoComposition: AVMutableVideoComposition?
    var videoCompositionTrack: AVMutableCompositionTrack?
    var audioCompositionTrack: AVMutableCompositionTrack?
    var videoSize: CGSize = .zero
    private var cancellables = Set<AnyCancellable>()
    init(asset: AVAsset) {
        self.asset = asset
        loadAsset()
    }
    func loadAsset() {
        let assetKeys = [
            "tracks",
           "duration",
            "commonMetadata",
            "preferredTransform"
        ]
        asset.loadValuesAsynchronously(forKeys: assetKeys) { [weak self] in
            guard let strongSelf = self else { return }
            for key in assetKeys {
                var error: NSError?
                if !strongSelf.asset.isPlayable || strongSelf.asset.statusOfValue(forKey: key, error: &error) == .failed {
                    return
                }
            }

            strongSelf.assetVideoTrack = strongSelf.asset.tracks(withMediaType: .video).first
            strongSelf.assetAudioTrack = strongSelf.asset.tracks(withMediaType: .audio).first
            strongSelf.videoSize = strongSelf.assetVideoTrack?.naturalSize ?? .zero
            strongSelf.composition = AVMutableComposition()
            strongSelf.videoComposition = AVMutableVideoComposition()
            strongSelf.videoComposition?.frameDuration = CMTime(value: 1, timescale: 30)
            strongSelf.videoComposition?.renderSize = strongSelf.videoSize
            let insertionPoint: CMTime = kCMTimeZero
            if let assetVideoTrack = strongSelf.assetVideoTrack {
                strongSelf.videoCompositionTrack = strongSelf.composition?.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                do {
                    try strongSelf.videoCompositionTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: strongSelf.asset.duration), of: assetVideoTrack, at: insertionPoint)
                } catch {

                }

            }

            if let assetAudioTrack = strongSelf.assetAudioTrack {

                strongSelf.audioCompositionTrack = strongSelf.composition?.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

                do {

                    try strongSelf.audioCompositionTrack?.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: strongSelf.asset.duration), of: assetAudioTrack, at: insertionPoint)
                } catch {
                }
            }
        }
    }
    func observeStatus() -> AnyPublisher<AVKeyValueStatus, Never> {
        return asset.publisher(for: \.status)
            .map { $0 as! AVKeyValueStatus }
            .eraseToAnyPublisher()
    }
    func observePlayable() -> AnyPublisher<Bool, Never> {
        return asset.publisher(for: \.isPlayable)
            .eraseToAnyPublisher()
    }
}

