// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import XCTest
@testable import TrialLicense

class UserDefaultsLicenseProviderTests: XCTestCase {

    var licenseProvider: UserDefaultsLicenseProvider!
    var userDefaultsDouble: TestUserDefaults!

    override func setUp() {
        super.setUp()

        userDefaultsDouble = TestUserDefaults()

        licenseProvider = UserDefaultsLicenseProvider(userDefaults: userDefaultsDouble)
    }

    override func tearDown() {
        userDefaultsDouble = nil
        licenseProvider = nil
        super.tearDown()
    }

    func provideLicenseDefaults(name: String?, licenseCode: String?) {
        userDefaultsDouble.testValues[License.UserDefaultsKeys.name] = name
        userDefaultsDouble.testValues[License.UserDefaultsKeys.licenseCode] = licenseCode
    }
    
    
    // MARK: -
    // MARK: Empty Defaults, no License

    func testObtainingCurrentLicense_WithEmptyDefaults_QueriesDefaultsForLicenseCode() {
        
        _ = licenseProvider.currentLicense
        
        let usedDefaultNames = userDefaultsDouble.didCallStringForKeyWith
        XCTAssert(hasValue(usedDefaultNames))
        
        if let usedDefaultNames = usedDefaultNames {
            XCTAssert(usedDefaultNames.contains(License.UserDefaultsKeys.licenseCode))
            XCTAssertFalse(usedDefaultNames.contains(License.UserDefaultsKeys.name))
        }
    }

    func testObtainingCurrentLicense_WithEmptyDefaults_ReturnsNil() {
        
        XCTAssertFalse(hasValue(licenseProvider.currentLicense))
    }
    
    
    // MARK: Existing Defaults, Registered

    func testObtainingCurrentLicense_QueriesDefaultsForNameAndKey() {
        
        provideLicenseDefaults(name: "irrelevant name", licenseCode: "irrelevant key")
        
        _ = licenseProvider.currentLicense
        
        let usedDefaultNames = userDefaultsDouble.didCallStringForKeyWith
        XCTAssert(hasValue(usedDefaultNames))
        
        if let usedDefaultNames = usedDefaultNames {
            XCTAssert(usedDefaultNames.contains(License.UserDefaultsKeys.name))
            XCTAssert(usedDefaultNames.contains(License.UserDefaultsKeys.licenseCode))
        }
    }

    func testObtainingCurrentLicense_WithLicenseCodeOnly_ReturnsLicenseWithInfo() {

        let key = "a license key"
        provideLicenseDefaults(name: nil, licenseCode: key)

        let licenseInfo = licenseProvider.currentLicense

        XCTAssert(hasValue(licenseInfo))
        if let licenseInfo = licenseInfo {
            XCTAssertNil(licenseInfo.name, name)
            XCTAssertEqual(licenseInfo.licenseCode, key)
        }
    }

    func testObtainingCurrentLicense_WithNameOnly_ReturnsNil() {

        provideLicenseDefaults(name: "a name", licenseCode: nil)

        XCTAssertNil(licenseProvider.currentLicense)
    }

    func testObtainingCurrentLicense_WithNameAndLicenseCode_ReturnsLicenseWithInfo() {

        let name = "a name"
        let key = "a license key"
        provideLicenseDefaults(name: name, licenseCode: key)
        
        let licenseInfo = licenseProvider.currentLicense
        
        XCTAssert(hasValue(licenseInfo))
        if let licenseInfo = licenseInfo {
            XCTAssertEqual(licenseInfo.name, name)
            XCTAssertEqual(licenseInfo.licenseCode, key)
        }
    }
    
    
    // MARK: -
    
    class TestUserDefaults: NullUserDefaults {
        
        var testValues = [String : String]()
        var didCallStringForKeyWith: [String]?
        override func string(forKey defaultName: String) -> String? {
            
            if !hasValue(didCallStringForKeyWith) {
                didCallStringForKeyWith = [String]()
            }
            
            didCallStringForKeyWith?.append(defaultName)
            
            return testValues[defaultName]
        }
    }
}

