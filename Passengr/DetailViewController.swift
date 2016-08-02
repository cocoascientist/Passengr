//
//  DetailViewController.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/25/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

private let reuseIdentifier = String(PassDetailCell.self)

class DetailViewController: UICollectionViewController {
    
    var dataSource: PassDataSource?
    
    var indexPath = IndexPath(row: 0, section: 0)
    
    private var passes: [Pass] {
        guard let dataSource = dataSource else {
            fatalError("data source is missing")
        }
        
        return dataSource.visiblePasses
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView?.collectionViewLayout = DetailViewLayout()
        self.collectionView?.isPagingEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = AppStyle.Color.LightBlue

        let nib = UINib(nibName: String(PassDetailCell.self), bundle: nil)
        self.collectionView!.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView?.scrollToItem(at: self.indexPath, at: .centeredHorizontally, animated: true)
        self.setTitleText(for: self.indexPath)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(self.dataSource, forKey: "dataSource")
        coder.encode(self.indexPath, forKey: "indexPath")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let dataSource = coder.decodeObject(forKey: "dataSource") as? PassDataSource else { return }
        guard let indexPath = coder.decodeObject(forKey: "indexPath") as? IndexPath else { return }
        
        self.dataSource = dataSource
        self.indexPath = indexPath
        
        super.decodeRestorableState(with: coder)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.passes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        configure(cell: cell, for: indexPath)
        
        return cell
    }
    
    // MARK: - UIScrollView
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.collectionView?.indexPathsForVisibleItems.first else { return }
        self.indexPath = indexPath
        self.setTitleText(for: indexPath)
    }
    
    // MARK: - Private
    
    private func setTitleText(for indexPath: NSIndexPath) -> Void {
        let pass = passes[indexPath.row]
        self.title = pass.name
    }
    
    private func configure(cell: UICollectionViewCell, for indexPath: NSIndexPath) {
        guard let cell = cell as? PassDetailCell else { return }
        let pass = passes[indexPath.row]
        cell.titleLabel.text = pass.name
        
        cell.conditionsLabel.text = pass.conditions
        cell.eastboundLabel.text = pass.eastbound
        cell.westboundLabel.text = pass.westbound
        cell.lastUpdatedLabel.text = self.dateFormatter.string(from: pass.lastModified as Date)
        cell.statusView.backgroundColor = pass.color
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM d, yyyy h:mm a"
        return formatter
    }()
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return DetailViewLayout.detailLayoutItemSize(for: UIScreen.main.bounds)
    }
}
