//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://jessesquires.com/JSQDataSourcesKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQDataSourcesKit
//
//
//  License
//  Copyright © 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import CoreData
import Foundation
import UIKit


/**
 A `TableViewDataSourceProvider` is responsible for providing a data source object for a table view.

 - warning: **Clients are responsbile for the following:**
 - Registering cells with the table view
 - Adding, removing, or reloading cells and sections as the provider's `sections` are modified.
 */
public final class TableViewDataSourceProvider<SectionInfo: SectionInfoProtocol, CellFactory: CellFactoryProtocol
where CellFactory.Item == SectionInfo.Item, CellFactory.Cell: UITableViewCell>: CustomStringConvertible {

    // MARK: Typealiases

    /// The type of elements for the data source provider.
    public typealias Item = SectionInfo.Item


    // MARK: Properties

    /// The sections in the table view
    public var sections: [SectionInfo]

    /// Returns the cell factory for this data source provider.
    public let cellFactory: CellFactory

    /// Returns the object that provides the data for the table view.
    public var dataSource: UITableViewDataSource { return bridgedDataSource }


    // MARK: Initialization

    /**
     Constructs a new data source provider for a table view.

     - parameter sections:    The sections to display in the table view.
     - parameter cellFactory: The cell factory from which the table view data source will dequeue cells.
     - parameter tableView:   The table view whose data source will be provided by this provider.

     - returns: A new `TableViewDataSourceProvider` instance.
     */
    public init(sections: [SectionInfo], cellFactory: CellFactory, tableView: UITableView? = nil) {
        self.sections = sections
        self.cellFactory = cellFactory
        tableView?.dataSource = dataSource
    }


    // MARK: Subscripts

    /**
     - parameter index: The index of the section to return.
     - returns: The section at `index`.
     */
    public subscript (index: Int) -> SectionInfo {
        get {
            return sections[index]
        }
        set {
            sections[index] = newValue
        }
    }

    /**
     - parameter indexPath: The index path of the item to return.
     - returns: The item at `indexPath`.
     */
    public subscript (indexPath: NSIndexPath) -> Item {
        get {
            return sections[indexPath.section].items[indexPath.row]
        }
        set {
            sections[indexPath.section].items[indexPath.row] = newValue
        }
    }


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(TableViewDataSourceProvider.self): sections=\(sections)>"
        }
    }


    // MARK: Private

    private lazy var bridgedDataSource: BridgedDataSource = {
        let dataSource = BridgedDataSource(
            numberOfSections: { [unowned self] () -> Int in
                return self.sections.count
            },
            numberOfItemsInSection: { [unowned self] (section) -> Int in
                return self.sections[section].items.count
            })

        dataSource.tableCellForRowAtIndexPath = { [unowned self] (tableView, indexPath) -> UITableViewCell in
            let item = self.sections[indexPath.section].items[indexPath.row]
            return self.cellFactory.cellFor(item: item, parentView: tableView, indexPath: indexPath)
        }

        dataSource.tableTitleForHeaderInSection = { [unowned self] (section) -> String? in
            return self.sections[section].headerTitle
        }

        dataSource.tableTitleForFooterInSection = { [unowned self] (section) -> String? in
            return self.sections[section].footerTitle
        }

        return dataSource
    }()
}


/**
 A `TableViewFetchedResultsDataSourceProvider` is responsible for providing a data source object for a table view
 that is backed by an `NSFetchedResultsController` instance.

 - warning: The `CellFactory.Item` type should correspond to the type of objects that the `NSFetchedResultsController` fetches.
 - note: Clients are responsbile for registering cells with the table view.
 */
public final class TableViewFetchedResultsDataSourceProvider <CellFactory: CellFactoryProtocol where CellFactory.Cell: UITableViewCell>: CustomStringConvertible {

    // MARK: Typealiases

    /// The type of elements for the data source provider.
    public typealias Item = CellFactory.Item


    // MARK: Properties

    /// Returns the fetched results controller that provides the data for the table view data source.
    public let fetchedResultsController: NSFetchedResultsController

    /// Returns the cell factory for this data source provider.
    public let cellFactory: CellFactory

    /// Returns the object that provides the data for the table view.
    public var dataSource: UITableViewDataSource { return bridgedDataSource }


    // MARK: Initialization

    /**
     Constructs a new data source provider for the table view.

     - parameter fetchedResultsController: The fetched results controller that provides the data for the table view.
     - parameter cellFactory:              The cell factory from which the table view data source will dequeue cells.
     - parameter tableView:                The table view whose data source will be provided by this provider.

     - returns: A new `TableViewFetchedResultsDataSourceProvider` instance.
     */
    public init(fetchedResultsController: NSFetchedResultsController, cellFactory: CellFactory, tableView: UITableView? = nil) {
        assert(fetchedResultsController: fetchedResultsController,
               fetchesObjectsOfClass: Item.self as! AnyClass)

        self.fetchedResultsController = fetchedResultsController
        self.cellFactory = cellFactory
        tableView?.dataSource = dataSource
    }


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(TableViewFetchedResultsDataSourceProvider.self): fetchedResultsController=\(fetchedResultsController)>"
        }
    }


    // MARK: Private

    private lazy var bridgedDataSource: BridgedDataSource = {
        let dataSource = BridgedDataSource(
            numberOfSections: { [unowned self] () -> Int in
                return self.fetchedResultsController.sections?.count ?? 0
            },
            numberOfItemsInSection: { [unowned self] (section) -> Int in
                return (self.fetchedResultsController.sections?[section])?.numberOfObjects ?? 0
            })

        dataSource.tableCellForRowAtIndexPath = { [unowned self] (tableView, indexPath) -> UITableViewCell in
            let item = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Item
            return self.cellFactory.cellFor(item: item, parentView: tableView, indexPath: indexPath)
        }

        dataSource.tableTitleForHeaderInSection = { [unowned self] (section) -> String? in
            return (self.fetchedResultsController.sections?[section])?.name
        }
        
        return dataSource
    }()
}
