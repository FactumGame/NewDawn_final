///**
/**
 NewDawn
 Created by: Mathieu Janneau on 29/03/2018
 Copyright (c) 2018 Mathieu Janneau
 */
// swiftlint:disable trailing_whitespace

import Foundation

protocol ChallengeControllerDelegate {
  func sendCategory() -> ChallengeType?
}

extension ChallengeControllerDelegate {
  func sendCategory() -> ChallengeType? { return nil}
  func sendChallengeTitle() -> String? {return nil}
}
