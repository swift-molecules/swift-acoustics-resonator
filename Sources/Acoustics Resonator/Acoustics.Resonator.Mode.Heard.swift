extension Acoustics.Resonator.Mode {
    public struct Heard: Hashable, Sendable {
        public var moving: Double
        public var turning: Double

        public init(moving: Double, turning: Double = 0) {
            self.moving = moving
            self.turning = turning
        }
    }
}
