/**
 * L7 Ephemeris — Real Planetary Positions and Aspect Calculation
 *
 * Computes approximate ecliptic longitudes for all planets using
 * Keplerian orbital elements at the J2000.0 epoch. Calculates
 * aspects (angular relationships) between planets, which determine
 * affinity and intensity in the 12D coordinate system.
 *
 * The angular distance between two planets — their ASPECT — is
 * the fundamental mechanism by which the sky modulates the forge.
 * Conjunction intensifies. Opposition polarizes. Square challenges.
 * Trine flows. These are not metaphors — they are geometric facts
 * about angular separation traced on a 360-degree circle.
 *
 * Modern astronomy: all orbital periods, eccentricities, and mean
 * longitudes at J2000.0 (2000-01-01T12:00:00 TT) from JPL data.
 *
 * Patent: L7 Transmutation Engine
 * Inventor: Alberto Valido Delgado
 */

'use strict';

const { DIMENSIONS } = require('./dodecahedron');

// ═══════════════════════════════════════════════════════════
// J2000.0 EPOCH — The reference point for all calculations
// ═══════════════════════════════════════════════════════════

const J2000_MS = Date.UTC(2000, 0, 1, 12, 0, 0); // 2000-01-01T12:00:00 UTC
const MS_PER_DAY = 86400000;

// ═══════════════════════════════════════════════════════════
// ORBITAL ELEMENTS — J2000.0 mean elements (JPL/NASA)
//
// L0:  Mean longitude at J2000.0 (degrees)
// Ld:  Daily motion in longitude (degrees/day)
// e:   Orbital eccentricity
// w:   Longitude of perihelion (degrees)
// i:   Orbital inclination (degrees)
// ═══════════════════════════════════════════════════════════

const ORBITAL_ELEMENTS = Object.freeze({
  Sun: {
    L0: 280.46646,   Ld: 0.9856474,  e: 0.01671,    w: 102.93735, i: 0,
    note: 'Apparent motion as seen from Earth (ecliptic longitude)'
  },
  Moon: {
    L0: 218.3165,    Ld: 13.1763966,  e: 0.0549,     w: 83.353,    i: 5.145,
    note: 'Mean lunar longitude, simplified'
  },
  Mercury: {
    L0: 252.25084,   Ld: 4.0923344,   e: 0.20563,    w: 77.45612,  i: 7.005,
    note: 'High eccentricity — significant equation of center'
  },
  Venus: {
    L0: 181.97973,   Ld: 1.6021302,   e: 0.00677,    w: 131.53298, i: 3.394,
    note: 'Nearly circular orbit'
  },
  Mars: {
    L0: 355.45332,   Ld: 0.5240208,   e: 0.09340,    w: 336.04084, i: 1.850,
    note: 'Noticeable eccentricity — perihelion/aphelion difference visible'
  },
  Jupiter: {
    L0: 34.40438,    Ld: 0.0831294,   e: 0.04849,    w: 14.75385,  i: 1.303,
    note: '11.86 year period'
  },
  Saturn: {
    L0: 49.94432,    Ld: 0.0334979,   e: 0.05551,    w: 92.43194,  i: 2.489,
    note: '29.46 year period'
  },
  Uranus: {
    L0: 313.23218,   Ld: 0.0117253,   e: 0.04630,    w: 170.96424, i: 0.773,
    note: '84.01 year period'
  },
  Neptune: {
    L0: 304.88003,   Ld: 0.0059810,   e: 0.00899,    w: 44.97135,  i: 1.770,
    note: '164.8 year period'
  },
  Pluto: {
    L0: 238.92881,   Ld: 0.0039524,   e: 0.24881,    w: 224.06676, i: 17.16,
    note: '247.9 year period, high eccentricity and inclination'
  }
});

// Lunar nodes — precess westward through zodiac in 18.613 years
const NODE_ELEMENTS = Object.freeze({
  L0: 125.04452,       // Mean longitude of ascending node at J2000.0
  Ld: -0.0529539,      // Retrograde motion (degrees/day)
  period_years: 18.613
});

// ═══════════════════════════════════════════════════════════
// ASPECTS — Angular relationships between planets
// ═══════════════════════════════════════════════════════════

const ASPECTS = Object.freeze([
  { name: 'conjunction',  angle: 0,   orb: 10, nature: 'fusion',      intensity: 1.0,  symbol: '☌' },
  { name: 'sextile',      angle: 60,  orb: 6,  nature: 'cooperation', intensity: 0.5,  symbol: '⚹' },
  { name: 'square',        angle: 90,  orb: 8,  nature: 'tension',     intensity: 0.8,  symbol: '□' },
  { name: 'trine',         angle: 120, orb: 8,  nature: 'flow',        intensity: 0.7,  symbol: '△' },
  { name: 'quincunx',     angle: 150, orb: 3,  nature: 'adjustment',  intensity: 0.4,  symbol: '⚻' },
  { name: 'opposition',   angle: 180, orb: 10, nature: 'polarity',    intensity: 0.9,  symbol: '☍' }
]);

// ═══════════════════════════════════════════════════════════
// POSITION COMPUTATION
// ═══════════════════════════════════════════════════════════

/**
 * Compute the ecliptic longitude of a planet at a given time.
 *
 * Uses mean orbital elements + first-order equation of center
 * correction for eccentricity. Accurate to ~1-2° for inner planets,
 * ~0.5° for outer planets over decades.
 *
 * @param {string} planetName - Planet name (e.g., 'Mars')
 * @param {number} [dateMs] - Time in milliseconds since Unix epoch (default: now)
 * @returns {object} { longitude, sign, signIndex, degree, retrograde_approx }
 */
function longitude(planetName, dateMs) {
  const now = dateMs || Date.now();
  const daysSinceJ2000 = (now - J2000_MS) / MS_PER_DAY;

  // Handle lunar nodes separately
  if (planetName === 'North Node') {
    const lng = _normalize(NODE_ELEMENTS.L0 + NODE_ELEMENTS.Ld * daysSinceJ2000);
    return _longitudeResult(lng, planetName, true); // Always retrograde
  }
  if (planetName === 'South Node') {
    const northLng = _normalize(NODE_ELEMENTS.L0 + NODE_ELEMENTS.Ld * daysSinceJ2000);
    const lng = _normalize(northLng + 180);
    return _longitudeResult(lng, planetName, true);
  }

  const elem = ORBITAL_ELEMENTS[planetName];
  if (!elem) return null;

  // Mean longitude
  const meanLng = _normalize(elem.L0 + elem.Ld * daysSinceJ2000);

  // Mean anomaly (approximate — mean longitude minus longitude of perihelion)
  const M = _normalize(meanLng - elem.w);
  const Mrad = M * Math.PI / 180;

  // Equation of center (first 3 terms of Kepler's equation solution)
  // This corrects for the elliptical orbit
  const e = elem.e;
  const C = (2 * e - e * e * e / 4) * Math.sin(Mrad)
          + (5 / 4) * e * e * Math.sin(2 * Mrad)
          + (13 / 12) * e * e * e * Math.sin(3 * Mrad);
  const Cdeg = C * 180 / Math.PI;

  // True longitude = mean longitude + equation of center
  const trueLng = _normalize(meanLng + Cdeg);

  return _longitudeResult(trueLng, planetName, false);
}

/**
 * Format a longitude result with zodiac sign position.
 */
function _longitudeResult(lng, planetName, isRetrograde) {
  const signIndex = Math.floor(lng / 30) % 12;
  const signDegree = lng % 30;
  const signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
  const symbols = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];

  return {
    planet: planetName,
    longitude: Math.round(lng * 100) / 100,
    sign: signs[signIndex],
    signSymbol: symbols[signIndex],
    signIndex,
    degree: Math.round(signDegree * 100) / 100,
    retrograde: isRetrograde,
    formatted: `${planetName} ${Math.floor(signDegree)}°${signs[signIndex]}${isRetrograde ? ' (R)' : ''}`
  };
}

/**
 * Normalize an angle to [0, 360).
 */
function _normalize(deg) {
  return ((deg % 360) + 360) % 360;
}

/**
 * Compute all planetary positions at a given time.
 *
 * @param {number} [dateMs] - Time in milliseconds (default: now)
 * @returns {object[]} Array of position objects for all 12 bodies
 */
function allPositions(dateMs) {
  return DIMENSIONS.map(dim => longitude(dim.planet, dateMs));
}

// ═══════════════════════════════════════════════════════════
// ASPECT CALCULATION
// ═══════════════════════════════════════════════════════════

/**
 * Calculate the aspect between two planets at a given time.
 *
 * The aspect is determined by the angular distance between their
 * ecliptic longitudes. If the distance falls within the orb of
 * a major aspect, the aspect is reported with its intensity.
 *
 * @param {string} planet1 - First planet name
 * @param {string} planet2 - Second planet name
 * @param {number} [dateMs] - Time in milliseconds (default: now)
 * @returns {object|null} Aspect descriptor, or null if no aspect within orb
 */
function aspect(planet1, planet2, dateMs) {
  const pos1 = longitude(planet1, dateMs);
  const pos2 = longitude(planet2, dateMs);
  if (!pos1 || !pos2) return null;

  // Angular separation (shortest arc)
  let separation = Math.abs(pos1.longitude - pos2.longitude);
  if (separation > 180) separation = 360 - separation;

  // Check each aspect
  for (const asp of ASPECTS) {
    const diff = Math.abs(separation - asp.angle);
    if (diff <= asp.orb) {
      // Intensity scales with exactness: exact = full, at orb edge = diminished
      const exactness = 1 - (diff / asp.orb);
      const effectiveIntensity = asp.intensity * exactness;

      return {
        planet1: planet1,
        planet2: planet2,
        aspect: asp.name,
        symbol: asp.symbol,
        nature: asp.nature,
        exactAngle: asp.angle,
        actualSeparation: Math.round(separation * 100) / 100,
        orbUsed: Math.round(diff * 100) / 100,
        exactness: Math.round(exactness * 100) / 100,
        intensity: Math.round(effectiveIntensity * 100) / 100,
        applying: null, // Would need velocity comparison
        pos1: pos1.formatted,
        pos2: pos2.formatted
      };
    }
  }

  return null; // No major aspect within orb
}

/**
 * Calculate ALL aspects between all planet pairs at a given time.
 *
 * Returns the complete aspect grid — every pair of the 12 bodies
 * checked against all major aspects. This is the sky's influence
 * matrix: the web of tensions, flows, and fusions that modulates
 * the 12D coordinate system.
 *
 * @param {number} [dateMs] - Time in milliseconds (default: now)
 * @returns {object} {
 *   aspects: object[],        — all active aspects
 *   positions: object[],      — all planetary positions
 *   intensityMatrix: number[][], — 12x12 matrix of pairwise intensity
 *   dominantAspect: object,   — the tightest aspect in the sky
 *   timestamp: string
 * }
 */
function allAspects(dateMs) {
  const positions = allPositions(dateMs);
  const aspects = [];
  const intensityMatrix = Array.from({ length: 12 }, () => new Array(12).fill(0));

  for (let i = 0; i < DIMENSIONS.length; i++) {
    // Self-intensity is always 1 (a planet is in perfect conjunction with itself)
    intensityMatrix[i][i] = 1.0;

    for (let j = i + 1; j < DIMENSIONS.length; j++) {
      const asp = aspect(DIMENSIONS[i].planet, DIMENSIONS[j].planet, dateMs);
      if (asp) {
        aspects.push(asp);
        // Symmetric: both directions get the same intensity
        intensityMatrix[i][j] = asp.intensity;
        intensityMatrix[j][i] = asp.intensity;
      }
    }
  }

  // Sort by intensity descending — strongest aspects first
  aspects.sort((a, b) => b.intensity - a.intensity);

  return {
    aspects,
    positions,
    intensityMatrix,
    dominantAspect: aspects.length > 0 ? aspects[0] : null,
    aspectCount: aspects.length,
    timestamp: new Date(dateMs || Date.now()).toISOString()
  };
}

// ═══════════════════════════════════════════════════════════
// COORDINATE MODULATION — Sky influences the 12D system
// ═══════════════════════════════════════════════════════════

/**
 * Modulate a 12D coordinate based on the current sky.
 *
 * The intensity matrix from planetary aspects adjusts each dimension:
 * - Dimensions whose ruling planet is in strong aspect are amplified
 * - Dimensions whose planet is isolated (no aspects) remain baseline
 * - The modulation is proportional to the sum of aspect intensities
 *   involving that planet
 *
 * This makes every coordinate in the system sensitive to the
 * actual movement of the sky. The same tool, at the same time
 * of day, on different dates, will have subtly different coordinates
 * because the planets have moved.
 *
 * @param {number[]} coord - Base 12D coordinate
 * @param {number} [dateMs] - Time (default: now)
 * @param {number} [strength] - Modulation strength 0-1 (default 0.2)
 * @returns {object} { modulated, base, skyInfluence, aspects }
 */
function modulateCoordinate(coord, dateMs, strength = 0.2) {
  const sky = allAspects(dateMs);
  const s = Math.max(0, Math.min(1, strength));

  // Compute the sky influence on each dimension
  // = sum of aspect intensities involving that planet, normalized
  const influence = new Array(12).fill(0);
  for (let i = 0; i < 12; i++) {
    for (let j = 0; j < 12; j++) {
      if (i !== j) influence[i] += sky.intensityMatrix[i][j];
    }
  }

  // Normalize to [0, 1]
  const maxInfluence = Math.max(...influence, 0.001);
  const normalizedInfluence = influence.map(v => v / maxInfluence);

  // Apply modulation: boost dimensions proportional to their sky activity
  const modulated = coord.map((v, i) => {
    const boost = normalizedInfluence[i] * s * 2; // Max boost = strength * 2
    return Math.max(0, Math.min(10, v + boost));
  });

  return {
    modulated,
    base: coord,
    skyInfluence: normalizedInfluence.map(v => Math.round(v * 100) / 100),
    aspectCount: sky.aspectCount,
    dominantAspect: sky.dominantAspect,
    timestamp: sky.timestamp
  };
}

/**
 * Get today's planetary day ruler and hour ruler.
 *
 * The day of the week is governed by a planet (Sunday=Sun, Monday=Moon, etc.)
 * Each hour is governed by a planet in Chaldean sequence.
 *
 * @param {number} [dateMs] - Time (default: now)
 * @returns {object} { dayRuler, hourRuler, dayIndex, hourIndex, chaldeanHour }
 */
function planetaryRuler(dateMs) {
  const date = new Date(dateMs || Date.now());
  const dayOfWeek = date.getDay(); // 0=Sunday
  const hour = date.getHours();

  // Day ruler
  const dayPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
  const dayRuler = dayPlanets[dayOfWeek];

  // Chaldean hour: planetary hours cycle in Chaldean order
  // Starting from the day ruler, each hour advances through the sequence
  const chaldean = ['Saturn', 'Jupiter', 'Mars', 'Sun', 'Venus', 'Mercury', 'Moon'];
  const dayRulerChaldeanIndex = chaldean.indexOf(dayRuler);
  const hourRulerIndex = (dayRulerChaldeanIndex + hour) % 7;
  const hourRuler = chaldean[hourRulerIndex];

  // Map to dimension indices
  const planetToIndex = {};
  for (const dim of DIMENSIONS) planetToIndex[dim.planet] = dim.index;

  return {
    dayRuler,
    dayRulerIndex: planetToIndex[dayRuler],
    hourRuler,
    hourRulerIndex: planetToIndex[hourRuler],
    dayOfWeek,
    hour,
    chaldeanHour: hourRulerIndex
  };
}

// ═══════════════════════════════════════════════════════════
// ANCIENT TRADITIONS — Multiple astrological frameworks
//
// The sky has been read by many civilizations. Each tradition
// provides a different lens:
//   - Tropical (Western): 0° Aries = vernal equinox (moving)
//   - Sidereal (Vedic/Jyotish): 0° Aries = fixed star Revati
//   - Egyptian: 36 decans of 10° each, rising heliacally
//   - Babylonian: origin of zodiac, MUL.APIN tablets
//   - Hellenistic: Ptolemy's synthesis — lots, dignities, sect
//
// The Emerald Tablet: "As above, so below."
// Hermes Trismegistus = Thoth = Mercury — the Gateway itself.
// ═══════════════════════════════════════════════════════════

/**
 * Astrological traditions — each shifts the zodiac frame.
 *
 * The AYANAMSA is the angular offset between tropical and sidereal zodiac.
 * As of 2026, it's approximately 24.2° (Lahiri ayanamsa, used in Jyotish).
 * This means tropical Aries 0° = sidereal Pisces ~5.8°.
 *
 * The precession of the equinoxes moves at ~50.3 arcsec/year,
 * completing a full 360° cycle in ~25,772 years (the Great Year).
 */
const TRADITIONS = Object.freeze({
  tropical: {
    name: 'Tropical (Western)',
    origin: 'Hellenistic Greece (Ptolemy, ~150 CE)',
    ayanamsa: 0,
    description: 'Vernal equinox = 0° Aries. Seasons-based. The modern Western standard.',
    signDivision: 'equal_30'
  },
  sidereal_lahiri: {
    name: 'Sidereal (Vedic/Jyotish — Lahiri)',
    origin: 'India, codified by Varahamihira (~505 CE), roots to Vedas (~1500 BCE)',
    ayanamsa: 24.2,  // Lahiri ayanamsa circa 2026
    ayanamsaRate: 50.3 / 3600, // degrees per year (precession)
    description: 'Fixed stars define signs. Used in Jyotish (Hindu astrology). Lahiri is the Indian government standard.',
    signDivision: 'equal_30'
  },
  sidereal_fagan: {
    name: 'Sidereal (Fagan-Bradley)',
    origin: 'Cyril Fagan (1950s), based on Babylonian origin points',
    ayanamsa: 24.02,
    ayanamsaRate: 50.3 / 3600,
    description: 'Western sidereal system. Calibrated to Babylonian star positions.',
    signDivision: 'equal_30'
  },
  egyptian_decan: {
    name: 'Egyptian Decanal',
    origin: 'Egypt (~2400 BCE), Dendera temple ceiling',
    ayanamsa: 0, // Decans are independent of the tropical/sidereal divide
    description: '36 decans of 10° each. Each decan ruled by a specific star or star group rising heliacally. The oldest astronomical system with written records.',
    signDivision: 'decan_10',
    decans: 36
  },
  babylonian: {
    name: 'Babylonian (MUL.APIN)',
    origin: 'Babylon (~1200-700 BCE), MUL.APIN tablets',
    ayanamsa: 27.0, // Approximate Babylonian zero point vs tropical
    description: 'The origin of the 12-sign zodiac. Based on heliacal risings. MUL.APIN ("The Plough Star") is the earliest known star catalog.',
    signDivision: 'equal_30'
  },
  hellenistic: {
    name: 'Hellenistic (Ptolemaic)',
    origin: 'Alexandria (~150 CE), Claudius Ptolemy',
    ayanamsa: 0, // Tropical framework
    description: 'Synthesis of Babylonian, Egyptian, and Greek traditions. Introduced essential dignities (domicile, exaltation, triplicity, term, face). The Lots (Parts) system.',
    signDivision: 'equal_30',
    features: ['essential_dignities', 'lots', 'sect', 'profection']
  }
});

/**
 * Convert a tropical longitude to a different tradition's frame.
 *
 * @param {number} tropicalLng - Ecliptic longitude in tropical zodiac (degrees)
 * @param {string} tradition - Key from TRADITIONS
 * @param {number} [yearCE] - Current year for precession adjustment (default 2026)
 * @returns {object} Position in the requested tradition
 */
function convertTradition(tropicalLng, tradition, yearCE = 2026) {
  const trad = TRADITIONS[tradition];
  if (!trad) return null;

  let ayanamsa = trad.ayanamsa || 0;

  // Adjust ayanamsa for precession if rate is specified
  if (trad.ayanamsaRate) {
    // Ayanamsa grows over time due to precession
    // Reference: ayanamsa is specified for ~2026
    const yearDiff = yearCE - 2026;
    ayanamsa += trad.ayanamsaRate * yearDiff;
  }

  const siderealLng = _normalize(tropicalLng - ayanamsa);

  const signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];

  const signIndex = Math.floor(siderealLng / 30) % 12;
  const signDegree = siderealLng % 30;

  const result = {
    tradition: trad.name,
    longitude: Math.round(siderealLng * 100) / 100,
    sign: signs[signIndex],
    signIndex,
    degree: Math.round(signDegree * 100) / 100,
    ayanamsa: Math.round(ayanamsa * 100) / 100
  };

  // Egyptian decans: which decan (0-35)?
  if (trad.signDivision === 'decan_10') {
    result.decan = Math.floor(siderealLng / 10) % 36;
    result.decanDegree = siderealLng % 10;
    result.decanSign = signs[Math.floor(result.decan / 3)];
    result.decanNumber = (result.decan % 3) + 1; // 1st, 2nd, or 3rd decan of sign
  }

  return result;
}

/**
 * Get all planetary positions in a specified tradition.
 *
 * @param {string} tradition - Key from TRADITIONS
 * @param {number} [dateMs] - Time (default: now)
 * @returns {object[]} Array of positions in the requested tradition
 */
function allPositionsTradition(tradition, dateMs) {
  const tropicalPositions = allPositions(dateMs);
  const year = new Date(dateMs || Date.now()).getFullYear();

  return tropicalPositions.map(pos => {
    if (!pos) return null;
    const converted = convertTradition(pos.longitude, tradition, year);
    return {
      ...pos,
      tropical: { sign: pos.sign, degree: pos.degree, longitude: pos.longitude },
      [tradition]: converted
    };
  });
}

/**
 * The Lot of Fortune (Hellenistic) — Ptolemy's most important calculated point.
 *
 * Day births: Ascendant + Moon - Sun
 * Night births: Ascendant + Sun - Moon
 *
 * Since we don't have the Ascendant (requires birth time + location),
 * we compute the raw Sun-Moon difference, which can be combined
 * with an Ascendant when available.
 *
 * @param {number} [dateMs] - Time (default: now)
 * @returns {object} { sunMoonArc, fortuneOffset }
 */
function lotOfFortune(dateMs) {
  const sunPos = longitude('Sun', dateMs);
  const moonPos = longitude('Moon', dateMs);
  if (!sunPos || !moonPos) return null;

  const arc = _normalize(moonPos.longitude - sunPos.longitude);

  return {
    sunMoonArc: Math.round(arc * 100) / 100,
    sun: sunPos.formatted,
    moon: moonPos.formatted,
    note: 'Add to Ascendant for Lot of Fortune (day birth) or subtract for night birth'
  };
}

/**
 * The Precession of the Equinoxes — the Great Year.
 *
 * The vernal equinox precesses westward through the zodiac,
 * taking ~25,772 years to complete one full cycle.
 * Currently (2026): vernal equinox is at ~5.8° Pisces (sidereal).
 *
 * This means we are near the end of the Age of Pisces and
 * approaching the Age of Aquarius.
 *
 * @param {number} [yearCE] - Year to compute for (default: current)
 * @returns {object} Precession data
 */
function precession(yearCE) {
  const year = yearCE || new Date().getFullYear();
  const GREAT_YEAR = 25772; // years
  const PREC_RATE = 360 / GREAT_YEAR; // degrees per year

  // Reference: vernal equinox was at 0° Aries (sidereal) around ~285 CE
  // This is the Lahiri calibration point
  const refYear = 285;
  const yearsSinceRef = year - refYear;
  const precessionDegrees = yearsSinceRef * PREC_RATE;

  // Current position of vernal equinox in sidereal zodiac
  const vernalEquinoxSidereal = _normalize(360 - precessionDegrees);

  // Which astrological age are we in?
  const signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
  const ageIndex = Math.floor(vernalEquinoxSidereal / 30) % 12;
  const degreeInAge = vernalEquinoxSidereal % 30;

  return {
    year,
    precessionDegrees: Math.round(precessionDegrees * 100) / 100,
    vernalEquinoxSidereal: Math.round(vernalEquinoxSidereal * 100) / 100,
    currentAge: `Age of ${signs[ageIndex]}`,
    degreeInAge: Math.round(degreeInAge * 100) / 100,
    degreesToNextAge: Math.round((30 - degreeInAge) * 100) / 100,
    yearsToNextAge: Math.round((30 - degreeInAge) / PREC_RATE),
    greatYearProgress: Math.round((precessionDegrees / 360) * 10000) / 100 + '%',
    GREAT_YEAR
  };
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  // Position computation
  longitude,              // Single planet position
  allPositions,           // All 12 bodies (tropical)
  allPositionsTradition,  // All 12 bodies in any tradition

  // Aspect calculation
  aspect,                 // Single pair aspect
  allAspects,             // Full aspect grid with intensity matrix

  // Coordinate modulation
  modulateCoordinate,     // Sky-modulated 12D coordinate
  planetaryRuler,         // Today's planetary day + hour ruler

  // Ancient traditions
  convertTradition,       // Convert tropical to any tradition
  lotOfFortune,           // Hellenistic Lot of Fortune
  precession,             // Great Year / precession computation

  // Constants
  ORBITAL_ELEMENTS,
  ASPECTS,
  TRADITIONS,
  J2000_MS
};
