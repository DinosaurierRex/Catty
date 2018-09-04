/**
 *  Copyright (C) 2010-2018 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest

@testable import Pocket_Code

final class FormulaManagerCacheTest: XCTestCase {
    
    var manager: FormulaManager!
    var object: SpriteObject!
    
    override func setUp() {
        manager = FormulaManager()
        object = SpriteObject()
    }
    
    func testStop() {
        manager.cachedResults[FormulaElement()] = "a" as AnyObject
        XCTAssertEqual(1, manager.cachedResults.count)
        
        manager.stop()
        XCTAssertEqual(0, manager.cachedResults.count)
    }
    
    func testInvalidateCache() {
        manager.cachedResults[FormulaElement()] = "a" as AnyObject
        XCTAssertEqual(1, manager.cachedResults.count)
        
        manager.invalidateCache()
        XCTAssertEqual(0, manager.cachedResults.count)
    }
    
    func testInvalidateCacheForFormula() {
        let leftChild = FormulaElement(integer: 1)!
        let rightChild = FormulaElement(elementType: ElementType.SENSOR, value: DateDaySensor.tag)!
        let formulaA = Formula(formulaElement: FormulaElement(elementType: ElementType.OPERATOR, value: Operators.getName(Operator.PLUS), leftChild: leftChild, rightChild: rightChild, parent: nil))!
        
        let formulaB = Formula(integer: 2)!
        
        XCTAssertEqual(0, manager.cachedResults.count)
        XCTAssertNotNil(manager.interpretInteger(formulaA, for: object))
        XCTAssertNotNil(manager.interpretInteger(formulaB, for: object))
        
        XCTAssertEqual(2, manager.cachedResults.count)
        XCTAssertNotNil(manager.cachedResults[leftChild])
        XCTAssertNil(manager.cachedResults[rightChild])
        XCTAssertNotNil(manager.cachedResults[formulaB.formulaTree])
        
        manager.invalidateCache(formulaB)
        XCTAssertEqual(1, manager.cachedResults.count)
        XCTAssertNotNil(manager.cachedResults[leftChild])
        XCTAssertNil(manager.cachedResults[formulaB.formulaTree])
        
        manager.invalidateCache(formulaA)
        XCTAssertEqual(0, manager.cachedResults.count)
    }
    
    func testCacheNumber() {
        let expectedNumber = 1
        let formula = Formula(integer: Int32(expectedNumber))!
        
        XCTAssertTrue(manager.isIdempotent(formula))
        XCTAssertEqual(0, manager.cachedResults.count)
        
        XCTAssertEqual(1, manager.interpretInteger(formula, for: object))
        XCTAssertEqual(1, manager.cachedResults.count)
        XCTAssertEqual(1, manager.cachedResults[formula.formulaTree] as! Int)
        
        formula.formulaTree.value = "2"
        
        XCTAssertEqual(expectedNumber, manager.interpretInteger(formula, for: object))
        XCTAssertEqual(1, manager.cachedResults.count)
        
        manager.invalidateCache()
        
        XCTAssertEqual(2, manager.interpretInteger(formula, for: object))
        XCTAssertEqual(1, manager.cachedResults.count)
    }
    
    func testDoNotCacheSensor() {
        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.SENSOR, value: DateDaySensor.tag))!
        XCTAssertFalse(manager.isIdempotent(formula))
        XCTAssertEqual(0, manager.cachedResults.count)
        
        XCTAssertEqual(Calendar.current.component(.day, from: Date()), manager.interpretInteger(formula, for: object))
        XCTAssertEqual(0, manager.cachedResults.count)
    }
    
    func testCacheNumberAndSensor() {
        let leftChild = FormulaElement(integer: 1)!
        let rightChild = FormulaElement(elementType: ElementType.SENSOR, value: DateDaySensor.tag)!
        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.OPERATOR, value: Operators.getName(Operator.PLUS), leftChild: leftChild, rightChild: rightChild, parent: nil))!
        XCTAssertFalse(manager.isIdempotent(formula))
        XCTAssertEqual(0, manager.cachedResults.count)
        
        XCTAssertEqual(Calendar.current.component(.day, from: Date()) + 1, manager.interpretInteger(formula, for: object))
        
        XCTAssertEqual(1, manager.cachedResults.count)
        XCTAssertNotNil(manager.cachedResults[leftChild])
        XCTAssertEqual(1, manager.cachedResults[leftChild] as! Int)
        XCTAssertNil(manager.cachedResults[rightChild])
        
        XCTAssertEqual(Calendar.current.component(.day, from: Date()) + 1, manager.interpretInteger(formula, for: object))
    }
}