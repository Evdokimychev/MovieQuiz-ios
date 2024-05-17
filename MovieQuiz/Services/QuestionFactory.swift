
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    func loadData() {
            moviesLoader.loadMovies { [weak self] result in
                DispatchQueue.main.async{
                    guard let self = self else { return }
                    switch result {
                    case .success(let mostPopularMovies):
                        if mostPopularMovies.errorMessage != ""{
                            self.delegate?.didFailToLoadData(with: NetworkError.apiKeyError)
                        }

                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(with: error)
                    }
                }
            }
        }


    func requestNextQuestion() {
        DispatchQueue.global().async {[weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            do{
                imageData = try Data(contentsOf: movie.resizedImageURL)
            }catch{
                DispatchQueue.main.async{ [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: NetworkError.imageError)
                }
                return
            }

            let rating = Float(movie.rating) ?? 0
            let randomRating = Float.randomMovieRating
            var text = String()
            var correctAnswer = Bool()
            if Bool.random(){
                text = "Рейтинг этого фильма больше чем \(randomRating)?"
                correctAnswer = rating > randomRating
            } else{
                text = "Рейтинг этого фильма меньше чем \(randomRating)?"
                correctAnswer = rating < randomRating
            }


            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            self.movies.remove(at: index)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
}


//    // массив вопросов
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false)
//    ]
//    
//    
//    //    func requestNextQuestion() -> QuizQuestion? {
//    //        guard let index = (0..<questions.count).randomElement() else {
//    //            return nil
//    //        }
//    //        
//    //        return questions[safe: index]
//    //    }
//    func requestNextQuestion() {
//        guard let index = (0..<questions.count).randomElement() else {
//            delegate?.didReceiveNextQuestion(question: nil)
//            return
//        }
//        
//        let question = questions[safe: index]
//        delegate?.didReceiveNextQuestion(question: question)
//    } 
//}
