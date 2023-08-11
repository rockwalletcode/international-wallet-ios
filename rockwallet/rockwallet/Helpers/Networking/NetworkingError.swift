// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import Foundation

protocol FEError: Error {
    var errorMessage: String { get }
    var errorType: ServerResponse.ErrorType? { get }
}

struct GeneralError: FEError {
    var errorMessage: String = L10n.ErrorMessages.unknownError
    var errorType: ServerResponse.ErrorType?
}

enum NetworkingError: FEError, Equatable {
    case noConnection
    case general(String)
    case accessDenied(String)
    case parameterMissing(String)
    case sessionExpired(String)
    case exchangesUnavailable
    case biometricAuthenticationRequired
    case biometricAuthenticationFailed
    case twoStepEmailRequired
    case twoStepAppRequired
    case twoStepInvalid
    case twoStepInvalidCode(Int?)
    case twoStepBlockedAccount
    case twoStepInvalidCodeBlockedAccount
    case inappropriatePaymail
    case livenessCheckLimit
    
    var errorMessage: String {
        switch self {
        case .noConnection:
            return L10n.ErrorMessages.checkInternet
            
        case .twoStepInvalidCode(let attemptCount):
            let attemptCount = attemptCount ?? 0
            let isMoreThanOne = attemptCount > 1
            let plural = L10n.TwoStep.Error.attempts(String(describing: attemptCount))
            let singular = L10n.TwoStep.Error.attempt(String(describing: attemptCount))
            return isMoreThanOne ? plural : singular
            
        case .inappropriatePaymail:
            return L10n.PaymailAddress.inappropriateWordsMessage
            
        case .general(let message),
                .accessDenied(let message),
                .parameterMissing(let message),
                .sessionExpired(let message):
            return message
            
        default:
            return L10n.ErrorMessages.unknownError
        }
    }
    
    var errorCategory: ServerResponse.ErrorCategory? {
        switch self {
        case .twoStepEmailRequired, .twoStepAppRequired, .twoStepInvalidCode,
                .twoStepBlockedAccount, .twoStepInvalidCodeBlockedAccount, .twoStepInvalid:
            return .twoStep
            
        default:
            return nil
        }
    }
    
    var errorType: ServerResponse.ErrorType? {
        switch self {
        case .exchangesUnavailable:
            return .exchangesUnavailable
            
        case .biometricAuthenticationFailed, .biometricAuthenticationRequired, .livenessCheckLimit:
            return .biometricAuthentication
            
        case .twoStepAppRequired, .twoStepEmailRequired:
            return .twoStepRequired
            
        case .twoStepBlockedAccount:
            return .twoStepBlockedAccount
            
        case .twoStepInvalidCodeBlockedAccount:
            return .twoStepInvalidCodeBlockedAccount
            
        case .twoStepInvalidCode:
            return .twoStepInvalidCode
            
        case .twoStepInvalid:
            return .twoStepInvalid
            
        default:
            return nil
        }
    }
    
    init?(error: ServerResponse.ServerError?) {
        let serverMessage = error?.serverMessage ?? L10n.ErrorMessages.somethingWentWrong
        
        switch error?.statusCode {
        case 101:
            self = .accessDenied(serverMessage)
            
        case 103:
            self = .parameterMissing(serverMessage)
            
        case 105:
            self = .sessionExpired(serverMessage)
        
        case 400:
            if serverMessage == ServerResponse.ErrorType.inappropriatePaymail.rawValue {
                self = .inappropriatePaymail
            } else {
                self = .general(serverMessage)
            }
            
        case 401:
            if serverMessage == ServerResponse.ErrorType.twoStepInvalidCode.rawValue {
                self = .twoStepInvalidCode(error?.attemptsLeft)
            } else if serverMessage == ServerResponse.ErrorType.twoStepInvalidCodeBlockedAccount.rawValue {
                self = .twoStepInvalidCodeBlockedAccount
            } else {
                switch TwoStepSettingsResponseData.TwoStepType(rawValue: error?.serverMessage ?? "") {
                case .authenticator:
                    self = .twoStepAppRequired
                    
                case .email:
                    self = .twoStepEmailRequired
                    
                default:
                    self = .accessDenied(serverMessage)
                }
            }
            
        case 403:
            if serverMessage == ServerResponse.ErrorType.twoStepBlockedAccount.rawValue {
                self = .twoStepBlockedAccount
            } else if serverMessage == ServerResponse.ErrorType.twoStepInvalidCodeBlockedAccount.rawValue {
                self = .twoStepInvalidCodeBlockedAccount
            } else {
                self = .general(serverMessage)
            }
            
        case 422:
            self = .general(serverMessage)
            
        case 503:
            switch error?.errorType {
            case .exchangesUnavailable:
                self = .exchangesUnavailable
                
            default:
                self = .general(serverMessage)
            }
            
        case 1001:
            self = .biometricAuthenticationRequired
            
        case 1002:
            self = .biometricAuthenticationFailed
            
        case 1003:
            if serverMessage == L10n.ErrorMessages.LivenessCheckLimit.errorMessage {
                self = .livenessCheckLimit
            } else {
                self = .general(serverMessage)
            }
            
        default:
            return nil
        }
    }
}

public class NetworkingErrorManager {
    static func getError(from response: HTTPURLResponse?, data: Data?, error: Error?) -> FEError? {
        if data?.isEmpty == true && error == nil {
            return nil
        }
        
        if let error = error as? URLError, error.code == .notConnectedToInternet {
            return NetworkingError.noConnection
        }
        
        let serverResponse = ServerResponse.parse(from: data, type: ServerResponse.self)
        let errorType = ServerResponse.ErrorType(rawValue: serverResponse?.errorType ?? "")
        var error = serverResponse?.error
        error?.errorType = errorType
        
        guard let error = NetworkingError(error: error) else { return error }
        
        return error
    }
}
