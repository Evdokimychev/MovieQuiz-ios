//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Для учёбы   on 26/04/2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
    func loadData()
}

