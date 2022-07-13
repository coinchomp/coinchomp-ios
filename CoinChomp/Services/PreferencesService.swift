//
//  PreferencesService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/8/21.
//

import Foundation
import Firebase

let prefsHideAdsEnabledKey = "hideAdsEnabled"
let prefsAutoPasteEnabledKey = "autoPasteEnabled"
let prefsTextSizeKey = "textSize"
let prefsFrontPageDividersEnabledKey = "frontPageDividersEnabled"
let prefsHideAlreadyViewedLinksKey = "hideAlreadyViewedLinks"
let prefsMarkAlreadyViewedLinksKey = "markAlreadyViewedLinks"

class PreferencesService {
    
    let fontSizeHeading : CGFloat = 20.0
    let fontSizeLinkTitle : CGFloat = 17.0
    let fontSizeLinkTitleHeadline : CGFloat = 40.0
    let fontSizeBody : CGFloat = 16.0
    let fontSizeCaption : CGFloat = 12.0
    
  static let shared = PreferencesService()
    
    func hideAdsEnabled() -> Bool {
        let defaults = UserDefaults.standard
        if let hae = defaults.value(forKey: prefsHideAdsEnabledKey) as? Bool {
            return hae
        }
        return false
    }
    
    func autoPasteEnabled() -> Bool {
        let defaults = UserDefaults.standard
        if let ape = defaults.value(forKey: prefsAutoPasteEnabledKey) as? Bool {
            return ape
        }
        return false
    }
    
    func markAlreadyViewedLinksEnabled() -> Bool {
        let defaults = UserDefaults.standard
        if let mav = defaults.value(forKey: prefsMarkAlreadyViewedLinksKey) as? Bool {
            return mav
        }
        return false
    }
    
    
    func hideAlreadyViewedLinksEnabled() -> Bool {
        let defaults = UserDefaults.standard
        if let hav = defaults.value(forKey: prefsHideAlreadyViewedLinksKey) as? Bool {
            return hav
        }
        return false
    }
    
    func frontPageDividersEnabled() -> Bool {
        let defaults = UserDefaults.standard
        if let fpd = defaults.value(forKey: prefsFrontPageDividersEnabledKey) as? Bool {
            return fpd
        }
        return true
    }
    
    func fontSizeForHeading() -> CGFloat {
        let defaults = UserDefaults.standard
        if let ts = defaults.value(forKey: prefsTextSizeKey) as? CGFloat {
            return ts * fontSizeHeading
        }
        return fontSizeHeading
    }
    
    func fontSizeForLinkTitle() -> CGFloat {
        let defaults = UserDefaults.standard
        if let ts = defaults.value(forKey: prefsTextSizeKey) as? CGFloat {
            return ts * fontSizeLinkTitle
        }
        return fontSizeLinkTitle
    }
    
    func fontSizeForLinkTitleHeadline() -> CGFloat {
        let defaults = UserDefaults.standard
        if let ts = defaults.value(forKey: prefsTextSizeKey) as? CGFloat {
            return ts * fontSizeLinkTitleHeadline
        }
        return fontSizeLinkTitleHeadline
    }
    
    func fontSizeForBody() -> CGFloat {
        let defaults = UserDefaults.standard
        if let ts = defaults.value(forKey: prefsTextSizeKey) as? CGFloat {
            return ts * fontSizeBody
        }
        return fontSizeBody
    }
    
    func fontSizeForCaption() -> CGFloat {
        let defaults = UserDefaults.standard
        if let ts = defaults.value(forKey: prefsTextSizeKey) as? CGFloat {
            return ts * fontSizeCaption
        }
        return fontSizeCaption
    }
}
