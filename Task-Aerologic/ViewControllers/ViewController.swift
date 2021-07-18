//
//  ViewController.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 17/07/2021.
//

import UIKit
import Combine
import SwiftUI

final class ViewController: UIViewController {
    
    fileprivate (set) lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.tableFooterView = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate (set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        return control
    }()
    
    fileprivate (set) var viewModel: PersonViewModel = PersonViewModel()
    
    fileprivate (set) lazy var loadFromFileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load From File", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(loadFromFile), for: .touchUpInside)
        return button
    }()
    
    enum Section {
        case main
    }
    
    var dataSource: UITableViewDiffableDataSource<Section,PersonListViewModel>! = nil
    
    fileprivate (set) var subscription: Set<AnyCancellable> = []
    
    var selectedIndex: PersonListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureRefreshControl()
        configureLayout()
        configureHUD()
        viewModel.fetchData()
        configureDataSource()
        
        configureSnapShot(force: false, items: [])
        
        viewModel.$personListViewModel.sink { [weak self] list in
            guard let self = self else { return }
            self.configureSnapShot(force: true, items: list)
        }.store(in: &subscription)
        
    }
}

extension ViewController {
    
    private func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Task App"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: loadFromFileButton)
    }
    
    private func configureLayout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    fileprivate func configureCell(withVM: PersonListViewModel) -> UITableViewCell? {
        let cell = UITableViewCell()
        let controller = UIHostingController(rootView: Cell(viewModel: withVM))
        cell.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: cell.topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
        ])
        
        
        return cell
    }
    
    func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, viewModel in
            guard let self = self else { fatalError() }
            return self.configureCell(withVM: viewModel)
        })
    }
    
    func configureSnapShot(force: Bool, items: [PersonListViewModel]) {
        var snapshot: NSDiffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, PersonListViewModel>()
        snapshot.appendSections([.main])
        
        if force {
            snapshot.deleteSections([.main])
            snapshot.appendSections([.main])
        }
        
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func configureHUD() {
        viewModel.progressHudSubject.sink { [weak self] shouldShow in
            guard let self = self else { return }
            if shouldShow.0 {
                self.refreshControl.beginRefreshing()
                self.refreshControl.attributedTitle = NSAttributedString(string: shouldShow.1.description)
            } else {
                self.refreshControl.attributedTitle = NSAttributedString(string: "")
                self.refreshControl.endRefreshing()
            }
        }.store(in: &subscription)
        
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refresh() {
        refreshControl.beginRefreshing()
        viewModel.fetchData()
        refreshControl.endRefreshing()
    }
    
    @objc private func loadFromFile() {
        refreshControl.beginRefreshing()
        viewModel.loadFromFile()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            self.refreshControl.attributedTitle = NSAttributedString(string: "Loading From Local File...")
            self.refreshControl.endRefreshing()
        }
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = dataSource.itemIdentifier(for: indexPath)
        
        var snapshot = dataSource.snapshot()
        
        if let index = selectedIndex {
            snapshot.reloadItems([index])
            dataSource.apply(snapshot)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = dataSource.itemIdentifier(for: indexPath)
        if item == selectedIndex {
            return 200
        }
        return 120
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedIndex = nil
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.main])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

