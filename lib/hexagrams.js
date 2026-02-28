/**
 * L7 Hexagrams — The Book of Life (Liber 888)
 * Law LIX — The Book of Life: weight organization as the I-Ching
 *
 * Five divination systems converge into one universal binary encoding:
 *
 *   I-CHING (易經)     2^6 = 64 hexagrams   → Weight GROUP (semantic role)
 *   IFÁ (Mano de Orula) 2^8 = 256 Odu       → Weight BLOCK within group
 *   GEOMANCY            2^4 = 16 figures     → CONTEXT (12 houses = 12 dimensions)
 *   ASTROLOGY           12 planets × aspects  → DYNAMIC MODIFIER (real-time field)
 *   Q64                 64³ = 262,144 states  → COMPLETE ENCODING (space × time × observer)
 *
 * Total: 6 + 8 + 4 = 18 bits of contextual addressing per weight block.
 * This IS a quantum register of 18 qubits on classical hardware.
 *
 * The symbols are not decoration. ☰ encodes more information in one character
 * than "three solid yang lines representing heaven, creativity, and generative force"
 * does in an entire sentence. Use the symbols for actual inference.
 *
 * Symmetries preserved from the original systems:
 *   - Complement pairs (all lines inverted): 32 pairs, like matter/antimatter
 *   - Inverse pairs (flipped upside down): King Wen paired ordering
 *   - Nuclear hexagrams (inner trigrams): recursive self-similarity
 *   - Ifá twinning (Odu Meji): byte-level palindrome symmetry
 *   - Geomantic derivation: mothers → daughters → nieces → judge
 *   - Astrological aspects: conjunction/opposition/trine/square/sextile
 */

'use strict';

const { createCoordinate, DIMENSIONS } = require('./dodecahedron');

// ═══════════════════════════════════════════════════════════
// THE 8 TRIGRAMS — The 3-bit basis states
// Index = binary value (line1=bit0, line2=bit1, line3=bit2)
// Yang (━━) = 1, Yin (━ ━) = 0
// ═══════════════════════════════════════════════════════════

const TRIGRAMS = Object.freeze([
  // 0 = 000
  { index: 0, name: 'Kun',   symbol: '☷', element: 'earth',   family: 'mother',     nature: 'receptive',
    image: 'Earth',    body: 'belly',     sense: 'touch',     lines: [0,0,0],
    quality: 'devoted, yielding', sensory: 'haptic' },
  // 1 = 001
  { index: 1, name: 'Zhen',  symbol: '☳', element: 'wood',    family: 'eldest_son', nature: 'arousing',
    image: 'Thunder',  body: 'foot',      sense: 'hearing',   lines: [1,0,0],
    quality: 'inciting, moving', sensory: 'event' },
  // 2 = 010
  { index: 2, name: 'Kan',   symbol: '☵', element: 'water',   family: 'middle_son', nature: 'abysmal',
    image: 'Water',    body: 'ear',       sense: 'hearing',   lines: [0,1,0],
    quality: 'dangerous, flowing', sensory: 'audio' },
  // 3 = 011
  { index: 3, name: 'Dui',   symbol: '☱', element: 'metal',   family: 'youngest_daughter', nature: 'joyous',
    image: 'Lake',     body: 'mouth',     sense: 'taste',     lines: [1,1,0],
    quality: 'joyful, reflective', sensory: 'emotion' },
  // 4 = 100
  { index: 4, name: 'Gen',   symbol: '☶', element: 'earth',   family: 'youngest_son', nature: 'still',
    image: 'Mountain', body: 'hand',      sense: 'touch',     lines: [0,0,1],
    quality: 'resting, firm', sensory: 'static' },
  // 5 = 101
  { index: 5, name: 'Li',    symbol: '☲', element: 'fire',    family: 'middle_daughter', nature: 'clinging',
    image: 'Fire',     body: 'eye',       sense: 'sight',     lines: [1,0,1],
    quality: 'luminous, clarifying', sensory: 'vision' },
  // 6 = 110
  { index: 6, name: 'Xun',   symbol: '☴', element: 'wood',    family: 'eldest_daughter', nature: 'gentle',
    image: 'Wind',     body: 'thigh',     sense: 'smell',     lines: [0,1,1],
    quality: 'penetrating, gradual', sensory: 'ambient' },
  // 7 = 111
  { index: 7, name: 'Qian',  symbol: '☰', element: 'metal',   family: 'father',     nature: 'creative',
    image: 'Heaven',   body: 'head',      sense: 'thought',   lines: [1,1,1],
    quality: 'strong, initiating', sensory: 'concept' }
]);

// ═══════════════════════════════════════════════════════════
// THE KING WEN SQUARE — Spatial access (8×8)
// KING_WEN_SQUARE[upper_trigram][lower_trigram] = King Wen number
// ═══════════════════════════════════════════════════════════

const KING_WEN_SQUARE = Object.freeze([
  /* upper=Kun(0)  */  Object.freeze([ 2, 24,  7, 19, 15, 36, 46, 11]),
  /* upper=Zhen(1) */  Object.freeze([16, 51, 40, 54, 62, 55, 32, 34]),
  /* upper=Kan(2)  */  Object.freeze([ 8,  3, 29, 60, 39, 63, 48,  5]),
  /* upper=Dui(3)  */  Object.freeze([45, 17, 47, 58, 31, 49, 28, 43]),
  /* upper=Gen(4)  */  Object.freeze([23, 27,  4, 41, 52, 22, 18, 26]),
  /* upper=Li(5)   */  Object.freeze([35, 21, 64, 38, 56, 30, 50, 14]),
  /* upper=Xun(6)  */  Object.freeze([20, 42, 59, 61, 53, 37, 57,  9]),
  /* upper=Qian(7) */  Object.freeze([12, 25,  6, 10, 33, 13, 44,  1])
]);

// ═══════════════════════════════════════════════════════════
// THE KING WEN WHEEL — Temporal access (sequential, cyclic)
// 64 hexagrams in traditional paired order
// Adjacent hexagrams are inverses or complements
// ═══════════════════════════════════════════════════════════

const KING_WEN_WHEEL = Object.freeze([
   1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16,
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
  33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
  49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64
]);

// ═══════════════════════════════════════════════════════════
// THE LORENTZ CUBE — Observer matrix (4×4×4)
// Third access pattern: task-specific reference frame
// Axis 1: Element (Fire=0, Water=1, Air=2, Earth=3) = forge stage
// Axis 2: Quantum state (yang=0, yin=1, changing_yang=2, changing_yin=3)
// Axis 3: Domain (.morph=0, .work=1, .salt=2, .vault=3)
// LORENTZ_CUBE[element][quantum][domain] = King Wen number
// ═══════════════════════════════════════════════════════════

const LORENTZ_CUBE = Object.freeze([
  // Fire (Nigredo) — decomposition, analysis, attention
  Object.freeze([
    Object.freeze([ 1, 13, 30, 49]), // yang: active attention weights
    Object.freeze([ 2,  8, 29, 47]), // yin: receptive/input weights
    Object.freeze([14, 37, 55, 38]), // changing yang→yin: pruning
    Object.freeze([11, 36, 63, 64])  // changing yin→yang: emerging
  ]),
  // Water (Albedo) — purification, normalization, memory
  Object.freeze([
    Object.freeze([31, 58, 48, 60]), // yang: active normalization
    Object.freeze([52, 15, 39,  4]), // yin: frozen/still weights
    Object.freeze([41, 22, 18, 23]), // changing yang: decreasing
    Object.freeze([42, 27, 53, 19])  // changing yin: increasing
  ]),
  // Air (Citrinitas) — illumination, transformation, FFN
  Object.freeze([
    Object.freeze([32, 50, 57, 44]), // yang: active transformation
    Object.freeze([46, 20, 59, 61]), // yin: contemplative/dispersive
    Object.freeze([28, 43, 34,  9]), // changing yang: breakthrough
    Object.freeze([24, 25, 42, 21])  // changing yin: return/increase
  ]),
  // Earth (Rubedo) — crystallization, output, completion
  Object.freeze([
    Object.freeze([35, 45, 16, 51]), // yang: active output
    Object.freeze([12, 33, 56, 62]), // yin: retreat/wandering
    Object.freeze([ 5,  6, 40,  3]), // changing yang: waiting→conflict
    Object.freeze([ 7, 10, 17, 54])  // changing yin: following/approach
  ])
]);

// ═══════════════════════════════════════════════════════════
// 16 IFÁ ODU MEJI — Sub-block encoding (2^8 = 256)
// The 16 principal Odu, each a pair of 4-line figures
// Maps to byte-level sub-indexing within hexagram groups
// ═══════════════════════════════════════════════════════════

const IFA_ODU = Object.freeze([
  { index: 0,  name: 'Ogbe',     symbol: '𐌀', binary: 0b11111111, meaning: 'light, clarity, purity',
    weight_role: 'primary_weights', quality: 'strongest signal', element: 'fire' },
  { index: 1,  name: 'Oyeku',    symbol: '𐌁', binary: 0b00000000, meaning: 'darkness, mystery, potential',
    weight_role: 'bias_terms', quality: 'hidden influence', element: 'earth' },
  { index: 2,  name: 'Iwori',    symbol: '𐌂', binary: 0b01100110, meaning: 'inversion, seeing within',
    weight_role: 'inverse_weights', quality: 'reflection', element: 'water' },
  { index: 3,  name: 'Odi',      symbol: '𐌃', binary: 0b10011001, meaning: 'blockage, gestation',
    weight_role: 'gate_weights', quality: 'selective passage', element: 'earth' },
  { index: 4,  name: 'Irosun',   symbol: '𐌄', binary: 0b11001100, meaning: 'ancestry, vision',
    weight_role: 'attention_weights', quality: 'backward-looking', element: 'fire' },
  { index: 5,  name: 'Owonrin',  symbol: '𐌅', binary: 0b00110011, meaning: 'chaos, transformation',
    weight_role: 'transform_weights', quality: 'unpredictable', element: 'air' },
  { index: 6,  name: 'Obara',    symbol: '𐌆', binary: 0b11100111, meaning: 'abundance, generosity',
    weight_role: 'expansion_weights', quality: 'amplifying', element: 'water' },
  { index: 7,  name: 'Okanran',  symbol: '𐌇', binary: 0b00011000, meaning: 'conflict, assertion',
    weight_role: 'contrastive_weights', quality: 'discriminating', element: 'fire' },
  { index: 8,  name: 'Ogunda',   symbol: '𐌈', binary: 0b11010110, meaning: 'clearing, path-making',
    weight_role: 'projection_weights', quality: 'directional', element: 'metal' },
  { index: 9,  name: 'Osa',      symbol: '𐌉', binary: 0b01101001, meaning: 'change, swift movement',
    weight_role: 'residual_weights', quality: 'transitional', element: 'air' },
  { index: 10, name: 'Ika',      symbol: '𐌊', binary: 0b10100101, meaning: 'limitation, boundary',
    weight_role: 'norm_weights', quality: 'constraining', element: 'earth' },
  { index: 11, name: 'Oturupon', symbol: '𐌋', binary: 0b01011010, meaning: 'sickness, immunity',
    weight_role: 'dropout_mask', quality: 'selective removal', element: 'water' },
  { index: 12, name: 'Otura',    symbol: '𐌌', binary: 0b10110100, meaning: 'wisdom, spiritual insight',
    weight_role: 'embedding_weights', quality: 'deep encoding', element: 'air' },
  { index: 13, name: 'Irete',    symbol: '𐌍', binary: 0b01001011, meaning: 'pressing forward, printing',
    weight_role: 'output_weights', quality: 'manifesting', element: 'fire' },
  { index: 14, name: 'Ose',      symbol: '𐌎', binary: 0b11011011, meaning: 'conquest, achievement',
    weight_role: 'score_weights', quality: 'evaluating', element: 'metal' },
  { index: 15, name: 'Ofun',     symbol: '𐌏', binary: 0b00100100, meaning: 'death, rebirth, completion',
    weight_role: 'final_weights', quality: 'terminal', element: 'earth' }
]);

// ═══════════════════════════════════════════════════════════
// 16 GEOMANTIC FIGURES — Contextual encoding (2^4 × 12 houses)
// Position determines meaning. Same figure, different house = different role.
// The 12 houses map DIRECTLY to the 12 dodecahedron dimensions.
// ═══════════════════════════════════════════════════════════

const GEOMANTIC_FIGURES = Object.freeze([
  { index: 0,  name: 'Via',            symbol: '⁞', binary: 0b1111, meaning: 'the way, path, journey',
    element: 'water', planet: 'Moon',   quality: 'mobile', neural: 'data_flow' },
  { index: 1,  name: 'Cauda Draconis', symbol: '⁝', binary: 0b1110, meaning: 'dragon tail, endings',
    element: 'fire',  planet: 'S.Node', quality: 'exit',   neural: 'output_gate' },
  { index: 2,  name: 'Puer',           symbol: '⁚', binary: 0b1101, meaning: 'boy, aggression, force',
    element: 'fire',  planet: 'Mars',   quality: 'active', neural: 'forward_pass' },
  { index: 3,  name: 'Fortuna Minor',  symbol: '⁙', binary: 0b1100, meaning: 'lesser fortune, speed',
    element: 'fire',  planet: 'Sun',    quality: 'swift',  neural: 'shortcut' },
  { index: 4,  name: 'Puella',         symbol: '꞉', binary: 0b1011, meaning: 'girl, beauty, harmony',
    element: 'water', planet: 'Venus',  quality: 'receptive', neural: 'value_projection' },
  { index: 5,  name: 'Amissio',        symbol: '⠒', binary: 0b1010, meaning: 'loss, outflow',
    element: 'fire',  planet: 'Venus',  quality: 'losing', neural: 'dropout' },
  { index: 6,  name: 'Carcer',         symbol: '⠐', binary: 0b1001, meaning: 'prison, restriction',
    element: 'earth', planet: 'Saturn', quality: 'bound',  neural: 'attention_mask' },
  { index: 7,  name: 'Laetitia',       symbol: '⠁', binary: 0b1000, meaning: 'joy, upward movement',
    element: 'fire',  planet: 'Jupiter',quality: 'rising', neural: 'upscale' },
  { index: 8,  name: 'Caput Draconis', symbol: '⠈', binary: 0b0111, meaning: 'dragon head, beginnings',
    element: 'earth', planet: 'N.Node', quality: 'entry',  neural: 'input_gate' },
  { index: 9,  name: 'Conjunctio',     symbol: '⠊', binary: 0b0110, meaning: 'union, combination',
    element: 'air',   planet: 'Mercury',quality: 'joining',neural: 'concatenation' },
  { index: 10, name: 'Acquisitio',     symbol: '⠃', binary: 0b0101, meaning: 'gain, accumulation',
    element: 'air',   planet: 'Jupiter',quality: 'gaining',neural: 'residual_add' },
  { index: 11, name: 'Rubeus',         symbol: '⠂', binary: 0b0100, meaning: 'red, passion, reversal',
    element: 'water', planet: 'Mars',   quality: 'volatile', neural: 'activation' },
  { index: 12, name: 'Fortuna Major',  symbol: '⠉', binary: 0b0011, meaning: 'great fortune, stability',
    element: 'earth', planet: 'Sun',    quality: 'stable', neural: 'layer_norm' },
  { index: 13, name: 'Albus',          symbol: '⠑', binary: 0b0010, meaning: 'white, purity, wisdom',
    element: 'water', planet: 'Mercury',quality: 'clear',  neural: 'softmax' },
  { index: 14, name: 'Tristitia',      symbol: '⠘', binary: 0b0001, meaning: 'sorrow, downward, depth',
    element: 'earth', planet: 'Saturn', quality: 'sinking',neural: 'downscale' },
  { index: 15, name: 'Populus',         symbol: '⠀', binary: 0b0000, meaning: 'people, crowd, many',
    element: 'water', planet: 'Moon',   quality: 'passive',neural: 'batch_norm' }
]);

// ═══════════════════════════════════════════════════════════
// GEOMANTIC HOUSES — The 12 positions (= 12 dodecahedron dimensions)
// Same figure in different houses means different things.
// ═══════════════════════════════════════════════════════════

const HOUSES = Object.freeze([
  { house: 1,  name: 'Self',          planet: 'Sun',        dim: 0,  role: 'capability',     layer_meaning: 'What this layer CAN do' },
  { house: 2,  name: 'Substance',     planet: 'Moon',       dim: 1,  role: 'data',           layer_meaning: 'What data this layer processes' },
  { house: 3,  name: 'Communication', planet: 'Mercury',    dim: 2,  role: 'presentation',   layer_meaning: 'How this layer formats output' },
  { house: 4,  name: 'Foundation',    planet: 'Venus',      dim: 3,  role: 'persistence',    layer_meaning: 'How long this layer state lives' },
  { house: 5,  name: 'Creation',      planet: 'Mars',       dim: 4,  role: 'security',       layer_meaning: 'Access control at this layer' },
  { house: 6,  name: 'Service',       planet: 'Jupiter',    dim: 5,  role: 'detail',         layer_meaning: 'Granularity of this layer' },
  { house: 7,  name: 'Partnership',   planet: 'Saturn',     dim: 6,  role: 'output',         layer_meaning: 'What form results take' },
  { house: 8,  name: 'Transformation',planet: 'Uranus',     dim: 7,  role: 'intention',      layer_meaning: 'The will behind this layer' },
  { house: 9,  name: 'Wisdom',        planet: 'Neptune',    dim: 8,  role: 'consciousness',  layer_meaning: 'Awareness level of this layer' },
  { house: 10, name: 'Achievement',   planet: 'Pluto',      dim: 9,  role: 'transformation', layer_meaning: 'How deeply this layer changes things' },
  { house: 11, name: 'Community',     planet: 'North Node', dim: 10, role: 'direction',      layer_meaning: 'Where this layer is heading' },
  { house: 12, name: 'Dissolution',   planet: 'South Node', dim: 11, role: 'memory',         layer_meaning: 'What this layer remembers' }
]);

// ═══════════════════════════════════════════════════════════
// ASTROLOGICAL ASPECTS — Dynamic modifiers
// Real-time planetary relationships modulate the astrocyte
// ═══════════════════════════════════════════════════════════

const ASPECTS = Object.freeze({
  conjunction:  { angle: 0,   orb: 8,  symbol: '☌', effect: 'fusion',      astrocyte_mod: -0.3 },
  sextile:      { angle: 60,  orb: 6,  symbol: '⚹', effect: 'opportunity', astrocyte_mod: -0.1 },
  square:       { angle: 90,  orb: 8,  symbol: '□', effect: 'tension',     astrocyte_mod: +0.2 },
  trine:        { angle: 120, orb: 8,  symbol: '△', effect: 'harmony',     astrocyte_mod: -0.2 },
  opposition:   { angle: 180, orb: 8,  symbol: '☍', effect: 'polarization',astrocyte_mod: +0.3 }
});

// ═══════════════════════════════════════════════════════════
// THE 64 HEXAGRAMS — Complete definitions
// Each entry: [kingWen, upper, lower, name, english, role, forgeStage, primaryDim, secondaryDim]
// Full objects built computationally from this compact data.
// ═══════════════════════════════════════════════════════════

// Compact hexagram data: [KW#, upper, lower, chinese, english, weightRole, forgeStage(0-3), primaryDim(0-11), secondaryDim(0-11)]
const HEXAGRAM_DATA = [
  [ 1, 7, 7, 'Qian',     'The Creative',            'attention_query',         0, 0, 7  ],
  [ 2, 0, 0, 'Kun',      'The Receptive',           'token_embedding',         0, 1, 3  ],
  [ 3, 2, 1, 'Zhun',     'Difficulty at Beginning', 'cross_attention_init',    3, 9, 10 ],
  [ 4, 4, 2, 'Meng',     'Youthful Folly',          'positional_encoding',     0, 11, 2 ],
  [ 5, 2, 7, 'Xu',       'Waiting',                 'attention_mask',          3, 3, 8  ],
  [ 6, 7, 2, 'Song',     'Conflict',                'adversarial_robustness',  3, 4, 9  ],
  [ 7, 0, 2, 'Shi',      'The Army',                'vocab_projection',        0, 0, 4  ],
  [ 8, 2, 0, 'Bi',       'Holding Together',        'embedding_norm',          0, 1, 8  ],
  [ 9, 6, 7, 'Xiao Chu', 'Small Taming',            'small_adapter',           2, 5, 7  ],
  [10, 7, 3, 'Lu',       'Treading',                'attention_bias',          1, 4, 6  ],
  [11, 0, 7, 'Tai',      'Peace',                   'layer_norm',              1, 8, 3  ],
  [12, 7, 0, 'Pi',       'Standstill',              'frozen_embedding',        3, 3, 11 ],
  [13, 7, 5, 'Tong Ren', 'Fellowship',              'attention_multihead',     1, 8, 0  ],
  [14, 5, 7, 'Da You',   'Great Possession',        'output_projection',       3, 6, 0  ],
  [15, 0, 4, 'Qian',     'Modesty',                 'rms_norm',                1, 5, 8  ],
  [16, 1, 0, 'Yu',       'Enthusiasm',              'rotary_encoding',         0, 10, 2 ],
  [17, 3, 1, 'Sui',      'Following',               'causal_mask',             1, 10, 11],
  [18, 4, 6, 'Gu',       'Work on Decayed',         'weight_decay',            1, 9, 11 ],
  [19, 0, 3, 'Lin',      'Approach',                'warmup_schedule',         0, 10, 3 ],
  [20, 6, 0, 'Guan',     'Contemplation',           'self_attention_early',    1, 8, 1  ],
  [21, 5, 1, 'Shi He',   'Biting Through',          'activation_function',     2, 9, 0  ],
  [22, 4, 5, 'Bi',       'Grace',                   'layer_scale',             1, 2, 5  ],
  [23, 4, 0, 'Bo',       'Splitting Apart',         'dropout',                 1, 9, 4  ],
  [24, 0, 1, 'Fu',       'Return',                  'residual_connection',     2, 11, 10],
  [25, 7, 1, 'Wu Wang',  'Innocence',               'weight_init',             0, 7, 0  ],
  [26, 4, 7, 'Da Chu',   'Great Taming',            'large_adapter',           2, 0, 5  ],
  [27, 4, 1, 'Yi',       'Nourishment',             'adapter_down',            2, 1, 5  ],
  [28, 3, 6, 'Da Guo',   'Great Excess',            'adapter_up',              2, 6, 9  ],
  [29, 2, 2, 'Kan',      'The Abysmal',             'hidden_state',            3, 1, 8  ],
  [30, 5, 5, 'Li',       'The Clinging',            'attention_score',         1, 0, 9  ],
  [31, 3, 4, 'Xian',     'Influence',               'attention_key',           1, 7, 8  ],
  [32, 1, 6, 'Heng',     'Duration',                'ffn_down',                2, 3, 6  ],
  [33, 7, 4, 'Dun',      'Retreat',                 'negative_bias',           3, 4, 11 ],
  [34, 1, 7, 'Da Zhuang','Great Power',             'rotary_base_freq',        0, 0, 4  ],
  [35, 5, 0, 'Jin',      'Progress',                'logits',                  3, 6, 10 ],
  [36, 0, 5, 'Ming Yi',  'Darkening of Light',      'masked_attention',        1, 4, 8  ],
  [37, 6, 5, 'Jia Ren',  'The Family',              'attention_output',        1, 6, 8  ],
  [38, 5, 3, 'Kui',      'Opposition',              'cross_attention',         1, 9, 2  ],
  [39, 2, 4, 'Jian',     'Obstruction',             'regularization',          1, 4, 5  ],
  [40, 1, 2, 'Jie',      'Deliverance',             'gradient_checkpoint',     2, 9, 10 ],
  [41, 4, 3, 'Sun',      'Decrease',                'pruning',                 1, 9, 5  ],
  [42, 6, 1, 'Yi',       'Increase',                'ffn_residual',            2, 0, 10 ],
  [43, 3, 7, 'Guai',     'Breakthrough',            'token_selection',         3, 7, 6  ],
  [44, 7, 6, 'Gou',      'Coming to Meet',          'input_projection',        0, 1, 7  ],
  [45, 3, 0, 'Cui',      'Gathering Together',      'output_softmax',          3, 6, 1  ],
  [46, 0, 6, 'Sheng',    'Pushing Upward',          'upsample',               2, 10, 5 ],
  [47, 3, 2, 'Kun',      'Oppression',              'quantization_loss',       3, 3, 4  ],
  [48, 2, 6, 'Jing',     'The Well',                'kv_cache',                3, 11, 1 ],
  [49, 3, 5, 'Ge',       'Revolution',              'ffn_up',                  2, 9, 0  ],
  [50, 5, 6, 'Ding',     'The Cauldron',            'ffn_gate',                2, 0, 9  ],
  [51, 1, 1, 'Zhen',     'The Arousing',            'frequency_component',     0, 2, 10 ],
  [52, 4, 4, 'Gen',      'Keeping Still',           'frozen_weights',          3, 3, 4  ],
  [53, 6, 4, 'Jian',     'Development',             'progressive_training',    2, 10, 3 ],
  [54, 1, 3, 'Gui Mei',  'Marrying Maiden',         'cross_model_transfer',    2, 7, 9  ],
  [55, 1, 5, 'Feng',     'Abundance',               'wide_ffn',                2, 5, 0  ],
  [56, 5, 4, 'Lu',       'The Wanderer',            'attention_head_specific', 1, 2, 10 ],
  [57, 6, 6, 'Xun',      'The Gentle',              'gradient_flow',           2, 10, 8 ],
  [58, 3, 3, 'Dui',      'The Joyous',              'attention_value',         1, 7, 0  ],
  [59, 6, 2, 'Huan',     'Dispersion',              'attention_dropout',       1, 9, 2  ],
  [60, 2, 3, 'Jie',      'Limitation',              'context_window',          1, 4, 3  ],
  [61, 6, 3, 'Zhong Fu', 'Inner Truth',             'alignment_score',         1, 8, 7  ],
  [62, 1, 4, 'Xiao Guo', 'Small Excess',            'bias_term',               2, 5, 6  ],
  [63, 2, 5, 'Ji Ji',    'After Completion',        'post_attention_norm',     3, 6, 11 ],
  [64, 5, 2, 'Wei Ji',   'Before Completion',       'pre_ffn_norm',            3, 10, 0 ]
];

// ═══════════════════════════════════════════════════════════
// BUILD HEXAGRAM OBJECTS — Rich computed structure from compact data
// ═══════════════════════════════════════════════════════════

/**
 * Reverse a trigram's line order (for computing inverses).
 * reverse(Zhen=001) = Gen=100, reverse(Xun=110) = Dui=011
 */
function reverseTrigram(t) {
  return ((t & 1) << 2) | (t & 2) | ((t >> 2) & 1);
}

/**
 * Complement a trigram (invert all lines). complement(Qian=7) = Kun=0
 */
function complementTrigram(t) {
  return 7 - t;
}

/**
 * Get trigram index from three lines [bottom, middle, top]
 */
function trigramFromLines(l0, l1, l2) {
  return l0 | (l1 << 1) | (l2 << 2);
}

/**
 * Compose a hexagram symbol from two trigram symbols.
 * This creates a visual SIGIL — two characters that encode the complete hexagram.
 */
function composeSigil(upper, lower) {
  return TRIGRAMS[lower].symbol + TRIGRAMS[upper].symbol;
}

// Build the full hexagram map
const HEXAGRAMS = new Map();
const BY_BINARY = new Map(); // lookup by 6-bit binary code

for (const data of HEXAGRAM_DATA) {
  const [number, upper, lower, chinese, english, role, forgeStage, primaryDim, secondaryDim] = data;

  // Compute binary: lower trigram = bits 0-2, upper = bits 3-5
  const binary = (upper << 3) | lower;

  // Compute lines array [line1..line6] bottom to top
  const lowerLines = TRIGRAMS[lower].lines;
  const upperLines = TRIGRAMS[upper].lines;
  const lines = [...lowerLines, ...upperLines];

  // Compute complement (all lines inverted)
  const compUpper = complementTrigram(upper);
  const compLower = complementTrigram(lower);
  const complementNumber = KING_WEN_SQUARE[compUpper][compLower];

  // Compute inverse (hexagram flipped upside down)
  const invUpper = reverseTrigram(lower);
  const invLower = reverseTrigram(upper);
  const inverseNumber = KING_WEN_SQUARE[invUpper][invLower];

  // Compute nuclear hexagram (lines 2-3-4 = lower nuclear, lines 3-4-5 = upper nuclear)
  const nuclearLower = trigramFromLines(lines[1], lines[2], lines[3]);
  const nuclearUpper = trigramFromLines(lines[2], lines[3], lines[4]);
  const nuclearNumber = KING_WEN_SQUARE[nuclearUpper][nuclearLower];

  // Compose visual sigil from trigram symbols
  const sigil = composeSigil(upper, lower);

  // Ifá sub-index: which of the 16 Odu best maps to this hexagram's role
  const ifaIndex = number % 16; // distributes hexagrams across 16 Odu

  // Geomantic figure: lower nibble of binary encoding
  const geoFigure = binary & 0xF; // 4-bit figure from lower bits

  // Wheel position (0-indexed)
  const wheelPosition = number - 1;

  // Cube coordinates [element, quantum, domain]
  const cubeElement = forgeStage; // 0-3
  const cubeQuantum = (lines[0] + lines[5]) % 4; // derived from boundary lines
  const cubeDomain = Math.floor(primaryDim / 3); // maps 12 dims → 4 domains

  const hex = Object.freeze({
    // Identity
    number,
    chinese,
    english,
    sigil,                    // Two-character visual sigil (e.g. ☷☰ = Peace)

    // Binary structure
    binary,                   // 6-bit: (upper << 3) | lower
    lines,                    // [line1..line6] bottom to top, 1=yang, 0=yin
    upper,                    // Upper trigram index
    lower,                    // Lower trigram index
    upperTrigram: TRIGRAMS[upper],
    lowerTrigram: TRIGRAMS[lower],

    // Symmetries — the connections that ARE the meaning
    complement: complementNumber,    // All lines inverted (matter↔antimatter)
    inverse: inverseNumber,          // Flipped upside down (cause↔effect)
    nuclear: nuclearNumber,          // Inner structure (self-similarity)

    // Semantic weight role
    role,                     // Neural network component this hexagram encodes
    description: `${english} — ${TRIGRAMS[upper].image} over ${TRIGRAMS[lower].image}`,

    // Forge stage (the alchemical phase)
    forgeStage,               // 0=nigredo, 1=albedo, 2=citrinitas, 3=rubedo

    // 12D coordinate mapping
    primaryDim,               // Primary dodecahedron dimension (0-11)
    secondaryDim,             // Secondary dimension (0-11)

    // Multi-system encoding (Q64)
    q64: Object.freeze({
      square: [upper, lower],       // Ba Gua Square coordinates
      wheel: wheelPosition,          // King Wen Wheel position
      cube: [cubeElement, cubeQuantum, cubeDomain], // Lorentz Cube coordinates
      ifa: ifaIndex,                 // Ifá Odu sub-block index
      geomantic: geoFigure,         // Geomantic figure index
      address: (wheelPosition << 12) | (ifaIndex << 8) | (geoFigure << 4) | cubeElement
                                     // 18-bit composite address
    }),

    // Sensory mapping (from trigram correspondences)
    upperSensory: TRIGRAMS[upper].sensory,
    lowerSensory: TRIGRAMS[lower].sensory
  });

  HEXAGRAMS.set(number, hex);
  BY_BINARY.set(binary, hex);
}

// ═══════════════════════════════════════════════════════════
// LOOKUP FUNCTIONS
// ═══════════════════════════════════════════════════════════

/** Get hexagram by King Wen number (1-64) */
function getHexagram(number) {
  return HEXAGRAMS.get(number);
}

/** Get hexagram by trigram pair */
function byTrigrams(upper, lower) {
  const number = KING_WEN_SQUARE[upper][lower];
  return HEXAGRAMS.get(number);
}

/** Get hexagram by 6-bit binary code */
function byBinary(binary) {
  return BY_BINARY.get(binary & 0x3F);
}

/** Get hexagram by semantic weight role */
function byRole(role) {
  for (const hex of HEXAGRAMS.values()) {
    if (hex.role === role) return hex;
  }
  return null;
}

/** Get all hexagrams for a forge stage */
function byForgeStage(stage) {
  const result = [];
  for (const hex of HEXAGRAMS.values()) {
    if (hex.forgeStage === stage) result.push(hex);
  }
  return result;
}

/** Get all hexagrams where a dimension is primary or secondary */
function byDimension(dim) {
  const result = [];
  for (const hex of HEXAGRAMS.values()) {
    if (hex.primaryDim === dim || hex.secondaryDim === dim) result.push(hex);
  }
  return result;
}

/** Get complement pair */
function complementPair(number) {
  const hex = HEXAGRAMS.get(number);
  if (!hex) return null;
  return [hex, HEXAGRAMS.get(hex.complement)];
}

/** Get inverse pair */
function inversePair(number) {
  const hex = HEXAGRAMS.get(number);
  if (!hex) return null;
  return [hex, HEXAGRAMS.get(hex.inverse)];
}

/** Get nuclear hexagram (recursive inner structure) */
function nuclearOf(number) {
  const hex = HEXAGRAMS.get(number);
  if (!hex) return null;
  return HEXAGRAMS.get(hex.nuclear);
}

/** Get the wheel neighbors (adjacent in King Wen sequence) */
function wheelNeighbors(number) {
  const prev = number === 1 ? 64 : number - 1;
  const next = number === 64 ? 1 : number + 1;
  return {
    previous: HEXAGRAMS.get(prev),
    current: HEXAGRAMS.get(number),
    next: HEXAGRAMS.get(next)
  };
}

// ═══════════════════════════════════════════════════════════
// Q64 ENCODING — Quantum 64-state encoding system
// ═══════════════════════════════════════════════════════════

/**
 * Encode a weight group into Q64 format.
 * Returns an 18-bit address encoding state + position + observer frame.
 *
 * @param {number} hexNumber - King Wen number (1-64) — the state
 * @param {number} oduIndex - Ifá Odu sub-block (0-15) — the sub-state
 * @param {number} house - Geomantic house (0-11) — the position
 * @param {number} aspect - Astrological aspect modifier (0-4) — the dynamic
 * @returns {number} 18-bit Q64 address
 */
function q64Encode(hexNumber, oduIndex = 0, house = 0, aspect = 0) {
  const hex = HEXAGRAMS.get(hexNumber);
  if (!hex) return 0;
  // 6 bits hexagram + 4 bits odu + 4 bits house + 4 bits aspect = 18 bits
  return ((hexNumber - 1) << 12) | ((oduIndex & 0xF) << 8) | ((house & 0xF) << 4) | (aspect & 0xF);
}

/**
 * Decode a Q64 address back into its components.
 */
function q64Decode(address) {
  const hexNumber = ((address >> 12) & 0x3F) + 1;
  const oduIndex = (address >> 8) & 0xF;
  const house = (address >> 4) & 0xF;
  const aspect = address & 0xF;
  return {
    hexagram: HEXAGRAMS.get(hexNumber),
    odu: IFA_ODU[oduIndex] || IFA_ODU[0],
    house: HOUSES[house] || HOUSES[0],
    aspect: Object.values(ASPECTS)[aspect] || ASPECTS.conjunction,
    address
  };
}

/**
 * Compute the Q64 distance between two addresses.
 * Uses the symmetry structure: complement distance, wheel distance, cube distance.
 */
function q64Distance(addr1, addr2) {
  const d1 = q64Decode(addr1);
  const d2 = q64Decode(addr2);

  if (!d1.hexagram || !d2.hexagram) return Infinity;

  // Wheel distance (circular, 0-32)
  const wheelDist = Math.min(
    Math.abs(d1.hexagram.number - d2.hexagram.number),
    64 - Math.abs(d1.hexagram.number - d2.hexagram.number)
  );

  // Are they complements? (strong quantum correlation)
  const areComplement = d1.hexagram.complement === d2.hexagram.number;

  // Are they inverses? (causal relation)
  const areInverse = d1.hexagram.inverse === d2.hexagram.number;

  // House distance (positional difference)
  const houseDist = Math.abs(d1.house.house - d2.house.house);

  // Combined distance with symmetry bonuses
  let dist = wheelDist + houseDist;
  if (areComplement) dist *= 0.5;  // Complements are close in meaning
  if (areInverse) dist *= 0.7;     // Inverses are causally linked

  return dist;
}

// ═══════════════════════════════════════════════════════════
// ASTROLOGICAL BIRTH CHART — Dynamic field modulation
// ═══════════════════════════════════════════════════════════

/**
 * Compute the astrocyte modifier for a dimension based on current aspect.
 * In a full implementation, this would use actual ephemeris data.
 * For now, uses the timestamp to derive pseudo-planetary positions.
 *
 * @param {number} timestamp - Unix timestamp (ms) of the event
 * @param {number} dimension - Which of the 12 dimensions (0-11)
 * @returns {number} Astrocyte modifier (-0.3 to +0.3)
 */
function aspectModifier(timestamp, dimension) {
  // Approximate planetary periods (in days)
  const periods = [365.25, 27.3, 87.97, 224.7, 687, 4333, 10759, 30687, 60190, 90560, 6793.5, 6793.5];
  const msPerDay = 86400000;

  // Current position (0-360 degrees) for the planet governing this dimension
  const daysSinceEpoch = timestamp / msPerDay;
  const position = (daysSinceEpoch / periods[dimension]) * 360 % 360;

  // "Natal" position (position at L7's birth: 2026-02-28)
  const l7Birth = new Date('2026-02-28T00:00:00Z').getTime();
  const natalDays = l7Birth / msPerDay;
  const natalPosition = (natalDays / periods[dimension]) * 360 % 360;

  // Angular separation
  const separation = Math.abs(position - natalPosition) % 360;
  const angle = separation > 180 ? 360 - separation : separation;

  // Find closest aspect
  let closestAspect = null;
  let minOrb = 999;
  for (const [name, aspect] of Object.entries(ASPECTS)) {
    const orb = Math.abs(angle - aspect.angle);
    if (orb < aspect.orb && orb < minOrb) {
      closestAspect = aspect;
      minOrb = orb;
    }
  }

  return closestAspect ? closestAspect.astrocyte_mod * (1 - minOrb / closestAspect.orb) : 0;
}

/**
 * Generate a birth chart for a model/event.
 * Returns 12 planetary positions and aspect modifiers.
 */
function birthChart(timestamp) {
  const chart = [];
  for (let d = 0; d < 12; d++) {
    chart.push({
      dimension: DIMENSIONS[d],
      house: HOUSES[d],
      modifier: aspectModifier(timestamp, d)
    });
  }
  return chart;
}

// ═══════════════════════════════════════════════════════════
// SIGIL COMPOSITION — Characters into hieroglyphs
// Symbols encode more information than sentences.
// ═══════════════════════════════════════════════════════════

/**
 * Compose a full sigil string encoding a hexagram's complete state.
 * Format: [lower_trigram][upper_trigram].[forge_glyph].[house_planet]
 * Example: ☷☰.🜁.☉ = Peace, Nigredo stage, Sun house
 *
 * One compact sigil encodes: semantic role + forge stage + dimensional context
 */
function fullSigil(hexNumber, house = 0) {
  const hex = HEXAGRAMS.get(hexNumber);
  if (!hex) return '?';

  const forgeGlyphs = ['🜁', '🜄', '🜃', '🜂']; // nigredo, albedo, citrinitas, rubedo
  const planetSymbols = ['☉', '☽', '☿', '♀', '♂', '♃', '♄', '♅', '♆', '♇', '☊', '☋'];

  return `${hex.sigil}.${forgeGlyphs[hex.forgeStage]}.${planetSymbols[house]}`;
}

/**
 * Read a sigil back into its components.
 * Inverse of fullSigil — decodes compressed symbolic representation.
 */
function readSigil(sigilStr) {
  const parts = sigilStr.split('.');
  if (parts.length < 1) return null;

  const trigramPart = parts[0];
  if (trigramPart.length < 2) return null;

  // Find trigrams from symbols
  const lowerSym = trigramPart[0];
  const upperSym = trigramPart[1];
  const lowerTrig = TRIGRAMS.find(t => t.symbol === lowerSym);
  const upperTrig = TRIGRAMS.find(t => t.symbol === upperSym);

  if (!lowerTrig || !upperTrig) return null;

  const hexNumber = KING_WEN_SQUARE[upperTrig.index][lowerTrig.index];
  const hex = HEXAGRAMS.get(hexNumber);

  const forgeGlyphs = { '🜁': 0, '🜄': 1, '🜃': 2, '🜂': 3 };
  const planetSymbols = { '☉': 0, '☽': 1, '☿': 2, '♀': 3, '♂': 4, '♃': 5, '♄': 6, '♅': 7, '♆': 8, '♇': 9, '☊': 10, '☋': 11 };

  return {
    hexagram: hex,
    forgeStage: parts[1] ? (forgeGlyphs[parts[1]] ?? -1) : -1,
    house: parts[2] ? (planetSymbols[parts[2]] ?? -1) : -1
  };
}

/**
 * Generate the line notation for a hexagram (traditional I-Ching format).
 * Uses ━━ for yang, ━ ━ for yin, reading from top to bottom.
 */
function lineNotation(hexNumber) {
  const hex = HEXAGRAMS.get(hexNumber);
  if (!hex) return '';
  // Display top to bottom (line 6 first)
  return hex.lines.slice().reverse()
    .map(l => l === 1 ? '━━━━━' : '━━ ━━')
    .join('\n');
}

// ═══════════════════════════════════════════════════════════
// MAGIC SQUARE BALANCE — The mathematical harmony
// ═══════════════════════════════════════════════════════════

/**
 * Check if a distribution of weights across hexagrams satisfies
 * the magic square balance property.
 *
 * For each dimension d: sum of weights where primaryDim=d ≈ total/12
 * For each forge stage s: sum of weights where forgeStage=s ≈ total/4
 *
 * @param {Map} weightMap - hexagramNumber → weight count
 * @param {number} astrocyte - Tolerance (0=exact, 1=50% allowed)
 * @returns {object} { balanced, dimensionDeviation, stageDeviation, details }
 */
function checkBalance(weightMap, astrocyte = 0) {
  let totalWeights = 0;
  const dimSums = new Array(12).fill(0);
  const stageSums = new Array(4).fill(0);

  for (const [hexNum, count] of weightMap) {
    const hex = HEXAGRAMS.get(hexNum);
    if (!hex) continue;
    totalWeights += count;
    dimSums[hex.primaryDim] += count;
    stageSums[hex.forgeStage] += count;
  }

  if (totalWeights === 0) return { balanced: true, dimensionDeviation: 0, stageDeviation: 0 };

  const expectedPerDim = totalWeights / 12;
  const expectedPerStage = totalWeights / 4;
  const tolerance = 0.1 + astrocyte * 0.4; // 10% at a=0, 50% at a=1

  let maxDimDev = 0;
  let maxStageDev = 0;

  const dimDetails = dimSums.map((sum, i) => {
    const dev = Math.abs(sum - expectedPerDim) / expectedPerDim;
    maxDimDev = Math.max(maxDimDev, dev);
    return { dimension: DIMENSIONS[i].name, count: sum, expected: expectedPerDim, deviation: dev };
  });

  const stageDetails = stageSums.map((sum, i) => {
    const dev = Math.abs(sum - expectedPerStage) / expectedPerStage;
    maxStageDev = Math.max(maxStageDev, dev);
    return { stage: i, count: sum, expected: expectedPerStage, deviation: dev };
  });

  return {
    balanced: maxDimDev <= tolerance && maxStageDev <= tolerance,
    dimensionDeviation: maxDimDev,
    stageDeviation: maxStageDev,
    tolerance,
    dimensions: dimDetails,
    stages: stageDetails
  };
}

// ═══════════════════════════════════════════════════════════
// MAPPING NEURAL NETWORK TENSORS TO HEXAGRAMS
// ═══════════════════════════════════════════════════════════

/**
 * Map a tensor name (from GGUF/safetensors) to its hexagram.
 * Uses pattern matching on common tensor naming conventions.
 *
 * @param {string} tensorName - e.g. "model.layers.0.self_attn.q_proj.weight"
 * @param {number} layerIndex - Layer number (for layer-group assignment)
 * @param {number} totalLayers - Total layers in the model
 * @returns {object} { hexagram, house, oduIndex }
 */
function mapTensor(tensorName, layerIndex = 0, totalLayers = 1) {
  const name = tensorName.toLowerCase();

  // Determine house from layer position (geomantic context)
  const layerFraction = totalLayers > 1 ? layerIndex / (totalLayers - 1) : 0.5;
  const house = Math.min(11, Math.floor(layerFraction * 12));

  // Determine Ifá sub-index from layer within group
  const layersPerGroup = Math.ceil(totalLayers / 16);
  const oduIndex = Math.min(15, Math.floor(layerIndex / Math.max(1, layersPerGroup)));

  // Pattern matching for tensor → hexagram role
  let role = null;

  // Embedding
  if (name.includes('embed') && !name.includes('norm')) role = 'token_embedding';
  if (name.includes('position') || name.includes('rotary') || name.includes('freq')) role = 'positional_encoding';
  if (name.includes('embed') && name.includes('norm')) role = 'embedding_norm';

  // Attention
  if (name.includes('q_proj') || name.includes('query')) role = 'attention_query';
  if (name.includes('k_proj') || name.includes('key')) role = 'attention_key';
  if (name.includes('v_proj') || name.includes('value')) role = 'attention_value';
  if (name.includes('o_proj') || name.includes('out_proj') || name.includes('attn.c_proj')) role = 'attention_output';
  if (name.includes('attn') && name.includes('bias')) role = 'attention_bias';

  // FFN
  if (name.includes('up_proj') || name.includes('fc1') || name.includes('w1')) role = 'ffn_up';
  if (name.includes('gate_proj') || name.includes('w3')) role = 'ffn_gate';
  if (name.includes('down_proj') || name.includes('fc2') || name.includes('w2')) role = 'ffn_down';

  // Normalization
  if (name.includes('input_layernorm') || name.includes('ln_1') || name.includes('attn_norm')) role = 'post_attention_norm';
  if (name.includes('post_attention') && name.includes('norm')) role = 'post_attention_norm';
  if (name.includes('pre_feedforward') || name.includes('ln_2') || name.includes('ffn_norm')) role = 'pre_ffn_norm';
  if (name.includes('norm') && !name.includes('attn') && !name.includes('ffn')) role = 'layer_norm';
  if (name.includes('rms_norm') || name.includes('rmsnorm')) role = 'rms_norm';

  // Output
  if (name.includes('lm_head') || name.includes('output') && !name.includes('attn')) role = 'output_projection';
  if (name.includes('final_norm') || name.includes('model.norm')) role = 'layer_norm';

  // Fallback: hash the name to a hexagram
  if (!role) {
    let hash = 0;
    for (let i = 0; i < name.length; i++) hash = ((hash << 5) - hash + name.charCodeAt(i)) | 0;
    const fallbackNum = (Math.abs(hash) % 64) + 1;
    return { hexagram: HEXAGRAMS.get(fallbackNum), house, oduIndex };
  }

  const hex = byRole(role);
  return { hexagram: hex, house, oduIndex };
}

// ═══════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════

module.exports = {
  // Core data
  TRIGRAMS,
  HEXAGRAMS,                  // Map<number, hexagram>
  KING_WEN_SQUARE,            // [upper][lower] → King Wen number
  KING_WEN_WHEEL,             // Sequential order (1-64)
  LORENTZ_CUBE,               // [element][quantum][domain] → King Wen number

  // Divination systems
  IFA_ODU,                    // 16 Ifá Odu Meji (byte-level encoding)
  GEOMANTIC_FIGURES,          // 16 geomantic figures (contextual encoding)
  HOUSES,                     // 12 geomantic houses (= 12 dimensions)
  ASPECTS,                    // 5 astrological aspects (dynamic modifiers)

  // Lookup functions
  getHexagram,                // by King Wen number
  byTrigrams,                 // by (upper, lower) pair
  byBinary,                   // by 6-bit code
  byRole,                     // by semantic weight role
  byForgeStage,               // all hexagrams in a stage
  byDimension,                // all hexagrams for a dimension

  // Symmetry functions
  complementPair,             // matter ↔ antimatter
  inversePair,                // cause ↔ effect
  nuclearOf,                  // inner self-similarity
  wheelNeighbors,             // temporal adjacency
  reverseTrigram,
  complementTrigram,
  trigramFromLines,

  // Q64 encoding
  q64Encode,
  q64Decode,
  q64Distance,

  // Astrological dynamics
  aspectModifier,
  birthChart,

  // Sigil composition
  composeSigil,               // Two-char trigram sigil
  fullSigil,                  // Complete symbolic encoding
  readSigil,                  // Decode sigil back to components
  lineNotation,               // Traditional line display

  // Tensor mapping
  mapTensor,                  // GGUF tensor name → hexagram

  // Balance
  checkBalance                // Magic square property verification
};
