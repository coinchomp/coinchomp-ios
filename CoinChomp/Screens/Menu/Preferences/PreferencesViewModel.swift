//
//  PreferencesViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/7/21.
//

import Foundation
import UIKit

class PreferencesViewModel : ObservableObject {
    
    let auth = AuthService.shared
    
    @Published var fontSizeForHeading = PreferencesService.shared.fontSizeForHeading()
    @Published var fontSizeForBody = PreferencesService.shared.fontSizeForBody()
    @Published var fontSizeForCaption = PreferencesService.shared.fontSizeForCaption()
       
    @Published var hideAdsEnabled : Bool {
        didSet {
            let defaults = UserDefaults.standard
            defaults.setValue(hideAdsEnabled, forKey: prefsHideAdsEnabledKey)
        }
    }
    
    @Published var hideAlreadyViewedLinks : Bool {
        didSet {
            let defaults = UserDefaults.standard
            defaults.setValue(hideAlreadyViewedLinks, forKey: prefsHideAlreadyViewedLinksKey)
        }
    }
    
    @Published var frontPageDividersEnabled : Bool {
        didSet {
            let defaults = UserDefaults.standard
            defaults.setValue(frontPageDividersEnabled, forKey: prefsFrontPageDividersEnabledKey)
        }
    }

    @Published var autoPasteEnabled : Bool {
        didSet {
            let defaults = UserDefaults.standard
            defaults.setValue(autoPasteEnabled, forKey: prefsAutoPasteEnabledKey)
        }
    }
    @Published var textSize : CGFloat {
        didSet {
            let defaults = UserDefaults.standard
            defaults.setValue(textSize, forKey: prefsTextSizeKey)
            refreshFontSizes()
        }
    }

    init(){
        self.frontPageDividersEnabled = false
        self.hideAdsEnabled = false
        self.hideAlreadyViewedLinks = false
        self.autoPasteEnabled = false
        self.textSize = 1.0
        let defaults = UserDefaults.standard
        if defaults.object(forKey: prefsFrontPageDividersEnabledKey) == nil {
            defaults.setValue(self.frontPageDividersEnabled, forKey: prefsFrontPageDividersEnabledKey)
        }
        if defaults.object(forKey: prefsAutoPasteEnabledKey) == nil {
            defaults.setValue(self.autoPasteEnabled, forKey: prefsAutoPasteEnabledKey)
        }
        if defaults.object(forKey: prefsTextSizeKey) == nil {
            defaults.setValue(self.textSize, forKey: prefsTextSizeKey)
        }
        if let ap = defaults.value(forKey: prefsAutoPasteEnabledKey) as? Bool {
            self.autoPasteEnabled = ap
        }
        if let hav = defaults.value(forKey: prefsHideAlreadyViewedLinksKey) as? Bool {
            self.hideAlreadyViewedLinks = hav
        }
        if let ts = defaults.value(forKey: prefsTextSizeKey) as? CGFloat {
            self.textSize = ts
        }
        if let hae = defaults.value(forKey: prefsHideAdsEnabledKey) as? Bool {
            self.hideAdsEnabled = hae
        }
    }
    
    func refreshFontSizes() {
        frontPageDividersEnabled = PreferencesService.shared.frontPageDividersEnabled()
        fontSizeForHeading = PreferencesService.shared.fontSizeForHeading()
        fontSizeForBody = PreferencesService.shared.fontSizeForBody()
        fontSizeForCaption = PreferencesService.shared.fontSizeForCaption()
    }
}
