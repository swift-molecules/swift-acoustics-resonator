extension Acoustics.Resonator {
    public struct Mode: Hashable, Sendable {
        public var frequency: Frequency.Value<Double>
        public var decay: Decay.Value<Double>
        public var mass: Mass.Value<Double>
        /// How far the struck place moves when the mode is displaced by one metre: a pure number.
        public var reach: Double
        /// How much the mode's displacement stretches the head, for a `stiffening` resonator: a pure number.
        public var stretch: Double
        /// How far each place it can be driven moves when the mode is displaced by one metre: pure numbers.
        public var driven: [Double]
        public var heard: [Heard]

        public init(
            frequency: Frequency.Value<Double>,
            decay: Decay.Value<Double>,
            mass: Mass.Value<Double>,
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
