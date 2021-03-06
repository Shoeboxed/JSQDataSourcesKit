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

import Foundation
import UIKit
import XCTest

import JSQDataSourcesKit


final class TitledCollectionReusableViewTests: XCTestCase {

    func test_ThatViewInitializesWithFrame() {
        let identifier = TitledCollectionReusableView.identifier
        XCTAssertEqual(identifier, String(TitledCollectionReusableView.self))

        let view = TitledCollectionReusableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        view.layoutIfNeeded()

        XCTAssertEqual(view.verticalInset, 8)
        XCTAssertEqual(view.horizontalInset, 8)
        XCTAssertEqual(view.label.frame, CGRect(x: 8, y: 8, width: 304, height: 84))
    }

    func test_ThatViewAdjustsLabelFrameForInsets() {
        let identifier = TitledCollectionReusableView.identifier
        XCTAssertEqual(identifier, String(TitledCollectionReusableView.self))

        let view = TitledCollectionReusableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        view.verticalInset = 10
        view.horizontalInset = 4
        view.layoutIfNeeded()

        XCTAssertEqual(view.label.frame, CGRect(x: 4, y: 10, width: 312, height: 80))
    }

    func test_ThatViewPreparesForReuse_ForText() {
        let view = TitledCollectionReusableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        view.layoutIfNeeded()
        view.label.text = "title text"

        XCTAssertNotNil(view.label.text)

        view.prepareForReuse()

        XCTAssertNil(view.label.text)
    }

    func test_ThatViewPreparesForReuse_ForAttributedText() {
        let view = TitledCollectionReusableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        view.layoutIfNeeded()
        view.label.attributedText = NSAttributedString(string:"title text")

        XCTAssertNotNil(view.label.attributedText)

        view.prepareForReuse()

        XCTAssertNil(view.label.attributedText)
    }

    func test_ThatViewSetsBackgoundColor() {
        let view = TitledCollectionReusableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        view.layoutIfNeeded()
        view.backgroundColor = .redColor()

        XCTAssertEqual(view.label.backgroundColor, view.backgroundColor)
        XCTAssertEqual(view.label.backgroundColor, .redColor())
    }
}
