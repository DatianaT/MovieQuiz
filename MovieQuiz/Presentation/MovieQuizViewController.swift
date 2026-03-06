import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Game State
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var questionsAmount = 10
    private let customFont = UIFont(name: "YSDisplay-Medium", size: 20)
    private lazy var questionFactory: QuestionFactoryProtocol = {
        QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
    }()
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        statisticService = StatisticService()
        showLoadingIndicator()
        questionFactory.loadData()
        setupImageView()
        setupButtons()
        statisticService = StatisticService()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
            
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Game Flow
    
    private func showViewModel() {
        questionFactory.requestNextQuestion()
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            questionFactory.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //    private func hideLoadingIndicator() {
    //        activityIndicator.isHidden = true
    //    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showNetworkError(message: String) {
        didLoadDataFromServer()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    } 
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - UI Update
    
    private func show(quiz step: QuizStepViewModel) {
        setButtonsEnabled(true)
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        guard let statisticService = statisticService else { return }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
            
        let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
        let model = AlertModel(title: result.title,
                               message: message,
                               buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
                
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }

        alertPresenter.show(in: self, model: model)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func setupImageView() {
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
    }
    
    private func setupButtons() {
        [yesButton, noButton].forEach { button in
            button?.backgroundColor = .white
            button?.layer.cornerRadius = 15
            button?.clipsToBounds = true
            button?.titleLabel?.font = customFont
        }
    }
    
    // MARK: - Actions
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func handleAnswer(_ givenAnswer: Bool) {
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }
}
