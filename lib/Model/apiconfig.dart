import 'package:addrive/Model/campaigns_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'https://addrive.kkms.co.in';
  }
  
  static String get registerdriverUrl {
    return '$baseUrl/api/driver/register/';
  }
  
  static String get loginUrl {
    return '$baseUrl/api/driver/login/';
  }

  static String get verifyOtpUrl {
    return '$baseUrl/api/driver/verify-otp/';
  }

  static String get resendOtpUrl {
    return '$baseUrl/api/driver/resend-otp/';
  }

  static String get forgotPasswordUrl {
    return '$baseUrl/api/driver/forgot-password/';
  }

  // static String get resetPasswordUrl {
  //   return '$baseUrl/api/driver/reset-password/';
  // }

  static String get personalDetailsUrl {
    return '$baseUrl/api/driver/profile-details/';
  }

  static String get bankDetailsUrl {
    return '$baseUrl/api/driver/bank-details/';
  }

  static String get vehicleDetailsUrl {
    return '$baseUrl/api/driver/vehicle-details/';
  }

  static String get fullDetailsUrl {
    return '$baseUrl/api/driver/full-details/';
  }

  static String get fleetListingUrl {
    return '$baseUrl/api/driver/active_fleets/';
  }

  static String get campaignListingUrl {
    return '$baseUrl/api/driver/campaigns/';
  }

  static String joinCampaignUrl(String campaignId) {
  return '$baseUrl/api/driver/join-campaign/$campaignId/';
}
 
 static String  cancelRequestsUrl(String requestId) {
    return '$baseUrl/api/campaign/cancel-request/$requestId/';
  }

  static String get CampaignButton {
    return '$baseUrl/api/driver/campaign-requests/';
  }
}