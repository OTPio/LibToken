# LibToken

LibToken is a library for managing 2FA tokens

#### How It Works
Create a token by passing in a `otpauth://` URL that conforms to [RFC 6238](https://tools.ietf.org/html/rfc6238) or [RFC 4226](https://tools.ietf.org/html/rfc4226)
```swift
let url = URL(string: "otpauth://totp/LABEL?secret=FEEDFACE&issuer=ISSUER")
let token = Token(url)
```

#### Properties
The following are accessible properties of `Token`
```swift
// Get the current 6-8 digit code
token.password() -> String
// Get a 6-8 digit code at a specified date
token.password(at: myDate) -> String

// How long the token is valid for (TOTP)
token.timeRemaining() -> Int
// How long the current token is valid for at a specified date (TOTP)
token.timeRemaining(at: myDate) -> Int
// How long the current token has been valid for at a specified date (date optional) (TOTP)
token.timeRemaining(at: myDate, reversed: true) -> Int

// Re-serialize to URL for storage
token.serialize() -> URL

// Get the next token (HOTP only)
token.nextToken() -> Token

// Token issuer (read/write)
token.issuer
// Token label or account name (read/write)
token.label
// Number of digits in code (read/write)
token.digits
// Algorithm  (read/write)
token.algorithm
// Secret (read only)
token.secret
// Period/Counter (read only)
token.period
// Type (HOTP/TOTP) (read only)
token.type
```

## Credit
- Author: [MatrixSenpai](https://github.com/MatrixSenpai/)
- Inspiration
    - mattrubin's [OneTimePassword](https://github.com/mattrubin/OneTimePassword)
    - kishikawakatsumi's [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)
- Uses
    - [Base32](https://github.com/mattrubin/Bases)
    - [RxSwift](https://github.com/ReactiveX/RxSwift)

## License
LibToken is licensed under the MIT license. See the LICENSE file for more information


All dependencies are licensed under their respective licenses. Access those repositories for more information
