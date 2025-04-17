# Set working environment
reticulate::py_install("scikit-learn")
reticulate::py_install("pandas")

# Load Chicago shapefile for leaflet plots
zip_codes <- st_read('chicago_shapefile/chicago.shp')
zip_codes <- st_transform(zip_codes, crs = 4326)

# Load smote synthetic data
smote_data <- read.csv('data/model_df.csv')
factor_cols <- c('TRAFFIC_CONTROL_DEVICE', 'DEVICE_CONDITION', 'WEATHER_CONDITION',
                 'LIGHTING_CONDITION', 'FIRST_CRASH_TYPE', 'TRAFFICWAY_TYPE',
                 'ROADWAY_SURFACE_COND', 'zip', 'POSTED_SPEED_LIMIT', 'severe')
smote_data[factor_cols] <- lapply(smote_data[factor_cols], as.factor)
model_df <- read.csv('data/model_df.csv')

# Mapping for label encoder
zip_map <- list(
  "60601"=0, "60602"=1, "60603"=2, "60604"=3, "60605"=4, "60606"=5, "60607"=6, "60608"=7, "60609"=8,
  "60610"=9, "60611"=10, "60612"=11, "60613"=12, "60614"=13, "60615"=14, "60616"=15, "60617"=16,
  "60618"=17, "60619"=18, "60620"=19, "60621"=20, "60622"=21, "60623"=22, "60624"=23, "60625"=24,
  "60626"=25, "60628"=26, "60629"=27, "60630"=28, "60631"=29, "60632"=30, "60633"=31, "60634"=32,
  "60636"=33, "60637"=34, "60638"=35, "60639"=36, "60640"=37, "60641"=38, "60642"=39, "60643"=40,
  "60644"=41, "60645"=42, "60646"=43, "60647"=44, "60649"=45, "60651"=46, "60652"=47, "60653"=48,
  "60654"=49, "60655"=50, "60656"=51, "60657"=52, "60659"=53, "60660"=54, "60661"=55, "60666"=56,
  "60707"=57, "60827"=58
)

enc <- list(
  TRAFFIC_CONTROL_DEVICE = list("NO CONTROLS"=0, "STOP SIGN/FLASHER"=1, "TRAFFIC SIGNAL"=2, "YIELD"=3),
  DEVICE_CONDITION = list("FUNCTIONING IMPROPERLY"=0, "FUNCTIONING PROPERLY"=1, "NOT FUNCTIONING"=2),
  WEATHER_CONDITION = list("CLEAR"=0, "CLOUDY/OVERCAST"=1, "RAIN"=2, "SNOW"=3),
  LIGHTING_CONDITION = list("DARKNESS"=0, "DARKNESS, LIGHTED ROAD"=1, "DAYLIGHT"=2, "LOW LIGHT"=3),
  FIRST_CRASH_TYPE = list("HIGH IMPACT"=0, "INTERSECTION"=1, "OTHER"=2, "PEDESTRIAN/BIKE"=3,
                          "REAR IMPACT"=4, "SIDESWIPE"=5, "STATIONARY/FIXED"=6),
  TRAFFICWAY_TYPE = list("ACCESS AREA"=0, "DIVIDED ROAD"=1, "INTERSECTION"=2, "STANDARD ROAD"=3,
                         "UNDIVIDED ROAD"=4),
  ROADWAY_SURFACE_COND = list("DRY"=0, "ICE"=1, "SNOW OR SLUSH"=2, "WET"=3),
  POSTED_SPEED_LIMIT = list("(0-15) VERY LOW"=0, "(16-25) LOW"=1, "(26-35) MODERATE"=2,
                            "(36-45) HIGH"=3, "(46+) VERY HIGH"=4)
)

# Store the model using python interpreter and pickle model
py_run_string("
import pickle
with open('model/rf_classifier.pkl', 'rb') as f:
    rf_model = pickle.load(f)
")