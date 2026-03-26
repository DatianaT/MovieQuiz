import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Game State
    
    private let customFont = UIFont(name: "YSDisplay-Medium", size: 20)
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
        statisticService = StatisticService()
        showLoadingIndicator()
        setupImageView()
        setupButtons()
    }

    // MARK: - Game Flow
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать ещё раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter.didTapRetry()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - UI Update
    
    func show(quiz step: QuizStepViewModel) { 
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        setButtonsEnabled(true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.presenter.restartGame()
        }
        
        alert.addAction(action)
        present(alert, animated: true)
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
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
