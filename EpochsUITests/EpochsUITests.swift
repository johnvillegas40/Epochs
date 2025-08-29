//
//  EpochsUITests.swift
//  EpochsUITests
//
//  Created by Johnny Villegas on 8/29/25.
//

import XCTest

final class EpochsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws { }

    @MainActor
    func testDeckBuildingFlow() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Deck Builder"].tap()
        XCTAssertTrue(app.staticTexts["Deck invalid"].waitForExistence(timeout: 5))

        let card = app.scrollViews.otherElements.staticTexts["Apprentice Scholar"].firstMatch
        if card.exists { card.tap() }

        XCTAssertTrue(app.staticTexts["Deck invalid"].exists)
    }

    @MainActor
    func testSandboxPlayFlow() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Play (Sandbox)"].tap()
        XCTAssertTrue(app.staticTexts["Influence Points: 20"].waitForExistence(timeout: 5))

        let nextPhase = app.buttons["Next Phase"]
        XCTAssertTrue(nextPhase.exists)
        nextPhase.tap()
        XCTAssertTrue(app.staticTexts["Influence Points: 21"].exists)

        let draw = app.buttons["Draw"]
        if draw.exists { draw.tap() }
        let play = app.buttons["Play First From Hand"]
        if play.exists { play.tap() }
        let attack = app.buttons["Attack With First"]
        if attack.exists { attack.tap() }
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
