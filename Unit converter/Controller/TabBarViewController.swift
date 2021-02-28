//
//  TabBarViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class TabBarViewController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch viewController{
        case is ConversionsViewController:
            print("User is in in Conversions view")
        case is HistoryViewController:
            print("User is in in history view")
        case is SettingsViewController:
            print("User is in in settings view")
        default:
            print("No screen available")
        }
    }
}
