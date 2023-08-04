import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var albumNameLabel: UILabel!
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var songNameLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!

    
    @IBOutlet weak var musicProgressSlider: UISlider!
    
    @IBOutlet weak var musicCurrentTimeLabel: UILabel!
    
    @IBOutlet weak var musicTotalTimeLabel: UILabel!

    
    @IBOutlet weak var playAndPauseButton: UIButton!

    
    @IBOutlet weak var fowardButton: UIButton!
    
    @IBOutlet weak var backwardButton: UIButton!

    
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var volumeView: UIView!
    
    @IBOutlet weak var volumeButton: UIButton!

    
    let soundPlayer = AVPlayer()

    
    var currentSong: Song?

    
    var currentSongIndex = 0

    
    var playMode: PlayMode = .sequential


    
    var songs: [Song] = [
        Song(albumName: "song_1", songName: "song_1", artist: "song_1", coverImage: UIImage(named: "song_1"), fileUrl: Bundle.main.url(forResource: "song_1", withExtension: "mp3")!),
        Song(albumName: "song_2", songName: "song_2", artist: "song_2", coverImage: UIImage(named: "song_2"), fileUrl: Bundle.main.url(forResource: "song_2", withExtension: "mp3")!),
        Song(albumName: "song_3", songName: "song_3", artist: "song_3", coverImage: UIImage(named: "song_3"), fileUrl: Bundle.main.url(forResource: "song_3", withExtension: "mp3")!),
        Song(albumName: "song_4", songName: "song_4", artist: "song_4", coverImage: UIImage(named: "song_4"), fileUrl: Bundle.main.url(forResource: "song_4", withExtension: "mp3")!),
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        soundPlayer.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main) { time in
            
            if !self.musicProgressSlider.isTracking {
                

                self.updateMusicProgress()
            }




        }


        
        musicProgressSlider.minimumValue = 0
        musicProgressSlider.maximumValue = 1
        musicProgressSlider.value = 0
        
        musicProgressSlider.isEnabled = false
        
        musicProgressSlider.setThumbImage(UIImage(named: "whiteDot"), for: .normal)


        
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 1          

        
        volumeView.isHidden = true

        
        fowardButton.isEnabled = false
        backwardButton.isEnabled = false
    }


    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {

        
        musicProgressSlider.isEnabled = true
        
        fowardButton.isEnabled = true
        backwardButton.isEnabled = true

        
        switch soundPlayer.timeControlStatus {
        
        case .paused:
            
            if currentSong != nil {
                
                soundPlayer.play()
                print("The player is currently paused, press the play button")
            } else {
                
                print("There is no song playing, play the song in the song list")
                playSong(song: songs[currentSongIndex])
            }

            
            sender.setImage(UIImage(systemName: "pause.circle"), for: .normal)

        
        case .playing:
            print("The player is currently playing, press the pause button")
            
            soundPlayer.pause()
            
            sender.setImage(UIImage(systemName: "play.circle"), for: .normal)

        
        default:
            break
        }
    }


    
    @IBAction func fowardButtonTapped(_ sender: UIButton) {
        if currentSongIndex < songs.count - 1 {
            currentSongIndex += 1
        } else {
            currentSongIndex = 0
        }

        playSong(song: songs[currentSongIndex])
    }


    
    @IBAction func backwardButtonTapped(_ sender: UIButton) {
        if currentSongIndex > 0 {
            currentSongIndex -= 1
        } else {
            currentSongIndex = songs.count - 1
        }

        playSong(song: songs[currentSongIndex])
    }


    
    @IBAction func changePlayModeButtonTapped(_ sender: UIButton) {
        
        switch playMode {
        case .random:
            playMode = .singleRepeat
            sender.setImage(UIImage(systemName: "repeat.1"), for: .normal)
             print("Currently in normal random mode")
        case .singleRepeat:
            playMode = .sequential
            sender.setImage(UIImage(systemName: "repeat"), for: .normal)
           print("Currently in normal playback mode")
        case .sequential:
            playMode = .random
            sender.setImage(UIImage(systemName: "shuffle"), for: .normal)
            print("Currently in shuffle mode")
        }
    }


    
    @IBAction func volumeSliderValueChanged(_ sender: UISlider) {
        
        soundPlayer.volume = sender.value

        
        var volumeIconName = ""
        if sender.value == 0.0 {
            volumeIconName = "speaker.slash"
        } else if sender.value <= 0.35 {
            volumeIconName = "speaker.wave.1"
        } else if sender.value <= 0.65 {
            volumeIconName = "speaker.wave.2"
        } else {
            volumeIconName = "speaker.wave.3"
        }

        
        volumeButton.setImage(UIImage(systemName: volumeIconName), for: .normal)
    }


    
    @IBAction func volumeButtonTapped(_ sender: UIButton) {
        
        volumeView.isHidden = !volumeView.isHidden
    }


    
    @IBAction func musicProgressSliderValueChanged(_ sender: UISlider) {

        
        let sliderValue = sender.value

        
        let duration = CMTimeGetSeconds(soundPlayer.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))

        
        let newTime = Double(sliderValue) * duration

        
        let seekTime = CMTimeMakeWithSeconds(newTime, preferredTimescale: 1)
        soundPlayer.seek(to: seekTime)

        
        let currentLabelValue = String(format: "%02d:%02d", Int(newTime) / 60, Int(newTime) % 60)
        musicCurrentTimeLabel.text = currentLabelValue
        let totalLabelValue = String(format: "%02d:%02d", Int(duration) / 60, Int(duration) % 60)
        musicTotalTimeLabel.text = totalLabelValue
    }


    
    
    func playSong(song: Song) {

        
        currentSong = song

        
        backgroundImageView.image = song.coverImage 
        albumNameLabel.text = song.albumName        
        songNameLabel.text = song.songName          
        artistLabel.text = song.artist              
        coverImageView.image = song.coverImage      

        
        let playerItem = AVPlayerItem(url: song.fileUrl)
        
        soundPlayer.replaceCurrentItem(with: playerItem)
        soundPlayer.play()

        
        playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)

        
        NotificationCenter.default.addObserver(self, selector: #selector(songDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    
    @objc func songDidEnd() {

        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        
        switch playMode {
        case .random:
            currentSongIndex = Int.random(in: 0..<songs.count)


        case .singleRepeat:
            break
        case .sequential:
            if currentSongIndex < songs.count - 1 {
                currentSongIndex += 1
            } else {
                currentSongIndex = 0        
            }
        }

        playSong(song: songs[currentSongIndex])
       print("The current song is played, the next one will be played automatically")
    }


    
    
    func updateMusicProgress() {



        
        if let currentTime = soundPlayer.currentItem?.currentTime(),
           let duration = soundPlayer.currentItem?.duration {

            
            let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
            let durationInSeconds = CMTimeGetSeconds(duration)

            
            let progress = Float(currentTimeInSeconds / durationInSeconds)
            musicProgressSlider.value = progress

            
            musicCurrentTimeLabel.text = formatSecondsToString(seconds: currentTimeInSeconds)
            musicTotalTimeLabel.text = formatSecondsToString(seconds: durationInSeconds)
        } else {

            
            return
        }
    }


    
    
    
    func formatSecondsToString(seconds: Double) -> String {

        
        if seconds.isNaN {
            return "00:00"
        }

        
        let mins = Int(seconds / 60)

        
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))

        
        let str = String(format: "%02d:%02d", mins, secs)

        
        return str
    }

}


































































































































































































































































































































































































































































































