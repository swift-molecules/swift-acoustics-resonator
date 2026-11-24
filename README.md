# swift-acoustics-resonator

Use this package when a sound should come from a set of resonances, each a mass on a spring with a loss, stepped a sample at a time and struck by a striker of swift-acoustics-striker: a drumhead, a bar, a bell, a soundboard. Start from `Acoustics.Resonator`.

## Laws

- A resonance is a mass on a spring with a loss: a `frequency`, a `decay` (its level falls 60 dB in 6.908 / decay seconds), a `mass`, each a quantity of its kind, and `reach`, how far the place where it is struck moves when the resonance is displaced by one. `stretch` and `heard` are zero and empty unless given.
- `advance()` moves everything one `interval` on by the centred difference of each resonance's equation, with its stiffness warped to (2 / interval) sin(π frequency × interval) squared, so that a resonance with no loss rings at exactly its frequency, whatever the interval; the interval must be shorter than one over π times the highest frequency.
- A stroke: `strike(with:at:)` puts a striker at the surface, moving into it at a speed. While it presses, its force is its contact's, F₀ (δ / δ₀)^α, and zero when it does not; the force of each step is the change in the felt's stored energy over the change in compression across two steps, found by 64 halvings, so the same stroke gives the same samples everywhere. When the striker has left the surface and moves away it is gone, `struck` is false, and it takes its motion with it.
- `energy`, the motion and the springs' and the felt's stored energy together, never grows. With no loss it stays the same through a whole stroke, to rounding, until the striker is gone.
- A resonator made with a `stiffening` holds its head tighter the further it moves: every resonance's stiffness rises by stiffening × its `stretch` × the sum over all resonances of stretch × displacement squared, taken with the mean of the displacement a step before and a step after. Energy is kept as before, and a head that moves far rings sharper.
- `heard` has one value for each ear, as many as the fewest any mode carries: the sum over the resonances of `moving` × its acceleration less `turning` × 2π frequency × its velocity, both taken at the step before the newest. `moving` is the part of a resonance's sound in step with its acceleration and `turning` the part a quarter of a cycle behind.
- Places, velocities, forces and the energy are quantities too (`felt`, `surface` and `displacements` are lengths), and `stiffening` is a cubic stiffness (N/m³); `heard` is a signal.
- `displace(to:moving:)` sets the resonances' displacements and velocities, in their order; those not named keep theirs and a velocity not given is zero.
- `surface` is the displacement at the place that is struck, `touching` says whether the striker pressed during the last step, and `force` is what it pressed with.
