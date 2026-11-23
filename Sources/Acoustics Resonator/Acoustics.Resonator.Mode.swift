extension Acoustics.Resonator {
    public struct Mode: Hashable, Sendable {
        public var frequency: Double
        public var decay: Double
        public var mass: Double
        public var reach: Double
        public var stretch: Double
        /// How far the mode moves each place it can be driven, per unit of the mode.
        public var driven: [Double]
        public var heard: [Heard]

        public init(
            frequency: Double,
            decay: Double,
            mass: Double,
            reach: Double,
            stretch: Double = 0,
            driven: [Double] = [],
            heard: [Heard] = []
        ) {
            self.frequency = frequency
            self.decay = decay
            self.mass = mass
            self.reach = reach
            self.stretch = stretch
            self.driven = driven
            self.heard = heard
        }
    }
}
