import XCTest
import Base32
@testable import LibToken

final class LibTokenTests: XCTestCase {
    // MARK: - Success Cases: creation
    /// Should successfully create a TOTP token using maximum options without throwing
    func testValidTotpToken() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=md5&digits=8&period=50")
        
        do {
            let token = try Token(url)
            if case .totp(let period) = token.generator.type {
                XCTAssertTrue(period == 50, "Got incorrect period")
            } else { XCTFail("Incorrect type initialized") }
            XCTAssertTrue(token.issuer == "Matrix Studios", "Got incorrect issuer")
            XCTAssertTrue(token.label == "MatrixSenpai", "Got incorrect label")
            XCTAssertTrue(token.generator.algorithm == .md5, "Got incorrect algorithm")
            XCTAssertTrue(token.generator.digits == 8, "Got incorrect digits")
            
            let secret = Base32.encode(token.generator.secret)
            XCTAssertTrue(secret == "FEEDFACE", "Incorrectly encoded/decoded or wrong secret")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Should successfully create a HOTP token using maximum options without throwing
    func testValidHotpToken() {
        let url = URL(string: "otpauth://hotp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha512&digits=7&counter=70")
        
        do {
            let token = try Token(url)
            if case .hotp(let counter) = token.generator.type {
                XCTAssertTrue(counter == 70, "Got incorrect counter")
            } else { XCTFail("Incorrect type initialized") }
            XCTAssertTrue(token.issuer == "Matrix Studios", "Got incorrect issuer")
            XCTAssertTrue(token.label == "MatrixSenpai", "Got incorrect label")
            XCTAssertTrue(token.generator.algorithm == .sha512, "Got incorrect algorithm")
            XCTAssertTrue(token.generator.digits == 7, "Got incorrect digits")
            
            let secret = Base32.encode(token.generator.secret)
            XCTAssertTrue(secret == "FEEDFACE", "Incorrectly encoded/decoded or wrong secret")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // MARK: - Success Cases: functionality
    /// Should successfully create a TOTP token and return its time
    func testTokenTime() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha1&digits=6&period=30")
        let date = Date(timeIntervalSince1970: 1576035350)
        
        do {
            let token = try Token(url)
            let remaining = token.timeRemaining(at: date)
            XCTAssert(remaining == 10)
            
            let reversed = token.timeRemaining(at: date, reversed: true)
            XCTAssert(reversed == 20)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Should successfully create a TOTP token and return the digits
    func testTotpTokenOutput() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&issuer=Matrix%20Studios&algorithm=sha1&digits=6&period=30")
        let date = Date(timeIntervalSince1970: 1576034678)
        do {
            let token = try Token(url)
            let password = token.password(at: date)
            XCTAssert(password == "187979")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Should successfully create a HOTP token and return the digits
    func testHotpTokenOutput() {
        let url = URL(string: "otpauth://hotp/MatrixSenpai?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&issuer=Matrix%20Studios&algorithm=sha1&digits=6&counter=4778929323")
        
        do {
            let token = try Token(url)
            let password = token.password()
            XCTAssert(password == "331727")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testNextHotpTokenOutput() {
        let url = URL(string: "otpauth://hotp/MatrixSenpai?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&issuer=Matrix%20Studios&algorithm=sha1&digits=6&counter=4778929323")
        
        do {
            var token = try Token(url)
            token = token.nextToken()
            let password = token.password()
            XCTAssert(password == "494109")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // MARK: - Success Cases: missing components
    /// Should successfully create with algorithm 'sha1'
    func testMissingAlgorithm() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&digits=6&period=30")
        
        do {
            let token = try Token(url)
            XCTAssertTrue(token.generator.algorithm == .sha1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Should successfully create with digits '6'
    func testMissingDigits() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha1&period=30")
        
        do {
            let token = try Token(url)
            XCTAssertTrue(token.generator.digits == 6)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Should successfully create with period '30'
    func testMissingPeriod() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha1&digits=6")
        
        do {
            let token = try Token(url)
            if case .totp(let period) = token.generator.type {
                XCTAssertTrue(period == 30)
            } else { XCTFail("Missing or wrong type") }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Should successfully create token
    func testMissingTotpOptionalComponents() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios")
        
        do {
            let token = try Token(url)
            if case .totp(let period) = token.generator.type {
                XCTAssertTrue(period == 30, "Got incorrect period")
            } else { XCTFail("Incorrect type initialized") }
            XCTAssertTrue(token.generator.algorithm == .sha1, "Got incorrect algorithm")
            XCTAssertTrue(token.generator.digits == 6, "Got incorrect digits")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    /// Should successfully create HOTP token
    func testMissingHotpOptionalComponents() {
        let url = URL(string: "otpauth://hotp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&counter=30")
        
        do {
            let token = try Token(url)
            XCTAssertTrue(token.generator.algorithm == .sha1, "Got incorrect algorithm")
            XCTAssertTrue(token.generator.digits == 6, "Got incorrect digits")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    // MARK: - Failure Cases
    /// Should throw 'incorrect schema'
    func testIncorrectScheme() {
        let url = URL(string: "http://totp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha1&digits=6&period=30")
        XCTAssertThrowsError(try Token(url))
    }
    
    /// Should throw 'missing type'
    func testMissingType() {
        let url = URL(string: "otpauth://%20/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha1&digits=6&period=30")
        XCTAssertThrowsError(try Token(url))
    }
    
    /// Should throw 'missing type'
    func testIncorrectType() {
        let url = URL(string: "otpauth://asdf/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha1&digits=6&period=30")
        XCTAssertThrowsError(try Token(url))
    }
    
    /// Should throw 'missing label'
    func testMissingLabel() {
        let url = URL(string: "otpauth://totp/?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha1&digits=6&period=30")
        XCTAssertThrowsError(try Token(url))
    }
    
    /// Should throw 'missing secret'
    func testMissingSecret() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?issuer=Matrix%20Studios&algorithm=sha1&digits=6&period=30")
        XCTAssertThrowsError(try Token(url))
    }
    
    /// Should throw 'missing issuer'
    func testMissingIssuer() {
        let url = URL(string: "otpauth://totp/MatrixSenpai?secret=FEEDFACE&algorithm=sha1&digits=6&period=30")
        XCTAssertThrowsError(try Token(url))
    }
    
    /// Should throw 'missing counter'
    func testMissingCounter() {
        let url = URL(string: "otpauth://hotp/MatrixSenpai?secret=FEEDFACE&issuer=Matrix%20Studios&algorithm=sha1&digits=6")
        XCTAssertThrowsError(try Token(url))
    }
}
