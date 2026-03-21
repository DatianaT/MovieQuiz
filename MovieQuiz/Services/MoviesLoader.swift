import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
  
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesURL: URL{
        guard let url = URL(string: "https://tv-api.com/en/API/Top250TVs/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    print("Movies loaded: \(mostPopularMovies.items.count)") // <-- DEBUG
                    handler(.success(mostPopularMovies))
                } catch {
                    print("JSON decode error: \(error)")
                    handler(.failure(error))
                }
            case .failure(let error):
                print("Network error: \(error)")
                handler(.failure(error))
            }
        }
    }
}
