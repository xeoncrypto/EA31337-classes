//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
enum ENUM_TIMEFRAMES_INDEX {
  M1  =  0, // 1 minute
  M2  =  1, // 2 minutea (non-standard)
  M3  =  2, // 3 minutes (non-standard)
  M4  =  3, // 4 minutes (non-standard)
  M5  =  4, // 5 minutes
  M6  =  5, // 6 minutes (non-standard)
  M10 =  6, // 10 minutes (non-standard)
  M12 =  7, // 12 minutes (non-standard)
  M15 =  8, // 15 minutes
  M20 =  9, // 20 minutes (non-standard)
  M30 = 10, // 30 minutes
  H1  = 11, // 1 hour
  H2  = 12, // 2 hours (non-standard)
  H3  = 13, // 3 hours (non-standard)
  H4  = 14, // 4 hours
  H6  = 15, // 6 hours (non-standard)
  H8  = 16, // 8 hours (non-standard)
  H12 = 17, // 12 hours (non-standard)
  D1  = 18, // Daily
  W1  = 19, // Weekly
  MN1 = 20, // Monthly
  // This item should be the last one.
  // Used to calculate the number of enum items.
  FINAL_ENUM_TIMEFRAMES_INDEX = 21
};

/**
 * Class to provide methods to deal with timeframes.
 */
class Timeframe {
public:

  /**
   * Convert period to proper chart timeframe value.
   */
  static ENUM_TIMEFRAMES IndexToTf(int index) {
    switch (index) {
      case M1:  return PERIOD_M1;  // For 1 minute.
      case M2:  return PERIOD_M2;  // For 2 minutes (non-standard).
      case M3:  return PERIOD_M3;  // For 3 minutes (non-standard).
      case M4:  return PERIOD_M4;  // For 4 minutes (non-standard).
      case M5:  return PERIOD_M5;  // For 5 minutes.
      case M6:  return PERIOD_M6;  // For 6 minutes (non-standard).
      case M10: return PERIOD_M10; // For 10 minutes (non-standard).
      case M12: return PERIOD_M12; // For 12 minutes (non-standard).
      case M15: return PERIOD_M15; // For 15 minutes.
      case M20: return PERIOD_M20; // For 20 minutes (non-standard).
      case M30: return PERIOD_M30; // For 30 minutes.
      case H1:  return PERIOD_H1;  // For 1 hour.
      case H2:  return PERIOD_H2;  // For 2 hours (non-standard).
      case H3:  return PERIOD_H3;  // For 3 hours (non-standard).
      case H4:  return PERIOD_H4;  // For 4 hours.
      case H6:  return PERIOD_H6;  // For 6 hours (non-standard).
      case H8:  return PERIOD_H8;  // For 8 hours (non-standard).
      case H12: return PERIOD_H12; // For 12 hours (non-standard).
      case D1:  return PERIOD_D1;  // Daily.
      case W1:  return PERIOD_W1;  // Weekly.
      case MN1: return PERIOD_MN1; // Monthly.
      default:  return NULL;
    }
  }

  /**
   * Convert timeframe constant to period value.
   */
  static int TfToIndex(ENUM_TIMEFRAMES tf) {
    switch (tf) {
      case PERIOD_M1:  return M1;
      case PERIOD_M2:  return M2;
      case PERIOD_M3:  return M3;
      case PERIOD_M4:  return M4;
      case PERIOD_M5:  return M5;
      case PERIOD_M6:  return M6;
      case PERIOD_M10: return M10;
      case PERIOD_M12: return M12;
      case PERIOD_M15: return M15;
      case PERIOD_M20: return M20;
      case PERIOD_M30: return M30;
      case PERIOD_H1:  return H1;
      case PERIOD_H2:  return H2;
      case PERIOD_H3:  return H3;
      case PERIOD_H4:  return H4;
      case PERIOD_H6:  return H6;
      case PERIOD_H8:  return H8;
      case PERIOD_H12: return H12;
      case PERIOD_D1:  return D1;
      case PERIOD_W1:  return W1;
      case PERIOD_MN1: return MN1;
      default:         return NULL;
    }
  }

  /**
   * Convert timeframe constant to period value.
   */
  static string TfToString(ENUM_TIMEFRAMES tf) {
    switch (tf) {
      case PERIOD_M1:  return "M1";
      case PERIOD_M2:  return "M2";
      case PERIOD_M3:  return "M3";
      case PERIOD_M4:  return "M4";
      case PERIOD_M5:  return "M5";
      case PERIOD_M6:  return "M6";
      case PERIOD_M10: return "M10";
      case PERIOD_M15: return "M15";
      case PERIOD_M20: return "M20";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H2:  return "H2";
      case PERIOD_H3:  return "H3";
      case PERIOD_H4:  return "H4";
      case PERIOD_H6:  return "H6";
      case PERIOD_H8:  return "H8";
      case PERIOD_H12: return "H12";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return NULL;
    }
  }

  /**
   * Convert timeframe index to period value.
   */
  static string IndexToString(uint tfi) {
    return TfToString(IndexToTf(tfi));
  }

  /**
   * Validate whether given timeframe is valid.
   */
  static bool ValidTf(ENUM_TIMEFRAMES tf, string symbol = NULL) {
    double _ima = iMA(symbol, tf, 13, 8, MODE_SMMA, PRICE_MEDIAN, 0);
    #ifdef __trace__ PrintFormat("%s: Tf: %d, MA: %g", __FUNCTION__, tf, _ima); #endif
    return (iMA(symbol, tf, 13, 8, MODE_SMMA, PRICE_MEDIAN, 0) > 0);
  }

  /**
   * Validate whether given timeframe index is valid.
   */
  static bool ValidTfIndex(uint tfi, string symbol = NULL) {
    return ValidTf(IndexToTf(tfi), symbol);
  }

};
