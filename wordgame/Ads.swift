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
        request.testDevices = [kGADSimulatorID, "890a9822760b480afac36531dc5b622e"]
        return request
    }
    
    private init() {}
}

protocol InterstitialAdDelegate {
    func adIsReady(_ ad: GADInterstitial)
    func adDidDismissScreen()
}

class VideoInterstitialAd: NSObject, GADInterstitialDelegate {
    
    private(set) var ad: GADInterstitial!
    
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

@objc protocol RewardAdDelegate {
    func rewardAd(didRewardUser reward: GADAdReward)
    @objc optional func rewardAd(isReady rewardAd: GADRewardBasedVideoAd)
    @objc optional func rewardAd(isLoading rewardAd: GADRewardBasedVideoAd)
}

class RewardAd: NSObject, GADRewardBasedVideoAdDelegate {
    
    var ad: GADRewardBasedVideoAd
    
    var delegate: RewardAdDelegate? {
        didSet {
            load()
        }
    }
    
    override init() {
        ad = GADRewardBasedVideoAd.sharedInstance()
        
        super.init()
        
        ad.delegate = self
    }
    
    private func load() {
        if !ad.isReady {
            print("RewardAd.load")
            ad.load(AdsRequest.create(), withAdUnitID: "ca-app-pub-3278005872817682/4839443470")
            delegate?.rewardAd?(isLoading: ad)
        }
    }
    
    // MARK: GADRewardBasedVideoAdDelegate
    
    /// Tells the delegate that the reward based video ad has rewarded the user.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        print("rewardBasedVideoAd:didRewardUserWith")
        delegate?.rewardAd(didRewardUser: reward)
        load()
    }
    
    /// Tells the delegate that the reward based video ad failed to load.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        print("rewardBasedVideoAd:didFailToLoadWithError", error.localizedDescription)
//        load()
    }
    
    /// Tells the delegate that a reward based video ad was received.
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("rewardBasedVideoAdDidReceive")
        print("rewardBasedVideoAd is ready", rewardBasedVideoAd.isReady)
        delegate?.rewardAd?(isReady: rewardBasedVideoAd)
    }
    
    /// Tells the delegate that the reward based video ad opened.
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("rewardBasedVideoAdDidOpen")
    }
    
    /// Tells the delegate that the reward based video ad started playing.
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("rewardBasedVideoAdDidStartPlaying")
    }
    
    /// Tells the delegate that the reward based video ad closed.
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("rewardBasedVideoAdDidClose")
        load()
    }
    
    /// Tells the delegate that the reward based video ad will leave the application.
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("rewardBasedVideoAdWillLeaveApplication")
    }

}

