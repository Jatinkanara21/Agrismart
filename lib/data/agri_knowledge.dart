/// Original AgriSmart knowledge layer.
///
/// The explanations below are written specifically for AgriSmart. Numeric
/// recommendations are intentionally kept as ranges or decision rules unless
/// a crop/soil/location-specific official recommendation is available.
///
/// Primary references used while curating this layer:
/// - ICAR crop science and agro-advisories: https://icar.gov.in/
/// - IMD location-specific agro-advisory: https://webgis.imd.gov.in/agro/
/// - Soil Health Card parameters: https://soilhealth.dac.gov.in/
/// - PM-KISAN official portal: https://pmkisan.gov.in/
/// - AGMARKNET market data: https://agmarknet.gov.in/

class CropKnowledge {
  const CropKnowledge({
    required this.name,
    required this.seasons,
    required this.soil,
    required this.waterNeed,
    required this.stagePlan,
    required this.riskSignals,
    required this.farmerTip,
  });

  final String name;
  final List<String> seasons;
  final List<String> soil;
  final String waterNeed;
  final List<String> stagePlan;
  final List<String> riskSignals;
  final String farmerTip;
}

class SchemeKnowledge {
  const SchemeKnowledge({
    required this.name,
    required this.summary,
    required this.eligibility,
    required this.action,
    required this.officialUrl,
    required this.verifiedOn,
  });

  final String name;
  final String summary;
  final String eligibility;
  final String action;
  final String officialUrl;
  final String verifiedOn;
}

class AgriKnowledge {
  static const sourceNote =
      'Agricultural guidance is decision support. Verify crop-, soil-, and locality-specific recommendations with a soil test, KVK/agriculture officer, or the cited official source.';

  static const crops = <CropKnowledge>[
    CropKnowledge(
      name: 'Wheat',
      seasons: ['Rabi'],
      soil: ['Loam', 'Sandy loam', 'Well-drained clay loam'],
      waterNeed: 'Moderate; protect the crop from moisture stress around critical growth stages.',
      stagePlan: [
        'Sowing: use locally recommended variety and a clean, treated seed lot.',
        'Tillering: monitor moisture and weeds; avoid blanket fertilizer application.',
        'Booting/flowering: protect against moisture stress and weather extremes.',
        'Grain filling: watch disease, lodging and irrigation need before harvest.',
      ],
      riskSignals: [
        'Sudden temperature rise during reproductive growth',
        'Standing water or poor drainage',
        'Yellowing that follows irregular irrigation or nutrient imbalance',
      ],
      farmerTip: 'Use soil-test information before deciding on nitrogen or other nutrient top-ups.',
    ),
    CropKnowledge(
      name: 'Rice',
      seasons: ['Kharif', 'Summer in suitable irrigated areas'],
      soil: ['Clay loam', 'Clay', 'Fields with dependable water supply'],
      waterNeed: 'High compared with most dryland crops; irrigation decisions should follow field condition and local advisory.',
      stagePlan: [
        'Nursery/transplanting: establish an even stand and avoid unnecessary plant shock.',
        'Vegetative growth: control weeds and monitor nutrient balance.',
        'Panicle initiation: prioritize timely moisture management.',
        'Grain filling: monitor pests, disease and storm/rain risk before harvest.',
      ],
      riskSignals: [
        'Extended water deficit during reproductive stages',
        'Excess standing water combined with disease pressure',
        'High humidity with prolonged leaf wetness',
      ],
      farmerTip: 'Use the IMD agro-advisory layer for location and crop-stage specific weather actions.',
    ),
    CropKnowledge(
      name: 'Groundnut',
      seasons: ['Kharif', 'Summer in suitable irrigated zones'],
      soil: ['Well-drained sandy loam', 'Loam'],
      waterNeed: 'Moderate; avoid waterlogging and manage moisture consistently around flowering and pod development.',
      stagePlan: [
        'Establishment: use well-drained soil and healthy seed.',
        'Vegetative stage: keep weeds under control and monitor nutrient status.',
        'Flowering/pegging: maintain suitable moisture without prolonged saturation.',
        'Pod development: inspect for leaf disease and weather-related harvest risk.',
      ],
      riskSignals: [
        'Waterlogging after heavy rain',
        'Leaf spot or rust under warm, humid conditions',
        'Sudden moisture stress around pod formation',
      ],
      farmerTip: 'ICAR advisories emphasize balanced nutrition and crop-protection monitoring for groundnut.',
    ),
    CropKnowledge(
      name: 'Soybean',
      seasons: ['Kharif'],
      soil: ['Well-drained loam', 'Sandy loam'],
      waterNeed: 'Moderate; avoid saline/alkaline conditions and prolonged waterlogging.',
      stagePlan: [
        'Sowing: use locally recommended seed and correct inoculation where advised.',
        'Vegetative growth: maintain weed control and scout for sucking pests.',
        'Flowering/pod set: monitor moisture, rust and leaf-spot pressure.',
        'Maturity: reduce unnecessary irrigation and plan harvest around weather windows.',
      ],
      riskSignals: [
        'Poor drainage or prolonged saturation',
        'High humidity with persistent leaf wetness',
        'Defoliator or sucking-pest increase',
      ],
      farmerTip: 'Use a soil-test-based nutrient plan instead of repeating the same fertilizer dose every season.',
    ),
    CropKnowledge(
      name: 'Cotton',
      seasons: ['Kharif'],
      soil: ['Well-drained loam', 'Sandy loam', 'Deep black soils where locally suitable'],
      waterNeed: 'Moderate to high depending on climate, soil and irrigation system.',
      stagePlan: [
        'Establishment: maintain uniform stand and drainage.',
        'Vegetative growth: scout regularly for sucking pests.',
        'Flowering/boll formation: protect moisture balance and monitor boll pests.',
        'Boll opening: avoid unnecessary irrigation and plan picking around dry weather.',
      ],
      riskSignals: [
        'Persistent humidity around dense canopy',
        'Rapid increase in sucking pests or boll damage',
        'Waterlogging following heavy rainfall',
      ],
      farmerTip: 'For Gujarat conditions, choose a variety and planting window using the local agriculture/KVK advisory rather than a national calendar alone.',
    ),
    CropKnowledge(
      name: 'Pearl Millet',
      seasons: ['Kharif'],
      soil: ['Sandy loam', 'Light loam', 'Well-drained soils'],
      waterNeed: 'Low to moderate and relatively drought-tolerant once established.',
      stagePlan: [
        'Establishment: secure a uniform plant stand before severe moisture stress.',
        'Tillering: maintain weed-free growth and monitor nutrient balance.',
        'Flowering: protect from severe moisture stress and heat spikes.',
        'Grain filling: monitor bird pressure and lodging before harvest.',
      ],
      riskSignals: [
        'Long dry spell during establishment',
        'Severe heat around flowering',
        'Poor drainage after intense rainfall',
      ],
      farmerTip: 'Millet can be a useful diversification option where rainfall is uncertain and soils drain quickly.',
    ),
  ];

  static const soilParameters = <String>[
    'Nitrogen (N)',
    'Phosphorus (P)',
    'Potassium (K)',
    'Sulphur (S)',
    'Zinc (Zn)',
    'Iron (Fe)',
    'Copper (Cu)',
    'Manganese (Mn)',
    'Boron (B)',
    'pH',
    'Electrical Conductivity (EC)',
    'Organic Carbon (OC)',
  ];

  static const schemes = <SchemeKnowledge>[
    SchemeKnowledge(
      name: 'PM-KISAN Samman Nidhi',
      summary: 'Central income-support scheme for eligible landholding farmer families.',
      eligibility: 'Eligibility and exclusion rules are applied under the official PM-KISAN guidelines and verified by the State/UT administration.',
      action: 'Check Know Your Status and complete mandatory eKYC on the official portal.',
      officialUrl: 'https://pmkisan.gov.in/',
      verifiedOn: '2026-08-24',
    ),
    SchemeKnowledge(
      name: 'Soil Health Card',
      summary: 'Provides a soil nutrient assessment and field-level fertilizer/soil-amendment guidance.',
      eligibility: 'Available through the government soil testing system for farm holdings; access routes vary by state.',
      action: 'Obtain or update a soil test before making major fertilizer changes.',
      officialUrl: 'https://soilhealth.dac.gov.in/',
      verifiedOn: '2026-08-24',
    ),
  ];

  static const officialSources = <String, String>{
    'ICAR': 'https://icar.gov.in/',
    'IMD Agro-Advisory': 'https://webgis.imd.gov.in/agro/',
    'Soil Health Card': 'https://soilhealth.dac.gov.in/',
    'PM-KISAN': 'https://pmkisan.gov.in/',
    'AGMARKNET': 'https://agmarknet.gov.in/',
  };

  static CropKnowledge? byName(String name) {
    for (final crop in crops) {
      if (crop.name.toLowerCase() == name.toLowerCase()) return crop;
    }
    return null;
  }
}
