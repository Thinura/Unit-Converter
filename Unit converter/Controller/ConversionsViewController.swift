//
//  ConversionsViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-15.
//

import UIKit

class ConversionsViewController: UIViewController {
    
    @IBOutlet var conversionsCollectionView: UICollectionView!
    
    /// Defaults
    var conversionsCell = [Conversion]()
    var cellItemSpacing = 10.0
    var cellLineSpacing =  15.0
    
    /// Initialising the conversionDetails tuple with the supported conversions
    let conversionDetails:(weightConversion:Conversion, temperatureConversion:Conversion, volumeConversion:Conversion, liquidVolumeConversion:Conversion, lengthConversion:Conversion, speedConversion:Conversion) = (
        
        /// Details about WEIGHT cell
        Conversion(name: "Weight",
                   icon: UIImage(named:"icon_weight")!,
                   segueIdentifier: "weightSegue"),
        
        /// Details about TEMPERATURE cell
        Conversion(name: "Temperature",
                   icon: UIImage(named:"icon_temperature")!,
                   segueIdentifier: "temperatureSegue"),
        
        /// Details about VOLUME cell
        Conversion(name: "Volume",
                   icon: UIImage(named:"icon_volume")!,
                   segueIdentifier: "volumeSegue"),
        
        /// Details about LIQUID VOLUME cell
        Conversion(name: "Liquid Volume",
                   icon: UIImage(named:"icon_liquidVolume")!,
                   segueIdentifier: "liquidVolumeSegue"),
        
        /// Details about LENGTH cell
        Conversion(name: "Length",
                   icon: UIImage(named:"icon_length")!,
                   segueIdentifier: "lengthSegue"),
        
        /// Details about SPEED cell
        Conversion(name: "Speed",
                   icon: UIImage(named:"icon_speed")!,
                   segueIdentifier: "speedSegue")
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Delegates and data source
        self.conversionsCollectionView.delegate = self
        self.conversionsCollectionView.dataSource = self
        
        // GridView
        self.setupGridView()
        
        // Generate the cells
        self.generateConversionCell()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupGridView()
        DispatchQueue.main.async {
            self.conversionsCollectionView.reloadData()
        }
    }
    
    /// generateConversionCell() - Function will generate the cells for the conversions
    func generateConversionCell() {
        
        let weightConversionDetails = conversionDetails.weightConversion
        let temperatureConversionDetails = conversionDetails.temperatureConversion
        let volumeConversionDetails = conversionDetails.volumeConversion
        let liquidVolumeConversionDetails = conversionDetails.liquidVolumeConversion
        let lengthConversionDetails = conversionDetails.lengthConversion
        let speedConversionDetails = conversionDetails.speedConversion
        
        conversionsCell += [weightConversionDetails, temperatureConversionDetails, volumeConversionDetails, liquidVolumeConversionDetails, lengthConversionDetails, speedConversionDetails]
        
    }
    
    /// Setting up the grid with 2 columns
    func setupGridView() {
        let flow = conversionsCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellItemSpacing)
        flow.minimumLineSpacing = CGFloat(self.cellLineSpacing)
    }
    
}

/// Extension for ConversionsViewController to override the UICollectionViewDataSource and UICollectionViewDelegate
/// To initialise  the number of cells
/// To initialise the cell image
/// To initialise the button click method

extension ConversionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversionsCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConversionCell", for: indexPath) as! ConversionViewCell
        cell.conversionIcon.image = conversionsCell[indexPath.row].getConversionIcon()
        cell.contentView.layer.masksToBounds = false
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: conversionsCell[indexPath.row].getSegueIdentifier(), sender: self)
    }
    
    
}
