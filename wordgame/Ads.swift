//
//  Ads.swift
//  wordgame
//
//  Created by Marek Mako on 19/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import Foundation
import GoogleMobileAds

class AdsRequest {
    
    class func create() -> GADRequest {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID,
                               "890a9822760b480afac36531dc5b622e"]
        return request
    }
    
    private init() {}
}

protocol InterstitialAdDelegate {
    func adIsReady(_ ad: GADInterstitial)
    func adDidDismissScreen()
}

class VideoInterstitialAd: NSObject, GADInterstitialDelegate {
    
    private var ad: GADInterstitial!
    
    var delegate: InterstitialAdDelegate?
    
    override init() {
        super.init()
        
        ad = createAndLoadAd()
    }
    
    private func createAndLoadAd() -> GADInterstitial {
        let ad = GADInterstitial(adUnitID: "ca-app-pub-3278005872817682/8067268277")
        ad.delegate = self
        ad.load(AdsRequest.create())
        return ad
    }
    
    // MARK: GADInterstitialDelegate
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        delegate?.adIsReady(ad)
        print("interstitialDidReceiveAd")
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        self.ad = createAndLoadAd()
        delegate?.adDidDismissScreen()
    }
}

