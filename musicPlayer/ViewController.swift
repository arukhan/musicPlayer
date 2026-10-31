import UIKit
import AVFoundation
class ViewController: UIViewController, AVAudioPlayerDelegate {
@IBOutlet weak var coverImageView: UIImageView!
@IBOutlet weak var titleLabel: UILabel!
@IBOutlet weak var artistLabel: UILabel!
@IBOutlet weak var playPauseButton: UIButton!

private let tracks = TrackLibrary.tracks
private var currentIndex = 0
private var audioPlayer: AVAudioPlayer?
private var isPlaying = false

override func viewDidLoad() {
    super.viewDidLoad()
    updateUI()
    loadCurrentTrack()
}

private func updateUI() {
    let track = tracks[currentIndex]

    titleLabel.text = track.title
    artistLabel.text = track.artist
    coverImageView.image = UIImage(
        named: track.coverImageName
    )

    let symbol = isPlaying ? "pause.fill" : "play.fill"

    playPauseButton.setImage(
        UIImage(systemName: symbol),
        for: .normal
    )
}

private func loadCurrentTrack() {
    let track = tracks[currentIndex]

    let fileURL = URL(fileURLWithPath: track.fileName)
    let name = fileURL.deletingPathExtension().lastPathComponent
    let ext = fileURL.pathExtension

    guard let url = Bundle.main.url(
        forResource: name,
        withExtension: ext
    ) else {
        audioPlayer = nil
        isPlaying = false
        updateUI()
        print("Audio file not found: \(track.fileName)")
        return
    }

    do {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
    } catch {
        audioPlayer = nil
        isPlaying = false
        updateUI()
        print("Audio loading error: \(error)")
    }
}

@IBAction func playPauseTapped(_ sender: UIButton) {
    if isPlaying {
        audioPlayer?.pause()
        isPlaying = false
    } else {
        if audioPlayer == nil {
            loadCurrentTrack()
        }

        if audioPlayer?.play() == true {
            isPlaying = true
        } else {
            isPlaying = false
            print("Unable to play current track")
        }
    }

    updateUI()
}

@IBAction func nextTapped(_ sender: UIButton) {
    changeTrack(by: 1)
}

@IBAction func previousTapped(_ sender: UIButton) {
    changeTrack(by: -1)
}

private func changeTrack(by offset: Int) {
    let shouldContinuePlaying = isPlaying

    audioPlayer?.stop()
    isPlaying = false

    currentIndex = (
        currentIndex + offset + tracks.count
    ) % tracks.count

    loadCurrentTrack()

    if shouldContinuePlaying {
        isPlaying = audioPlayer?.play() == true
    }

    updateUI()
}

func audioPlayerDidFinishPlaying(
    _ player: AVAudioPlayer,
    successfully flag: Bool
) {
    if flag {
        changeTrack(by: 1)
    } else {
        isPlaying = false
        updateUI()
        print("Audio playback did not finish successfully")
    }
}
}
