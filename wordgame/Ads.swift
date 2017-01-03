//
//  Ads.swift
//  wordgame
//
//  Created by Marek Mako on 19/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import Foundation
import GoogleMobileAds

class AdsContainer {
    
    static let shared = AdsContainer()
    
    let videoInterstitialAd: VideoInterstitialAd
    let rewardAd: RewardAd
    
    class func loadAds() {
        let _ = AdsContainer.shared
    }
    
    private init() {
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3278005872817682~8486070675")
        videoInterstitialAd = VideoInterstitialAd()
        rewardAd = RewardAd()
    }
}

class AdsRequest {
    
    class func create() -> GADRequest {
        let request = GADRequest()
        #if DEBUG
            request.testDevices = [kGADSimulatorID, "890a9822760b480afac36531dc5b622e", "b10394fda1adcb1b6c9f4042ff79f21d"]
        #endif
        return request
    }
    
    private init() {}
}

protocol InterstitialAdDelegate: class {
    func adIsReady(_ ad: GADInterstitial)
    func adDidDismissScreen()
    func addWillLeaveApplication()
}

class VideoInterstitialAd: NSObject, GADInterstitialDelegate {
    
    private(set) var ad: GADInterstitial!
    
    weak var delegate: InterstitialAdDelegate?
    
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
        #if DEBUG
            print("interstitialDidReceiveAd")
        #endif
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        #if DEBUG
            print("interstitialDidDismissScreen")
        #endif
        self.ad = createAndLoadAd()
        delegate?.adDidDismissScreen()
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        #if DEBUG
            print("interstitialWillLeaveApplication")
        #endif
    }
    
    #if DEBUG
    deinit {
        print(#function, self)
    }
    #endif
}

@objc protocol RewardAdDelegate: class {
    func rewardAd(didRewardUser reward: GADAdReward)
    @objc optional func rewardAd(isReady rewardAd: GADRewardBasedVideoAd)
    @objc optional func rewardAd(isLoading rewardAd: GADRewardBasedVideoAd)
}

class RewardAd: NSObject, GADRewardBasedVideoAdDelegate {

    var ad: GADRewardBasedVideoAd
    
    weak var delegate: RewardAdDelegate? {
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
            #if DEBUG
                print("RewardAd.load")
            #endif
            ad.load(AdsRequest.create(), withAdUnitID: "ca-app-pub-3278005872817682/4839443470")
            delegate?.rewardAd?(isLoading: ad)
        }
    }
    
    // MARK: GADRewardBasedVideoAdDelegate
    
    /// Tells the delegate that the reward based video ad has rewarded the user.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        #if DEBUG
            print("rewardBasedVideoAd:didRewardUserWith")
        #endif
        delegate?.rewardAd(didRewardUser: reward)
        load()
    }
    
    /// Tells the delegate that the reward based video ad failed to load.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        #if DEBUG
            print("rewardBasedVideoAd:didFailToLoadWithError", error.localizedDescription)
        #endif
    }
    
    /// Tells the delegate that a reward based video ad was received.
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdDidReceive")
            print("rewardBasedVideoAd is ready", rewardBasedVideoAd.isReady)
        #endif
        delegate?.rewardAd?(isReady: rewardBasedVideoAd)
    }
    
    /// Tells the delegate that the reward based video ad opened.
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdDidOpen")
        #endif
    }
    
    /// Tells the delegate that the reward based video ad started playing.
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdDidStartPlaying")
        #endif
    }
    
    /// Tells the delegate that the reward based video ad closed.
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdDidClose")
        #endif
        load()
    }
    
    /// Tells the delegate that the reward based video ad will leave the application.
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        #if DEBUG
            print("rewardBasedVideoAdWillLeaveApplication")
        #endif
    }
    
    #if DEBUG
    deinit {
        print(#function, self)
    }
    #endif
}

