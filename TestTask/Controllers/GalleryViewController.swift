//
//  GalleryViewController.swift
//  TestTask
//
//  Created by Bobby numdevios on 24.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var hidenLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var imagesData:[ImageModel] = []
    fileprivate let reuseIdentifier = "ImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        getData()
    }
    
    func getData(){
        NetworkManager.shared.getAll(success: { (images) in
            self.imagesData = images
            self.collectionView.reloadData()
            self.hidenLabel.isHidden = (self.imagesData.count != 0)
        },fail: { (error) in
            AlertsManager.shared.presentAlert(self, title: "Error", message: error)
        })
    }
    //MARK: - Actions
    
    @IBAction func playGifTapped(_ sender: UIBarButtonItem) {
        if imagesData.count == 0 {return}
        guard let weather = imagesData.last?.parameters?.weather else {return}
        NetworkManager.shared.getGif(weather: weather, success: { url in
            print(url)
            let image = UIImage.gifImageWithURL(url)
            let alert = CustomAlertView(image: image!)
            alert.show(animated: true)
        }, fail: { (error) in
            AlertsManager.shared.presentAlert(self, title: "Error", message: error)
        })
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImagesCell
        cell.update(imageModel: imagesData[row])
        return cell
    }
    
    @objc(collectionView:layout:sizeForItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin : CGFloat = 5;
        let itemsPerRow : CGFloat = 2;
        let allMargins = margin * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - allMargins
        let width = availableWidth / itemsPerRow
        print(width)
        return CGSize(width: width, height: width)
    }
}
