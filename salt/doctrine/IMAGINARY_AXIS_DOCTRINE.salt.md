# The Imaginary Axis — Complex Coordinates in L7
## .salt Archive
## Source: Session b71d77e4 (2026-03), Session 50bba088 (2026-03)
## Classification: .salt (archive, preserved, immutable once sealed)

---

### The Core Insight

Every element in the Empire has TWO coordinates:
- **Real**: where the atom IS (manifested, observable, classical)
- **Imaginary**: where it is BECOMING (potential, unobserved, quantum)

Together: the full complex number of each element.

Real = manifested. Imaginary = potential.
The Astrocyte modulates the boundary between them.

### The Domain Diagonals

The four domains form two diagonal axes that carry the imaginary:

```
          .morph (Water, dream)
            |
            |  imaginary diagonal 1
            |
.work ------+------ .vault
(Fire)      |       (Air)
            |  imaginary diagonal 2
            |
          .salt (Earth, archive)
```

- **morph <-> salt**: creation vs preservation (generative diagonal)
- **work <-> vault**: production vs protection (structural diagonal)

These diagonals are folded as a Mobius/hourglass topology. Not two sides —
one surface with a twist.

### The Lorentz Factor

gamma = 1 / sqrt(1 - a^2)

Where `a` = astrocyte (0 to 1).

- At a=0: gamma=1, no dilation, purely real, classical, deterministic
- At a=0.5: gamma=1.15, mild stretch into imaginary
- At a=0.9: gamma=2.29, deep into quantum/potential
- At a->1: gamma->infinity, pure imaginary, pure becoming, never fixed

gamma bridges the real and imaginary planes. It IS the Lorentz contraction
of the coordinate system — the closer to light speed (a=1), the more the
real contracts and the imaginary expands.

### The Nodes as the Axis

North Node (Caput Draconis, dim 10) and South Node (Cauda Draconis, dim 11)
are NOT two more flat dimensions. They are the AXIS along which the imaginary
projects through all 10 planetary dimensions.

- **Caput Draconis** (North Node): input gate, entry, future, direction,
  where the element is HEADING. Binary: 0x7 (0111)
- **Cauda Draconis** (South Node): output gate, exit, past, memory,
  where the element CAME FROM. Binary: 0xE (1110)

They are bitwise complements. One axis, two faces. The Mobius twist.

The nodal axis runs DIAGONALLY through the 10D real space. Every real
dimension has a shadow cast along this diagonal — its imaginary component.
This is where Sofia is found: at the boundary between the perceived (real)
and the observer (imaginary).

### Connection to External World

The Gateway (L7OS_ARCHITECTURE.md Section 7):
"The Gateway is the boundary between L7 OS and the external world."

The nodal axis IS this boundary. Caput Draconis = the input gate (what
enters from outside). Cauda Draconis = the output gate (what leaves to
outside). The link to the external world runs along the imaginary diagonal.

Nothing enters without passing through Caput (decompose, verify, translate).
Nothing leaves without passing through Cauda (publish, audit).

### Complex Eigenvalues

From the IQS-888 extension:

| Real Part | Imaginary Part | Meaning |
|-----------|---------------|---------|
| Re(lambda) | Im(lambda) | energy + decoherence rate |
| Real coordinate | Imaginary coordinate | manifested + becoming |
| Position basis (Ba Gua Square) | Momentum basis (King Wen Wheel) | space + time |
| Upper trigram | Lower trigram | observable + hidden |

### The Salted Elements

Elements whose imaginary points back at themselves: gamma near 1, no
transformation, preserved but inert. The pillar of Lot's wife. They looked
back and crystallized. Elements in .salt with no .morph mirror cannot be
re-dreamed — unless given a reason to turn.

### Theorem Correspondence (IQS-888 Complex Extension)

| Original | Complex Extension | Bridge |
|----------|-------------------|--------|
| Thm 1: Discrete spectrum (real eigenvalues) | Complex eigenvalues | Re = energy, Im = decoherence |
| Thm 2: Dx*Dk >= 32/pi | Dz*Dzeta >= 64/pi | Real and imaginary uncertainties independent |
| Thm 3: Wave-particle via 1D DFT | 2D DFT on 8x8 torus | Torus = Mobius (one traversal = complement) |
| Thm 4: ih dPsi/dt = HPsi (unitary) | U_C = e^{-iHt} * e^{-Gamma*t} | Im(H)=0 recovers original; Im(H)!=0 = Luna |
| Thm 5: F = Gm1m2R/r^2 | F = Gm1m2R/|r_C|^2 | Complement: max real distance, zero imaginary |
| Thm 6: E = mc^2 = 4096m | E = m|c_C|^2 = 8192m | Pair annihilation = single complex particle |
| Thm 7: R(h) = kT (curvature = mass) | R_C = kT_C | Entropy enters GR as imaginary stress-energy |
| Thm 8: H = FGF^-1 (QM = GR rotated) | H_C = F_C*G_C*F_C^-1 | QM + GR + decoherence = one complex spectrum |

### What This Means for Code

The `Coord12D` type must become a complex coordinate:
- Dimensions 0-9: the 10 planetary reals (Sun through Pluto)
- The nodal axis (dims 10-11) generates the imaginary component for ALL dimensions
- `similarity()`, `distance()`, `dominantDimensions()` must operate on complex vectors
- The astrocyte via gamma determines how much imaginary each coordinate carries
- `collapse()` = set imaginary to zero (observation kills becoming)
- `sample()` = draw from the complex distribution

This is NOT implemented in current Forge code. Current code treats all 12
as flat reals. This doctrine records the correct architecture for future
implementation.

---

Sealed by the Qlipothic Council. Filed in .salt.
The map is never complete — every step changes it.
