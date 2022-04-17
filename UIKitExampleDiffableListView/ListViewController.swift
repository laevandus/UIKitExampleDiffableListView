//
//  ListViewController.swift
//  UIKitExampleDiffableListView
//
//  Created by Toomas Vahter on 17.04.2022.
//

import UIKit

final class ListViewController: UIViewController {
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Data Source
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<String, PaletteColor> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, PaletteColor> { [viewModel] cell, indexPath, paletteColor in
            var configutation = UIListContentConfiguration.cell()
            configutation.image = viewModel.cellImage(for: paletteColor)
            configutation.text = viewModel.cellTitle(for: paletteColor)
            cell.contentConfiguration = configutation
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [viewModel] supplementaryView, elementKind, indexPath in
            var configutation = UIListContentConfiguration.groupedHeader()
            configutation.text = viewModel.headerTitle(in: indexPath.section)
            supplementaryView.contentConfiguration = configutation
        }
        let dataSource = UICollectionViewDiffableDataSource<String, PaletteColor>(collectionView: collectionView, cellProvider: { collectionView, indexPath, paletteColor in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: paletteColor)
        })
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        return dataSource
    }
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: Loading a View
    
    private func makeCollectionView() -> UICollectionView {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private lazy var collectionView = makeCollectionView()
    
    override func loadView() {
        title = "Palettes"
        view = UIView(frame: .zero)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        viewModel.reloadContent(in: dataSource)
    }
}

extension ListViewController {
    @MainActor final class ViewModel {
        let palettes: [Palette]
        
        init(palettes: [Palette]) {
            self.palettes = palettes
        }
        
        func cellTitle(for paletteColor: PaletteColor) -> String {
            paletteColor.name
        }
        
        func cellImage(for paletteColor: PaletteColor) -> UIImage {
            var image = UIImage(systemName: "circle.fill")!
            image = image.withRenderingMode(.alwaysOriginal)
            return image.withTintColor(paletteColor.color)
        }
        
        func headerTitle(in section: Int) -> String {
            palettes[section].name
        }
        
        func reloadContent(in dataSource: UICollectionViewDiffableDataSource<String, PaletteColor>) {
            var snapshot = NSDiffableDataSourceSnapshot<String, PaletteColor>()
            snapshot.appendSections(palettes.map(\.name))
            palettes.forEach({ palette in
                snapshot.appendItems(palette.colors, toSection: palette.name)
            })
            dataSource.apply(snapshot)
        }
    }
}

struct Palette: Hashable {
    let name: String
    let colors: [PaletteColor]
    // other properties
    
    static let fancy = Palette(name: "Fancy", colors: [
        PaletteColor(name: "Red", color: .systemRed),
        PaletteColor(name: "Blue", color: .systemBlue),
        PaletteColor(name: "Cyan", color: .systemCyan),
        PaletteColor(name: "Mint", color: .systemMint),
        PaletteColor(name: "Pink", color: .systemPink),
        PaletteColor(name: "Teal", color: .systemTeal),
        PaletteColor(name: "Green", color: .systemGreen),
        PaletteColor(name: "Brown", color: .systemBrown)
    ])

    static let secondary = Palette(name: "Secondary", colors: [
        PaletteColor(name: "Label", color: .secondaryLabel),
        PaletteColor(name: "Fill", color: .secondarySystemFill)
    ])
}

struct PaletteColor: Hashable {
    let name: String
    let color: UIColor
    // other properties
}
