

import Foundation
import UIKit


public enum Environment: String {
    case Staging = "staging"
    case Production = "production"
    case StagingV2 = "StagingV2"


    var baseURL: String {
        switch self {
        case .Staging: return "https://r6g753nsac.execute-api.us-east-1.amazonaws.com/dev/"
        case .Production: return "https://r6g753nsac.execute-api.us-east-1.amazonaws.com/dev/"
        case .StagingV2 : return "https://r6g753nsac.execute-api.us-east-1.amazonaws.com/dev/"
            
//        case .Staging: return "https://ul7g3vvzwi.execute-api.us-east-1.amazonaws.com/prod/"
//        case .Production: return "https://ul7g3vvzwi.execute-api.us-east-1.amazonaws.com/prod/"
//        case .StagingV2 : return "https://ul7g3vvzwi.execute-api.us-east-1.amazonaws.com/prod/"
        }
    }
    
    var googleApisKey: String {
        switch self {
        case .Staging: return "AIzaSyB__kkDzuHpGrqEkySwRWrgKDiW4NsFTWQ"
        case .Production: return "AIzaSyA23kpVPqmJ40hcxUOI1U4R9lhY0Buue_Y"
        case .StagingV2: return "AIzaSyA23kpVPqmJ40hcxUOI1U4R9lhY0Buue_Y"

        }
    }
    
    var isProductionaENV: Bool {
          switch self {
          case .Staging: return false
          case .Production: return true
          case .StagingV2: return true

          }
      }
    
 
}


struct Configuration {
     var environment: Environment = {
        if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration == "Staging" {
                return Environment.Staging
            }else if configuration == "StagingV2" {
                return Environment.StagingV2
            }
        }

        return Environment.Production
    }()
}
