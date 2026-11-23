internal import Numeric

extension Acoustics {
    public struct Resonator: Sendable {
        public let interval: Double
        public let stiffening: Double
        public let ears: Int
        public private(set) var touching = false
        public private(set) var force = 0.0
        public private(set) var heard: [Double]
        /// The number of places the modes can be driven.
        public let ports: Int
        /// Where each driven place is now.
        public private(set) var felt: [Double]
        @usableFromInline var driven: [Double]
        @usableFromInline var count: Int
        @usableFromInline var warped: [Double]
        @usableFromInline var square: [Double]
        @usableFromInline var loss: [Double]
        @usableFromInline var mass: [Double]
        @usableFromInline var reach: [Double]
        @usableFromInline var stretch: [Double]
        @usableFromInline var angular: [Double]
        @usableFromInline var moving: [Double]
        @usableFromInline var turning: [Double]
        @usableFromInline var now: [Double]
        @usableFromInline var before: [Double]
        @usableFromInline var ahead: [Double]
        @usableFromInline var lean: [Double]
        @usableFromInline var striker: Striker?
        @usableFromInline var place = 0.0
        @usableFromInline var placed = 0.0

        public init(_ modes: [Mode], stiffening: Double = 0, every interval: Double) {
            self.interval = interval
            self.stiffening = stiffening
            self.count = modes.count
            self.ears = modes.map(\.heard.count).min() ?? 0
            self.heard = [Double](repeating: 0, count: ears)
            let ports = modes.map(\.driven.count).min() ?? 0
            self.ports = ports
            self.felt = [Double](repeating: 0, count: ports)
            self.driven = modes.flatMap { $0.driven.prefix(ports) }
            self.angular = modes.map { 2 * Double.pi * $0.frequency }
            self.warped = angular.map { angle in
                let half = Double.math.sin(angle * interval / 2)
                return 4 * half * half
            }
            self.square = angular.map { $0 * $0 * interval * interval / 2 }
            self.loss = modes.map { $0.decay * interval }
            self.mass = modes.map(\.mass)
            self.reach = modes.map(\.reach)
            self.stretch = modes.map(\.stretch)
            var moving: [Double] = []
            var turning: [Double] = []
            moving.reserveCapacity(count * ears)
            turning.reserveCapacity(count * ears)
            for (index, mode) in modes.enumerated() {
                for ear in mode.heard.prefix(ears) {
                    moving.append(ear.moving / (interval * interval))
                    turning.append(ear.turning * angular[index] / (2 * interval))
                }
            }
            self.moving = moving
            self.turning = turning
            self.now = [Double](repeating: 0, count: count)
            self.before = now
            self.ahead = now
            self.lean = now
        }
    }
}

extension Acoustics.Resonator {
    public var displacements: [Double] { now }

    public var surface: Double {
        var sum = 0.0
        for index in now.indices { sum += reach[index] * now[index] }
        return sum
    }

    public mutating func displace(to displacements: [Double], moving velocities: [Double] = []) {
        for (index, displacement) in displacements.prefix(count).enumerated() {
            now[index] = displacement
            before[index] = displacement - (index < velocities.count ? velocities[index] : 0) * interval
        }
    }

    public mutating func strike(with striker: Acoustics.Striker, at speed: Double) {
        self.striker = striker
        place = surface
        placed = place - speed * interval
        touching = false
    }

    public var struck: Bool { striker != nil }

    public var energy: Double {
        var total = 0.0
        var reached = 0.0
        var reachedBefore = 0.0
        var spread = 0.0
        var spreadBefore = 0.0
        for index in now.indices {
            let velocity = (now[index] - before[index]) / interval
            let stiffness = mass[index] * warped[index] / (interval * interval)
            total += mass[index] * velocity * velocity / 2 + stiffness * now[index] * before[index] / 2
            reached += reach[index] * now[index]
            reachedBefore += reach[index] * before[index]
            spread += stretch[index] * now[index] * now[index]
            spreadBefore += stretch[index] * before[index] * before[index]
        }
        total += stiffening * spread * spreadBefore / 4
        if let striker {
            let velocity = (place - placed) / interval
            total += striker.mass * velocity * velocity / 2
            total +=
                (striker.energy(pressed: place - reached) + striker.energy(pressed: placed - reachedBefore))
                / 2
        }
        return total
    }

    /// Steps once. `forces` push on the driven places, one each, as they stand now.
    public mutating func advance(driven forces: [Double] = []) {
        var spread = 0.0
        if stiffening != 0 {
            for index in now.indices { spread += stretch[index] * now[index] * now[index] }
        }
        let tension = stiffening * spread
        let step = interval * interval
        var free = 0.0
        var give = 0.0
        var reachedBefore = 0.0
        for index in now.indices {
            let extra = tension == 0 ? 0 : tension * stretch[index] / mass[index] * step / 2
            let weight = 1 + loss[index] + extra
            var next =
                (2 * now[index] - (1 - loss[index] + extra) * before[index] - warped[index] * now[index])
                / weight
            if !forces.isEmpty {
                var pushed = 0.0
                var port = 0
                let used = Swift.min(ports, forces.count)
                while port < used {
                    pushed += driven[index * ports + port] * forces[port]
                    port += 1
                }
                next += step * pushed / (mass[index] * weight)
            }
            ahead[index] = next
            lean[index] = step * reach[index] / (mass[index] * weight)
            reachedBefore += reach[index] * before[index]
            free += reach[index] * next
            give += reach[index] * lean[index]
        }
        var push = 0.0
        if let striker {
            let coasting = 2 * place - placed
            let last = placed - reachedBefore
            let wanted = coasting - free - last
            push = Self.push(striker, from: last, wanted: wanted, slack: step / striker.mass + give)
            let next = coasting - step * push / striker.mass
            placed = place
            place = next
            touching = push > 0
            if !touching, place < placed, last + wanted < 0 { self.striker = nil }
        } else {
            touching = false
        }
        force = push
        for ear in heard.indices { heard[ear] = 0 }
        for port in felt.indices { felt[port] = 0 }
        for index in now.indices {
            let next = ahead[index] + lean[index] * push
            let quickening = next - 2 * now[index] + before[index]
            let speed = next - before[index]
            let base = index * ears
            var ear = 0
            while ear < ears {
                heard[ear] += moving[base + ear] * quickening - turning[base + ear] * speed
                ear += 1
            }
            var port = 0
            while port < ports {
                felt[port] += driven[index * ports + port] * next
                port += 1
            }
            before[index] = now[index]
            now[index] = next
        }
    }

    static func push(
        _ striker: Acoustics.Striker,
        from last: Double,
        wanted: Double,
        slack: Double
    )
        -> Double
    {
        guard last > 0 || last + wanted > 0 else { return 0 }
        func secant(_ change: Double) -> Double {
            change.magnitude < 1e-13
                ? striker.force(pressed: last + change / 2)
                : (striker.energy(pressed: last + change) - striker.energy(pressed: last)) / change
        }
        var high = wanted
        var low =
            wanted - slack
            * Swift.max(striker.force(pressed: last), striker.force(pressed: last + wanted))
        var count = 0
        while count < 64 {
            let middle = low + (high - low) / 2
            if middle + slack * secant(middle) - wanted > 0 { high = middle } else { low = middle }
            count += 1
        }
        return secant(low + (high - low) / 2)
    }
}
