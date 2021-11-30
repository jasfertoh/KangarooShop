//
//  HomeTableViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 3/11/21.
//

import UIKit

var currentUser: UserData?
var currentItem: ItemData?
class HomeViewController: UIViewController {
    var imageArray = [String]()
    var titleArray = [String]()
    var priceArray = [Double]()
    var descriptionArray = [String]()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var creditCount: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // set fixed width and height for the collection view cells
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 180, height: 180)
        collectionView.collectionViewLayout = layout
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        searchBar.delegate = self
        // set the welcome text to user's first name and credit count
        welcomeLabel.text = "Welcome, \(currentUser!.firstName)"
        creditCount.title = "\(currentUser!.credits.round(to: 2))"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        creditCount.title = "\(currentUser!.credits.round(to: 2))"
    }
    @IBAction func walletTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toWallet", sender: nil)
    }
    @IBAction func cartTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toCart", sender: nil)
    }
    
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if searchBar.text == "" {
            //if search bar has no text, display all the available products
            currentItem = ItemData(productTitle: DataArray.itemArray[1][indexPath.row], productImage: DataArray.itemArray[0][indexPath.row], productPrice: Double(DataArray.priceArray[indexPath.row]), productDescription: DataArray.descriptionArray[indexPath.row])
        } else {
            // if searchbar is not empty, display the products containing the word in the searchbar
            currentItem = ItemData(productTitle: titleArray[indexPath.row], productImage: imageArray[indexPath.row], productPrice: priceArray[indexPath.row], productDescription: descriptionArray[indexPath.row])
        }
        
        performSegue(withIdentifier: "toDetails", sender: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        cell.layer.cornerRadius = 6
        cell.layer.borderWidth = 1
        titleArray = [String]()
        imageArray = [String]()
        if searchBar.text == "" {
            // set each cell to display each available product
            cell.configure(with: UIImage(named: DataArray.itemArray[0][indexPath.row])!, productTitle: DataArray.itemArray[1][indexPath.row])
        } else {
            // filter out products containing the text in the title
            titleArray = [String]()
            imageArray = [String]()
            descriptionArray = [String]()
            priceArray = [Double]()
            for title in DataArray.itemArray[1] {
                if title.lowercased().contains(searchBar.text!.lowercased()) {
                titleArray.append(title)
                imageArray.append(DataArray.itemArray[0][DataArray.itemArray[1].firstIndex(of: title)!])
                descriptionArray.append(DataArray.descriptionArray[DataArray.itemArray[1].firstIndex(of: title)!])
                priceArray.append(Double(DataArray.priceArray[DataArray.itemArray[1].firstIndex(of: title)!]))
                }
            }
            // set each cell to display the products containing the text in the searchbar.
            cell.configure(with: UIImage(named: imageArray[indexPath.row])!, productTitle: titleArray[indexPath.row])
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBar.text == "" {
            return DataArray.itemArray[1].count
        } else {
            titleArray = [String]()
            imageArray = [String]()
            for title in DataArray.itemArray[1] {
                if title.lowercased().contains(searchBar.text!.lowercased()) {
                    titleArray.append(title)
                    imageArray.append(DataArray.itemArray[0][DataArray.itemArray[1].firstIndex(of: title)!])
                }
            }
            return titleArray.count
            
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 180)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        collectionView.reloadData()
    }
}

