// ============================================================================
// PANTHEON DATA — The Gods of All Nations & Leaders of All Ages
// L7 WAY — The Universal Operating System
// Generated 2026-03-09 for the Empire
// ============================================================================

// ============================================================================
// I. GODS & DIVINE FIGURES — Organized by Tradition
// ============================================================================

const PANTHEON_GODS = [

  // ========================================================================
  // EGYPTIAN (Kemet)
  // ========================================================================
  {name:'Ra', tradition:'Egyptian', domain:'Sun, creation, king of gods', planet:'Sun', symbol:'☀️ Sun disk'},
  {name:'Amun', tradition:'Egyptian', domain:'Hidden one, king of gods, wind', planet:'Jupiter', symbol:'Ram horns'},
  {name:'Amun-Ra', tradition:'Egyptian', domain:'Supreme state god, merged solar-hidden deity', planet:'Sun', symbol:'Double crown with sun disk'},
  {name:'Thoth', tradition:'Egyptian', domain:'Wisdom, writing, magic, moon', planet:'Mercury', symbol:'Ibis, crescent moon'},
  {name:'Isis', tradition:'Egyptian', domain:'Magic, motherhood, healing, throne', planet:'Moon', symbol:'Throne headdress, tyet knot'},
  {name:'Osiris', tradition:'Egyptian', domain:'Underworld, death, resurrection, fertility', planet:'Pluto', symbol:'Crook and flail, djed pillar'},
  {name:'Anubis', tradition:'Egyptian', domain:'Mummification, death, afterlife, guardian of scales', planet:'Saturn', symbol:'Jackal head'},
  {name:'Horus', tradition:'Egyptian', domain:'Sky, kingship, war, protection', planet:'Sun', symbol:'Eye of Horus, falcon'},
  {name:'Set', tradition:'Egyptian', domain:'Chaos, storms, desert, violence, foreigners', planet:'Mars', symbol:'Set animal, was scepter'},
  {name:'Hathor', tradition:'Egyptian', domain:'Love, beauty, music, joy, fertility', planet:'Venus', symbol:'Cow horns with sun disk'},
  {name:'Nut', tradition:'Egyptian', domain:'Sky, stars, cosmos, mother of gods', planet:'Uranus', symbol:'Arched body of stars'},
  {name:'Geb', tradition:'Egyptian', domain:'Earth, fertility, vegetation', planet:'Earth', symbol:'Goose, barley'},
  {name:'Sekhmet', tradition:'Egyptian', domain:'War, destruction, healing, plague', planet:'Mars', symbol:'Lioness head, sun disk'},
  {name:'Bastet', tradition:'Egyptian', domain:'Home, cats, fertility, protection', planet:'Moon', symbol:'Cat, sistrum'},
  {name:'Ptah', tradition:'Egyptian', domain:'Crafts, creation, metalworking, architecture', planet:'Saturn', symbol:'Djed pillar, was scepter'},
  {name:'Ma\'at', tradition:'Egyptian', domain:'Truth, justice, cosmic order, balance', planet:'Jupiter', symbol:'Ostrich feather'},
  {name:'Khonsu', tradition:'Egyptian', domain:'Moon, time, youth, healing', planet:'Moon', symbol:'Crescent moon, sidelock'},
  {name:'Sobek', tradition:'Egyptian', domain:'Crocodiles, Nile, military prowess, fertility', planet:'Mars', symbol:'Crocodile'},
  {name:'Nephthys', tradition:'Egyptian', domain:'Mourning, night, rivers, protection of dead', planet:'Moon', symbol:'House and basket hieroglyphs'},
  {name:'Tefnut', tradition:'Egyptian', domain:'Moisture, rain, dew, water', planet:'Neptune', symbol:'Lioness, sun disk with uraei'},
  {name:'Shu', tradition:'Egyptian', domain:'Air, wind, light, atmosphere', planet:'Mercury', symbol:'Ostrich feather'},
  {name:'Atum', tradition:'Egyptian', domain:'Creation, completion, evening sun', planet:'Sun', symbol:'Double crown'},
  {name:'Khnum', tradition:'Egyptian', domain:'Potter god, Nile source, creation of bodies', planet:'Saturn', symbol:'Ram, potter\'s wheel'},
  {name:'Bes', tradition:'Egyptian', domain:'Protection, childbirth, humor, dance', planet:'Jupiter', symbol:'Dwarf lion figure'},
  {name:'Taweret', tradition:'Egyptian', domain:'Childbirth, fertility, protection', planet:'Moon', symbol:'Hippopotamus'},
  {name:'Min', tradition:'Egyptian', domain:'Fertility, reproduction, harvest', planet:'Mars', symbol:'Flail, lettuce'},
  {name:'Wadjet', tradition:'Egyptian', domain:'Protection, royalty, Lower Egypt', planet:'Sun', symbol:'Cobra, Eye of Horus'},
  {name:'Nekhbet', tradition:'Egyptian', domain:'Protection, royalty, Upper Egypt', planet:'Sun', symbol:'Vulture'},
  {name:'Serqet', tradition:'Egyptian', domain:'Scorpions, healing, magic, protection', planet:'Pluto', symbol:'Scorpion'},
  {name:'Apep', tradition:'Egyptian', domain:'Chaos, darkness, enemy of Ra', planet:'Pluto', symbol:'Giant serpent'},
  {name:'Khepri', tradition:'Egyptian', domain:'Dawn, sunrise, rebirth, creation', planet:'Sun', symbol:'Scarab beetle'},
  {name:'Aten', tradition:'Egyptian', domain:'Solar disk, monotheistic sun god', planet:'Sun', symbol:'Sun disk with rays ending in hands'},
  {name:'Seshat', tradition:'Egyptian', domain:'Writing, measurement, architecture, astronomy', planet:'Mercury', symbol:'Seven-pointed star, notched palm'},
  {name:'Wepwawet', tradition:'Egyptian', domain:'War, funerary rites, opener of ways', planet:'Mars', symbol:'Wolf/jackal'},
  {name:'Renenutet', tradition:'Egyptian', domain:'Harvest, nourishment, good fortune', planet:'Venus', symbol:'Cobra'},
  {name:'Hapi', tradition:'Egyptian', domain:'Nile inundation, fertility, abundance', planet:'Neptune', symbol:'Lotus, papyrus'},

  // ========================================================================
  // GREEK
  // ========================================================================
  {name:'Zeus', tradition:'Greek', domain:'Sky, thunder, king of gods, law, order', planet:'Jupiter', symbol:'Thunderbolt, eagle, oak'},
  {name:'Hera', tradition:'Greek', domain:'Marriage, family, women, queen of gods', planet:'Venus', symbol:'Peacock, cow, pomegranate'},
  {name:'Athena', tradition:'Greek', domain:'Wisdom, strategy, war, crafts, justice', planet:'Jupiter', symbol:'Owl, olive tree, aegis'},
  {name:'Apollo', tradition:'Greek', domain:'Sun, music, prophecy, healing, poetry, archery', planet:'Sun', symbol:'Lyre, laurel, sun chariot'},
  {name:'Artemis', tradition:'Greek', domain:'Moon, hunt, wilderness, childbirth, virginity', planet:'Moon', symbol:'Bow and arrow, stag, crescent'},
  {name:'Ares', tradition:'Greek', domain:'War, bloodshed, violence, courage', planet:'Mars', symbol:'Spear, helmet, vulture'},
  {name:'Aphrodite', tradition:'Greek', domain:'Love, beauty, desire, pleasure', planet:'Venus', symbol:'Dove, myrtle, mirror, shell'},
  {name:'Hermes', tradition:'Greek', domain:'Messengers, trade, thieves, travel, boundaries', planet:'Mercury', symbol:'Caduceus, winged sandals'},
  {name:'Poseidon', tradition:'Greek', domain:'Sea, earthquakes, horses, storms', planet:'Neptune', symbol:'Trident, horse, dolphin'},
  {name:'Hades', tradition:'Greek', domain:'Underworld, death, riches, the dead', planet:'Pluto', symbol:'Helm of darkness, cerberus, cypress'},
  {name:'Demeter', tradition:'Greek', domain:'Harvest, agriculture, fertility, seasons', planet:'Earth', symbol:'Wheat, torch, cornucopia'},
  {name:'Hephaestus', tradition:'Greek', domain:'Fire, forge, metalworking, crafts, volcanoes', planet:'Saturn', symbol:'Hammer, anvil, tongs'},
  {name:'Dionysus', tradition:'Greek', domain:'Wine, ecstasy, theater, fertility, madness', planet:'Neptune', symbol:'Thyrsus, grapevine, leopard'},
  {name:'Hestia', tradition:'Greek', domain:'Hearth, home, domesticity, sacred fire', planet:'Earth', symbol:'Hearth flame'},
  {name:'Persephone', tradition:'Greek', domain:'Spring, underworld queen, vegetation, death', planet:'Pluto', symbol:'Pomegranate, torch'},
  {name:'Hecate', tradition:'Greek', domain:'Magic, crossroads, ghosts, necromancy, night', planet:'Moon', symbol:'Torches, keys, dogs'},
  {name:'Pan', tradition:'Greek', domain:'Shepherds, nature, wild, music, fertility', planet:'Saturn', symbol:'Pan flute, goat'},
  {name:'Eros', tradition:'Greek', domain:'Love, desire, attraction, procreation', planet:'Venus', symbol:'Bow and arrow, wings'},
  {name:'Helios', tradition:'Greek', domain:'Sun, sight, oaths', planet:'Sun', symbol:'Sun chariot, radiant crown'},
  {name:'Selene', tradition:'Greek', domain:'Moon, night, lunacy', planet:'Moon', symbol:'Crescent moon, chariot'},
  {name:'Nike', tradition:'Greek', domain:'Victory, speed, strength', planet:'Mars', symbol:'Wings, laurel wreath'},
  {name:'Nemesis', tradition:'Greek', domain:'Retribution, divine vengeance, balance', planet:'Saturn', symbol:'Sword, scales, wheel'},
  {name:'Tyche', tradition:'Greek', domain:'Fortune, chance, prosperity', planet:'Jupiter', symbol:'Cornucopia, rudder'},
  {name:'Asclepius', tradition:'Greek', domain:'Medicine, healing, rejuvenation', planet:'Sun', symbol:'Rod of Asclepius, serpent'},
  {name:'Eris', tradition:'Greek', domain:'Strife, discord, chaos', planet:'Pluto', symbol:'Apple of discord'},
  {name:'Thanatos', tradition:'Greek', domain:'Death, peaceful death', planet:'Pluto', symbol:'Inverted torch, butterfly'},
  {name:'Hypnos', tradition:'Greek', domain:'Sleep, rest, dreams', planet:'Neptune', symbol:'Poppy, horn of sleep'},
  {name:'Morpheus', tradition:'Greek', domain:'Dreams, shaping dreams', planet:'Neptune', symbol:'Wings, ivory gate'},
  {name:'Prometheus', tradition:'Greek', domain:'Forethought, fire-bringer, craft, humanity\'s champion', planet:'Uranus', symbol:'Torch, eagle'},
  {name:'Kronos', tradition:'Greek', domain:'Time, harvest, king of Titans', planet:'Saturn', symbol:'Scythe, sickle'},
  {name:'Rhea', tradition:'Greek', domain:'Motherhood, fertility, comfort, Titan queen', planet:'Earth', symbol:'Lions, crown'},
  {name:'Gaia', tradition:'Greek', domain:'Earth, mother of all, primal creation', planet:'Earth', symbol:'Earth, cornucopia'},
  {name:'Ouranos', tradition:'Greek', domain:'Sky, father of Titans, heavens', planet:'Uranus', symbol:'Starry dome'},
  {name:'Nyx', tradition:'Greek', domain:'Night, darkness, primordial shadow', planet:'Pluto', symbol:'Dark veil, stars'},
  {name:'Iris', tradition:'Greek', domain:'Rainbow, divine messenger', planet:'Mercury', symbol:'Rainbow, pitcher'},
  {name:'Triton', tradition:'Greek', domain:'Sea, messenger of the deep, waves', planet:'Neptune', symbol:'Conch shell'},
  {name:'Amphitrite', tradition:'Greek', domain:'Sea, queen of the ocean', planet:'Neptune', symbol:'Trident, sea creatures'},
  {name:'Cybele', tradition:'Greek', domain:'Mother of gods, nature, wild animals, caverns', planet:'Earth', symbol:'Lions, mural crown, drum'},

  // ========================================================================
  // ROMAN
  // ========================================================================
  {name:'Jupiter', tradition:'Roman', domain:'Sky, thunder, king of gods, state', planet:'Jupiter', symbol:'Thunderbolt, eagle'},
  {name:'Juno', tradition:'Roman', domain:'Marriage, women, childbirth, queen of gods', planet:'Venus', symbol:'Peacock, diadem'},
  {name:'Minerva', tradition:'Roman', domain:'Wisdom, strategy, arts, trade', planet:'Jupiter', symbol:'Owl, olive tree'},
  {name:'Mars', tradition:'Roman', domain:'War, agriculture, guardian of Rome', planet:'Mars', symbol:'Spear, shield, wolf'},
  {name:'Venus', tradition:'Roman', domain:'Love, beauty, desire, prosperity', planet:'Venus', symbol:'Mirror, dove, myrtle'},
  {name:'Mercury', tradition:'Roman', domain:'Commerce, messages, travelers, thieves', planet:'Mercury', symbol:'Caduceus, winged hat'},
  {name:'Neptune', tradition:'Roman', domain:'Sea, horses, earthquakes', planet:'Neptune', symbol:'Trident'},
  {name:'Pluto', tradition:'Roman', domain:'Underworld, death, riches', planet:'Pluto', symbol:'Scepter, Cerberus'},
  {name:'Ceres', tradition:'Roman', domain:'Agriculture, grain, harvest, motherly love', planet:'Earth', symbol:'Wheat sheaf, torch'},
  {name:'Vulcan', tradition:'Roman', domain:'Fire, forge, metalworking, destruction', planet:'Saturn', symbol:'Hammer, anvil'},
  {name:'Bacchus', tradition:'Roman', domain:'Wine, festivity, ecstasy, theater', planet:'Neptune', symbol:'Grapevine, thyrsus'},
  {name:'Diana', tradition:'Roman', domain:'Moon, hunt, wilderness, crossroads', planet:'Moon', symbol:'Bow, crescent, stag'},
  {name:'Apollo', tradition:'Roman', domain:'Sun, music, prophecy, healing (kept Greek name)', planet:'Sun', symbol:'Lyre, laurel'},
  {name:'Janus', tradition:'Roman', domain:'Beginnings, endings, doorways, time, duality', planet:'Saturn', symbol:'Two faces, key'},
  {name:'Vesta', tradition:'Roman', domain:'Hearth, home, sacred fire', planet:'Earth', symbol:'Eternal flame'},
  {name:'Saturn', tradition:'Roman', domain:'Agriculture, time, wealth, liberation, cycles', planet:'Saturn', symbol:'Scythe, grain'},
  {name:'Fortuna', tradition:'Roman', domain:'Fortune, luck, fate', planet:'Jupiter', symbol:'Wheel, cornucopia, rudder'},
  {name:'Victoria', tradition:'Roman', domain:'Victory, triumph', planet:'Mars', symbol:'Wings, laurel wreath'},
  {name:'Bellona', tradition:'Roman', domain:'War, destruction, conquest', planet:'Mars', symbol:'Sword, torch, helmet'},
  {name:'Cupid', tradition:'Roman', domain:'Love, desire, erotic attraction', planet:'Venus', symbol:'Bow and arrow, wings'},
  {name:'Sol Invictus', tradition:'Roman', domain:'Unconquered sun, imperial solar cult', planet:'Sun', symbol:'Radiant crown'},
  {name:'Luna', tradition:'Roman', domain:'Moon, night', planet:'Moon', symbol:'Crescent, chariot'},
  {name:'Proserpina', tradition:'Roman', domain:'Underworld queen, spring, renewal', planet:'Pluto', symbol:'Pomegranate'},
  {name:'Terminus', tradition:'Roman', domain:'Boundaries, borders, property markers', planet:'Saturn', symbol:'Boundary stone'},
  {name:'Mithras', tradition:'Roman Mystery', domain:'Sun, soldiers, cosmic order, bull-slaying', planet:'Sun', symbol:'Bull, torch, dagger'},

  // ========================================================================
  // NORSE
  // ========================================================================
  {name:'Odin', tradition:'Norse', domain:'Wisdom, war, death, magic, poetry, runes, the hanged god', planet:'Mercury', symbol:'Ravens (Huginn & Muninn), spear Gungnir, one eye'},
  {name:'Thor', tradition:'Norse', domain:'Thunder, lightning, storms, strength, protection', planet:'Jupiter', symbol:'Mjolnir (hammer), goats'},
  {name:'Freyja', tradition:'Norse', domain:'Love, beauty, war, death, magic, gold, seidr', planet:'Venus', symbol:'Cats, falcon cloak, Brísingamen necklace'},
  {name:'Freyr', tradition:'Norse', domain:'Fertility, prosperity, sunshine, peace, harvest', planet:'Sun', symbol:'Boar Gullinbursti, antler, ship Skidbladnir'},
  {name:'Loki', tradition:'Norse', domain:'Trickery, chaos, shape-shifting, fire, mischief', planet:'Mercury', symbol:'Fire, serpent, mistletoe'},
  {name:'Tyr', tradition:'Norse', domain:'War, justice, law, heroic glory, sacrifice', planet:'Mars', symbol:'Sword, one hand'},
  {name:'Frigg', tradition:'Norse', domain:'Marriage, motherhood, wisdom, foresight, queen of Asgard', planet:'Venus', symbol:'Distaff, mistletoe, falcon'},
  {name:'Baldur', tradition:'Norse', domain:'Light, beauty, joy, purity, innocence', planet:'Sun', symbol:'Light, mistletoe'},
  {name:'Heimdall', tradition:'Norse', domain:'Watchfulness, guardianship, Bifrost, light, foreknowledge', planet:'Sun', symbol:'Gjallarhorn, rainbow bridge'},
  {name:'Hel', tradition:'Norse', domain:'Death, underworld (Helheim), the dishonored dead', planet:'Pluto', symbol:'Half-living half-dead face'},
  {name:'Njord', tradition:'Norse', domain:'Sea, wind, fishing, wealth, voyaging', planet:'Neptune', symbol:'Ships, fishing net'},
  {name:'Skadi', tradition:'Norse', domain:'Winter, mountains, skiing, hunting, vengeance', planet:'Saturn', symbol:'Skis, bow, mountains'},
  {name:'Idun', tradition:'Norse', domain:'Youth, rejuvenation, spring, immortality', planet:'Venus', symbol:'Golden apples'},
  {name:'Bragi', tradition:'Norse', domain:'Poetry, eloquence, music, skalds', planet:'Mercury', symbol:'Harp, runes on tongue'},
  {name:'Vidar', tradition:'Norse', domain:'Vengeance, silence, strength, survival', planet:'Saturn', symbol:'Thick shoe'},
  {name:'Vali', tradition:'Norse', domain:'Vengeance, archery (avenger of Baldur)', planet:'Mars', symbol:'Bow'},
  {name:'Forseti', tradition:'Norse', domain:'Justice, mediation, peace, reconciliation', planet:'Jupiter', symbol:'Golden hall, axe'},
  {name:'Aegir', tradition:'Norse', domain:'Sea, brewing, feasts of the deep', planet:'Neptune', symbol:'Cauldron, waves'},
  {name:'Ran', tradition:'Norse', domain:'Sea, drowning, the drowned dead', planet:'Neptune', symbol:'Fishing net'},
  {name:'Norns (Urd/Verdandi/Skuld)', tradition:'Norse', domain:'Fate, destiny, past/present/future', planet:'Saturn', symbol:'Well of Urd, threads'},
  {name:'Fenrir', tradition:'Norse', domain:'Destruction, chaos, the bound wolf, Ragnarok', planet:'Pluto', symbol:'Great wolf, chains'},
  {name:'Jormungandr', tradition:'Norse', domain:'World serpent, ocean, ouroboros, Ragnarok', planet:'Neptune', symbol:'Serpent encircling world'},
  {name:'Mimir', tradition:'Norse', domain:'Wisdom, knowledge, counsel, memory', planet:'Saturn', symbol:'Severed head, well'},
  {name:'Sif', tradition:'Norse', domain:'Earth, harvest, golden grain', planet:'Earth', symbol:'Golden hair'},
  {name:'Ullr', tradition:'Norse', domain:'Winter, archery, skiing, hunting, duels', planet:'Mars', symbol:'Bow, skis, shield'},

  // ========================================================================
  // HINDU
  // ========================================================================
  {name:'Brahma', tradition:'Hindu', domain:'Creation, knowledge, Vedas, the creator of the Trimurti', planet:'Jupiter', symbol:'Four faces, lotus, Vedas'},
  {name:'Vishnu', tradition:'Hindu', domain:'Preservation, dharma, cosmic order, ten avatars', planet:'Jupiter', symbol:'Conch, discus, mace, lotus'},
  {name:'Shiva', tradition:'Hindu', domain:'Destruction, transformation, meditation, dance, asceticism', planet:'Saturn', symbol:'Trident, third eye, crescent moon, Nandi'},
  {name:'Lakshmi', tradition:'Hindu', domain:'Wealth, fortune, beauty, prosperity, grace', planet:'Venus', symbol:'Lotus, gold coins, elephants'},
  {name:'Saraswati', tradition:'Hindu', domain:'Knowledge, music, arts, speech, learning', planet:'Mercury', symbol:'Veena, book, lotus, swan'},
  {name:'Parvati', tradition:'Hindu', domain:'Love, fertility, devotion, divine strength, motherhood', planet:'Moon', symbol:'Lotus, lion'},
  {name:'Ganesha', tradition:'Hindu', domain:'Wisdom, beginnings, obstacle removal, arts, sciences', planet:'Jupiter', symbol:'Elephant head, modak, mouse'},
  {name:'Hanuman', tradition:'Hindu', domain:'Devotion, strength, courage, perseverance, wind', planet:'Mars', symbol:'Mace, mountain, monkey form'},
  {name:'Kali', tradition:'Hindu', domain:'Time, destruction, death, liberation, fierce motherhood', planet:'Pluto', symbol:'Skull garland, sword, severed head'},
  {name:'Durga', tradition:'Hindu', domain:'War, protection, strength, motherhood, demon-slaying', planet:'Mars', symbol:'Lion mount, multiple arms, weapons'},
  {name:'Indra', tradition:'Hindu', domain:'Thunder, rain, king of gods (Vedic), war, heaven', planet:'Jupiter', symbol:'Vajra (thunderbolt), Airavata (elephant)'},
  {name:'Agni', tradition:'Hindu', domain:'Fire, sacrifice, messenger between gods and humans', planet:'Mars', symbol:'Flames, ram'},
  {name:'Surya', tradition:'Hindu', domain:'Sun, light, health, cosmic eye', planet:'Sun', symbol:'Chariot, seven horses, lotus'},
  {name:'Chandra', tradition:'Hindu', domain:'Moon, night, plants, emotions, time', planet:'Moon', symbol:'Crescent moon, antelope chariot'},
  {name:'Kartikeya (Murugan)', tradition:'Hindu', domain:'War, victory, youth, commander of divine armies', planet:'Mars', symbol:'Spear (Vel), peacock'},
  {name:'Rama', tradition:'Hindu', domain:'Virtue, dharma, ideal king (7th avatar of Vishnu)', planet:'Sun', symbol:'Bow, blue skin'},
  {name:'Krishna', tradition:'Hindu', domain:'Love, compassion, divine play, wisdom (8th avatar of Vishnu)', planet:'Moon', symbol:'Flute, peacock feather, butter'},
  {name:'Yama', tradition:'Hindu', domain:'Death, justice, ruler of the underworld', planet:'Saturn', symbol:'Buffalo, noose, mace'},
  {name:'Vayu', tradition:'Hindu', domain:'Wind, air, breath, life force (prana)', planet:'Mercury', symbol:'Flag, deer'},
  {name:'Varuna', tradition:'Hindu', domain:'Water, cosmic order, oceans, celestial law', planet:'Neptune', symbol:'Noose, makara (sea creature)'},
  {name:'Kubera', tradition:'Hindu', domain:'Wealth, treasures, guardian of the north', planet:'Jupiter', symbol:'Mongoose, pot of jewels'},
  {name:'Kamadeva', tradition:'Hindu', domain:'Love, desire, attraction', planet:'Venus', symbol:'Sugarcane bow, flower arrows, parrot'},
  {name:'Narasimha', tradition:'Hindu', domain:'Protection, fierce avatar, destroyer of evil (4th avatar of Vishnu)', planet:'Mars', symbol:'Man-lion form, pillar'},
  {name:'Parashurama', tradition:'Hindu', domain:'Warrior sage, dharma enforcer (6th avatar of Vishnu)', planet:'Mars', symbol:'Axe'},
  {name:'Radha', tradition:'Hindu', domain:'Unconditional love, devotion, divine feminine consort of Krishna', planet:'Venus', symbol:'Lotus, flute'},
  {name:'Sita', tradition:'Hindu', domain:'Purity, devotion, sacrifice, earth-born princess', planet:'Earth', symbol:'Earth, golden deer'},
  {name:'Nataraja', tradition:'Hindu', domain:'Cosmic dance, creation through destruction (Shiva as dancer)', planet:'Saturn', symbol:'Ring of fire, drum, raised foot'},
  {name:'Kalki', tradition:'Hindu', domain:'Future avatar, end of Kali Yuga, renewal (10th avatar of Vishnu)', planet:'Pluto', symbol:'White horse, flaming sword'},
  {name:'Dhanvantari', tradition:'Hindu', domain:'Medicine, healing, Ayurveda', planet:'Sun', symbol:'Pot of amrita, herbs'},
  {name:'Budha', tradition:'Hindu', domain:'Planet Mercury, intellect, communication (son of Chandra)', planet:'Mercury', symbol:'Scimitar, shield'},
  {name:'Shani', tradition:'Hindu', domain:'Planet Saturn, karma, justice, discipline', planet:'Saturn', symbol:'Crow, iron, slow movement'},
  {name:'Rahu', tradition:'Hindu', domain:'North lunar node, eclipse, illusion, obsession', planet:'Rahu (North Node)', symbol:'Serpent head, darkness'},
  {name:'Ketu', tradition:'Hindu', domain:'South lunar node, liberation, spirituality, detachment', planet:'Ketu (South Node)', symbol:'Serpent tail, flag'},
  {name:'Mangala', tradition:'Hindu', domain:'Planet Mars, courage, martial energy', planet:'Mars', symbol:'Mace, red color'},

  // ========================================================================
  // MESOPOTAMIAN (Sumerian / Babylonian / Akkadian / Assyrian)
  // ========================================================================
  {name:'Anu', tradition:'Mesopotamian', domain:'Sky, heaven, king of gods, authority', planet:'Uranus', symbol:'Horned crown, stars'},
  {name:'Enlil', tradition:'Mesopotamian', domain:'Wind, air, storms, earth, kingship', planet:'Jupiter', symbol:'Horned crown, wind'},
  {name:'Enki (Ea)', tradition:'Mesopotamian', domain:'Water, wisdom, magic, crafts, creation', planet:'Mercury', symbol:'Goat-fish, flowing water'},
  {name:'Inanna (Ishtar)', tradition:'Mesopotamian', domain:'Love, war, beauty, desire, fertility, power', planet:'Venus', symbol:'Eight-pointed star, lion, gate'},
  {name:'Marduk', tradition:'Mesopotamian', domain:'Justice, storms, creation, patron of Babylon', planet:'Jupiter', symbol:'Dragon (mushhushshu), spade'},
  {name:'Tiamat', tradition:'Mesopotamian', domain:'Primordial chaos, salt sea, creation through destruction', planet:'Neptune', symbol:'Sea dragon, chaos waters'},
  {name:'Shamash (Utu)', tradition:'Mesopotamian', domain:'Sun, justice, truth, divination', planet:'Sun', symbol:'Sun disk, rays, saw'},
  {name:'Sin (Nanna)', tradition:'Mesopotamian', domain:'Moon, wisdom, cattle herding, timekeeping', planet:'Moon', symbol:'Crescent moon, bull'},
  {name:'Nabu', tradition:'Mesopotamian', domain:'Writing, wisdom, literacy, scribes', planet:'Mercury', symbol:'Clay tablet, stylus'},
  {name:'Nergal', tradition:'Mesopotamian', domain:'War, death, plague, underworld, destruction', planet:'Mars', symbol:'Lion-headed mace'},
  {name:'Ereshkigal', tradition:'Mesopotamian', domain:'Underworld, death, queen of the great below', planet:'Pluto', symbol:'Lapis lazuli throne'},
  {name:'Dumuzi (Tammuz)', tradition:'Mesopotamian', domain:'Shepherds, fertility, vegetation, seasonal death/rebirth', planet:'Venus', symbol:'Grain, shepherd\'s crook'},
  {name:'Ninhursag (Ki)', tradition:'Mesopotamian', domain:'Earth, mountains, fertility, mother of gods', planet:'Earth', symbol:'Omega symbol, mountains'},
  {name:'Ninurta', tradition:'Mesopotamian', domain:'War, agriculture, healing, storms, heroism', planet:'Mars', symbol:'Plow, mace'},
  {name:'Adad (Ishkur)', tradition:'Mesopotamian', domain:'Storms, rain, thunder, floods', planet:'Jupiter', symbol:'Lightning bolt, bull'},
  {name:'Nisaba', tradition:'Mesopotamian', domain:'Grain, writing, learning, astronomy', planet:'Mercury', symbol:'Grain stalk, tablet'},
  {name:'Gula', tradition:'Mesopotamian', domain:'Healing, medicine, dogs', planet:'Sun', symbol:'Dog, scalpel'},
  {name:'Pazuzu', tradition:'Mesopotamian', domain:'Wind demon, protection against plague, exorcism', planet:'Saturn', symbol:'Winged lion-demon'},
  {name:'Lamashtu', tradition:'Mesopotamian', domain:'Demoness, menace to pregnant women and infants', planet:'Pluto', symbol:'Lioness head, donkey'},
  {name:'Dumuzid', tradition:'Mesopotamian', domain:'Shepherds, seasonal fertility, consort of Inanna', planet:'Venus', symbol:'Shepherd\'s crook'},
  {name:'Apsu', tradition:'Mesopotamian', domain:'Primordial freshwater, abyss, creation', planet:'Neptune', symbol:'Fresh water depths'},
  {name:'Girra (Gibil)', tradition:'Mesopotamian', domain:'Fire, light, purification', planet:'Mars', symbol:'Flames'},
  {name:'Asalluhi', tradition:'Mesopotamian', domain:'Exorcism, healing magic, son of Enki', planet:'Mercury', symbol:'Incantation'},

  // ========================================================================
  // CHINESE
  // ========================================================================
  {name:'Jade Emperor (Yu Huang)', tradition:'Chinese', domain:'Supreme ruler of heaven, all gods, mortals, and realms', planet:'Jupiter', symbol:'Dragon throne, imperial robes'},
  {name:'Guanyin (Kuan Yin)', tradition:'Chinese', domain:'Mercy, compassion, healing, salvation', planet:'Moon', symbol:'Lotus, willow, vase of pure water'},
  {name:'Sun Wukong', tradition:'Chinese', domain:'Monkey King, trickery, rebellion, immortality, strength', planet:'Mars', symbol:'Golden staff, cloud-somersault'},
  {name:'Guan Yu', tradition:'Chinese', domain:'War, righteousness, loyalty, brotherhood', planet:'Mars', symbol:'Green Dragon Crescent Blade, red face'},
  {name:'Nuwa', tradition:'Chinese', domain:'Creation of humanity, repairing heaven, marriage', planet:'Earth', symbol:'Serpent body, compass, five-colored stones'},
  {name:'Pangu', tradition:'Chinese', domain:'Primordial creation, separation of heaven and earth', planet:'Earth', symbol:'Axe, egg, giant body'},
  {name:'Xi Wangmu (Queen Mother of the West)', tradition:'Chinese', domain:'Immortality, yin energy, punishment, cosmic order', planet:'Venus', symbol:'Peaches of immortality, phoenix, tiger'},
  {name:'Lei Gong', tradition:'Chinese', domain:'Thunder, justice, punishment of evildoers', planet:'Jupiter', symbol:'Drum, hammer, wings'},
  {name:'Nezha', tradition:'Chinese', domain:'Protection, youth, rebellious spirit, exorcism', planet:'Mars', symbol:'Fire-tipped spear, wind-fire wheels, cosmic ring'},
  {name:'Erlang Shen', tradition:'Chinese', domain:'Truth, water, engineering, third eye, demon-slaying', planet:'Sun', symbol:'Three-pointed spear, celestial dog, third eye'},
  {name:'Zhong Kui', tradition:'Chinese', domain:'Exorcism, demon-slaying, protector against evil', planet:'Mars', symbol:'Sword, scholarly robes'},
  {name:'Chang\'e', tradition:'Chinese', domain:'Moon, immortality, longing, Mid-Autumn', planet:'Moon', symbol:'Moon, jade rabbit'},
  {name:'Hou Yi', tradition:'Chinese', domain:'Archery, heroism, sun-shooting, protection', planet:'Sun', symbol:'Bow, ten suns'},
  {name:'Caishen', tradition:'Chinese', domain:'Wealth, fortune, prosperity', planet:'Jupiter', symbol:'Gold ingot, tiger'},
  {name:'Mazu', tradition:'Chinese', domain:'Sea, seafarers, protection of fishermen', planet:'Neptune', symbol:'Red robes, lantern'},
  {name:'Zao Jun (Kitchen God)', tradition:'Chinese', domain:'Hearth, family, household report to heaven', planet:'Saturn', symbol:'Kitchen stove, scroll'},
  {name:'Menshen (Door Gods)', tradition:'Chinese', domain:'Protection of doorways, guardian spirits', planet:'Mars', symbol:'Paired warriors, weapons'},
  {name:'Shangdi', tradition:'Chinese', domain:'Supreme deity (ancient), heaven, cosmic authority', planet:'Sun', symbol:'Heaven'},
  {name:'Fuxi', tradition:'Chinese', domain:'Civilization, trigrams, fishing, writing, calendar', planet:'Mercury', symbol:'Serpent body, square, trigrams'},
  {name:'Shennong', tradition:'Chinese', domain:'Agriculture, medicine, tea, herbalism', planet:'Earth', symbol:'Plants, ox horns, plow'},
  {name:'Yan Wang', tradition:'Chinese', domain:'King of Hell, judgment of the dead, underworld', planet:'Pluto', symbol:'Judge\'s cap, book of life and death'},
  {name:'Doumu', tradition:'Chinese', domain:'Pole star, Big Dipper, mother of stars, Daoist astral goddess', planet:'Saturn', symbol:'Multiple arms, sun and moon disks'},
  {name:'Wenchang Wang', tradition:'Chinese', domain:'Literature, scholarship, examinations', planet:'Mercury', symbol:'Brush, books'},
  {name:'Zhenwu', tradition:'Chinese', domain:'North, water, martial arts, exorcism, Dark Warrior', planet:'Saturn', symbol:'Snake and turtle, sword'},

  // ========================================================================
  // JAPANESE (Shinto / Buddhist syncretism)
  // ========================================================================
  {name:'Amaterasu', tradition:'Japanese', domain:'Sun, universe, Imperial ancestor, highest kami', planet:'Sun', symbol:'Sacred mirror (Yata no Kagami), sun'},
  {name:'Tsukuyomi', tradition:'Japanese', domain:'Moon, night, darkness, time', planet:'Moon', symbol:'Moon, night'},
  {name:'Susanoo', tradition:'Japanese', domain:'Storms, sea, underworld, trickery, valor', planet:'Mars', symbol:'Sword (Kusanagi), storms'},
  {name:'Izanagi', tradition:'Japanese', domain:'Creation, life, purification, father of gods', planet:'Sun', symbol:'Jeweled spear (Ame-no-Nuhoko)'},
  {name:'Izanami', tradition:'Japanese', domain:'Creation, death, underworld (Yomi), mother of gods', planet:'Pluto', symbol:'Underworld, fire'},
  {name:'Inari', tradition:'Japanese', domain:'Rice, fertility, foxes, commerce, industry, success', planet:'Mercury', symbol:'Fox (kitsune), rice sheaves, torii'},
  {name:'Raijin', tradition:'Japanese', domain:'Thunder, lightning, storms', planet:'Jupiter', symbol:'Thunder drums, demon form'},
  {name:'Fujin', tradition:'Japanese', domain:'Wind, air, breeze', planet:'Mercury', symbol:'Bag of winds, demon form'},
  {name:'Hachiman', tradition:'Japanese', domain:'War, archery, divine protector, agriculture', planet:'Mars', symbol:'Bow, dove, tomoe symbol'},
  {name:'Benzaiten (Benten)', tradition:'Japanese', domain:'Music, eloquence, water, wealth, knowledge, love', planet:'Venus', symbol:'Biwa (lute), serpent, water'},
  {name:'Bishamonten', tradition:'Japanese', domain:'War, warriors, punishment, authority, treasure', planet:'Mars', symbol:'Pagoda, spear, armor'},
  {name:'Daikokuten', tradition:'Japanese', domain:'Wealth, commerce, farming, great darkness/abundance', planet:'Jupiter', symbol:'Mallet, rice bales, rats'},
  {name:'Ebisu', tradition:'Japanese', domain:'Fishermen, luck, merchants, prosperity', planet:'Jupiter', symbol:'Fishing rod, sea bream'},
  {name:'Fukurokuju', tradition:'Japanese', domain:'Longevity, wisdom, happiness', planet:'Saturn', symbol:'Long forehead, staff, crane'},
  {name:'Jurojin', tradition:'Japanese', domain:'Longevity, wisdom, elderly', planet:'Saturn', symbol:'Scroll, staff, deer'},
  {name:'Hotei', tradition:'Japanese', domain:'Abundance, contentment, fortune, the laughing Buddha', planet:'Jupiter', symbol:'Cloth sack, large belly'},
  {name:'Kannon (Kanzeon)', tradition:'Japanese', domain:'Mercy, compassion (Japanese Avalokiteshvara)', planet:'Moon', symbol:'Lotus, multiple arms, willow'},
  {name:'Jizo', tradition:'Japanese', domain:'Children, travelers, underworld travelers, mercy', planet:'Moon', symbol:'Staff, jewel, bib'},
  {name:'Fudo Myoo', tradition:'Japanese', domain:'Immovable wisdom, fire, protection, destroyer of delusion', planet:'Mars', symbol:'Flaming sword, rope, fire halo'},
  {name:'Ryujin', tradition:'Japanese', domain:'Sea, dragons, storms, tide jewels', planet:'Neptune', symbol:'Dragon, tide jewels'},
  {name:'Ame-no-Uzume', tradition:'Japanese', domain:'Dawn, mirth, revelry, the arts, persuasion', planet:'Venus', symbol:'Dance, laughter, mirror'},
  {name:'Sarutahiko', tradition:'Japanese', domain:'Crossroads, guidance, earthly kami, strength', planet:'Earth', symbol:'Long nose, crossroads'},
  {name:'Tenjin', tradition:'Japanese', domain:'Scholarship, learning, calligraphy (deified Sugawara no Michizane)', planet:'Mercury', symbol:'Plum blossom, ox, brush'},
  {name:'Dosojin', tradition:'Japanese', domain:'Roads, travelers, boundaries, fertility', planet:'Saturn', symbol:'Paired stone figures'},

  // ========================================================================
  // CELTIC
  // ========================================================================
  {name:'Dagda', tradition:'Celtic', domain:'Earth, life, death, agriculture, abundance, magic, druidry', planet:'Jupiter', symbol:'Cauldron, club, harp'},
  {name:'Brigid', tradition:'Celtic', domain:'Fire, poetry, healing, smithcraft, spring', planet:'Sun', symbol:'Flame, Brigid\'s cross, well'},
  {name:'Lugh', tradition:'Celtic', domain:'Light, crafts, skill in all arts, heroism, harvest', planet:'Sun', symbol:'Spear, sling, ravens'},
  {name:'Morrigan', tradition:'Celtic', domain:'War, death, fate, sovereignty, shapeshifting', planet:'Mars', symbol:'Crow/raven, sword'},
  {name:'Cernunnos', tradition:'Celtic', domain:'Nature, animals, fertility, underworld, wealth', planet:'Earth', symbol:'Antlers, torc, serpent'},
  {name:'Danu (Dana)', tradition:'Celtic', domain:'Mother goddess, rivers, earth, fertility, Tuatha Dé Danann', planet:'Moon', symbol:'Flowing water, earth'},
  {name:'Manannán mac Lir', tradition:'Celtic', domain:'Sea, otherworld, mist, trickery, magic', planet:'Neptune', symbol:'Crane bag, boat, mist cloak'},
  {name:'Aengus (Óengus)', tradition:'Celtic', domain:'Love, youth, poetry, dreams', planet:'Venus', symbol:'Four birds (kisses), swan'},
  {name:'Nuada', tradition:'Celtic', domain:'Kingship, justice, war, silver hand', planet:'Jupiter', symbol:'Silver hand, sword of light'},
  {name:'Ogma', tradition:'Celtic', domain:'Eloquence, writing, Ogham script, poetry, strength', planet:'Mercury', symbol:'Ogham, sun-face, chain'},
  {name:'Arawn', tradition:'Celtic', domain:'Underworld (Annwn), death, hunting, hounds', planet:'Pluto', symbol:'White hounds, cauldron'},
  {name:'Rhiannon', tradition:'Celtic', domain:'Horses, otherworld, enchantment, sovereignty, patience', planet:'Moon', symbol:'White horse, birds'},
  {name:'Epona', tradition:'Celtic', domain:'Horses, fertility, sovereignty, protector of cavalry', planet:'Earth', symbol:'Horse, cornucopia'},
  {name:'Belenus', tradition:'Celtic', domain:'Sun, healing, light, Beltane', planet:'Sun', symbol:'Sun wheel, horse'},
  {name:'Taranis', tradition:'Celtic', domain:'Thunder, storms, sky', planet:'Jupiter', symbol:'Wheel, thunderbolt'},
  {name:'Cerridwen', tradition:'Celtic', domain:'Rebirth, transformation, poetic inspiration, the cauldron', planet:'Moon', symbol:'Cauldron, sow, grain'},
  {name:'Sucellos', tradition:'Celtic', domain:'Agriculture, wine, forests, hammer god', planet:'Jupiter', symbol:'Long-handled hammer, barrel'},
  {name:'Goibniu', tradition:'Celtic', domain:'Smithcraft, brewing, immortality', planet:'Saturn', symbol:'Hammer, ale'},
  {name:'Dian Cecht', tradition:'Celtic', domain:'Medicine, healing, surgery', planet:'Sun', symbol:'Herbs, silver hand'},
  {name:'Bodb Dearg', tradition:'Celtic', domain:'Kingship of the Tuatha Dé Danann, wisdom', planet:'Jupiter', symbol:'Crown'},
  {name:'Aine', tradition:'Celtic', domain:'Summer, wealth, sovereignty, love', planet:'Sun', symbol:'Red mare'},
  {name:'Badb', tradition:'Celtic', domain:'War, battle fury, prophetic crows', planet:'Mars', symbol:'Crow'},
  {name:'Macha', tradition:'Celtic', domain:'War, horses, sovereignty, Ulster', planet:'Mars', symbol:'Horse, crow'},
  {name:'Cliodhna', tradition:'Celtic', domain:'Love, beauty, otherworld, sea waves', planet:'Venus', symbol:'Three birds, waves'},

  // ========================================================================
  // AFRICAN / YORUBA (Orisha tradition — West Africa, Diaspora)
  // ========================================================================
  {name:'Olodumare (Olorun)', tradition:'Yoruba', domain:'Supreme creator, source of all ashé (life force)', planet:'Sun', symbol:'White light, sky'},
  {name:'Ogun', tradition:'Yoruba', domain:'Iron, war, labor, technology, truth, clearing paths', planet:'Mars', symbol:'Iron, machete, anvil, palm fronds'},
  {name:'Shango (Sango)', tradition:'Yoruba', domain:'Thunder, lightning, fire, justice, kingship, drumming', planet:'Jupiter', symbol:'Double-headed axe (oshe), red and white'},
  {name:'Oshun', tradition:'Yoruba', domain:'Rivers, love, beauty, fertility, diplomacy, sweet water', planet:'Venus', symbol:'Mirror, fan, honey, gold, peacock'},
  {name:'Yemoja (Yemaya)', tradition:'Yoruba', domain:'Ocean, motherhood, children, protection, moon tides', planet:'Moon', symbol:'Cowrie shells, fish, blue/white'},
  {name:'Obatala', tradition:'Yoruba', domain:'Creation, purity, wisdom, ethics, white cloth, sculptor of humans', planet:'Jupiter', symbol:'White cloth, staff, snail shell'},
  {name:'Eshu (Elegua/Legba)', tradition:'Yoruba', domain:'Crossroads, messages, communication, trickster, opener of ways', planet:'Mercury', symbol:'Crossroads, red and black, cowrie eyes'},
  {name:'Orunmila (Ifa)', tradition:'Yoruba', domain:'Divination, wisdom, destiny, Ifa oracle', planet:'Mercury', symbol:'Ikin (palm nuts), opele chain'},
  {name:'Oya', tradition:'Yoruba', domain:'Wind, storms, death, transformation, cemeteries, rebirth', planet:'Pluto', symbol:'Buffalo horns, nine colors, sword'},
  {name:'Babalu-Aye (Sopona)', tradition:'Yoruba', domain:'Disease, healing, earth, smallpox, the afflicted', planet:'Saturn', symbol:'Crutch, straw, broom, dogs'},
  {name:'Nana Buruku', tradition:'Yoruba', domain:'Primordial swamp, ancestors, death, creation mud', planet:'Saturn', symbol:'Ibiri staff, mud, purple'},
  {name:'Osanyin (Osain)', tradition:'Yoruba', domain:'Herbs, healing, forest medicine, plant magic', planet:'Earth', symbol:'One-legged figure, gourd, bird staff'},
  {name:'Oduduwa', tradition:'Yoruba', domain:'Earth, ancestor of Yoruba people, creation of land', planet:'Earth', symbol:'Black, earth, creation chain'},
  {name:'Ori', tradition:'Yoruba', domain:'Personal destiny, inner head, consciousness', planet:'Sun', symbol:'Head, white'},
  {name:'Ibeji', tradition:'Yoruba', domain:'Twins, duality, joy, mischief, abundance', planet:'Mercury', symbol:'Twin figures'},
  {name:'Aganju', tradition:'Yoruba', domain:'Volcanoes, wilderness, strength, the desert', planet:'Mars', symbol:'Volcano, fire'},
  {name:'Olokun', tradition:'Yoruba', domain:'Deep ocean, wealth, mysteries, ocean floor', planet:'Neptune', symbol:'Chains, ocean depths, dark blue'},
  {name:'Yewa', tradition:'Yoruba', domain:'Death, cemetery, solitude, chastity', planet:'Pluto', symbol:'Skull, cemetery gate'},

  // ========================================================================
  // MAYAN
  // ========================================================================
  {name:'Itzamna', tradition:'Mayan', domain:'Sky, creation, writing, healing, supreme god', planet:'Jupiter', symbol:'Iguana, celestial throne'},
  {name:'Kukulkan (K\'uk\'ulkan)', tradition:'Mayan', domain:'Feathered serpent, wind, rain, civilization', planet:'Venus', symbol:'Feathered serpent, pyramid shadow'},
  {name:'Chaac', tradition:'Mayan', domain:'Rain, thunder, fertility, agriculture', planet:'Jupiter', symbol:'Axe, jade, serpentine nose'},
  {name:'Ixchel', tradition:'Mayan', domain:'Moon, medicine, childbirth, weaving, floods', planet:'Moon', symbol:'Rabbit, water jar, loom'},
  {name:'Ah Puch (Kisin)', tradition:'Mayan', domain:'Death, underworld (Xibalba), decay', planet:'Pluto', symbol:'Skeletal figure, owl, bells'},
  {name:'Hunahpu', tradition:'Mayan', domain:'Hero twin, blowgun hunter, sun, trickery', planet:'Sun', symbol:'Blowgun, jaguar skin'},
  {name:'Xbalanque', tradition:'Mayan', domain:'Hero twin, moon, jaguar, cunning', planet:'Moon', symbol:'Jaguar patches'},
  {name:'Kinich Ahau', tradition:'Mayan', domain:'Sun god, fire, heat, drought', planet:'Sun', symbol:'Sun jaguar, cross-eyes'},
  {name:'Ix Tab', tradition:'Mayan', domain:'Suicide (honorable death), the hanged, afterlife', planet:'Pluto', symbol:'Noose, rope'},
  {name:'Yum Kaax', tradition:'Mayan', domain:'Maize, agriculture, nature, forests', planet:'Earth', symbol:'Maize plant, youth'},
  {name:'Bacabs', tradition:'Mayan', domain:'Four gods holding up sky at cardinal directions', planet:'Earth', symbol:'Four directions, shell'},
  {name:'Ek Chuaj', tradition:'Mayan', domain:'Merchants, cacao, war, travel', planet:'Mercury', symbol:'Cacao pod, merchant pack'},
  {name:'Zipacna', tradition:'Mayan', domain:'Earth, mountains, earthquakes, crocodilian demon', planet:'Earth', symbol:'Crocodile, mountain'},
  {name:'Camazotz', tradition:'Mayan', domain:'Bats, night, death, sacrifice (Xibalba lord)', planet:'Pluto', symbol:'Bat'},

  // ========================================================================
  // AZTEC (Mexica)
  // ========================================================================
  {name:'Quetzalcoatl', tradition:'Aztec', domain:'Wind, air, learning, civilization, feathered serpent, morning star', planet:'Venus', symbol:'Feathered serpent, wind jewel (ehecailacacozcatl)'},
  {name:'Tezcatlipoca', tradition:'Aztec', domain:'Night, sorcery, destiny, jaguar, conflict, the smoking mirror', planet:'Saturn', symbol:'Obsidian mirror, jaguar'},
  {name:'Huitzilopochtli', tradition:'Aztec', domain:'Sun, war, sacrifice, patron of Tenochtitlan', planet:'Sun', symbol:'Hummingbird, fire serpent (xiuhcoatl)'},
  {name:'Tlaloc', tradition:'Aztec', domain:'Rain, fertility, water, lightning, caves', planet:'Neptune', symbol:'Goggle eyes, jade, fangs'},
  {name:'Xipe Totec', tradition:'Aztec', domain:'Agriculture, spring, renewal, flayed skin, goldsmiths', planet:'Earth', symbol:'Flayed skin, golden staff'},
  {name:'Mictlantecuhtli', tradition:'Aztec', domain:'Death, underworld (Mictlan), lord of the dead', planet:'Pluto', symbol:'Skeletal figure, owl, spider'},
  {name:'Coatlicue', tradition:'Aztec', domain:'Earth, motherhood, creation, destruction, serpent skirt', planet:'Earth', symbol:'Serpent skirt, skull necklace'},
  {name:'Tonatiuh', tradition:'Aztec', domain:'Fifth sun, era, demands blood sacrifice', planet:'Sun', symbol:'Sun stone face, eagle'},
  {name:'Chalchiuhtlicue', tradition:'Aztec', domain:'Water, rivers, lakes, streams, baptism, jade skirt', planet:'Neptune', symbol:'Jade skirt, flowing water'},
  {name:'Xochiquetzal', tradition:'Aztec', domain:'Beauty, love, flowers, fertility, arts, weaving', planet:'Venus', symbol:'Flowers, butterflies, quetzal feathers'},
  {name:'Tlazolteotl', tradition:'Aztec', domain:'Purification, filth, lust, confession, steam baths', planet:'Moon', symbol:'Cotton spindle, crescent nose ornament'},
  {name:'Ehecatl', tradition:'Aztec', domain:'Wind (aspect of Quetzalcoatl), breath of life', planet:'Mercury', symbol:'Duck-beak mask'},
  {name:'Xiuhtecuhtli', tradition:'Aztec', domain:'Fire, day, heat, time, the calendar', planet:'Mars', symbol:'Fire, turquoise'},
  {name:'Centeotl', tradition:'Aztec', domain:'Maize, agriculture, sustenance', planet:'Earth', symbol:'Maize ears'},
  {name:'Mayahuel', tradition:'Aztec', domain:'Agave, pulque (alcohol), fertility, nourishment', planet:'Moon', symbol:'Agave plant, 400 breasts'},
  {name:'Mixcoatl', tradition:'Aztec', domain:'Hunt, stars, Milky Way, cloud serpent', planet:'Mars', symbol:'Arrow, starry body paint'},
  {name:'Ometeotl', tradition:'Aztec', domain:'Duality, supreme creator (Ometecuhtli + Omecihuatl), origin of all', planet:'Sun', symbol:'Dual face, day and night'},

  // ========================================================================
  // ABORIGINAL AUSTRALIAN
  // ========================================================================
  {name:'Rainbow Serpent (Wagyl/Ungud)', tradition:'Aboriginal Australian', domain:'Creation, water, life, fertility, weather, law', planet:'Neptune', symbol:'Rainbow, serpent, waterways'},
  {name:'Baiame', tradition:'Aboriginal Australian', domain:'Sky father, creator, lawgiver, initiation', planet:'Jupiter', symbol:'Sky, crystal, initiatory marks'},
  {name:'Yhi', tradition:'Aboriginal Australian', domain:'Sun goddess, creation, light bringer', planet:'Sun', symbol:'Sun, light, flowers'},
  {name:'Altjira', tradition:'Aboriginal Australian', domain:'Dreaming, sky, Alcheringa (Dreamtime), creation', planet:'Neptune', symbol:'Emu feet, sky'},
  {name:'Tiddalik', tradition:'Aboriginal Australian', domain:'Floods, water, the frog who drank all water', planet:'Neptune', symbol:'Giant frog'},
  {name:'Bunjil', tradition:'Aboriginal Australian', domain:'Creator eagle hawk, sky, ceremonies (Kulin people)', planet:'Sun', symbol:'Wedge-tailed eagle'},
  {name:'Djanggawul', tradition:'Aboriginal Australian', domain:'Creation siblings, fertility, sacred objects, land-shaping', planet:'Earth', symbol:'Sacred dilly bags, rangga poles'},
  {name:'Wollunqua', tradition:'Aboriginal Australian', domain:'Rain serpent, fertility, danger (Warumungu people)', planet:'Neptune', symbol:'Giant water serpent'},
  {name:'Mimi Spirits', tradition:'Aboriginal Australian', domain:'Teaching rock art, hunting, thin rock-dwelling spirits', planet:'Mercury', symbol:'Thin elongated figures'},

  // ========================================================================
  // NATIVE AMERICAN (Multiple traditions)
  // ========================================================================
  {name:'Wakan Tanka (Great Spirit)', tradition:'Native American (Lakota)', domain:'Supreme being, totality of existence, the great mystery', planet:'Sun', symbol:'Circle, sky, all directions'},
  {name:'Coyote', tradition:'Native American (Pan-tribal)', domain:'Trickster, creation, mischief, survival, culture hero', planet:'Mercury', symbol:'Coyote'},
  {name:'Raven', tradition:'Native American (Pacific NW)', domain:'Trickster, creation, light-bringer, transformer', planet:'Mercury', symbol:'Raven, sun in beak'},
  {name:'Kokopelli', tradition:'Native American (Southwest)', domain:'Fertility, music, joy, agriculture, flute player', planet:'Venus', symbol:'Flute, hunchback, dancing'},
  {name:'Thunderbird', tradition:'Native American (Pan-tribal)', domain:'Thunder, lightning, storms, power, protection', planet:'Jupiter', symbol:'Great eagle, lightning wings'},
  {name:'White Buffalo Woman', tradition:'Native American (Lakota)', domain:'Sacred pipe, prayer, ceremony, prophecy', planet:'Moon', symbol:'Sacred pipe, white buffalo'},
  {name:'Spider Woman (Na\'ashjé\'ii Asdzáá)', tradition:'Native American (Navajo/Hopi)', domain:'Creation, weaving, wisdom, protection, earth', planet:'Earth', symbol:'Spider, web, loom'},
  {name:'Gitche Manitou', tradition:'Native American (Algonquian)', domain:'Great Spirit, supreme creator, life force', planet:'Sun', symbol:'Circle, breath, nature'},
  {name:'Sedna', tradition:'Native American (Inuit)', domain:'Sea, marine animals, underworld (Adlivun), provision', planet:'Neptune', symbol:'Fingers (sea creatures), ocean depths'},
  {name:'Nanabozho', tradition:'Native American (Ojibwe)', domain:'Trickster, culture hero, shape-shifter, teacher', planet:'Mercury', symbol:'Rabbit/hare, shape-shifting'},
  {name:'Coyolxauhqui', tradition:'Native American (Aztec)', domain:'Moon, stars, defeated by sun (Huitzilopochtli)', planet:'Moon', symbol:'Dismembered moon disk'},
  {name:'Changing Woman (Asdzáá Nádleehé)', tradition:'Native American (Navajo)', domain:'Seasons, aging, renewal, earth, Navajo creation', planet:'Earth', symbol:'Four seasons, turquoise'},
  {name:'Unetlanvhi', tradition:'Native American (Cherokee)', domain:'Creator, great spirit, apportioner', planet:'Sun', symbol:'Sacred fire'},
  {name:'Michabo', tradition:'Native American (Algonquian)', domain:'Great Hare, creator, trickster, dawn', planet:'Sun', symbol:'Hare, dawn light'},
  {name:'Iktomi', tradition:'Native American (Lakota)', domain:'Trickster spider, cunning, stories, web of fate', planet:'Mercury', symbol:'Spider, web'},

  // ========================================================================
  // ZOROASTRIAN
  // ========================================================================
  {name:'Ahura Mazda', tradition:'Zoroastrian', domain:'Supreme creator, wisdom, truth, light, cosmic order (Asha)', planet:'Sun', symbol:'Faravahar, winged disk, fire'},
  {name:'Angra Mainyu (Ahriman)', tradition:'Zoroastrian', domain:'Destruction, darkness, lies, chaos, adversary', planet:'Pluto', symbol:'Darkness, serpent'},
  {name:'Mithra', tradition:'Zoroastrian', domain:'Covenant, light, sun, justice, war, contracts', planet:'Sun', symbol:'Sun, bull, radiant crown'},
  {name:'Anahita', tradition:'Zoroastrian', domain:'Water, fertility, wisdom, healing, rivers', planet:'Venus', symbol:'Water, beavers, golden chariot'},
  {name:'Atar', tradition:'Zoroastrian', domain:'Fire, sacred flame, truth, divine spark', planet:'Mars', symbol:'Sacred fire'},
  {name:'Vayu-Vata', tradition:'Zoroastrian', domain:'Wind, air, atmosphere, breath', planet:'Mercury', symbol:'Wind'},
  {name:'Tishtrya', tradition:'Zoroastrian', domain:'Rain, star Sirius, fertility, cosmic battle', planet:'Jupiter', symbol:'White horse, star'},
  {name:'Sraosha', tradition:'Zoroastrian', domain:'Obedience, discipline, prayer, protector of souls', planet:'Jupiter', symbol:'Rooster (herald of dawn)'},
  {name:'Rashnu', tradition:'Zoroastrian', domain:'Justice, judgment of the dead, the scales', planet:'Saturn', symbol:'Golden scales'},
  {name:'Amesha Spentas (Seven)', tradition:'Zoroastrian', domain:'Seven divine sparks of Ahura Mazda — archangels of virtues', planet:'Jupiter', symbol:'Seven rays'},
  {name:'Verethragna', tradition:'Zoroastrian', domain:'Victory, warrior spirit, ten incarnations', planet:'Mars', symbol:'Wild boar, bird'},
  {name:'Haurvatat', tradition:'Zoroastrian', domain:'Wholeness, health, water (Amesha Spenta)', planet:'Neptune', symbol:'Water'},
  {name:'Ameretat', tradition:'Zoroastrian', domain:'Immortality, plants (Amesha Spenta)', planet:'Earth', symbol:'Plants, immortality'},
  {name:'Daena', tradition:'Zoroastrian', domain:'Religion, conscience, inner self, the maiden at the bridge', planet:'Moon', symbol:'Beautiful/ugly maiden'},

  // ========================================================================
  // ABRAHAMIC ANGELS / DIVINE FIGURES
  // ========================================================================
  {name:'Michael', tradition:'Abrahamic', domain:'Protection, warrior archangel, leader of heavenly host, justice', planet:'Sun', symbol:'Flaming sword, scales, armor'},
  {name:'Gabriel', tradition:'Abrahamic', domain:'Messenger, revelation, annunciation, strength of God', planet:'Moon', symbol:'Trumpet, lily, scroll'},
  {name:'Raphael', tradition:'Abrahamic', domain:'Healing, guidance, travelers, restoration', planet:'Mercury', symbol:'Staff, fish, healing balm'},
  {name:'Uriel', tradition:'Abrahamic', domain:'Light, wisdom, repentance, fire of God', planet:'Sun', symbol:'Flame, book, sword'},
  {name:'Metatron', tradition:'Abrahamic (Kabbalistic)', domain:'Scribe of God, highest angel, celestial archive, voice of God', planet:'Saturn', symbol:'Metatron\'s Cube, pen, throne'},
  {name:'Samael', tradition:'Abrahamic (Kabbalistic)', domain:'Severity, death, poison of God, accuser, Mars energy', planet:'Mars', symbol:'Sword, poison, serpent'},
  {name:'Azrael', tradition:'Abrahamic (Islamic)', domain:'Death, angel of death, separation of soul from body', planet:'Pluto', symbol:'Scythe, scroll of souls'},
  {name:'Sandalphon', tradition:'Abrahamic (Kabbalistic)', domain:'Prayer, music, earth, twin of Metatron', planet:'Earth', symbol:'Lyre, prayer, pillar'},
  {name:'Raziel', tradition:'Abrahamic (Kabbalistic)', domain:'Mysteries, secrets, Sefer Raziel, keeper of divine secrets', planet:'Neptune', symbol:'Book of secrets, veil'},
  {name:'Haniel', tradition:'Abrahamic (Kabbalistic)', domain:'Joy, beauty, Venus energy, grace of God', planet:'Venus', symbol:'Rose, lantern'},
  {name:'Tzaphkiel', tradition:'Abrahamic (Kabbalistic)', domain:'Understanding, contemplation, Saturn energy, Binah', planet:'Saturn', symbol:'Dark robe, throne'},
  {name:'Chamuel', tradition:'Abrahamic', domain:'Peace, compassion, finding what is lost', planet:'Venus', symbol:'Heart, pink light'},
  {name:'Jophiel', tradition:'Abrahamic', domain:'Beauty, wisdom, illumination, creativity', planet:'Sun', symbol:'Flaming sword, light'},
  {name:'Zadkiel', tradition:'Abrahamic', domain:'Mercy, forgiveness, benevolence, Jupiter energy', planet:'Jupiter', symbol:'Dagger (stayed Abraham\'s hand)'},
  {name:'Seraphim', tradition:'Abrahamic', domain:'Highest choir, burning ones, perpetual praise, divine fire', planet:'Sun', symbol:'Six wings, fire, song'},
  {name:'Shekinah', tradition:'Abrahamic (Kabbalistic)', domain:'Divine feminine presence, indwelling of God, Malkuth', planet:'Moon', symbol:'Light, dove, bride'},

  // ========================================================================
  // BUDDHIST FIGURES (Buddhas, Bodhisattvas, Dharma Protectors)
  // ========================================================================
  {name:'Shakyamuni Buddha (Siddhartha Gautama)', tradition:'Buddhist', domain:'Awakening, enlightenment, the dharma, the middle way', planet:'Sun', symbol:'Lotus, Bodhi tree, wheel, ushnisha'},
  {name:'Avalokiteshvara (Chenrezig)', tradition:'Buddhist', domain:'Compassion, mercy, bodhisattva of infinite compassion', planet:'Moon', symbol:'Lotus, thousand arms, Om Mani Padme Hum'},
  {name:'Maitreya', tradition:'Buddhist', domain:'Future Buddha, loving-kindness, hope, the coming age', planet:'Jupiter', symbol:'Water flask, Dharma wheel, throne'},
  {name:'Amitabha', tradition:'Buddhist', domain:'Infinite light, Pure Land, western paradise, devotion', planet:'Sun', symbol:'Red, lotus, begging bowl'},
  {name:'Manjushri', tradition:'Buddhist', domain:'Wisdom, learning, intelligence, cutting through ignorance', planet:'Mercury', symbol:'Flaming sword, book (Prajnaparamita)'},
  {name:'Vajrapani', tradition:'Buddhist', domain:'Power, protection, wrathful compassion, thunderbolt holder', planet:'Mars', symbol:'Vajra (thunderbolt), fierce face'},
  {name:'Tara (Green)', tradition:'Buddhist', domain:'Compassion, protection, action, female enlightenment', planet:'Venus', symbol:'Green, blue lotus, right foot extended'},
  {name:'Tara (White)', tradition:'Buddhist', domain:'Longevity, healing, serenity, seven eyes', planet:'Moon', symbol:'White, seven eyes, full lotus'},
  {name:'Vairochana', tradition:'Buddhist', domain:'Cosmic Buddha, center, illumination, dharmakaya', planet:'Sun', symbol:'White, Dharma wheel, teaching mudra'},
  {name:'Akshobhya', tradition:'Buddhist', domain:'Mirror-like wisdom, immovable, east, steadfastness', planet:'Saturn', symbol:'Blue, vajra, elephant'},
  {name:'Ratnasambhava', tradition:'Buddhist', domain:'Equanimity, generosity, richness, south', planet:'Jupiter', symbol:'Yellow, jewel, horse'},
  {name:'Amoghasiddhi', tradition:'Buddhist', domain:'Fearlessness, accomplishment, north, all-accomplishing wisdom', planet:'Mars', symbol:'Green, double vajra, Garuda'},
  {name:'Medicine Buddha (Bhaisajyaguru)', tradition:'Buddhist', domain:'Healing, medicine, lapis lazuli, curing spiritual illness', planet:'Sun', symbol:'Lapis lazuli, medicine jar'},
  {name:'Kshitigarbha (Jizo)', tradition:'Buddhist', domain:'Hell beings, children, vow to save all in six realms', planet:'Saturn', symbol:'Staff, wish-fulfilling jewel'},
  {name:'Samantabhadra', tradition:'Buddhist', domain:'Universal worthy, practice, meditation, vows', planet:'Jupiter', symbol:'Elephant, lotus, jewel'},
  {name:'Hayagriva', tradition:'Buddhist', domain:'Wrathful protector, horse-headed, defeating obstacles', planet:'Mars', symbol:'Horse head, flames'},
  {name:'Yamantaka', tradition:'Buddhist', domain:'Conqueror of death, wrathful Manjushri, ending fear', planet:'Pluto', symbol:'Buffalo head, weapons, flames'},
  {name:'Mahakala', tradition:'Buddhist', domain:'Protector, time, destruction of obstacles, fierce guardian', planet:'Saturn', symbol:'Skull cup, chopper, dark body'},
  {name:'Palden Lhamo', tradition:'Buddhist', domain:'Wrathful protector, only female Dharmapala, fierceness', planet:'Mars', symbol:'Mule, sun disk, skull cup'},
  {name:'Padmasambhava (Guru Rinpoche)', tradition:'Buddhist (Tibetan)', domain:'Lotus-born guru, tamer of demons, bringer of dharma to Tibet', planet:'Sun', symbol:'Vajra, lotus, skull cup, hat'},
  {name:'Hotei (Budai)', tradition:'Buddhist (Chinese/Japanese)', domain:'Contentment, abundance, joy, laughing monk (future Maitreya)', planet:'Jupiter', symbol:'Cloth sack, big belly, laughter'},

  // ========================================================================
  // POLYNESIAN
  // ========================================================================
  {name:'Maui', tradition:'Polynesian', domain:'Trickster, demigod, fire-bringer, fisher of islands, sun-snarer', planet:'Sun', symbol:'Fishhook, sun, islands'},
  {name:'Pele', tradition:'Polynesian (Hawaiian)', domain:'Volcanoes, fire, lightning, creation/destruction', planet:'Mars', symbol:'Volcano, lava, fire'},
  {name:'Tangaroa (Kanaloa)', tradition:'Polynesian', domain:'Sea, ocean, fish, navigation, creation', planet:'Neptune', symbol:'Ocean, octopus, whale'},
  {name:'Tu (Ku)', tradition:'Polynesian', domain:'War, strength, fierce courage', planet:'Mars', symbol:'Weapons, war club'},
  {name:'Tane (Kane)', tradition:'Polynesian', domain:'Forests, birds, light, creation, life', planet:'Sun', symbol:'Trees, birds, light'},
  {name:'Rongo (Lono)', tradition:'Polynesian', domain:'Cultivated plants, peace, fertility, rain, music', planet:'Jupiter', symbol:'Sweet potato, peace, rainbow'},
  {name:'Hina', tradition:'Polynesian', domain:'Moon, women, tapa cloth, night, beauty', planet:'Moon', symbol:'Moon, tapa beater'},
  {name:'Rangi (Wakea)', tradition:'Polynesian', domain:'Sky father, primordial sky', planet:'Uranus', symbol:'Sky, clouds, embrace'},
  {name:'Papa (Papatuanuku)', tradition:'Polynesian', domain:'Earth mother, primordial earth, fertility', planet:'Earth', symbol:'Earth, stone, embrace'},
  {name:'Whiro', tradition:'Polynesian', domain:'Darkness, evil, disease, underworld lord', planet:'Pluto', symbol:'Darkness, reptiles'},
  {name:'Tawhirimatea', tradition:'Polynesian', domain:'Storms, wind, thunder, lightning', planet:'Jupiter', symbol:'Storm clouds, wind'},
  {name:'Ruaumoko', tradition:'Polynesian', domain:'Earthquakes, volcanoes, unborn god within earth', planet:'Mars', symbol:'Shaking earth'},
  {name:'Haumia-tiketike', tradition:'Polynesian', domain:'Wild plants, uncultivated food, fern roots', planet:'Earth', symbol:'Fern, wild plants'},
  {name:'Hi\'iaka', tradition:'Polynesian (Hawaiian)', domain:'Dance, sorcery, medicine, sister of Pele', planet:'Venus', symbol:'Fern skirt, lightning'},
  {name:'Laka', tradition:'Polynesian (Hawaiian)', domain:'Hula, fertility, forest, wild plants', planet:'Venus', symbol:'Fern, lei, maile'},
  {name:'Oro', tradition:'Polynesian (Tahitian)', domain:'War, peace (season-dependent), harvest', planet:'Mars', symbol:'Feathered girdle'},
  {name:'Tiki', tradition:'Polynesian', domain:'First man, creation, ancestor, carving', planet:'Earth', symbol:'Carved figure'},
  {name:'Io', tradition:'Polynesian (Maori esoteric)', domain:'Supreme being, the hidden one, the parentless', planet:'Sun', symbol:'Void, nothingness, potential'},

  // ========================================================================
  // SLAVIC
  // ========================================================================
  {name:'Perun', tradition:'Slavic', domain:'Thunder, lightning, war, sky, oak, supreme god', planet:'Jupiter', symbol:'Thunderbolt, axe, eagle, oak'},
  {name:'Veles', tradition:'Slavic', domain:'Underworld, cattle, magic, wealth, waters, trickery', planet:'Mercury', symbol:'Serpent, bear, horns'},
  {name:'Svarog', tradition:'Slavic', domain:'Fire, smithing, sky, celestial forge, father of gods', planet:'Sun', symbol:'Forge, fire, hammer'},
  {name:'Dazhbog', tradition:'Slavic', domain:'Sun, giving, prosperity, ancestor of Slavs', planet:'Sun', symbol:'Sun, golden chariot'},
  {name:'Mokosh', tradition:'Slavic', domain:'Earth, fertility, women, weaving, fate, moisture', planet:'Earth', symbol:'Spindle, earth, sheep'},
  {name:'Stribog', tradition:'Slavic', domain:'Wind, air, storm, distribution', planet:'Mercury', symbol:'Wind'},
  {name:'Marzanna (Morana)', tradition:'Slavic', domain:'Winter, death, rebirth, seasonal cycle', planet:'Pluto', symbol:'Straw effigy (drowned at spring), sickle'},
  {name:'Jarilo (Yarilo)', tradition:'Slavic', domain:'Spring, vegetation, fertility, war, youth', planet:'Venus', symbol:'White horse, wheat'},
  {name:'Rod', tradition:'Slavic', domain:'Creation, fate, ancestry, the cosmic pillar', planet:'Jupiter', symbol:'Cosmic tree, pillar'},
  {name:'Lada', tradition:'Slavic', domain:'Love, beauty, marriage, spring, harmony', planet:'Venus', symbol:'White swan, linden tree'},
  {name:'Chernobog', tradition:'Slavic', domain:'Darkness, misfortune, evil, the black god', planet:'Saturn', symbol:'Darkness, black'},
  {name:'Belobog', tradition:'Slavic', domain:'Light, goodness, fortune, the white god', planet:'Sun', symbol:'Light, white'},
  {name:'Svantevit', tradition:'Slavic', domain:'War, divination, abundance (four-headed god of Arkona)', planet:'Mars', symbol:'Four heads, white horse, horn, sword'},
  {name:'Triglav', tradition:'Slavic', domain:'Triple god — sky, earth, underworld; three-headed', planet:'Jupiter', symbol:'Three heads, black horse'},
  {name:'Zorya', tradition:'Slavic', domain:'Dawn and dusk, guardians of the doomsday hound, morning/evening stars', planet:'Venus', symbol:'Morning star, evening star, veil'},
  {name:'Kupala', tradition:'Slavic', domain:'Summer solstice, water, fire, purification, ferns', planet:'Sun', symbol:'Fire, water, fern flower'},
  {name:'Simargl', tradition:'Slavic', domain:'Vegetation, winged dog/griffin, guardian of the world tree', planet:'Earth', symbol:'Winged dog'},

  // ========================================================================
  // FINNISH / BALTIC
  // ========================================================================
  {name:'Ukko', tradition:'Finnish', domain:'Sky, thunder, harvest, supreme god', planet:'Jupiter', symbol:'Hammer, oak'},
  {name:'Väinämöinen', tradition:'Finnish', domain:'Music, magic, wisdom, eternal sage, kantele player', planet:'Mercury', symbol:'Kantele (harp), boat'},
  {name:'Ilmarinen', tradition:'Finnish', domain:'Smithing, sky, creation of the Sampo, invention', planet:'Saturn', symbol:'Forge, Sampo (world-pillar mill)'},
  {name:'Louhi', tradition:'Finnish', domain:'Sorcery, Pohjola (north), winter, antagonist', planet:'Pluto', symbol:'North, cold, Sampo theft'},
  {name:'Ahti (Ahto)', tradition:'Finnish', domain:'Sea, water, fish, depths', planet:'Neptune', symbol:'Waves, fish'},
  {name:'Mielikki', tradition:'Finnish', domain:'Forests, hunting, healing, animals', planet:'Earth', symbol:'Forest, animals, berries'},
  {name:'Tapio', tradition:'Finnish', domain:'Forest king, hunting, game animals', planet:'Saturn', symbol:'Moss cloak, forest'},
  {name:'Tuoni', tradition:'Finnish', domain:'Death, underworld (Tuonela), the black river', planet:'Pluto', symbol:'Black river, swan'},
  {name:'Perkūnas', tradition:'Baltic (Lithuanian)', domain:'Thunder, lightning, sky, justice, purification', planet:'Jupiter', symbol:'Axe, oak, thunderbolt'},
  {name:'Laima', tradition:'Baltic (Latvian)', domain:'Fate, luck, childbirth, destiny weaver', planet:'Moon', symbol:'Loom, cuckoo bird'},
  {name:'Dievas', tradition:'Baltic', domain:'Sky, supreme god, cosmic order, shining sky', planet:'Sun', symbol:'Sky, light'},
  {name:'Saule', tradition:'Baltic', domain:'Sun goddess, fertility, orphans, weaving', planet:'Sun', symbol:'Sun, spinning wheel'},

  // ========================================================================
  // ETRUSCAN
  // ========================================================================
  {name:'Tinia', tradition:'Etruscan', domain:'Sky, thunder, king of gods (equiv. Zeus/Jupiter)', planet:'Jupiter', symbol:'Thunderbolt, scepter'},
  {name:'Uni', tradition:'Etruscan', domain:'Fertility, queen of gods (equiv. Hera/Juno)', planet:'Venus', symbol:'Diadem'},
  {name:'Menrva', tradition:'Etruscan', domain:'Wisdom, war, arts (equiv. Athena/Minerva)', planet:'Jupiter', symbol:'Owl, spear'},
  {name:'Turan', tradition:'Etruscan', domain:'Love, vitality, beauty (equiv. Aphrodite/Venus)', planet:'Venus', symbol:'Swan, dove, mirror'},
  {name:'Fufluns', tradition:'Etruscan', domain:'Wine, vegetation, festivity (equiv. Dionysus/Bacchus)', planet:'Neptune', symbol:'Ivy, vine'},
  {name:'Vanth', tradition:'Etruscan', domain:'Death, guide of the dead, underworld', planet:'Pluto', symbol:'Torch, key, wings, scroll'},
  {name:'Charun', tradition:'Etruscan', domain:'Death, underworld guardian (equiv. Charon)', planet:'Pluto', symbol:'Hammer, blue skin'},

  // ========================================================================
  // CANAANITE / PHOENICIAN
  // ========================================================================
  {name:'El', tradition:'Canaanite', domain:'Supreme father god, creator, king, bull of heaven', planet:'Saturn', symbol:'Bull, throne'},
  {name:'Baal (Hadad)', tradition:'Canaanite', domain:'Storm, rain, fertility, warrior, lord', planet:'Jupiter', symbol:'Thunderbolt, bull'},
  {name:'Asherah', tradition:'Canaanite', domain:'Mother goddess, sea, fertility, consort of El', planet:'Venus', symbol:'Tree/pole, lions'},
  {name:'Anat', tradition:'Canaanite', domain:'War, hunting, fertility, violence, maiden warrior', planet:'Mars', symbol:'Axe, shield'},
  {name:'Astarte', tradition:'Canaanite', domain:'Love, war, fertility, sexuality, Venus star', planet:'Venus', symbol:'Eight-pointed star, dove'},
  {name:'Mot', tradition:'Canaanite', domain:'Death, underworld, sterility, drought', planet:'Pluto', symbol:'Open jaws, barren land'},
  {name:'Yam', tradition:'Canaanite', domain:'Sea, chaos, rivers, primordial water', planet:'Neptune', symbol:'Sea serpent, waves'},
  {name:'Dagon', tradition:'Canaanite/Philistine', domain:'Grain, agriculture, fertility, fish', planet:'Earth', symbol:'Fish-grain, temple'},
  {name:'Resheph', tradition:'Canaanite', domain:'Plague, war, healing, lightning', planet:'Mars', symbol:'Arrow, shield'},
  {name:'Kothar-wa-Khasis', tradition:'Canaanite', domain:'Crafts, magic, smithing, divine artisan', planet:'Mercury', symbol:'Hammer, forge, bow'},
  {name:'Shapash', tradition:'Canaanite', domain:'Sun, torch of the gods, light', planet:'Sun', symbol:'Sun torch'},
  {name:'Yarikh', tradition:'Canaanite', domain:'Moon, illumination', planet:'Moon', symbol:'Crescent moon'},

  // ========================================================================
  // TIBETAN BON / ADDITIONAL TIBETAN
  // ========================================================================
  {name:'Shenrab Miwoche', tradition:'Tibetan (Bon)', domain:'Founder of Bon, enlightened teacher, the great man', planet:'Sun', symbol:'Swastika (yungdrung), blue garments'},
  {name:'Satrig Ersang', tradition:'Tibetan (Bon)', domain:'Wisdom goddess, great mother of Bon', planet:'Moon', symbol:'Mirror, lamp'},

  // ========================================================================
  // GNOSTIC
  // ========================================================================
  {name:'Sophia', tradition:'Gnostic', domain:'Wisdom, divine feminine, fallen aeon, mother of creation', planet:'Moon', symbol:'Dove, mirror, fallen light'},
  {name:'Abraxas', tradition:'Gnostic', domain:'Cosmic totality, 365 heavens, duality beyond good/evil', planet:'Saturn', symbol:'Rooster head, serpent legs, shield'},
  {name:'Barbelo', tradition:'Gnostic', domain:'First emanation, forethought, divine mother', planet:'Moon', symbol:'Light, mirror'},
  {name:'Yaldabaoth', tradition:'Gnostic', domain:'Demiurge, blind creator, false god, lion-faced serpent', planet:'Saturn', symbol:'Lion face, blindfold, serpent tail'},
  {name:'Christos', tradition:'Gnostic', domain:'Aeon of redemption, divine spark within matter, liberator', planet:'Sun', symbol:'Light, dove, cross of light'},

  // ========================================================================
  // HERMETIC / ALCHEMICAL (Included for L7 relevance)
  // ========================================================================
  {name:'Hermes Trismegistus', tradition:'Hermetic', domain:'Thrice-great, alchemy, astrology, magic, divine wisdom, As Above So Below', planet:'Mercury', symbol:'Caduceus, emerald tablet, three crowns'},
  {name:'Thoth-Hermes', tradition:'Hermetic', domain:'Synthesis of Egyptian Thoth and Greek Hermes, universal wisdom', planet:'Mercury', symbol:'Ibis, caduceus, tablet'},

  // ========================================================================
  // SUMERIAN (Pre-Babylonian specifics)
  // ========================================================================
  {name:'Nammu', tradition:'Sumerian', domain:'Primordial sea, creation, mother of all gods', planet:'Neptune', symbol:'Sea, wavy lines'},
  {name:'An', tradition:'Sumerian', domain:'Sky, heaven, father of gods (precursor to Anu)', planet:'Uranus', symbol:'Horned crown'},
  {name:'Ki', tradition:'Sumerian', domain:'Earth, mother earth, consort of An', planet:'Earth', symbol:'Earth'},
  {name:'Ningal', tradition:'Sumerian', domain:'Reeds, marshes, mother of Shamash/Inanna', planet:'Moon', symbol:'Reeds, cow'},
  {name:'Ningishzida', tradition:'Sumerian', domain:'Underworld, vegetation, serpents, healing', planet:'Pluto', symbol:'Two intertwined serpents'},
  {name:'Geshtinanna', tradition:'Sumerian', domain:'Wine, agriculture, poetry, dream interpretation', planet:'Venus', symbol:'Grapevine'},
  {name:'Nanshe', tradition:'Sumerian', domain:'Social justice, prophecy, dreams, fishing, compassion', planet:'Jupiter', symbol:'Fish, water'},

  // ========================================================================
  // KOREAN
  // ========================================================================
  {name:'Hwanung', tradition:'Korean', domain:'Divine prince, bringer of civilization, wind/rain/clouds', planet:'Jupiter', symbol:'Sacred tree, heavenly seal'},
  {name:'Dangun', tradition:'Korean', domain:'Legendary founder of Korea, mountain god', planet:'Sun', symbol:'Bear, tiger, garlic'},
  {name:'Mago', tradition:'Korean', domain:'Great goddess, creation, cosmic grandmother', planet:'Earth', symbol:'Great mountain, creation'},
  {name:'Habaek', tradition:'Korean', domain:'Water, rivers, dragon king', planet:'Neptune', symbol:'Dragon, river'},
  {name:'Dokkaebi', tradition:'Korean', domain:'Trickster nature spirits, fire, mischief, luck', planet:'Mars', symbol:'Spiked club, horns'},

  // ========================================================================
  // PHILIPPINE
  // ========================================================================
  {name:'Bathala', tradition:'Philippine (Tagalog)', domain:'Supreme creator, sky, lightning, harvest', planet:'Sun', symbol:'Sky, kapok tree'},
  {name:'Mayari', tradition:'Philippine (Tagalog)', domain:'Moon, revolution, beauty, strength, war', planet:'Moon', symbol:'Moon, one eye'},
  {name:'Tala', tradition:'Philippine (Tagalog)', domain:'Morning and evening star, goddess of stars', planet:'Venus', symbol:'Star'},
  {name:'Apolaki', tradition:'Philippine (Tagalog)', domain:'Sun, war, guardianship', planet:'Sun', symbol:'Sun, golden warrior'},
  {name:'Dian Masalanta', tradition:'Philippine (Tagalog)', domain:'Love, childbirth, peace, lovers', planet:'Venus', symbol:'Peace, love'},

  // ========================================================================
  // HAITIAN VODOU (LWA)
  // ========================================================================
  {name:'Papa Legba', tradition:'Haitian Vodou', domain:'Crossroads, communication, gatekeeper between worlds', planet:'Mercury', symbol:'Crossroads, cane, straw hat'},
  {name:'Baron Samedi', tradition:'Haitian Vodou', domain:'Death, resurrection, sexuality, ancestors, the crossroads of death', planet:'Pluto', symbol:'Top hat, skull, cigar, purple/black'},
  {name:'Maman Brigitte', tradition:'Haitian Vodou', domain:'Death, cemeteries, justice, healing, wife of Baron Samedi', planet:'Pluto', symbol:'Black rooster, peppered rum'},
  {name:'Erzulie Freda', tradition:'Haitian Vodou', domain:'Love, beauty, luxury, romance, dreams', planet:'Venus', symbol:'Heart, mirror, pink, jewelry'},
  {name:'Ogou (Ogun)', tradition:'Haitian Vodou', domain:'Iron, war, politics, fire, power', planet:'Mars', symbol:'Machete, iron, rum, fire'},
  {name:'Damballa', tradition:'Haitian Vodou', domain:'Creation, serpent, sky, purity, wisdom', planet:'Jupiter', symbol:'White serpent, egg, rainbow'},
  {name:'Ayida-Weddo', tradition:'Haitian Vodou', domain:'Rainbow, fertility, serpent goddess, wife of Damballa', planet:'Moon', symbol:'Rainbow serpent'},
  {name:'Agwé', tradition:'Haitian Vodou', domain:'Sea, sailors, navigation, fish', planet:'Neptune', symbol:'Boat, fish, shells, blue/white'},
  {name:'Simbi', tradition:'Haitian Vodou', domain:'Magic, rivers, rain, knowledge, herbalism', planet:'Mercury', symbol:'Snake, water, herbs'},
  {name:'Marasa', tradition:'Haitian Vodou', domain:'Twins, children, duality, cosmic balance', planet:'Mercury', symbol:'Twin figures, three plates'},

];

// ============================================================================
// II. HISTORICAL WORLD LEADERS — Organized by Era
// ============================================================================

const PANTHEON_LEADERS = [

  // ========================================================================
  // ANCIENT ERA (~3000 BCE — 500 CE)
  // ========================================================================
  {name:'Gilgamesh', title:'King of Uruk', civilization:'Sumerian', era:'Ancient', years:'c. 2700 BCE', significance:'Semi-legendary king; protagonist of the oldest known epic poem; explored mortality and friendship'},
  {name:'Menes (Narmer)', title:'Pharaoh', civilization:'Egyptian', era:'Ancient', years:'c. 3100 BCE', significance:'United Upper and Lower Egypt; founded the First Dynasty; created Memphis'},
  {name:'Sargon of Akkad', title:'King of Akkad', civilization:'Akkadian/Mesopotamian', era:'Ancient', years:'c. 2334–2279 BCE', significance:'Founded the first known empire in history; unified Mesopotamia'},
  {name:'Hammurabi', title:'King of Babylon', civilization:'Babylonian', era:'Ancient', years:'c. 1792–1750 BCE', significance:'Created the Code of Hammurabi — one of the earliest written legal codes; unified Mesopotamia'},
  {name:'Hatshepsut', title:'Pharaoh', civilization:'Egyptian', era:'Ancient', years:'c. 1478–1458 BCE', significance:'One of the most successful female pharaohs; expanded trade; built Deir el-Bahri temple'},
  {name:'Akhenaten', title:'Pharaoh', civilization:'Egyptian', era:'Ancient', years:'c. 1353–1336 BCE', significance:'Revolutionary monotheist who worshipped Aten alone; moved capital to Amarna'},
  {name:'Ramesses II', title:'Pharaoh', civilization:'Egyptian', era:'Ancient', years:'c. 1279–1213 BCE', significance:'Longest-reigning pharaoh; built Abu Simbel; signed first known peace treaty (with Hittites)'},
  {name:'Tutankhamun', title:'Pharaoh', civilization:'Egyptian', era:'Ancient', years:'c. 1332–1323 BCE', significance:'Restored traditional religion after Akhenaten; famous for intact tomb discovery'},
  {name:'Nebuchadnezzar II', title:'King of Babylon', civilization:'Neo-Babylonian', era:'Ancient', years:'c. 605–562 BCE', significance:'Built Hanging Gardens; destroyed Jerusalem Temple; apex of Babylonian power'},
  {name:'Cyrus the Great', title:'King of Kings', civilization:'Persian (Achaemenid)', era:'Ancient', years:'c. 559–530 BCE', significance:'Founded the Persian Empire; issued first declaration of human rights (Cyrus Cylinder); freed Babylonian captives'},
  {name:'Darius I', title:'King of Kings', civilization:'Persian (Achaemenid)', era:'Ancient', years:'c. 522–486 BCE', significance:'Expanded Persian Empire to its peak; built Persepolis; organized satrapies and the Royal Road'},
  {name:'Pericles', title:'Strategos (First Citizen)', civilization:'Athenian Greek', era:'Ancient', years:'c. 495–429 BCE', significance:'Golden Age of Athens; built Parthenon; championed democracy; patron of arts and philosophy'},
  {name:'Alexander the Great', title:'King of Macedon, Pharaoh of Egypt, King of Persia', civilization:'Macedonian/Greek', era:'Ancient', years:'356–323 BCE', significance:'Conquered the largest empire of the ancient world by age 30; spread Hellenistic culture across three continents'},
  {name:'Chandragupta Maurya', title:'Emperor', civilization:'Indian (Maurya)', era:'Ancient', years:'c. 321–298 BCE', significance:'Founded the Maurya Empire; unified most of the Indian subcontinent'},
  {name:'Ashoka the Great', title:'Emperor', civilization:'Indian (Maurya)', era:'Ancient', years:'c. 268–232 BCE', significance:'Converted to Buddhism after Kalinga War; spread nonviolence; one of India\'s greatest rulers'},
  {name:'Qin Shi Huang', title:'First Emperor', civilization:'Chinese (Qin)', era:'Ancient', years:'259–210 BCE', significance:'Unified China; built the Great Wall; standardized writing, currency, and measurements; buried with terracotta army'},
  {name:'Hannibal Barca', title:'General', civilization:'Carthaginian', era:'Ancient', years:'247–183 BCE', significance:'Crossed the Alps with elephants; nearly conquered Rome; considered one of the greatest military strategists ever'},
  {name:'Julius Caesar', title:'Dictator Perpetuo', civilization:'Roman', era:'Ancient', years:'100–44 BCE', significance:'Conquered Gaul; crossed the Rubicon; transformed Roman Republic; assassinated on the Ides of March'},
  {name:'Cleopatra VII', title:'Pharaoh', civilization:'Egyptian (Ptolemaic)', era:'Ancient', years:'69–30 BCE', significance:'Last active ruler of Ptolemaic Egypt; allied with Caesar and Antony; symbol of intelligence, power, and diplomacy'},
  {name:'Augustus Caesar (Octavian)', title:'First Roman Emperor (Princeps)', civilization:'Roman', era:'Ancient', years:'63 BCE–14 CE', significance:'Founded the Roman Empire; Pax Romana; transformed Rome from republic to empire; longest-reigning Roman emperor'},
  {name:'Marcus Aurelius', title:'Roman Emperor', civilization:'Roman', era:'Ancient', years:'121–180 CE', significance:'Philosopher-king; authored Meditations (Stoic philosophy); last of the Five Good Emperors'},
  {name:'Constantine I', title:'Roman Emperor', civilization:'Roman', era:'Ancient', years:'272–337 CE', significance:'First Christian Roman emperor; founded Constantinople; issued Edict of Milan; convened Council of Nicaea; unified empire under one vision'},
  {name:'Trajan', title:'Roman Emperor', civilization:'Roman', era:'Ancient', years:'53–117 CE', significance:'Expanded Roman Empire to its greatest extent; built Trajan\'s Column and Forum; Optimus Princeps'},
  {name:'Attila', title:'King of the Huns', civilization:'Hunnic', era:'Ancient', years:'c. 406–453 CE', significance:'Scourge of God; terrorized both Roman empires; one of the most feared rulers in European history'},
  {name:'Liu Bang (Emperor Gaozu)', title:'Emperor', civilization:'Chinese (Han)', era:'Ancient', years:'256–195 BCE', significance:'Founded the Han Dynasty; peasant who became emperor; established Confucian state'},
  {name:'Emperor Wu of Han', title:'Emperor', civilization:'Chinese (Han)', era:'Ancient', years:'156–87 BCE', significance:'Expanded Han Empire to Central Asia; established Silk Road trade; promoted Confucianism'},
  {name:'Leonidas I', title:'King of Sparta', civilization:'Greek (Spartan)', era:'Ancient', years:'c. 540–480 BCE', significance:'Led 300 Spartans at Thermopylae against Persian invasion; symbol of ultimate sacrifice'},
  {name:'Solon', title:'Archon', civilization:'Athenian Greek', era:'Ancient', years:'c. 630–560 BCE', significance:'Father of Athenian democracy; constitutional reformer; canceled debts; one of Seven Sages'},
  {name:'Xerxes I', title:'King of Kings', civilization:'Persian (Achaemenid)', era:'Ancient', years:'c. 518–465 BCE', significance:'Invaded Greece with massive army; Battles of Thermopylae and Salamis; completed Persepolis'},

  // ========================================================================
  // MEDIEVAL ERA (500 — 1500 CE)
  // ========================================================================
  {name:'Justinian I', title:'Byzantine Emperor', civilization:'Byzantine/Roman', era:'Medieval', years:'482–565 CE', significance:'Reconquered much of the Western Roman Empire; codified Roman law (Corpus Juris Civilis); built Hagia Sophia'},
  {name:'Muhammad', title:'Prophet and Statesman', civilization:'Arabian/Islamic', era:'Medieval', years:'570–632 CE', significance:'Founded Islam; unified Arabian Peninsula; established the ummah; Quran revealed to him'},
  {name:'Charlemagne', title:'Emperor of the Romans, King of the Franks', civilization:'Frankish/European', era:'Medieval', years:'742–814 CE', significance:'Father of Europe; united Western Europe; Carolingian Renaissance; crowned by the Pope'},
  {name:'Alfred the Great', title:'King of Wessex', civilization:'Anglo-Saxon/English', era:'Medieval', years:'849–899 CE', significance:'Defended England from Vikings; promoted literacy and law; only English king called "the Great"'},
  {name:'Genghis Khan', title:'Great Khan', civilization:'Mongol', era:'Medieval', years:'c. 1162–1227 CE', significance:'Founded largest contiguous land empire in history; united Mongol tribes; Pax Mongolica; reformed Mongol law'},
  {name:'Kublai Khan', title:'Great Khan, Emperor of China (Yuan)', civilization:'Mongol/Chinese', era:'Medieval', years:'1215–1294 CE', significance:'Founded Yuan Dynasty in China; grandson of Genghis Khan; hosted Marco Polo'},
  {name:'Saladin', title:'Sultan', civilization:'Ayyubid (Kurdish/Islamic)', era:'Medieval', years:'1137–1193 CE', significance:'Recaptured Jerusalem from Crusaders; known for chivalry, honor, and mercy even by enemies'},
  {name:'Mansa Musa', title:'Mansa (Emperor)', civilization:'Malian', era:'Medieval', years:'c. 1280–1337 CE', significance:'Richest person in history; pilgrimage to Mecca crashed gold markets; made Timbuktu a center of learning'},
  {name:'Wu Zetian', title:'Empress Regnant', civilization:'Chinese (Tang/Zhou)', era:'Medieval', years:'624–705 CE', significance:'Only woman to rule China as emperor in her own name; expanded Tang territory; promoted Buddhism and meritocracy'},
  {name:'Tamerlane (Timur)', title:'Emir', civilization:'Timurid', era:'Medieval', years:'1336–1405 CE', significance:'Conquered from Anatolia to India; devastating campaigns but also patron of arts; ancestor of Mughals'},
  {name:'Richard I (Lionheart)', title:'King of England', civilization:'English/Plantagenet', era:'Medieval', years:'1157–1199 CE', significance:'Led Third Crusade; famous warrior-king; chivalric legend'},
  {name:'Sundiata Keita', title:'Mansa (Emperor)', civilization:'Malian', era:'Medieval', years:'c. 1217–1255 CE', significance:'Founded the Mali Empire; Lion King of Mali; overcame disability to become conqueror'},
  {name:'William the Conqueror', title:'King of England, Duke of Normandy', civilization:'Norman/English', era:'Medieval', years:'c. 1028–1087 CE', significance:'Won Battle of Hastings 1066; reshaped England; Domesday Book; Norman architecture'},
  {name:'Harun al-Rashid', title:'Caliph', civilization:'Abbasid Caliphate', era:'Medieval', years:'763–809 CE', significance:'Golden Age of the Islamic world; House of Wisdom in Baghdad; patron of arts and sciences; Thousand and One Nights'},
  {name:'Song Taizu (Zhao Kuangyin)', title:'Emperor', civilization:'Chinese (Song)', era:'Medieval', years:'927–976 CE', significance:'Founded the Song Dynasty; reunified China; promoted meritocracy and civil service'},
  {name:'Montezuma II', title:'Huey Tlatoani (Emperor)', civilization:'Aztec', era:'Medieval', years:'c. 1466–1520 CE', significance:'Last independent Aztec emperor; ruled at Spanish contact; oversaw Aztec Empire at its height'},
  {name:'Pachacuti', title:'Sapa Inca (Emperor)', civilization:'Inca', era:'Medieval', years:'c. 1418–1471 CE', significance:'Transformed Cusco kingdom into the vast Inca Empire; built Machu Picchu; great reformer'},

  // ========================================================================
  // RENAISSANCE / EARLY MODERN (1500 — 1800)
  // ========================================================================
  {name:'Elizabeth I', title:'Queen of England', civilization:'English', era:'Renaissance', years:'1533–1603', significance:'Elizabethan Golden Age; defeated the Spanish Armada; patron of Shakespeare; established English Protestantism'},
  {name:'Suleiman the Magnificent', title:'Sultan', civilization:'Ottoman', era:'Renaissance', years:'1494–1566', significance:'Longest-reigning Ottoman sultan; golden age of art, law, architecture; expanded empire across three continents'},
  {name:'Akbar the Great', title:'Mughal Emperor', civilization:'Indian (Mughal)', era:'Renaissance', years:'1542–1605', significance:'Religious tolerance (Din-i-Ilahi); expanded Mughal Empire; patron of arts; abolished Jizya tax'},
  {name:'Tokugawa Ieyasu', title:'Shogun', civilization:'Japanese', era:'Renaissance', years:'1543–1616', significance:'Founded the Tokugawa Shogunate; unified Japan; 250 years of peace (Edo period)'},
  {name:'Peter the Great', title:'Tsar/Emperor', civilization:'Russian', era:'Renaissance', years:'1672–1725', significance:'Modernized and westernized Russia; founded St. Petersburg; created the Russian Empire'},
  {name:'Catherine the Great', title:'Empress', civilization:'Russian', era:'Renaissance', years:'1729–1796', significance:'Expanded Russian Empire; Enlightenment patron; reformed administration; golden age of Russian culture'},
  {name:'Louis XIV', title:'King of France (Sun King)', civilization:'French', era:'Renaissance', years:'1638–1715', significance:'Longest-reigning European monarch (72 years); built Versailles; absolute monarchy; patron of arts'},
  {name:'Henry VIII', title:'King of England', civilization:'English', era:'Renaissance', years:'1491–1547', significance:'Broke from Rome; established Church of England; six wives; transformed English governance'},
  {name:'Ivan IV (the Terrible)', title:'Tsar', civilization:'Russian', era:'Renaissance', years:'1530–1584', significance:'First Tsar of Russia; expanded territory massively; created Oprichnina; complex legacy of reform and terror'},
  {name:'Philip II', title:'King of Spain', civilization:'Spanish', era:'Renaissance', years:'1527–1598', significance:'Ruled the first empire on which the sun never set; Spanish Golden Age; launched the Armada'},
  {name:'Kangxi Emperor', title:'Emperor', civilization:'Chinese (Qing)', era:'Renaissance', years:'1654–1722', significance:'Longest-reigning Chinese emperor (61 years); stabilized Qing rule; patron of learning; expanded borders'},
  {name:'Frederick the Great', title:'King of Prussia', civilization:'Prussian', era:'Renaissance', years:'1712–1786', significance:'Enlightened despot; military genius; patron of arts and Voltaire; made Prussia a European power'},
  {name:'Shaka Zulu', title:'King of the Zulu', civilization:'Zulu', era:'Renaissance', years:'c. 1787–1828', significance:'Transformed Zulu into a military superpower; revolutionary military tactics; reshaped southern Africa'},
  {name:'Nader Shah', title:'Shah', civilization:'Persian (Afsharid)', era:'Renaissance', years:'1688–1747', significance:'Napoleon of Persia; restored Persian power; invaded India; one of the greatest military commanders'},
  {name:'Oda Nobunaga', title:'Daimyo', civilization:'Japanese', era:'Renaissance', years:'1534–1582', significance:'Began the unification of Japan; innovative military tactics; broke feudal samurai power'},
  {name:'Toyotomi Hideyoshi', title:'Imperial Regent', civilization:'Japanese', era:'Renaissance', years:'1537–1598', significance:'Peasant who became ruler of all Japan; continued unification; invaded Korea'},
  {name:'George Washington', title:'1st President', civilization:'American', era:'Renaissance', years:'1732–1799', significance:'Led American Revolution; first President of the United States; voluntary transfer of power; Father of the Nation'},
  {name:'Benjamin Franklin', title:'Statesman/Polymath', civilization:'American', era:'Renaissance', years:'1706–1790', significance:'Founding Father; ambassador to France; scientist; inventor; shaped the Constitution'},

  // ========================================================================
  // MODERN ERA (1800 — Present)
  // ========================================================================
  {name:'Napoleon Bonaparte', title:'Emperor of the French', civilization:'French', era:'Modern', years:'1769–1821', significance:'Conquered most of Europe; Napoleonic Code (foundation of civil law worldwide); reshaped the political map of Europe'},
  {name:'Simón Bolívar', title:'Liberator', civilization:'South American', era:'Modern', years:'1783–1830', significance:'Liberated six nations from Spanish rule; dreamed of a united South America; the George Washington of South America'},
  {name:'Abraham Lincoln', title:'16th President', civilization:'American', era:'Modern', years:'1809–1865', significance:'Preserved the Union; abolished slavery (Emancipation Proclamation, 13th Amendment); assassinated at Ford\'s Theatre'},
  {name:'Queen Victoria', title:'Queen of the United Kingdom, Empress of India', civilization:'British', era:'Modern', years:'1819–1901', significance:'Victorian Era; British Empire at its peak; longest-reigning British monarch until Elizabeth II; industrial revolution'},
  {name:'Otto von Bismarck', title:'Chancellor', civilization:'Prussian/German', era:'Modern', years:'1815–1898', significance:'Unified Germany through "blood and iron"; master diplomat; created the modern German state'},
  {name:'Meiji Emperor', title:'Emperor', civilization:'Japanese', era:'Modern', years:'1852–1912', significance:'Meiji Restoration; transformed Japan from feudal isolationism to modern industrial world power in one generation'},
  {name:'Mahatma Gandhi', title:'Father of the Nation', civilization:'Indian', era:'Modern', years:'1869–1948', significance:'Led India to independence through nonviolent resistance; inspired civil rights movements worldwide; satyagraha'},
  {name:'Mustafa Kemal Atatürk', title:'President', civilization:'Turkish', era:'Modern', years:'1881–1938', significance:'Founded the Republic of Turkey from Ottoman ruins; secular reforms; modernized Turkish society'},
  {name:'Winston Churchill', title:'Prime Minister', civilization:'British', era:'Modern', years:'1874–1965', significance:'Led Britain through WWII; "We shall fight on the beaches"; Nobel Prize in Literature; symbol of resistance'},
  {name:'Franklin D. Roosevelt', title:'32nd President', civilization:'American', era:'Modern', years:'1882–1945', significance:'Led US through Great Depression and WWII; New Deal; only president elected four times'},
  {name:'Mao Zedong', title:'Chairman', civilization:'Chinese', era:'Modern', years:'1893–1976', significance:'Founded People\'s Republic of China; Long March; Cultural Revolution; reshaped China completely'},
  {name:'Nelson Mandela', title:'President', civilization:'South African', era:'Modern', years:'1918–2013', significance:'27 years imprisoned; ended apartheid; first Black president of South Africa; symbol of reconciliation and forgiveness'},
  {name:'Martin Luther King Jr.', title:'Civil Rights Leader', civilization:'American', era:'Modern', years:'1929–1968', significance:'Led American civil rights movement; "I Have a Dream"; Nobel Peace Prize; nonviolent resistance'},
  {name:'Jawaharlal Nehru', title:'Prime Minister', civilization:'Indian', era:'Modern', years:'1889–1964', significance:'First PM of independent India; architect of modern Indian democracy; Non-Aligned Movement'},
  {name:'Charles de Gaulle', title:'President', civilization:'French', era:'Modern', years:'1890–1970', significance:'Led Free France in WWII; founded Fifth Republic; restored French grandeur; decolonization'},
  {name:'Haile Selassie', title:'Emperor', civilization:'Ethiopian', era:'Modern', years:'1892–1975', significance:'Last emperor of Ethiopia; resisted Italian invasion; founder of OAU; revered as divine in Rastafari'},
  {name:'David Ben-Gurion', title:'Prime Minister', civilization:'Israeli', era:'Modern', years:'1886–1973', significance:'Declared Israeli independence in 1948; founding father; shaped the modern state of Israel'},
  {name:'Kwame Nkrumah', title:'President', civilization:'Ghanaian', era:'Modern', years:'1909–1972', significance:'Led Ghana to independence (first sub-Saharan African nation); Pan-Africanism; vision of united Africa'},
  {name:'Lee Kuan Yew', title:'Prime Minister', civilization:'Singaporean', era:'Modern', years:'1923–2015', significance:'Transformed Singapore from third-world to first-world in one generation; master statesman'},
  {name:'Deng Xiaoping', title:'Paramount Leader', civilization:'Chinese', era:'Modern', years:'1904–1997', significance:'Opened China to market economy; Special Economic Zones; lifted hundreds of millions from poverty'},
  {name:'Mikhail Gorbachev', title:'General Secretary / President', civilization:'Soviet/Russian', era:'Modern', years:'1931–2022', significance:'Glasnost and Perestroika; ended the Cold War; Nobel Peace Prize; dissolution of Soviet Union'},
  {name:'Cleopatra (modern influence note)', title:'Pharaoh', civilization:'Egyptian (Ptolemaic)', era:'Ancient', years:'69–30 BCE', significance:'Listed in Ancient era above — her influence echoes through all subsequent history'},

  // ========================================================================
  // PHILOSOPHICAL / SPIRITUAL LEADERS (Civilization Shapers)
  // ========================================================================
  {name:'Confucius (Kong Qiu)', title:'Philosopher', civilization:'Chinese', era:'Ancient', years:'551–479 BCE', significance:'Founded Confucianism; shaped Chinese civilization for 2500+ years; ethics, governance, social harmony'},
  {name:'Laozi', title:'Philosopher', civilization:'Chinese', era:'Ancient', years:'c. 6th century BCE', significance:'Founded Daoism; authored Tao Te Ching; the Way that cannot be named; wu wei (non-action)'},
  {name:'Siddhartha Gautama (Buddha)', title:'The Awakened One', civilization:'Indian', era:'Ancient', years:'c. 563–483 BCE', significance:'Founded Buddhism; Four Noble Truths; Eightfold Path; Middle Way; influenced billions'},
  {name:'Socrates', title:'Philosopher', civilization:'Greek', era:'Ancient', years:'470–399 BCE', significance:'Father of Western philosophy; Socratic method; "I know that I know nothing"; died for his principles'},
  {name:'Plato', title:'Philosopher', civilization:'Greek', era:'Ancient', years:'428–348 BCE', significance:'Founded the Academy; Theory of Forms; The Republic; teacher of Aristotle; shaped all Western thought'},
  {name:'Aristotle', title:'Philosopher', civilization:'Greek', era:'Ancient', years:'384–322 BCE', significance:'Founded the Lyceum; logic, metaphysics, ethics, biology, politics; tutor of Alexander; "the master of those who know"'},
  {name:'Jesus of Nazareth', title:'Christ / Messiah', civilization:'Judean/Universal', era:'Ancient', years:'c. 4 BCE–33 CE', significance:'Central figure of Christianity; teachings of love, forgiveness, salvation; most influential figure in Western history'},
  {name:'Zoroaster (Zarathustra)', title:'Prophet', civilization:'Persian', era:'Ancient', years:'c. 1500–500 BCE (debated)', significance:'Founded Zoroastrianism; cosmic dualism; influenced Judaism, Christianity, Islam; first monotheistic-leaning prophet'},
  {name:'Moses', title:'Prophet / Lawgiver', civilization:'Hebrew/Israelite', era:'Ancient', years:'c. 1391–1271 BCE (traditional)', significance:'Led Exodus from Egypt; received the Ten Commandments; foundational figure of Judaism, Christianity, Islam'},
  {name:'Solomon', title:'King', civilization:'Israelite', era:'Ancient', years:'c. 970–931 BCE', significance:'Built the First Temple; legendary wisdom; united kingdom\'s golden age; Song of Solomon, Proverbs'},

];

// ============================================================================
// III. EXPORT / SUMMARY
// ============================================================================

const PANTHEON_SUMMARY = {
  totalGods: PANTHEON_GODS.length,
  totalLeaders: PANTHEON_LEADERS.length,
  traditions: [...new Set(PANTHEON_GODS.map(g => g.tradition))].sort(),
  eras: [...new Set(PANTHEON_LEADERS.map(l => l.era))],
  generatedDate: '2026-03-09',
  generatedFor: 'L7 WAY — The Universal Operating System',
  note: 'Planetary correspondences follow Western esoteric tradition (Hermetic/alchemical). Where no historical correspondence exists, assignments reflect the deity\'s primary domain mapped to the seven classical planets plus Uranus, Neptune, and Pluto. Hindu navagraha correspondences are noted where applicable.'
};

// For Node.js / CommonJS
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { PANTHEON_GODS, PANTHEON_LEADERS, PANTHEON_SUMMARY };
}

// For browser / HTML embedding
if (typeof window !== 'undefined') {
  window.PANTHEON_GODS = PANTHEON_GODS;
  window.PANTHEON_LEADERS = PANTHEON_LEADERS;
  window.PANTHEON_SUMMARY = PANTHEON_SUMMARY;
}
