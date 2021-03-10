//
//  UserDefaultsKeyHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-03-03.
//

import Foundation

struct UserDefaultsKeys {
    /// Weight conversions are saved by type "weight" in User defaults
    struct Weight {
        static let WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY = "weight"
        static let WEIGHT_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5
        static let LAST_WEIGHT_CONVERSION_USER_DEFAULTS_KEY = "lastAddWeight"
        static let LAST_EDITED_FIELD_WEIGHT_CONVERSION_TAG_USER_DEFAULTS_KEY = "lastEditedFieldWeight"
    }
    struct Length {
        static let LENGTH_CONVERSIONS_USER_DEFAULTS_KEY = "length"
        static let LENGTH_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5
        static let LAST_LENGTH_CONVERSION_USER_DEFAULTS_KEY = "lastAddLength"
        static let LAST_EDITED_FIELD_LENGTH_CONVERSION_TAG_USER_DEFAULTS_KEY = "lastEditedFieldLength"
    }
    struct Speed {
        static let SPEED_CONVERSIONS_USER_DEFAULTS_KEY = "speed"
        static let SPEED_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5
        static let LAST_SPEED_CONVERSION_USER_DEFAULTS_KEY = "lastAddSpeed"
        static let LAST_EDITED_FIELD_SPEED_CONVERSION_TAG_USER_DEFAULTS_KEY = "lastEditedFieldSpeed"
    }
    struct Volume {
        static let VOLUME_CONVERSIONS_USER_DEFAULTS_KEY = "volume"
        static let VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5
        static let LAST_VOLUME_CONVERSION_USER_DEFAULTS_KEY = "lastAddVolume"
        static let LAST_EDITED_FIELD_VOLUME_CONVERSION_TAG_USER_DEFAULTS_KEY = "lastEditedFieldVolume"
    }
    struct LiquidVolume {
        static let LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY = "liquidVolume"
        static let LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5
        static let LAST_LIQUID_VOLUME_CONVERSION_USER_DEFAULTS_KEY = "lastAddLiquidVolume"
        static let LAST_EDITED_FIELD_LIQUID_VOLUME_CONVERSION_TAG_USER_DEFAULTS_KEY = "lastEditedFieldLiquidVolume"
    }
    struct Temperature {
        static let TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY = "temperature"
        static let TEMPERATURE_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5
        static let LAST_TEMPERATURE_CONVERSION_USER_DEFAULTS_KEY = "lastAddTemperature"
        static let LAST_EDITED_FIELD_TEMPERATURE_CONVERSION_TAG_USER_DEFAULTS_KEY = "lastEditedFieldTemperature"
    }
    struct Settings {
        static let DECIMAL_DIGIT_USER_DEFAULTS_KEY = "decimal"
    }
}
