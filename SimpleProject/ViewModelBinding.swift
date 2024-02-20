//
//  ViewModelBinding.swift
//  SimpleProject
//
//  Created by Peter Shih on 2024/3/6.
//

protocol ViewModelBinding {
    associatedtype Inputs
    associatedtype Outputs

    func bind(_ inputs: Inputs) -> Outputs
}
