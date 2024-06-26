
import Foundation

public enum APIsEndPoints: String {
    case ksignupUser = "customers"
    case krequest = "requests"
    case kRequestList = "customers/requests/list"
    case kGetCustor = "customers/requests/"
    case kConfirmArrival = "requests/confirmarrival/"
    case kCancelRequest = "requests/cancel/"
    case kGetMe = "customers/me"
    case kUploadImage = "customers/pre-signed-url?count=1"
    case kUpdateInviteLink  = "customers/update/invitelink"
    case kgetAds = "customer/getAds"
}
