///**
/**
NewDawn
Created by: Mathieu Janneau on 14/04/2018
Copyright (c) 2018 Mathieu Janneau
*/
// swiftlint:disable trailing_whitespace

import Foundation

enum Alert {        //for failure and success results
  case success
  case failure
  case error
}
//for success or failure of validation with alert message
enum Valid {
  case success
  case failure(Alert, AlertMessages)
}
enum ValidationType {
  case email
  case stringWithFirstLetterCaps
  case phoneNo
  case alphabeticString
  case password
}
enum RegEx: String {
  case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" // Email
  case password = "^.{6,15}$" // Password length 6-15
  case alphabeticStringWithSpace = "^[a-zA-Z ]*$" // e.g. hello sandeep
  case alphabeticStringFirstLetterCaps = "^[A-Z]+[a-zA-Z]*$" // SandsHell
  case phoneNo = "[0-9]{10,14}" // PhoneNo 10-14 Digits        //Change RegEx according to your Requirement
}

enum AlertMessages: String {
  case inValidEmail = "InvalidEmail"
  case invalidFirstLetterCaps = "First Letter should be capital"
  case inValidPhone = "Invalid Phone"
  case invalidAlphabeticString = "Invalid String"
  case inValidPSW = "Invalid Password"
  
  case emptyPhone = "Empty Phone"
  case emptyEmail = "Empty Email"
  case emptyFirstLetterCaps = "Empty Name"
  case emptyAlphabeticString = "Empty String"
  case emptyPSW = "Empty Password"
  
  func localized() -> String {
    return NSLocalizedString(self.rawValue, comment: "")
  }
}

class Validator: NSObject {
  
  public static let shared = Validator()
  
  func validate(values: (type: ValidationType, inputValue: String)...) -> Valid {
    for valueToBeChecked in values {
      switch valueToBeChecked.type {
      case .email:
        if let tempValue = isValidString((valueToBeChecked.inputValue, .email, .emptyEmail, .inValidEmail)) {
          return tempValue
        }
      case .stringWithFirstLetterCaps:
        if let tempValue = isValidString((valueToBeChecked.inputValue,
                                          .alphabeticStringFirstLetterCaps,
                                          .emptyFirstLetterCaps,
                                          .invalidFirstLetterCaps)) {
          return tempValue
        }
      case .phoneNo:
        if let tempValue = isValidString((valueToBeChecked.inputValue, .phoneNo, .emptyPhone, .inValidPhone)) {
          return tempValue
        }
      case .alphabeticString:
        if let tempValue = isValidString((valueToBeChecked.inputValue,
                                          .alphabeticStringWithSpace,
                                          .emptyAlphabeticString,
                                          .invalidAlphabeticString)) {
          return tempValue
        }
      case .password:
        if let tempValue = isValidString((valueToBeChecked.inputValue, .password, .emptyPSW, .inValidPSW)) {
          return tempValue
        }
      }
    }
    return .success
  }
  
  func isValidString(_ input: (text: String, regex: RegEx, emptyAlert: AlertMessages, invalidAlert: AlertMessages)) -> Valid? {
    if input.text.isEmpty {
      return .failure(.error, input.emptyAlert)
    } else if isValidRegEx(input.text, input.regex) != true {
      return .failure(.error, input.invalidAlert)
    }
    return nil
  }
  
  func isValidRegEx(_ testStr: String, _ regex: RegEx) -> Bool {
    let stringTest = NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
    let result = stringTest.evaluate(with: testStr)
    return result
  }
}
