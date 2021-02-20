//
//  HistoryViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit
class HistoryViewController: UIViewController {
    

    /// Default variables
    var allHistory = [History]()

    var conversionType = WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY
    var icon: UIImage = UIImage(named: "icon_weight")!
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historySegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Initialising initial segment cells
        generateHistoryCells(type: conversionType, icon: icon)
        DispatchQueue.main.async { self.historyTableView.reloadData() }
        
        // checks if the clear button should be visible
        checkAvailabilityDeleteBarButton()
    }
    
    
    /**
     This function handle the segment control and also render the data for respective content type, conversion icon and detailed history about the history of conversion
     */
    @IBAction func handleUnitsSegmentControl(_ sender: UISegmentedControl) {
        initSegmentUnit(index: historySegmentControl.selectedSegmentIndex)
        
        DispatchQueue.main.async { self.historyTableView.reloadData() }
        
        // checks if the clear button should be visible
        checkAvailabilityDeleteBarButton()
    }
    
    /// Initialising the segment with cell data
    func initSegmentUnit(index: Int) {
        
        switch index {
        case 0:
            conversionType = WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY
            icon = UIImage(named: "icon_weight")!
        case 1:
            conversionType = TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY
            icon = UIImage(named: "icon_temperature")!
        case 2:
            conversionType = VOLUME_CONVERSIONS_USER_DEFAULTS_KEY
            icon = UIImage(named: "icon_volume")!
        case 3:
            conversionType = SPEED_CONVERSIONS_USER_DEFAULTS_KEY
            icon = UIImage(named: "icon_speed")!
        default:
            break
        }
        generateHistoryCells(type: conversionType, icon: icon)
    }
    
    
    /// Generating history cells
    func generateHistoryCells(type: String, icon: UIImage) {
        allHistory = []
        ///Check conversion is volume
        if conversionType == VOLUME_CONVERSIONS_USER_DEFAULTS_KEY{
            /// adding volume to the history list
            let historyListVolume = UserDefaults.standard.value(forKey: conversionType) as? [String]
            if historyListVolume?.count ?? 0 > 0 {
                for conversion in historyListVolume! {
                    let history = History(type: type,icon: icon ,conversionDetails: conversion)
                    allHistory += [history]
                }
            }
            /// adding liquid volume to the history
            conversionType = LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY
            self.icon = UIImage(named: "icon_liquidVolume")!
            let historyListLiquidVolume = UserDefaults.standard.value(forKey: conversionType) as? [String]
            if historyListLiquidVolume?.count ?? 0 > 0 {
                for conversion in historyListLiquidVolume! {
                    let history = History(type: type,icon: icon, conversionDetails: conversion)
                    allHistory += [history]
                }
            }
            
        
        }else{
            
         let historyList = UserDefaults.standard.value(forKey: conversionType) as? [String]
            if historyList?.count ?? 0 > 0 {
                for conversion in historyList! {
                    let history = History(type: type,icon: icon, conversionDetails: conversion)
                    allHistory += [history]
                }
            }
        }
        
    }
    
    /// Checking whether the there is no data, if so save button needs to be disabled
    func checkAvailabilityDeleteBarButton() {
        print(allHistory.count)
        if allHistory.count > 0  {
            self.navigationItem.rightBarButtonItem!.isEnabled = true;
        } else {
            self.navigationItem.rightBarButtonItem!.isEnabled = false;
        }
    }
}



extension HistoryViewController:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allHistory.count == 0 {
            
            self.historyTableView.setEmptyMessage("No saved conversions found", UIColor.black)
        } else {
            self.historyTableView.restore()
        }
        
        return allHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        
        cell.historyConversionText.text = allHistory[indexPath.row].getHistoryConversionDetails()
        cell.historyConversionIcon.image = allHistory[indexPath.row].getHistoryIcon()
        
        // Card(cell) styles
        cell.isUserInteractionEnabled = false
        /*cell.contentView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.00)
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.00).cgColor*/
        cell.contentView.layer.masksToBounds = false
        
        return cell
    }
    
    
}
