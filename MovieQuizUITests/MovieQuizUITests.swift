import XCTest
//import XCUIElement

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
    }
    
    func testTapOnYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testTapOnNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testVerifyAlertIsVisible() {
        for _ in 1...10 {
            let noButton = app.buttons["No"].firstMatch
            XCTAssert(noButton.waitForExistence(timeout: 5), "Не отображается кнопка 'Нет'")
            
            let isEnabledPredicate = NSPredicate(format: "isEnabled == true")
            expectation(for: isEnabledPredicate, evaluatedWith: noButton, handler: nil)
            waitForExpectations(timeout: 5)
            
            noButton.tap()
        }

        let alert = app.alerts.firstMatch
        let gameIsFinished = app.staticTexts["Этот раунд окончен!"].firstMatch
        let playAgainButton = app.buttons["Сыграть ещё раз"].firstMatch
        
        XCTAssert(alert.waitForExistence(timeout: 5), "Аллерт не отображается!'")
        XCTAssert(gameIsFinished.waitForExistence(timeout: 5), "Не отображается текст 'Этот раунд окончен!'")
        XCTAssert(playAgainButton.waitForExistence(timeout: 5), "Не отображается кнопка 'Сыграть ещё раз'")
    }

    
    func testVerifyAlertNotVisible() {
        for _ in 1...10 {
            let noButton = app.buttons["No"].firstMatch
            XCTAssert(noButton.waitForExistence(timeout: 5), "Не отображается кнопка 'Нет'")
                
            let isEnabledPredicate = NSPredicate(format: "isEnabled == true")
            expectation(for: isEnabledPredicate, evaluatedWith: noButton, handler: nil)
            waitForExpectations(timeout: 5)
            
            noButton.tap()
        }
            
        let alert = app.alerts.firstMatch
        let playAgainButton = app.buttons["Сыграть ещё раз"].firstMatch
            
        XCTAssert(alert.waitForExistence(timeout: 5), "Аллерт не отображается!'")
        XCTAssert(playAgainButton.waitForExistence(timeout: 5), "Не отображается кнопка 'Сыграть ещё раз'")
        playAgainButton.tap()
            
        let indexLabel = app.staticTexts["Index"]
            
        XCTAssertFalse(alert.exists)
        XCTAssert(indexLabel.waitForExistence(timeout: 15), "Индекс не отображается!'")
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
