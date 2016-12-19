//
//  TestAdsViewController.swift
//  wordgame
//
//  Created by Marek Mako on 19/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TestAdsViewController: UIViewController, UIAlertViewDelegate, GADInterstitialDelegate {
    
    private var interstitial: GADInterstitial! {
        didSet {
            interstitial.delegate = self
        }
    }
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var interstitialButton: UIButton!
    
    @IBAction func onInterstitialClick() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            
        } else {
            print("interstitial is no ready")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitialButton.isEnabled = false
        createAndLoadInterstitial()

        bannerView.adUnitID = "ca-app-pub-3278005872817682/9962803872"
        bannerView.rootViewController = self
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "890a9822760b480afac36531dc5b622e"]
        
        bannerView.load(request)
    }
    
    private func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3278005872817682/8067268277")
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "890a9822760b480afac36531dc5b622e"]
        
        interstitial.load(request)
    }
    
    // MARK: GADInterstitialDelegate
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        interstitialButton.isEnabled = true
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        let alert = UIAlertController(title: "interstitial:didFailToReceiveAdWithError", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
