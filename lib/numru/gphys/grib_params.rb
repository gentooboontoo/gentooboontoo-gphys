CENTERS = {
  0 => "Not defined",
  7 => "US Weather Service - National Met. Center",
  8 => "US Weather Service - NWS Telecomms Gateway",
  9 => "US Weather Service - Field Stations",
  34 => "Japanese Meteorological Agency - Tokyo",
  52 => "National Hurricane Center, Miami",
  54 => "Canadian Meteorological Service - Montreal",
  57 => "U.S. Air Force - Global Weather Center",
  58 => "US Navy - Fleet Numerical Oceanography Center",
  59 => "NOAA Forecast Systems Lab, Boulder CO",
  74 => "U.K. Met Office - Bracknell",
  85 => "French Weather Service - Toulouse",
  97 => "European Space Agency (ESA)",
  98 => "European Center for Medium-Range Weather Forecasts - Reading",
  99 => "DeBilt, Netherlands"
}
GRIDS = {
  21 => [ [5.0,2.5], [[0,180],[0,90]], [[37],[36,"pole"]], 1333],
  22 => [ [5.0,2.5], [[-180,0],[0,90]], [[37],[36,"pole"]], 1333],
  23 => [ [5.0,2.5], [[0,180], [-90,0]], [["pole",37],[36]], 1333],
  24 => [ [5.0,2.5], [[-180,0],[-90,0]], [["pole",37],[36]], 1333],
  25 => [ [5.0,5.0], [[0,355],[0,90]], [[72],[18,"pole"]], 1297], 
  26 => [ [5.0,5.0], [[0,355],[-90,0]], [["pole",72],[18]], 1297],
  61 => [ [2.0,2.0], [[0,180],[0,90]], [[91],[45,"pole"]], 4096],
  62 => [ [2.0,2.0], [[-180,0],[0,90]], [[91],[45,"pole"]], 4096],
      63 => [ [2.0,2.0], [[0,180],[-90,0]], [["pole",91],[45]], 4096],
  64 => [ [2.0,2.0], [[-180,0],[-90,0]], [["pole",91],[45]], 4096],
  255 => [ nil, nil, nil,  nil]
}
GRID_TYPES = {
  0 => "Latitude/Longitude Grid also called Equidistant Cylindrical or Plate Carree projection grid",
  1 => "Mercator Projection Grid",
  2 => "Gnomonic Projection Grid",
  3 => "Lambert Conformal, secant or tangent, conical or bipolar (normal or oblique) Projection Grid",
  4 => "Gaussian Latitude/Longitude Grid",
  5 => "Polar Stereographic Projection Grid",
  13 => "Oblique Lambert conformal, secant or tangent, conical or bipolar, projection",
  50 => "Spherical Harmonic Coefficients",
  90 => "Space view perspective or orthographic grid"
}
Z_TYPES = {
  1 => ["surface (of the Earth, which includes sea surface)", "sfc"],
  2 => ["cloud base level", "clbs"],
  3 => ["cloud top level", "cltp"],
  4 => ["0 deg (C) isotherm level", "frzlvl"],
  5 => ["adiabatic condensation level(parcel lifted from surface)", "adcn"],
  6 => ["maximum wind speed level", "maxwind"],
  7 => ["tropopause level", "trop"],
  8 => ["Nominal top of atmosphere", "topa"],
  9 => ["Sea bottom", "sbot"],
  20 => ["isothermal level", "isot"],
  100 => ["isobaric level", "level"],
  101 => ["layer between two isobaric levels", "liso"],
  102 => ["mean sea level", "msl"],
  103 => ["fixed height level", "fh"],
  104 => ["layer between two height levels above msl", "lfhm"],
  105 => ["fixed height above ground", "fhg"],
  106 => ["layer between two height levels above ground", "lfhg"],
  107 => ["sigma level", "sigma"],
  108 => ["layer between two sigma levels", "ls"],
  109 => ["Hybrid level", "hybr"],
  110 => ["layer between two hybrid levels", "lhyb"],
  111 => ["depth below land surface", "bls"],
  112 => ["layer between two depths below land surface", "lbls"],
  113 => ["isentropic (theta) level", "isen"],
  114 => ["layer between two isentropic levels", "lisn"],
  116 => ["layer between two isobaric surfaces above ground", "lisg"],
  117 => ["potential vorticity surface", "pvs"],
  119 => ["ETA level", "eta"],
  120 => ["layer between two ETA levels", "leta"],
  121 => ["layer between two isobaric surfaces (high precision)", "lish"],
  125 => ["Height level above ground (heigh precision)", "fhgh"],
  128 => ["layer between two sigma levels (high precision)", "lsh"],
  141 => ["layer between two isobaric surfaces (mixed precision)", "lism"],
  160 => ["depth below sea level", "dbs"],
  200 => ["entire atmosphere considered as a single layer", "atm"],
  201 => ["entire ocean considered as single layer", "ocn"],
  204 => ["highest tropospheric freezing level", "htfl"],
  212 => ["low cloud bottom", "lcb"],
  213 => ["low cloud top", "lct"],
  214 => ["low cloud layer", "lcl"],
  222 => ["middle cloud bottom", "mcb"],
  223 => ["middle cloud top", "mct"],
  224 => ["middle cloud layer", "mcl"],
  232 => ["high cloud bottom", "hcb"],
  233 => ["high cloud top", "hct"],
  234 => ["high cloud layer", "hcl"],
  242 => ["convect cloud bottom", "ccb"],
  243 => ["convect cloud top", "cct"],
  244 => ["convect cloud layer", "ccl"],
  246 => ["maximum equivalent potential temperature pressure", "meptp"],
  247 => ["equilibrium level height", "elh"],
}
Z_LEVELS = {
  100 => [{"name"=>"pressure","units"=>"hPa"}],
  101 => [{"name"=>"pressure of top","units"=>"kPa"},
    {"name"=>"pressure of botton","units"=>"kPa"}],
  103 => [{"name"=>"height above MSL","units"=>"m"}],
  104 => [{"name"=>"height of top above MSL","units"=>"hm"},
    {"name"=>"height of bottom above MSL","units"=>"hm"}],
  105 => [{"name"=>"height","units"=>"m"}],
  106 => [{"name"=>"height of top above ground","units"=>"hm"},
    {"name"=>"height of bottom above ground","units"=>"hm"}],
  107 => [{"name"=>"sigma value","units"=>"1/10000"}],
  108 => [{"name"=>"sigma value at top","units"=>"1/100"},
    {"name"=>"sigma value at bottom","units"=>"1/100"}],
  109 => [{"name"=>"level number"}],
  110 => [{"name"=>"level number of top"},
    {"name"=>"level number of bottom"}],
  111 => [{"name"=>"depth","units"=>"cm"}],
  112 => [{"name"=>"depth of upper surface","units"=>"cm"},
    {"name"=>"depth of lower surface","units"=>"cm"}],
  113 => [{"name"=>"potential temperature","units"=>"K"}],
  114 => [{"name"=>"475K minus theta of top","units"=>"K"},
    {"name"=>"475K minus theta of bottom","units"=>"K"}],
  116 => [{"name"=>"pressure of top above ground", "units"=>"hPa"},
    {"name"=>"pressure of bottom above ground", "units"=>"hPa"}],
  117 => [{"name"=>"PV unit", "units"=>"1/1000000Km2/kg/s"}],
  119 => [{"name"=>"ETA value", "units"=>"1/10000"}],
  120 => [{"name"=>"ETA level of top", "units"=>"1/100"},
    {"name"=>"ETA level of bottom", "units"=>"1/100"}],
  121 => [{"name="=>"1100hPa minus pressure of top","units"=>"hPa"},
    {"name"=>"1100hPa minus pressure of bottom","units"=>"hPa"}],
  125 => [{"name"=>"height","units"=>"cm"}],
  128 => [{"name"=>"1.1 minus sigma of top","units"=>"1/1000"},
    {"name"=>"1.1 minus sigma of bottom","units"=>"1/1000"}],
  141 => [{"name"=>"pressure of top","units"=>"kPa"},
    {"name"=>"pressure of bottom","units"=>"kPa"}],
  160 => [{"name"=>"depth","units"=>"m"}],
}
TIME_UNITS = {
  0 => "minute",
  1 => "hour",
  2 => "day",
  3 => "month",
  4 => "year",
  5 => "decade",
  6 => "normal (30 years)",
  7 => "century",
  254 => "second"
}
D19000101 = Date.new(1900,1,1)


## Paramete Constants
PARAM_UNKNOWN = 0
PARAM_PRESSURE = 1
PARAM_PMSL = 2
PARAM_PTND = 3
#PARAM_ICAHT = 4
# 5
PARAM_GPT = 6
PARAM_GPT_HGT = 7
PARAM_GEOM_HGT = 8
PARAM_HSTDV = 9
PARAM_TOZNE = 10
PARAM_TEMP = 11
PARAM_VTEMP = 12
PARAM_POT_TEMP = 13
PARAM_APOT_TEMP = 14
PARAM_MAX_TEMP = 15
PARAM_MIN_TEMP = 16
PARAM_DP_TEMP = 17
PARAM_DP_DEP = 18
PARAM_LAPSE = 19
PARAM_VIS = 20
PARAM_RAD1 = 21
PARAM_RAD2 = 22
PARAM_RAD3 = 23
#PARAM_PLI = 24
PARAM_TANOM = 25
PARAM_PANOM = 26
PARAM_ZANOM = 27
PARAM_WAV1 = 28
PARAM_WAV2 = 29
PARAM_WAV3 = 30
PARAM_WND_DIR = 31
PARAM_WND_SPEED = 32
PARAM_U_WIND = 33
PARAM_V_WIND = 34
PARAM_STRM_FUNC = 35
PARAM_VPOT = 36
PARAM_MNTSF = 37
PARAM_SIG_VEL = 38
PARAM_VERT_VEL = 39
PARAM_GEOM_VEL = 40
PARAM_ABS_VOR = 41
PARAM_ABS_DIV = 42
PARAM_REL_VOR = 43
PARAM_REL_DIV = 44
PARAM_U_SHR = 45
PARAM_V_SHR = 46
PARAM_CRNT_DIR = 47
PARAM_CRNT_SPD = 48
PARAM_U_CRNT = 49
PARAM_V_CRNT = 50
PARAM_SPEC_HUM = 51
PARAM_REL_HUM = 52
PARAM_HUM_MIX = 53
PARAM_PR_WATER = 54
PARAM_VAP_PR = 55
PARAM_SAT_DEF = 56
PARAM_EVAP = 57
PARAM_C_ICE = 58
PARAM_PRECIP_RT = 59
PARAM_THND_PROB = 60
PARAM_PRECIP_TOT = 61
PARAM_PRECIP_LS = 62
PARAM_PRECIP_CN = 63
PARAM_SNOW_RT = 64
PARAM_SNOW_WAT = 65
PARAM_SNOW = 66
PARAM_MIXED_DPTH = 67
PARAM_TT_DEPTH = 68
PARAM_MT_DEPTH = 69
PARAM_MTD_ANOM = 70
PARAM_CLOUD = 71
PARAM_CLOUD_CN = 72
PARAM_CLOUD_LOW = 73
PARAM_CLOUD_MED = 74
PARAM_CLOUD_HI = 75
PARAM_CLOUD_WAT = 76
#PARAM_BLI = 77
PARAM_SNO_C = 78
PARAM_SNO_L = 79
PARAM_SEA_TEMP = 80
PARAM_LAND_MASK = 81
PARAM_SEA_MEAN = 82
PARAM_SRF_RN = 83
PARAM_ALBEDO = 84
PARAM_SOIL_TEMP = 85
PARAM_SOIL_MST = 86
PARAM_VEG = 87
PARAM_SAL = 88
PARAM_DENS = 89
PARAM_WATR = 90
PARAM_ICE_CONC = 91
PARAM_ICE_THICK = 92
PARAM_ICE_DIR = 93
PARAM_ICE_SPD = 94
PARAM_ICE_U = 95
PARAM_ICE_V = 96
PARAM_ICE_GROWTH = 97
PARAM_ICE_DIV = 98
PARAM_SNO_M = 99
PARAM_WAVE_HGT = 100
PARAM_SEA_DIR = 101
PARAM_SEA_HGT = 102
PARAM_SEA_PER = 103
PARAM_SWELL_DIR = 104
PARAM_SWELL_HGT = 105
PARAM_SWELL_PER = 106
PARAM_WAVE_DIR = 107
PARAM_WAVE_PER = 108
PARAM_WAVE2_DIR = 109
PARAM_WAVE2_PER = 110
PARAM_RDN_SWSRF = 111
PARAM_RDN_LWSRF = 112
PARAM_RDN_SWTOP = 113
PARAM_RDN_LWTOP = 114
PARAM_RDN_LW = 115
PARAM_RDN_SW = 116
PARAM_RDN_GLBL = 117
#PARAM_BRTMP = 118
#PARAM_LWRAD = 119
#PARAM_SWRAD = 120
PARAM_LAT_HT = 121
PARAM_SEN_HT = 122
PARAM_BL_DISS = 123
PARAM_U_FLX = 124
PARAM_V_FLX = 125
PARAM_WMIXE = 126
PARAM_IMAGE = 127


## GRIB EDITION 0
PARAM_VERT_SHR = 1000
PARAM_CON_PRECIP = 1001
PARAM_PRECIP = 1002
PARAM_NCON_PRECIP = 1003
PARAM_SST_WARM = 1004
PARAM_UND_ANOM = 1005
PARAM_SEA_TEMP_0 = 1006
PARAM_PRESSURE_D = 1007
PARAM_GPT_THICK = 1008
PARAM_GPT_HGT_D = 1009
PARAM_GEOM_HGT_D = 1010
PARAM_TEMP_D = 1011
PARAM_REL_HUM_D = 1012
PARAM_LIFT_INDX = 1013
PARAM_LIFT_INDX4 = 1014
PARAM_LIFT_INDX_D = 1015
PARAM_REL_VOR_D = 1016
PARAM_ABS_VOR_D = 1017
PARAM_VERT_VEL_D = 1018
PARAM_SEA_TEMP_D = 1019
PARAM_SST_ANOM = 1020
PARAM_QUAL_IND = 1021
PARAM_GPT_DEP = 1022
PARAM_PRESSURE_DEP = 1023
PARAM_LAST_ENTRY = 1024
PARAM_LN_PRES = 1025

## NCEP
PARAM_LFT_X = 2131
PARAM_4LFTX = 2132
PARAM_VW_SH = 2136
PARAM_SOILW = 2144
PARAM_CLWMR = 2153
PARAM_O3MR = 2154
PARAM_CIN = 2156
PARAM_CAPE = 2157
PARAM_HPBL = 2221
PARAM_5WAVH = 2222
PARAM_5WAVA = 2230

## ECMWF 128
PARAM_EQPT_TEMP = 3004
PARAM_SEPT_TEMP = 3005
PARAM_U_DIV_WND = 3011
PARAM_V_DIV_WND = 3012
PARAM_U_ROT_WND = 3013
PARAM_V_ROT_WND = 3014
PARAM_UBC_TEMP = 3021
PARAM_UB_PRES = 3022
PARAM_UB_DIV = 3023
PARAM_LAKE_COV = 3026
PARAM_LVEG_COV = 3027
PARAM_HVEG_COV = 3028
PARAM_TYP_LVEG = 3029
PARAM_TYP_HVEG = 3030
PARAM_ICE_COV = 3031
PARAM_SNOW_ALBD = 3032
PARAM_SNOW_DENS = 3033
PARAM_SEASRF_TEMP = 3034
PARAM_ICESRF_TEMP = 3035
PARAM_SOIL_WATER = 3039
PARAM_TYP_SOIL = 3043
PARAM_SNOW_EVAP = 3044

PARAM_SOL_DUR = 3045
PARAM_RND_SOL_DIR = 3047
PARAM_STRESS_SRF = 3048
PARAM_WNDGUST = 3049
PARAM_PRECIP_LS_FRAC = 3050

PARAM_MNTPOT = 3053

PARAM_POT_VOR = 3060

PARAM_ATM_TIDE = 3127
PARAM_BUDG_VAL = 3128

PARAM_WATER_TOT = 3136
PARAM_WATV_TOT = 3137

PARAM_SOIL_WET = 3140

PARAM_SNOW_FALL = 3144

PARAM_CHNK = 3148
PARAM_RDN_SRF = 3149
PARAM_RDN_TOP = 3150

PARAM_HT_SW = 3153
PARAM_HT_LW = 3154

PARAM_BL_HGT = 3159
PARAM_ORG_STDV = 3160
PARAM_SGORG_ANIS = 3161
PARAM_SGORG_ANGL = 3162
PARAM_SGORG_SLOP = 3163

PARAM_RND_SOL_SRFD = 3169

PARAM_ALBEDO_F = 3174
PARAM_RDN_THE_SRFD = 3175
PARAM_RDN_SOL_SRF = 3176
PARAM_RDN_THE_SRF = 3177
PARAM_RDN_SOL_TOP = 3178
PARAM_RDN_THE_TOP = 3179
PARAM_STRESS_EW_SRF = 3180
PARAM_STRESS_NS_SRF = 3181

PARAM_SUN_DUR = 3189
PARAM_ORG_EW_VARI = 3190
PARAM_ORG_NS_VARI = 3191
PARAM_ORG_NWSE_VARI = 3192
PARAM_ORG_NESW_VARI = 3193
PARAM_BRIT_TEMP = 3194
PARAM_STRESS_LAT_GWAVE = 3195
PARAM_STRESS_MER_GWAVE = 3196
PARAM_GW_DISS  = 3197
PARAM_SKIN_RESV = 3198
PARAM_VEG_FRAC = 3199
PARAM_ORG_VARI = 3200

PARAM_OZON_MIX = 3203
PARAM_PRECIP_WGT = 3204
PARAM_RUNOFF = 3205
PARAM_OZON_TOT = 3206

PARAM_RDN_SOL_CS_TOP = 3208
PARAM_RDN_THE_CS_TOP = 3209
PARAM_RDN_SOL_CS_SRF = 3210
PARAM_RDN_THE_CS_SRF = 3211
PARAM_SOL_INSL = 3212

PARAM_DHT_RDN = 3214
PARAM_DHT_VDIFS = 3215
PARAM_DHT_CUMCONV = 3216
PARAM_DHT_LSCND = 3217
PARAM_VDIFS_ZWND = 3218
PARAM_VDIFS_MWND = 3219
PARAM_DTND_EW_GWAVE = 3220
PARAM_DTND_NS_GWAVE = 3221
PARAM_CTND_ZWND = 3222
PARAM_CTND_MWND = 3223
PARAM_VDIFS_HUM = 3224
PARAM_HTND_CUMCONV = 3225
PARAM_HTND_LSCND = 3226
PARAM_CNG_NHUM = 3227

PARAM_STRESS_EW_SRF_IN = 3229
PARAM_STRESS_NS_SRF_IN = 3230
PARAM_HT_SRF_IN = 3231
PARAM_MST_IN = 3232
PARAM_APP_HUM_SRF = 3233
PARAM_LRGN_HT_SRF = 3234
PARAM_SKIN_TEMP = 3235

PARAM_SNOW_TEMP = 3238
PARAM_SNOW_FALL_CONV = 3239
PARAM_SNOW_FALL_LS = 3240
PARAM_CLOUD_TND = 3241
PARAM_LW_TND = 3242
PARAM_ALBEDO_FC = 3243
PARAM_RGN_SRF_FC = 3244
PARAM_RGN_NT_SRF_FC = 3245
PARAM_CLOUD_LIQ = 3246
PARAM_CLOUD_ICE = 3247
PARAM_CLOUD_F = 3248
PARAM_ICE_TND = 3249
PARAM_ICE_AGE = 3250
PARAM_TND_TEMP_AD = 3251
PARAM_TND_HUM_AD = 3252
PARAM_TND_ZWND_AD = 3253
PARAM_TND_MWND_AD = 3254


## ECMWF 128
PARAM_WATV_EFLX = 4071
PARAM_WATV_NFLX = 4072
PARAM_DIV_MST_FLX = 4084



NAMES_UNITS = {
  PARAM_UNKNOWN => ["unknown", "dat", nil, nil],
  PARAM_PRESSURE => ["Pressure", "PRES", "Pa" ,"air_pressure"],
  PARAM_PMSL => ["Pressure reduced to MSL", "PRMSL", "Pa" , "air_pressure_at_sea_level"],
  PARAM_PTND => ["Pressure tendency", "PTEND", "Pa/s", "tendency_of_air_pressure"],
#  PARAM_ICAHT => nil,
  PARAM_GPT => ["Geopotential", "GP", "m2/s2", "geopotential"],
  PARAM_GPT_HGT => ["Geopotential height", "HGTZ", "Gpm", "geopotential_height"],
  PARAM_GEOM_HGT => ["Geometric height", "DIST", "M", "altitude"],
  PARAM_HSTDV => ["Standard deviation of height", "HSTDV", "M", "equivalent_thickness_at_stp_of_atmosphere_o3_content"],
  PARAM_TOZNE => ["Total ozone", "TOZNE", "Dobson", "equivalent_thickness_at_stp_of_atmosphere_o3_content"],
  PARAM_TEMP => ["Temperature", "TMP", "K", "air_temperature"],
  PARAM_VTEMP => ["Virtual temperature", "VTMP", "K", "virtual_temperature"],
  PARAM_POT_TEMP => ["Potential temperature", "POT", "K", "air_potential_temperature"],
  PARAM_APOT_TEMP => ["Pseudo-adiabatic potential temperature", "EPOT", "K", "pseudo_equivalent_potential_temperature"],
  PARAM_MAX_TEMP => ["Maximum temperature", "TMAX", "K", "air_temperature with a cell_methods attribute including time: maximum within days."],
  PARAM_MIN_TEMP => ["Minimum temperature", "TMIN", "K", "air_temperature with a cell_methods attribute including time: minimum within days."],
  PARAM_DP_TEMP => ["Dew point temperature", "TPD", "K", "dew_point_temperature"],
  PARAM_DP_DEP => ["Dew point depression (or deficit)", "DEPR", "K", "dew_point_depression"],
  PARAM_LAPSE => ["Lapse rate", "LAPR", "K/m", "air_temperature_lapse_rate"],
  PARAM_VIS => ["Visibility", "VISIB", "M", "visibility_in_air"],
  PARAM_RAD1 => ["Radar Spectra (1)", "RDSP1", nil, nil],
  PARAM_RAD2 => ["Radar Spectra (2)", "RDSP2", nil, nil],
  PARAM_RAD3 => ["Radar Spectra (3)", "RDSP3", nil, nil],
#  PARAM_PLI => nil,
  PARAM_TANOM => ["Temperature anomaly", "TMPA", "K", "air_temperature_anomaly"],
  PARAM_PANOM => ["Pressure anomaly", "PRESA", "Pa", "air_pressure_anomaly"],
  PARAM_ZANOM => ["Geopotential height anomaly", "GPA", "Gpm", "geopotential_height_anomaly"],
  PARAM_WAV1 => ["Wave Spectra (1)", "WVSP1", nil, nil],
  PARAM_WAV2 => ["Wave Spectra (2)", "WVSP2", nil, nil],
  PARAM_WAV3 => ["Wave Spectra (3)", "WVSP3", nil, nil],
  PARAM_WND_DIR => ["Wind direction", "WDIR", "Deg. true", "wind_from_direction"],
  PARAM_WND_SPEED => ["Wind speed", "WIND", "m/s", "wind_speed"],
  PARAM_U_WIND => ["u-component of wind", "UGRD", "m/s", "eastward_wind"],
  PARAM_V_WIND => ["v-component of wind", "VGRD", "m/s", "northward_wind"],
  PARAM_STRM_FUNC => ["Stream function", "STRM", "m2/s", "atmosphere_horizontal_streamfunction"],
  PARAM_VPOT => ["Velocity potential", "VPOT", "m2/s", "atmosphere_horizontal_velocity_potential"],
  PARAM_MNTSF => ["Montgomery stream function", "MNTSF", "m2/s2", nil],
  PARAM_SIG_VEL => ["Sigma coord. vertical velocity", "SGCVV", "s /s", "vertical_air_velocity_expressed_as_tendency_of_sigma"],
  PARAM_VERT_VEL => ["Pressure Vertical velocity", "VVEL", "Pa/s", "vertical_air_velocity_expressed_as_tendency_of_pressure"],
  PARAM_GEOM_VEL => ["Geometric Vertical velocity", "DZGT", "m/s", "upward_air_velocity"],
  PARAM_ABS_VOR => ["Absolute vorticity", "ABSV", "/s", "atmosphere_absolute_vorticity"],
  PARAM_ABS_DIV => ["Absolute divergence", "ABSD", "/s", ""],
  PARAM_REL_VOR => ["Relative vorticity", "RELV", "/s", "atmosphere_relative_vorticity"],
  PARAM_REL_DIV => ["Relative divergence", "RELD", "/s", "divergence_of_wind"],
  PARAM_U_SHR => ["Vertical u-component shear", "VUCSH", "/s", "eastward_wind_shear"],
  PARAM_V_SHR => ["Vertical v-component shear", "VVCSH", "/s", "northward_wind_shear"],
  PARAM_CRNT_DIR => ["Direction of current", "DIRC", "Deg. true", "direction_of_sea_water_velocity"],
  PARAM_CRNT_SPD => ["Speed of current", "SPC", "m/s", "sea_water_speed"],
  PARAM_U_CRNT => ["u-component of current", "UOGRD", "m/s", "eastward_sea_water_velocity"],
  PARAM_V_CRNT => ["v-component of current", "VOGRD", "m/s", "northward_sea_water_velocity"],
  PARAM_SPEC_HUM => ["Specific humidity", "SPFH", "kg/kg", "specific_humidity"],
  PARAM_REL_HUM => ["Relative humidity", "RH", "%", "relative_humidity"],
  PARAM_HUM_MIX => ["Humidity mixing ratio", "MIXR", "kg/kg", "humidity_mixing_ratio"],
  PARAM_PR_WATER => ["Precipitable water", "PWAT", "kg/m2", "atmosphere_water_vapour_content"],
  PARAM_VAP_PR => ["Vapour pressure", "VAPP", "Pa", "water_vapour_pressure"],
  PARAM_SAT_DEF => ["Saturation deficit", "SATD", "Pa", "water_vapour_saturation_deficit"],
  PARAM_EVAP => ["Evaporation", "EVP", "kg/m2", "water_evaporation_amount"],
  PARAM_C_ICE => ["Cloud Ice", "CICE", "kg/m2", "atmosphere_cloud_ice_content"],
  PARAM_PRECIP_RT => ["Precipitation rate", "PRATE", "kg/m2/s", "precipitation_flux"],
  PARAM_THND_PROB => ["Thunderstorm probability", "TSTM", "%", "thunderstorm_probability"],
  PARAM_PRECIP_TOT => ["Total precipitation", "APCP", "kg/m2", "precipitation_amount"],
  PARAM_PRECIP_LS => ["Large scale precipitation", "NCPCP", "kg/m2", "large_scale_precipitation_amount"],
  PARAM_PRECIP_CN => ["Convective precipitation", "ACPCP", "kg/m2", "convective_precipitation_amount"],
  PARAM_SNOW_RT => ["Snowfall rate water equivalent", "SRWEQ", "kg/m2s", "snowfall_flux"],
  PARAM_SNOW_WAT => ["Water equiv. of accum. snow depth", "WEASD", "kg/m2", "surface_snow_amount"],
  PARAM_SNOW => ["Snow depth", "SNOD", "M", "surface_snow_thickness"],
  PARAM_MIXED_DPTH => ["Mixed layer depth", "MIXHT", "M", "ocean_mixed_layer_thickness"],
  PARAM_TT_DEPTH => ["Transient thermocline depth", "TTHDP", "M", nil],
  PARAM_MT_DEPTH => ["Main thermocline depth", "MTHD", "M", nil],
  PARAM_MTD_ANOM => ["Main thermocline anomaly", "MTHA", "M", nil],
  PARAM_CLOUD => ["Total cloud cover", "TCDC", "%", "cloud_area_fraction"],
  PARAM_CLOUD_CN => ["Convective cloud cover", "CDCON", "%", "convective_cloud_area_fraction"],
  PARAM_CLOUD_LOW => ["Low cloud cover", "LCDC", "%", "low_cloud_area_fraction"],
  PARAM_CLOUD_MED => ["Medium cloud cover", "MCDC", "%", "medium_cloud_area_fraction"],
  PARAM_CLOUD_HI => ["High cloud cover", "HCDC", "%", "high_cloud_area_fraction"],
  PARAM_CLOUD_WAT => ["Cloud water", "CWAT", "kg/m2", "atmosphere_cloud_condensed_water_content"],
#  PARAM_BLI => nil,
  PARAM_SNO_C => ["Convective snow", "SNOC", "kg/m2", "convective_snowfall_amount"],
  PARAM_SNO_L => ["Large scale snow", "SNOL", "kg/m2", "large_scale_snowfall_amount"],
  PARAM_SEA_TEMP => ["Water Temperature", "WTMP", "K", "sea_water_temperature"],
  PARAM_LAND_MASK => ["Land-sea mask", "LAND", "Fraction", "land_area_fraction"],
  PARAM_SEA_MEAN => ["Deviation of sea level from mean", "DSLM", "M", "sea_surface_height_above_sea_level"],
  PARAM_SRF_RN => ["Surface roughness", "SFCR", "M", "surface_roughness_length"],
  PARAM_ALBEDO => ["Albedo", "ALBDO", "%", "surface_albedo"],
  PARAM_SOIL_TEMP => ["Soil temperature", "TSOIL", "K", "soil_temperature"],
  PARAM_SOIL_MST => ["Soil moisture content", "SOILM", "kg/m2", "soil_moisture_content"],
  PARAM_VEG => ["Vegetation", "VEG", "%", "vegetation_area_fraction"],
  PARAM_SAL => ["Salinity", "SALTY", "kg/kg", "sea_water_salinity"],
  PARAM_DENS => ["Density", "DEN", "kg/m3", "density"],
  PARAM_WATR => ["Water run off", "RUNOF", "kg/m2", "surface_runoff_amount"],
  PARAM_ICE_CONC => ["Ice concentration", "ICEC", "Fraction", "sea_ice_area_fraction"],
  PARAM_ICE_THICK => ["Ice thickness", "ICETK", "M", "sea_ice_thickness"],
  PARAM_ICE_DIR => ["Direction of ice drift", "DICED", "deg. true", "direction_of_sea_ice_velocity"],
  PARAM_ICE_SPD => ["Speed of ice drift", "SICED", "m/s", "sea_ice_speed"],
  PARAM_ICE_U => ["u-component of ice drift", "UICE", "m/s", "sea_ice_eastward_velocity"],
  PARAM_ICE_V => ["v-component of ice drift", "VICE", "m/s", "sea_ice_northward_velocity"],
  PARAM_ICE_GROWTH => ["Ice growth rate", "ICEG", "m/s", "tendency_of_sea_ice_thickness_due_to_thermodynamics"],
  PARAM_ICE_DIV => ["Ice divergence", "ICED", "/s", "divergence_of_sea_ice_velocity"],
  PARAM_SNO_M => ["Snow melt", "SNOM", "kg/m2", "surface_snow_melt_amount"],
  PARAM_WAVE_HGT => ["Significant height of combined", "HTSGW", "wind m", "significant_height_of_wind_and_swell_waves"],
  PARAM_SEA_DIR => ["Direction of wind waves", "WVDIR", "deg. true", "direction_of_wind_wave_velocity"],
  PARAM_SEA_HGT => ["Significant height of wind waves", "WVHGT", "m", "significant_height_of_wind_waves"],
  PARAM_SEA_PER => ["Mean period of wind waves", "WVPER", "s", "wind_wave_period"],
  PARAM_SWELL_DIR => ["Direction of swell waves", "SWDIR", "deg. true", "direction_of_swell_wave_velocity"],
  PARAM_SWELL_HGT => ["Significant height of swell waves", "SWELL", "m", "significant_height_of_swell_waves"],
  PARAM_SWELL_PER => ["Mean period of swell waves", "SWPER", "s", "swell_wave_period"],
  PARAM_WAVE_DIR => ["Primary wave direction", "DIRPW", "deg. true", nil],
  PARAM_WAVE_PER => ["Primary wave mean period", "PERPW", "s", nil],
  PARAM_WAVE2_DIR => ["Secondary wave direction", "DIRSW", "deg. true", nil],
  PARAM_WAVE2_PER => ["Secondary wave mean period", "PERSW", "s", nil],
  PARAM_RDN_SWSRF => ["Net short-wave radiation (surface)", "NSWRS", "W/m2", "surface_net_upward_shortwave_flux"],
  PARAM_RDN_LWSRF => ["Net long wave radiation (surface)", "NLWRS", "W/m2", "surface_net_upward_longwave_flux"],
  PARAM_RDN_SWTOP => ["Net short-wave radiation (top of atmos.)", "NSWRT", "W/m2", "toa_net_upward_shortwave_flux"],
  PARAM_RDN_LWTOP => ["Net long wave radiation (top of atmos.)", "NLWRT", "W/m2", "toa_net_upward_longwave_flux"],
  PARAM_RDN_LW => ["Long wave radiation", "LWAVR", "W/m2", "net_upward_longwave_flux_in_air"],
  PARAM_RDN_SW => ["Short wave radiation", "SWAVR", "W/m2", "net_upward_shortwave_flux_in_air"],
  PARAM_RDN_GLBL => ["Global radiation", "GRAD", "W/m2", "surface_downwelling_shortwave_flux"],
#  PARAM_BRTMP => nil,
#  PARAM_LWRAD => nil,
#  PARAM_SWRAD => nil,
  PARAM_LAT_HT => ["Latent heat net flux", "LHTFL", "W/m2", "surface_upward_latent_heat_flux"],
  PARAM_SEN_HT => ["Sensible heat net flux", "SHTFL", "W/m2", "surface_upward_sensible_heat_flux"],
  PARAM_BL_DISS => ["Boundary layer dissipation", "VLYDP", "W/m2", nil],
  PARAM_U_FLX => ["Momentum flux, u component", "UFLX", "N/m2", "downward_eastward_momentum_flux_in_air"],
  PARAM_V_FLX => ["Momentum flux, v component", "VFLX", "N/m2", "downward_northward_momentum_flux_in_air"],
  PARAM_WMIXE => ["Wind mixing energy", "WMIXE", "J", "wind_mixing_energy_flux_into_ocean"],
  PARAM_IMAGE => ["Image data", "IMGD", "", nil],



## GRIB Edition 0
  PARAM_VERT_SHR => nil,
  PARAM_CON_PRECIP => nil,
  PARAM_PRECIP => nil,
  PARAM_NCON_PRECIP => nil,
  PARAM_SST_WARM => nil,
  PARAM_UND_ANOM => nil,
  PARAM_SEA_TEMP_0 => nil,
  PARAM_PRESSURE_D => nil,
  PARAM_GPT_THICK => nil,
  PARAM_GPT_HGT_D => nil,
  PARAM_GEOM_HGT_D => nil,
  PARAM_TEMP_D => nil,
  PARAM_REL_HUM_D => nil,
  PARAM_LIFT_INDX_D => nil,
  PARAM_REL_VOR_D => nil,
  PARAM_ABS_VOR_D => nil,
  PARAM_VERT_VEL_D => nil,
  PARAM_SEA_TEMP_D => nil,
  PARAM_SST_ANOM => nil,
  PARAM_QUAL_IND => nil,
  PARAM_GPT_DEP => nil,
  PARAM_PRESSURE_DEP => nil,
  PARAM_LAST_ENTRY => nil,
  PARAM_LN_PRES => ["Logarithm of surface pressure", "LNSP", "", nil],


## NCEP Edition 2
#128	MSLSA	Pa		Mean Sea Level Pressure (Standard Atmosphere Reduction)		
#129	MSLMA	Pa		Mean Sea Level Pressure (MAPS System Reduction)		
#130	MSLET	Pa		Mean Sea Level Pressure (ETA Model Reduction)		
  PARAM_LFT_X => ["Surface lifted index", "LFT_X", "K", nil],		
  PARAM_4LFTX => ["Best (4 layer) lifted index", "4LFTX", "K", nil],		
#133	K X	K		K index		
#134	S X	K		Sweat index		
#135	MCONV	kg/kg/s		Horizontal moisture divergence		
  PARAM_VW_SH => ["Vertical speed shear", "VW_SH", "1/s", "wind_speed_shear"],
#137	TSLSA	Pa/s		3-hr pressure tendency (Std. Atmos. Reduction)		
#138	BVF 2	1/s2		Brunt-Vaisala frequency (squared)		
#139	PV MW	1/s/m		Potential vorticity (density weighted)		
#140	CRAIN	(yes=1; no=0)		Categorical rain		
#141	CFRZR	(yes=1; no=0)		Categorical freezing rain		
#142	CICEP	(yes=1; no=0)		Categorical ice pellets		
#143	CSNOW	(yes=1; no=0)		Categorical snow		
  PARAM_SOILW => ["Volumetric soil moisture content", "SOILW", "fraction", nil],
#145	PEVPR	W/m**2		Potential evaporation rate		
#146	CWORK	J/kg		Cloud workfunction		
#147	U-GWD	N/m**2		Zonal flux of gravity wave stress		
#148	V-GWD	N/m**2		Meridional flux of gravity wave stress		
#149	PV	m**2/s/kg		Potential vorticity		
#150	COVMZ	m2/s2		Covariance between meridional and zonal components of the wind. Defined as [uv]-[u][v], where "[]" indicates the mean over the indicated time span.		
#151	COVTZ1	K*m/s		Covariance between temperature and zonal component of the wind. Defined as [uT]-[u][T], where "[]" indicates the mean over the indicated time span.		
#152	COVTM	K*m/s		Covariance between temperature and meridional component of the wind. Defined as [vT]-[v][T], where "[]" indicates the mean over the indicated time span.		
  PARAM_CLWMR => ["Cloud water", "CLWMR", "Kg/kg", nil],
  PARAM_O3MR => ["Ozone mixing ratio", "O3MR", "Kg/kg", nil],
#155	GFLUX	W/m2		Ground Heat Flux		
  PARAM_CIN => ["Convective inhibition", "CIN", "J/kg", nil],
  PARAM_CAPE => ["Convective Available Potential Energy", "CAPE", "J/kg", nil],		
#158	TKE	J/kg		Turbulent Kinetic Energy		
#159	CONDP	Pa		Condensation pressure of parcel lifted from indicated surface		
#160	CSUSF	W/m2		Clear Sky Upward Solar Flux		
#161	CSDSF	W/m2		Clear Sky Downward Solar Flux		
#162	CSULF	W/m2		Clear Sky upward long wave flux		
#163	CSDLF	W/m2		Clear Sky downward long wave flux		
#164	CFNSF	W/m2		Cloud forcing net solar flux		
#165	CFNLF	W/m2		Cloud forcing net long wave flux		
#166	VBDSF	W/m2		Visible beam downward solar flux		
#167	VDDSF	W/m2		Visible diffuse downward solar flux		
#168	NBDSF	W/m2		Near IR beam downward solar flux		
#169	NDDSF	W/m2		Near IR diffuse downward solar flux		
#172	M FLX	N/m2		Momentum flux		
#173	LMH	non-dim		Mass point model surface		
#174	LMV	non-dim		Velocity point model surface		
#175	MLYNO	non-dim		Model layer number (from bottom up)		
#176	NLAT	deg		latitude (-90 to +90)		
#177	ELON	deg		east longitude (0-360)		
#181	LPS X	1/m		x-gradient of log pressure		
#182	LPS Y	1/m		y-gradient of log pressure		
#183	HGT X	m/m		x-gradient of height		
#184	HGT Y	m/m		y-gradient of height		
#189	VPTMP	K		Virtual potential temperature		
#190	HLCY	m2/s2		Storm relative helicity		
#191	PROB	numeric		Probability from ensemble		
#192	PROBN	numeric		Probability from ensemble normalized with respect to climate expectancy		
#193	POP	%		Probability of precipitation		
#194	CPOFP	%		Probability of frozen precipitation		
#195	CPOZP	%		Probability of freezing precipitation		
#196	USTM	m/s		u-component of storm motion		
#197	VSTM	m/s		v-component of storm motion		
#201	ICWAT	%		Ice-free water surface		
#204	DSWRF	W/m2		downward short wave rad. flux		
#205	DLWRF	W/m2		downward long wave rad. flux		
#206	UVI	J/m2		Ultra violet index (1 hour integration centered at solar noon)		
#207	MSTAV	%		Moisture availability		
#208	SFEXC	(kg/m3)(m/s)		Exchange coefficient		
#209	MIXLY	integer		No. of mixed layers next to surface		
#211	USWRF	W/m2		upward short wave rad. flux		
#212	ULWRF	W/m2		upward long wave rad. flux		
#213	CDLYR	%		Amount of non-convective cloud		
#214	CPRAT	kg/m2/s		Convective Precipitation rate		
#215	TTDIA	K/s		Temperature tendency by all physics		
#216	TTRAD	K/s		Temperature tendency by all radiation		
#217	TTPHY	K/s		Temperature tendency by non-radiation physics		
#218	PREIX	fraction		precip.index(0.0-1.00)(see note)		
#219	TSD1D	K		Std. dev. of IR T over 1x1 deg area		
#220	NLGSP	ln(kPa)		Natural log of surface pressure		
  PARAM_HPBL => ["Planetary boundary layer height", "HPBL", "m", nil],
  PARAM_5WAVH => ["5-wave geopotential height", "5WAVH", "gpm", nil],
#223	C WAT	kg/m2		Plant canopy surface water		
#226	BMIXL	m		Blackadar's mixing length scale		
#227	AMIXL	m		Asymptotic mixing length scale		
#228	PEVAP	kg/m2		Potential evaporation		
#229	SNOHF	W/m2		Snow phase-change heat flux
  PARAM_5WAVA =>["5-wave geopotential height anomaly", "5WAVA", "gpm", nil],
#231	MFLUX	Pa/s		Convective cloud mass flux		
#232	DTRF	W/m2		Downward total radiation flux		
#233	UTRF	W/m2		Upward total radiation flux		
#234	BGRUN	kg/m2		Baseflow-groundwater runoff		
#235	SSRUN	kg/m2		Storm surface runoff		
#237	03TOT	Kg/m2		Total ozone		
#238	SNO C	percent		Snow cover		
#239	SNO T	K		Snow temperature		
#241	LRGHR	K/s		Large scale condensat. heat rate		
#242	CNVHR	K/s		Deep convective heating rate		
#243	CNVMR	kg/kg/s		Deep convective moistening rate		
#244	SHAHR	K/s		Shallow convective heating rate		
#245	SHAMR	kg/kg/s		Shallow convective moistening rate		
#246	VDFHR	K/s		Vertical diffusion heating rate		
#247	VDFUA	m/s2		Vertical diffusion zonal acceleration		
#248	VDFVA	m/s2		Vertical diffusion meridional accel		
#249	VDFMR	kg/kg/s		Vertical diffusion moistening rate		
#250	SWHR	K/s		Solar radiative heating rate		
#251	LWHR	K/s		long wave radiative heating rate		
#252	CD	non-dim		Drag coefficient		
#253	FRICV	m/s		Friction velocity		
#254	RI	non-dim.		Richardson number


## ECMWF 128  #incomplite
#  4 => PARAM_EQPT_TEMP,
#  5 => PARAM_SEPT_TEMP,
#  11 => PARAM_U_DIV_WND,
#  12 => PARAM_V_DIV_WND,
#  13 => PARAM_U_ROT_WND,
#  14 => PARAM_V_ROT_WND,
#  21 => PARAM_UBC_TEMP,
#  22 => PARAM_UB_PRES,
#  23 => PARAM_UB_DIV,
#  26 => PARAM_LAKE_COV
  PARAM_LVEG_COV => ["Low vegetation cover", "CVL", "Fraction", nil],
  PARAM_HVEG_COV => ["High vegetation cover", "CVH", "Fraction", nil],
  PARAM_TYP_LVEG => ["Type of low vegetation", "TVL", nil, nil],
  PARAM_TYP_HVEG => ["Type of high vegetation", "TVH", nil, nil],
  PARAM_ICE_COV => ["Sea-ice cover", "CI", "Fraction", "sea_ice_area_fraction"],
  PARAM_SNOW_ALBD => ["Snow albedo", "ASN", "Fraction", nil],
  PARAM_SNOW_DENS => ["Snow density", "RSN", "kg/m3", nil],
  PARAM_SEASRF_TEMP => ["Sea surface temperature", "SSTK", "K", "sea_surface_temperature"],
  PARAM_ICESRF_TEMP => ["Ice surface temperature", "ISTL", "K", nil],
  PARAM_SOIL_WATER => ["Volumetric soil water","SWVL", "m3/m2", nil],
#  43 => PARAM_TYP_SOIL
#  44 => PARAM_SNOW_EVAP

#  46 => PARAM_SOL_DUR,
#  47 => PARAM_RND_SOL_DIR,
#  48 => PARAM_STRESS_SRF,
#  49 => PARAM_WNDGUST,
#  50 => PARAM_PRECIP_LS_FRAC,

#  53 => PARAM_MNTPOT,

   PARAM_POT_VOR => ["Potential vorticity", "PV", "K m2/kg/s", nil],

#  127 => PARAM_ATM_TIDE,
#  128 => PARAM_BUDG_VAL

  PARAM_WATER_TOT => ["Total column water", "TWC", "kg/m2", nil],
  PARAM_WATV_TOT => ["Totl column water vapour", "PWC", "kg/m2", nil],

#  140 => PARAM_SOIL_WET,
#  144 => PARAM_SNOW_FALL,

  PARAM_CHNK => ["Charnock", "CHNK", nil, nil],
#  149 => PARAM_RDN_SRF,
#  150 => PARAM_RDN_TOP,

#  153 => PARAM_HT_SW,
#  154 => PARAM_HT_LW,

#  159 => PARAM_BL_HGT,
  PARAM_ORG_STDV => ["Standard deciation of orography", "SDOR", nil, nil],
  PARAM_SGORG_ANIS => ["Anisotropy of sub-gridscale orography", "ISOR", nil, nil],
  PARAM_SGORG_ANGL => ["Angle of sub-gridscale orography", "ANOR", "rad", nil],
  PARAM_SGORG_SLOP => ["Slope of sub-gridscale orography", "SLOR", nil, nil],

#  169 => PARAM_RND_SOL_SRFD,

  PARAM_ALBEDO_F => ["Albedo", "AL", "Fraction", "surface_albedo"],
#  175 => PARAM_RDN_THE_SRFD,
#  176 => PARAM_RDN_SOL_SRF,
#  177 => PARAM_RDN_THE_SRF,
#  178 => PARAM_RDN_SOL_TOP,
#  179 => PARAM_RDN_THE_TOP,
#  180 => PARAM_STRESS_EW_SRF,
#  181 => PARAM_STRESS_NS_SRF,

#  189 => PARAM_SUN_DUR,
#  190 => PARAM_ORG_EW_VARI,
#  191 => PARAM_ORG_NS_VARI,
#  192 => PARAM_ORG_NWSE_VARI,
#  193 => PARAM_ORG_NESW_VARI,
#  194 => PARAM_BRIT_TEMP,
#  195 => PARAM_STRESS_LAT_GWAVE,
#  196 => PARAM_STRESS_MER_GWAVE,
#  197 => PARAM_GW_DISS,
  PARAM_SKIN_RESV => ["Skin reservoir content", "SRC", "m", nil],
#  199 => PARAM_VEG_FRAC,
#  200 => PARAM_ORG_VARI,

  PARAM_OZON_MIX => ["Ozone mass mixing ratio", "O3", "kg/kg", nil],
#  204 => PARAM_PRECIP_WGT,
#  205 => PARAM_RUNOFF,
  PARAM_OZON_TOT => ["Total column ozone", "TCO3", "Dobson", nil],

#  208 => PARAM_RDN_SOL_CS_TOP,
#  209 => PARAM_RDN_THE_CS_TOP,
#  210 => PARAM_RDN_SOL_CS_SRF,
#  211 => PARAM_RDN_THE_CS_SRF,
#  212 => PARAM_SOL_INSL,

#  214 => PARAM_DHT_RDN,
#  215 => PARAM_DHT_VDIFS,
#  216 => PARAM_DHT_CUMCONV,
#  217 => PARAM_DHT_LSCND,
#  218 => PARAM_VDIFS_ZWND,
#  219 => PARAM_VDIFS_MWND,
#  220 => PARAM_DTND_EW_GWAVE,
#  221 => PARAM_DTND_NS_GWAVE,
#  222 => PARAM_CTND_ZWND,
#  223 => PARAM_CTND_MWND,
#  224 => PARAM_VDIFS_HUM,
#  225 => PARAM_HTND_CUMCONV,
#  226 => PARAM_HTND_LSCND,
#  227 => PARAM_CNG_NHUM,

#  229 => PARAM_STRESS_EW_SRF_IN,
#  230 => PARAM_STRESS_NS_SRF_IN,
#  231 => PARAM_HT_SRF_IN,
#  232 => PARAM_MST_IN,
#  233 => PARAM_APP_HUM_SRF,
  PARAM_LRGN_HT_SRF => ["Logarithm of sruface roughness length for heat", "LSRH", nil, nil],
  PARAM_SKIN_TEMP => ["Skin temperature", "SKT", "K", nil],

  PARAM_SNOW_TEMP => ["Temperature of snow layer", "TSN", "K", nil],
#  239 => PARAM_SNOW_FALL_CONV,
#  240 => PARAM_SNOW_FALL_LS,
#  241 => PARAM_CLOUD_TND,
#  242 => PARAM_LW_TND,
#  243 => PARAM_ALBEDO_FC,
#  244 => PARAM_RGN_SRF_FC,
#  245 => PARAM_RGN_NT_SRF_FC,
#  246 => PARAM_CLOUD_LIQ,
#  247 => PARAM_CLOUD_ICE,
#  248 => PARAM_CLOUD_F,
#  249 => PARAM_ICE_TND,
#  250 => PARAM_ICE_AGE,
#  251 => PARAM_TND_TEMP_AD,
#  252 => PARAM_TND_HUM_AD,
#  253 => PARAM_TND_ZWND_AD,
#  254 => PARAM_TND_MWND_AD

## ECMWF 162  #incomplite
  PARAM_WATV_EFLX => ["Vertical integral of eastward water vapour flux", "VIEWVF", "kg/m/s", nil],
  PARAM_WATV_NFLX => ["Vertical integral of northward water vapour flux", "VINWVF", "kg/m/s", nil],
  PARAM_DIV_MST_FLX => ["Vertical integral of divergence of moisture flux", "VIDMOF", "kg/m2/s", nil],


nil => nil
}


PARAMS_0 = {
  0 => PARAM_UNKNOWN,
  1 => PARAM_PRESSURE,
  2 => PARAM_GPT_HGT,
  3 => PARAM_GEOM_HGT,
  4 => PARAM_TEMP,
  5 => PARAM_MAX_TEMP,
  6 => PARAM_MIN_TEMP,
  8 => PARAM_POT_TEMP,
  10 => PARAM_DP_TEMP,
  11 => PARAM_DP_DEP,
  12 => PARAM_SPEC_HUM,
  13 => PARAM_REL_HUM,
  14 => PARAM_HUM_MIX,
  15 => PARAM_LIFT_INDX,
  17 => PARAM_LIFT_INDX4,
  21 => PARAM_WND_SPEED,
  23 => PARAM_U_WIND,
  24 => PARAM_V_WIND,
  29 => PARAM_STRM_FUNC,
  30 => PARAM_REL_VOR,
  31 => PARAM_ABS_VOR,
  40 => PARAM_VERT_VEL,
  44 => PARAM_VERT_SHR,
  47 => PARAM_PR_WATER,
  48 => PARAM_CON_PRECIP,
  50 => PARAM_PRECIP,
  51 => PARAM_SNOW,
  55 => PARAM_NCON_PRECIP,
  58 => PARAM_SST_WARM,
  59 => PARAM_UND_ANOM,
  61 => PARAM_SEA_TEMP_0,
  64 => PARAM_WAVE_HGT,
  65 => PARAM_SWELL_DIR,
  66 => PARAM_SWELL_HGT,
  67 => PARAM_SWELL_PER,
  68 => PARAM_SEA_DIR,
  69 => PARAM_SEA_HGT,
  70 => PARAM_SEA_PER,
  75 => PARAM_WAVE_DIR,
  76 => PARAM_WAVE_PER,
  77 => PARAM_WAVE2_DIR,
  78 => PARAM_WAVE2_PER,
  90 => PARAM_ICE_CONC,
  91 => PARAM_ICE_THICK,
  92 => PARAM_ICE_U,
  93 => PARAM_ICE_V,
  94 => PARAM_ICE_GROWTH,
  95 => PARAM_ICE_DIV,
  100 => PARAM_PRESSURE_D,
  101 => PARAM_GPT_THICK,
  102 => PARAM_GPT_HGT_D,
  103 => PARAM_GEOM_HGT_D,
  104 => PARAM_TEMP_D,
  113 => PARAM_REL_HUM_D,
  115 => PARAM_LIFT_INDX_D,
  130 => PARAM_REL_VOR_D,
  131 => PARAM_ABS_VOR_D,
  141 => PARAM_VERT_VEL_D,
  162 => PARAM_SEA_TEMP_D,
  163 => PARAM_SST_ANOM,
  180 => PARAM_MIXED_DPTH,
  181 => PARAM_TT_DEPTH,
  182 => PARAM_MT_DEPTH,
  183 => PARAM_MTD_ANOM,
  190 => PARAM_QUAL_IND,
  210 => PARAM_GPT_DEP,
  211 => PARAM_PRESSURE_DEP
}

PARAMS_2 = {
  0 => PARAM_UNKNOWN,
  1 => PARAM_PRESSURE,
  2 => PARAM_PMSL,
  3 => PARAM_PTND,
  #4 => PARAM_ICAHT,
  #5 => 5,
  6 => PARAM_GPT,
  7 => PARAM_GPT_HGT,
  8 => PARAM_GEOM_HGT,
  9 => PARAM_HSTDV,
  10 => PARAM_TOZNE,
  11 => PARAM_TEMP,
  12 => PARAM_VTEMP,
  13 => PARAM_POT_TEMP,
  14 => PARAM_APOT_TEMP,
  15 => PARAM_MAX_TEMP,
  16 => PARAM_MIN_TEMP,
  17 => PARAM_DP_TEMP,
  18 => PARAM_DP_DEP,
  19 => PARAM_LAPSE,
  20 => PARAM_VIS,
  21 => PARAM_RAD1,
  22 => PARAM_RAD2,
  23 => PARAM_RAD3,
  #24 => PARAM_PLI,
  25 => PARAM_TANOM,
  26 => PARAM_PANOM,
  27 => PARAM_ZANOM,
  28 => PARAM_WAV1,
  29 => PARAM_WAV2,
  30 => PARAM_WAV3,
  31 => PARAM_WND_DIR,
  32 => PARAM_WND_SPEED,
  33 => PARAM_U_WIND,
  34 => PARAM_V_WIND,
  35 => PARAM_STRM_FUNC,
  36 => PARAM_VPOT,
  37 => PARAM_MNTSF,
  38 => PARAM_SIG_VEL,
  39 => PARAM_VERT_VEL,
  40 => PARAM_GEOM_VEL,
  41 => PARAM_ABS_VOR,
  42 => PARAM_ABS_DIV,
  43 => PARAM_REL_VOR,
  44 => PARAM_REL_DIV,
  45 => PARAM_U_SHR,
  46 => PARAM_V_SHR,
  47 => PARAM_CRNT_DIR,
  48 => PARAM_CRNT_SPD,
  49 => PARAM_U_CRNT,
  50 => PARAM_V_CRNT,
  51 => PARAM_SPEC_HUM,
  52 => PARAM_REL_HUM,
  53 => PARAM_HUM_MIX,
  54 => PARAM_PR_WATER,
  55 => PARAM_VAP_PR,
  56 => PARAM_SAT_DEF,
  57 => PARAM_EVAP,
  58 => PARAM_C_ICE,
  59 => PARAM_PRECIP_RT,
  60 => PARAM_THND_PROB,
  61 => PARAM_PRECIP_TOT,
  62 => PARAM_PRECIP_LS,
  63 => PARAM_PRECIP_CN,
  64 => PARAM_SNOW_RT,
  65 => PARAM_SNOW_WAT,
  66 => PARAM_SNOW,
  67 => PARAM_MIXED_DPTH,
  68 => PARAM_TT_DEPTH,
  69 => PARAM_MT_DEPTH,
  70 => PARAM_MTD_ANOM,
  71 => PARAM_CLOUD,
  72 => PARAM_CLOUD_CN,
  73 => PARAM_CLOUD_LOW,
  74 => PARAM_CLOUD_MED,
  75 => PARAM_CLOUD_HI,
  76 => PARAM_CLOUD_WAT,
  #77 => PARAM_BLI,
  78 => PARAM_SNO_C,
  79 => PARAM_SNO_L,
  80 => PARAM_SEA_TEMP,
  81 => PARAM_LAND_MASK,
  82 => PARAM_SEA_MEAN,
  83 => PARAM_SRF_RN,
  84 => PARAM_ALBEDO,
  85 => PARAM_SOIL_TEMP,
  86 => PARAM_SOIL_MST,
  87 => PARAM_VEG,
  88 => PARAM_SAL,
  89 => PARAM_DENS,
  90 => PARAM_WATR,
  91 => PARAM_ICE_CONC,
  92 => PARAM_ICE_THICK,
  93 => PARAM_ICE_DIR,
  94 => PARAM_ICE_SPD,
  95 => PARAM_ICE_U,
  96 => PARAM_ICE_V,
  97 => PARAM_ICE_GROWTH,
  98 => PARAM_ICE_DIV,
  99 => PARAM_SNO_M,
  100 => PARAM_WAVE_HGT,
  101 => PARAM_SEA_DIR,
  102 => PARAM_SEA_HGT,
  103 => PARAM_SEA_PER,
  104 => PARAM_SWELL_DIR,
  105 => PARAM_SWELL_HGT,
  106 => PARAM_SWELL_PER,
  107 => PARAM_WAVE_DIR,
  108 => PARAM_WAVE_PER,
  109 => PARAM_WAVE2_DIR,
  110 => PARAM_WAVE2_PER,
  111 => PARAM_RDN_SWSRF,
  112 => PARAM_RDN_LWSRF,
  113 => PARAM_RDN_SWTOP,
  114 => PARAM_RDN_LWTOP,
  115 => PARAM_RDN_LW,
  116 => PARAM_RDN_SW,
  117 => PARAM_RDN_GLBL,
  #118 => PARAM_BRTMP,
  #119 => PARAM_LWRAD,
  #120 => PARAM_SWRAD,
  121 => PARAM_LAT_HT,
  122 => PARAM_SEN_HT,
  123 => PARAM_BL_DISS,
  124 => PARAM_U_FLX,
  125 => PARAM_V_FLX,
  126 => PARAM_WMIXE,
  127 => PARAM_IMAGE
}

PARAMS_NCEP_2 = {   #incomplete
  131 => PARAM_LFT_X,
  132 => PARAM_4LFTX,
  136 => PARAM_VW_SH,
  144 => PARAM_SOILW,
  153 => PARAM_CLWMR,
  154 => PARAM_O3MR,
  156 => PARAM_CIN,
  157 => PARAM_CAPE,
  221 => PARAM_HPBL,
  222 => PARAM_5WAVH,
  230 => PARAM_5WAVA,
}


PARAMS_ECMWF_128 = {   #inconmplte
  0 => PARAM_UNKNOWN,
  1 => PARAM_STRM_FUNC,
  2 => PARAM_VPOT,
  3 => PARAM_POT_TEMP,
  4 => PARAM_EQPT_TEMP,
  5 => PARAM_SEPT_TEMP,

  11 => PARAM_U_DIV_WND,
  12 => PARAM_V_DIV_WND,
  13 => PARAM_U_ROT_WND,
  14 => PARAM_V_ROT_WND,

  21 => PARAM_UBC_TEMP,
  22 => PARAM_UB_PRES,
  23 => PARAM_UB_DIV,

  26 => PARAM_LAKE_COV,
  27 => PARAM_LVEG_COV,
  28 => PARAM_HVEG_COV,
  29 => PARAM_TYP_LVEG,
  30 => PARAM_TYP_HVEG,
  31 => PARAM_ICE_COV,
  32 => PARAM_SNOW_ALBD,
  33 => PARAM_SNOW_DENS,
  34 => PARAM_SEASRF_TEMP,
  35 => PARAM_ICESRF_TEMP,
  36 => PARAM_ICESRF_TEMP,
  37 => PARAM_ICESRF_TEMP,
  38 => PARAM_ICESRF_TEMP,
  39 => PARAM_SOIL_WATER,
  40 => PARAM_SOIL_WATER,
  41 => PARAM_SOIL_WATER,
  42 => PARAM_SOIL_WATER,
  43 => PARAM_TYP_SOIL,
  44 => PARAM_SNOW_EVAP,
  45 => PARAM_SNO_M,
  46 => PARAM_SOL_DUR,
  47 => PARAM_RND_SOL_DIR,
  48 => PARAM_STRESS_SRF,
  49 => PARAM_WNDGUST,
  50 => PARAM_PRECIP_LS_FRAC,
  51 => PARAM_MAX_TEMP,
  52 => PARAM_MIN_TEMP,
  53 => PARAM_MNTPOT,
  54 => PARAM_PRESSURE,

  60 => PARAM_POT_VOR,

  127 => PARAM_ATM_TIDE,
  128 => PARAM_BUDG_VAL,
  129 => PARAM_GPT,
  130 => PARAM_TEMP,
  131 => PARAM_U_WIND,
  132 => PARAM_V_WIND,
  133 => PARAM_SPEC_HUM,
  134 => PARAM_PRESSURE,
  135 => PARAM_VERT_VEL,
  136 => PARAM_WATER_TOT,
  137 => PARAM_WATV_TOT,
  138 => PARAM_REL_VOR,
  139 => PARAM_SOIL_TEMP,
  140 => PARAM_SOIL_WET,
  141 => PARAM_SNOW,
  142 => PARAM_PRECIP_LS,
  143 => PARAM_PRECIP_CN,
  144 => PARAM_SNOW_FALL,
  145 => PARAM_BL_DISS,
  146 => PARAM_SEN_HT,
  147 => PARAM_LAT_HT,
  148 => PARAM_CHNK,
  149 => PARAM_RDN_SRF,
  150 => PARAM_RDN_TOP,
  151 => PARAM_PMSL,
  152 => PARAM_LN_PRES,
  153 => PARAM_HT_SW,
  154 => PARAM_HT_LW,
  155 => PARAM_ABS_DIV,
  156 => PARAM_GPT_HGT,
  157 => PARAM_REL_HUM,
  158 => PARAM_PTND,
  159 => PARAM_BL_HGT,
  160 => PARAM_ORG_STDV,
  161 => PARAM_SGORG_ANIS,
  162 => PARAM_SGORG_ANGL,
  163 => PARAM_SGORG_SLOP,
  164 => PARAM_CLOUD,
  165 => PARAM_U_WIND,
  166 => PARAM_V_WIND,
  167 => PARAM_TEMP,
  168 => PARAM_DP_TEMP,
  169 => PARAM_RND_SOL_SRFD,
  170 => PARAM_SOIL_TEMP,
  171 => PARAM_SOIL_WET,
  172 => PARAM_LAND_MASK,
  173 => PARAM_SRF_RN,
  174 => PARAM_ALBEDO_F,
  175 => PARAM_RDN_THE_SRFD,
  176 => PARAM_RDN_SOL_SRF,
  177 => PARAM_RDN_THE_SRF,
  178 => PARAM_RDN_SOL_TOP,
  179 => PARAM_RDN_THE_TOP,
  180 => PARAM_STRESS_EW_SRF,
  181 => PARAM_STRESS_NS_SRF,
  182 => PARAM_EVAP,
  183 => PARAM_SOIL_TEMP,
  184 => PARAM_SOIL_WET,
  185 => PARAM_CLOUD_CN,
  186 => PARAM_CLOUD_LOW,
  187 => PARAM_CLOUD_MED,
  188 => PARAM_CLOUD_HI,
  189 => PARAM_SUN_DUR,
  190 => PARAM_ORG_EW_VARI,
  191 => PARAM_ORG_NS_VARI,
  192 => PARAM_ORG_NWSE_VARI,
  193 => PARAM_ORG_NESW_VARI,
  194 => PARAM_BRIT_TEMP,
  195 => PARAM_STRESS_LAT_GWAVE,
  196 => PARAM_STRESS_MER_GWAVE,
  197 => PARAM_GW_DISS,
  198 => PARAM_SKIN_RESV,
  199 => PARAM_VEG_FRAC,
  200 => PARAM_ORG_VARI,
  201 => PARAM_MAX_TEMP,
  202 => PARAM_MIN_TEMP,
  203 => PARAM_OZON_MIX,
  204 => PARAM_PRECIP_WGT,
  205 => PARAM_RUNOFF,
  206 => PARAM_OZON_TOT,
  207 => PARAM_WND_SPEED,
  208 => PARAM_RDN_SOL_CS_TOP,
  209 => PARAM_RDN_THE_CS_TOP,
  210 => PARAM_RDN_SOL_CS_SRF,
  211 => PARAM_RDN_THE_CS_SRF,
  212 => PARAM_SOL_INSL,

  214 => PARAM_DHT_RDN,
  215 => PARAM_DHT_VDIFS,
  216 => PARAM_DHT_CUMCONV,
  217 => PARAM_DHT_LSCND,
  218 => PARAM_VDIFS_ZWND,
  219 => PARAM_VDIFS_MWND,
  220 => PARAM_DTND_EW_GWAVE,
  221 => PARAM_DTND_NS_GWAVE,
  222 => PARAM_CTND_ZWND,
  223 => PARAM_CTND_MWND,
  224 => PARAM_VDIFS_HUM,
  225 => PARAM_HTND_CUMCONV,
  226 => PARAM_HTND_LSCND,
  227 => PARAM_CNG_NHUM,
  228 => PARAM_PRECIP_TOT,
  229 => PARAM_STRESS_EW_SRF_IN,
  230 => PARAM_STRESS_NS_SRF_IN,
  231 => PARAM_HT_SRF_IN,
  232 => PARAM_MST_IN,
  233 => PARAM_APP_HUM_SRF,
  234 => PARAM_LRGN_HT_SRF,
  235 => PARAM_SKIN_TEMP,
  236 => PARAM_SOIL_TEMP,
  237 => PARAM_SOIL_WET,
  238 => PARAM_SNOW_TEMP,
  239 => PARAM_SNOW_FALL_CONV,
  240 => PARAM_SNOW_FALL_LS,
  241 => PARAM_CLOUD_TND,
  242 => PARAM_LW_TND,
  243 => PARAM_ALBEDO_FC,
  244 => PARAM_RGN_SRF_FC,
  245 => PARAM_RGN_NT_SRF_FC,
  246 => PARAM_CLOUD_LIQ,
  247 => PARAM_CLOUD_ICE,
  248 => PARAM_CLOUD_F,
  249 => PARAM_ICE_TND,
  250 => PARAM_ICE_AGE,
  251 => PARAM_TND_TEMP_AD,
  252 => PARAM_TND_HUM_AD,
  253 => PARAM_TND_ZWND_AD,
  254 => PARAM_TND_MWND_AD
}


PARAMS_ECMWF_162 = {   #inconmplte
  71 => PARAM_WATV_EFLX,
  72 => PARAM_WATV_NFLX,
  84 => PARAM_DIV_MST_FLX
}
