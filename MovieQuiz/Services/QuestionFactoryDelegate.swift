//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Для учёбы   on 26/04/2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
