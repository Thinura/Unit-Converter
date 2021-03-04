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
    var conversionType = UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY
    var lastAddedConversionType = UserDefaultsKeys.Weight.LAST_WEIGHT_CONVERSION_USER_DEFAULTS_KEY
    var icon: UIImage = UIImageIcon.HistoryIcon.weightIcon!
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historySegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Delegates and data source
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
            conversionType = UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY
            lastAddedConversionType = UserDefaultsKeys.Weight.LAST_WEIGHT_CONVERSION_USER_DEFAULTS_KEY
            icon = UIImageIcon.HistoryIcon.weightIcon!
        case 1:
            conversionType = UserDefaultsKeys.Temperature.TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY
            lastAddedConversionType = UserDefaultsKeys.Temperature.LAST_TEMPERATURE_CONVERSION_USER_DEFAULTS_KEY
            icon = UIImageIcon.HistoryIcon.temperatureIcon!
        case 2:
            conversionType = UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY
            lastAddedConversionType = UserDefaultsKeys.Volume.LAST_VOLUME_CONVERSION_USER_DEFAULTS_KEY
            icon = UIImageIcon.HistoryIcon.volumeIcon!
        case 3:
            conversionType = UserDefaultsKeys.Speed.SPEED_CONVERSIONS_USER_DEFAULTS_KEY
            lastAddedConversionType = UserDefaultsKeys.Speed.LAST_SPEED_CONVERSION_USER_DEFAULTS_KEY
            icon = UIImageIcon.HistoryIcon.speedIcon!
        case 4:
            conversionType = UserDefaultsKeys.Length.LENGTH_CONVERSIONS_USER_DEFAULTS_KEY
            lastAddedConversionType = UserDefaultsKeys.Length.LAST_LENGTH_CONVERSION_USER_DEFAULTS_KEY
            icon = UIImageIcon
                .HistoryIcon.lengthIcon!
        default:
            break
        }
        generateHistoryCells(type: conversionType, icon: icon)
    }
    
    
    /// Generating history cells
    func generateHistoryCells(type: String, icon: UIImage) {
        allHistory = []
        ///Check conversion is volume
        if conversionType == UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY{
            /// adding volume to the history list
            let historyListVolume = UserDefaults.standard.value(forKey: conversionType) as? [String]
            if historyListVolume?.count ?? 0 > 0 {
                for conversion in historyListVolume! {
                    let history = History(type: type,icon: icon ,conversionDetails: conversion)
                    allHistory += [history]
                }
            }
            /// adding liquid volume to the history
            let conversionTypeLV = UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY
            let liquidVolumeIcon = UIImageIcon.HistoryIcon.liquidVolumeIcon!
            let historyListLiquidVolume = UserDefaults.standard.value(forKey: conversionTypeLV) as? [String]
            if historyListLiquidVolume?.count ?? 0 > 0 {
                for conversion in historyListLiquidVolume! {
                    let history = History(type: conversionTypeLV,icon: liquidVolumeIcon, conversionDetails: conversion)
                    allHistory += [history]
                }
            }
            
        }else{
            
            /// Read from user defaults
            let historyList = UserDefaults.standard.value(forKey: conversionType) as? [String]
            if historyList?.count ?? 0 > 0 {
                for conversion in historyList! {
                    let history = History(type: type,icon: icon, conversionDetails: conversion)
                    allHistory += [history]
                }
            }
        }
        
    }
    
    /// Checking whether the there is no data, if so delete button needs to be disabled
    func checkAvailabilityDeleteBarButton() {
        if allHistory.count > 0  {
            self.navigationItem.rightBarButtonItem!.isEnabled = true;
        } else {
            self.navigationItem.rightBarButtonItem!.isEnabled = false;
        }
    }
    
    /**
     This function clears the history of the current view
     */
    @IBAction func handleClearHistory(_ sender: UIBarButtonItem) {
        if allHistory.count > 0 {
            
            /// Clearing Liquid volume and volume
            if (conversionType == UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY || conversionType == UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY){
                //Volume UserDefaults clear
                UserDefaults.standard.set([], forKey: UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY)
                UserDefaults.standard.set([], forKey: UserDefaultsKeys.Volume.LAST_VOLUME_CONVERSION_USER_DEFAULTS_KEY)
                //Liquid Volume UserDefaults clear
                UserDefaults.standard.set([], forKey: UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY)
                UserDefaults.standard.set([], forKey: UserDefaultsKeys.LiquidVolume.LAST_LIQUID_VOLUME_CONVERSION_USER_DEFAULTS_KEY)
            }
            
            UserDefaults.standard.set([], forKey: conversionType)
            UserDefaults.standard.set([],forKey: lastAddedConversionType)
            
            showAlert(title: Alert.Success.title, message: Alert.Success.History.message)
            
            /// refresh history screen
            generateHistoryCells(type: conversionType, icon: icon)
            DispatchQueue.main.async{ self.historyTableView.reloadData() }
            checkAvailabilityDeleteBarButton()
        }
    }
    
    
}


extension HistoryViewController:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allHistory.count == 0 {
            
            self.historyTableView.setEmptyMessage(EmptyConversion.message.rawValue,UIColor.label)
        } else {
            self.historyTableView.restore()
        }
        
        return allHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        
        cell.historyConversionText.text = allHistory[indexPath.row].getHistoryConversionDetails()
        cell.historyConversionIcon.image = allHistory[indexPath.row].getHistoryIcon()
        
        // History cell styles
        cell.isUserInteractionEnabled = false
        cell.contentView.layer.masksToBounds = false
        
        return cell
    }
    
    
}
