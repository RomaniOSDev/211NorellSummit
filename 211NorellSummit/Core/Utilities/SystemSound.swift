import AudioToolbox

enum SystemSound {
    static func play(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }

    static func tick() {
        play(1003)
    }

    static func favorite() {
        play(1104)
    }

    static func timerComplete() {
        play(1005)
    }

    static func success() {
        play(1057)
    }

    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
