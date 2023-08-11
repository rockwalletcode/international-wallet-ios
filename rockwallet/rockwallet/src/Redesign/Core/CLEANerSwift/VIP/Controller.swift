//
//  Controller.swift
//  MagicFactory
//
//  Created by Rok Cresnik on 20/08/2021.
//

import UIKit

struct Scenes {}

protocol Controller: BaseResponseDisplays, BaseDataPassing, BaseControllable {
    associatedtype ViewActions: BaseViewActions
    associatedtype DataStorable: BaseDataStore
    associatedtype Coordinator: CoordinatableRoutes
    
    var interactor: ViewActions? { get set }
    var coordinator: Coordinator? { get set }
    var dataStore: DataStorable? { get }
    
    func setupVIP()
}
