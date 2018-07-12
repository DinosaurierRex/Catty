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

final class AccelerationYSensorTest: XCTestCase {
    
    var motionManager: MotionManagerMock!
    var sensor: AccelerationYSensor!
    
    override func setUp() {
        self.motionManager = MotionManagerMock()
        self.sensor = AccelerationYSensor { [weak self] in self?.motionManager }
    }
    
    override func tearDown() {
        self.sensor = nil
        self.motionManager = nil
    }
    
    func testDefaultRawValue() {
        let sensor = AccelerationYSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        motionManager.yUserAcceleration = 0
        XCTAssertEqual(0, sensor.rawValue(), accuracy: 0.0001)
        
        motionManager.yUserAcceleration = 9.8
        XCTAssertEqual(9.8, sensor.rawValue(), accuracy: 0.0001)
        
        motionManager.yUserAcceleration = -9.8
        XCTAssertEqual(-9.8, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testConvertToStandardized() {
        XCTAssertEqual(0, self.sensor.convertToStandardized(rawValue: 0), accuracy: 0.0001)
        XCTAssertEqual(9.8, self.sensor.convertToStandardized(rawValue: 1), accuracy: 0.0001)
        XCTAssertEqual(-9.8, self.sensor.convertToStandardized(rawValue: -1), accuracy: 0.0001)
        XCTAssertEqual(98, self.sensor.convertToStandardized(rawValue: 10), accuracy: 0.0001)
        XCTAssertEqual(-98, self.sensor.convertToStandardized(rawValue: -10), accuracy: 0.0001)
    }
    
    func testTag() {
        XCTAssertEqual("Y_ACCELERATION", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.deviceMotion, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
}
