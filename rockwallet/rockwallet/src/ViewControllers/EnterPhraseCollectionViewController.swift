//
//  EnterPhraseCollectionViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-23.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

private let itemHeight: CGFloat = ViewSizes.Common.defaultCommon.rawValue

class EnterPhraseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Public
    var didFinishPhraseEntry: ((String) -> Void)?
    var isViewOnly = false
    var height: CGFloat {
        return (itemHeight * 4.0) + (2 * sectionInsets) + (3 * interItemSpacing)
    }
    
    init(keyMaster: KeyMaster) {
        self.keyMaster = keyMaster
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    private let cellHeight: CGFloat = ViewSizes.Common.defaultCommon.rawValue
    
    var interItemSpacing: CGFloat {
        return E.isSmallScreen ? 6 : Margins.small.rawValue
    }
    
    var sectionInsets: CGFloat {
        return E.isSmallScreen ? 0 : Margins.large.rawValue
    }
    
    private lazy var cellSize: CGSize = {
        let margins = sectionInsets * 2            // left and right section insets
        let spacing = interItemSpacing * 2
        let widthAvailableForCells = collectionView.frame.width - margins - spacing
        let cellsPerRow: CGFloat = 3
        return CGSize(width: widthAvailableForCells / cellsPerRow, height: cellHeight)
    }()
    
    // MARK: - Private
    private let cellIdentifier = "CellIdentifier"
    private let keyMaster: KeyMaster
    var phrase: String {
        return (0...11).map { index in
            guard let phraseCell = collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? EnterPhraseCell else { return ""}
            return phraseCell.textField.value?.lowercased() ?? ""
        }.joined(separator: " ")
    }
    private var displayedPhrase: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView?.register(EnterPhraseCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isViewOnly {
            becomeFirstResponder(atIndex: 0)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        guard let enterPhraseCell = item as? EnterPhraseCell else { return item }
        
        var word: String? = enterPhraseCell.textField.value
        if displayedPhrase.count > indexPath.row {
            word = displayedPhrase[indexPath.row]
        }
        enterPhraseCell.hideBorder = isViewOnly
        enterPhraseCell.textField.configure(with: Presets.TextField.phrase)
        enterPhraseCell.textField.setup(with: .init(title: String(format: "%02i", indexPath.row + 1),
                                                    value: word))
        
        enterPhraseCell.index = indexPath.row
        enterPhraseCell.didTapNext = { [weak self] in
            self?.becomeFirstResponder(atIndex: indexPath.row + 1)
        }
        enterPhraseCell.didTapPrevious = { [weak self] in
            self?.becomeFirstResponder(atIndex: indexPath.row - 1)
        }
        enterPhraseCell.didTapDone = { [weak self] in
            guard let phrase = self?.phrase else { return }
            self?.didFinishPhraseEntry?(phrase)
        }
        enterPhraseCell.didEndEditing = { [weak self] in
            guard let phrase = self?.phrase else { return }
            self?.didFinishPhraseEntry?(phrase)
        }
        enterPhraseCell.isWordValid = { [weak self] word in
            guard let self = self else { return false }
            return self.keyMaster.isSeedWordValid(word.lowercased())
        }
        enterPhraseCell.didEnterSpace = {
            enterPhraseCell.didTapNext?()
        }
        enterPhraseCell.didPasteWords = { [weak self] text in
            let text = text.replacingOccurrences(of: "\n", with: " ")
            let words = text.split(separator: " ").compactMap { String($0) }
            
            guard enterPhraseCell.index == 0, words.count <= 12, let `self` = self else { return }
            self.displayedPhrase = words
            self.collectionView.reloadData()
        }
        
        if displayedPhrase.count > indexPath.row {
            let word = displayedPhrase[indexPath.row]
            enterPhraseCell.textField.value = word
            enterPhraseCell.isUserInteractionEnabled = false
        }
        
        if indexPath.item == 0 {
            enterPhraseCell.disablePreviousButton()
        } else if indexPath.item == 11 {
            enterPhraseCell.disableNextButton()
        }
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = sectionInsets
        return UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {}
    
    // MARK: - Extras
    private func becomeFirstResponder(atIndex: Int) {
        guard let phraseCell = collectionView?.cellForItem(at: IndexPath(item: atIndex, section: 0)) as? EnterPhraseCell else { return }
        phraseCell.textField.changeToFirstResponder()
    }
    
    private func setText(_ text: String, atIndex: Int) {
        guard let phraseCell = collectionView.cellForItem(at: IndexPath(row: atIndex, section: 0)) as? EnterPhraseCell else { return }
        phraseCell.textField.value = text
    }
    
    func setPhrase(_ phrase: String) {
        displayedPhrase = phrase.split(separator: " ").compactMap { String($0) }
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EnterPhraseCollectionViewController: Shadable {
    func configure(shadow: ShadowConfiguration?) {
        guard let shadow = shadow else { return }
        collectionView.layer.setShadow(with: shadow)
    }
}

extension EnterPhraseCollectionViewController: Borderable {
    func configure(background: BackgroundConfiguration?) {
        guard let background = background else { return }
        collectionView.setBackground(with: background)
    }
}
