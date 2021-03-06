require_relative "lib/movie"
require_relative "lib/api"

class MovieJson

  attr_reader :movies
  def initialize
    @movies = []
  end

  def run
    search
  end

  def movie_search_prompt
    puts "OH HAI. Please add a movie you like"
    print ">>" 
    movie_title = gets.downcase.chomp
    return "Sorry, but you have to actually enter something to search" if movie_title.empty?
    puts "Cool, searching for #{movie_title}"
    search = movie_search_by_title(movie_title)
    return "Sorry we cannot find that movie" if search.title.nil?
    add_to_movie_list(search)
    puts movie_title != search.title ? "This is the closest we could find: #{search.title} was released in #{search.year}. It recieved a critics score of #{search.score}" : "#{search.title} was released in #{search.year}. It recieved a critics score of #{search.score}"
  end

  def movie_search_by_title(movie_title)
    Api.search_by_title(movie_title)
  end

  def add_to_movie_list(movie)
    @movies << movie
  end

  def search_again(response)
    if response == "yes"
      puts movie_search_prompt
    elsif response == "no"
      false
    else
      puts "I don't understand that"
    end
  end

  def search
    puts "Would you like to: \n1) Search\n2) Average rating?\n3) Average year?\n4) Calculate movie happiness?\n5) Exit?"
    print ">>"
    u_start = gets.chomp
    if u_start == "1"
      puts movie_search_prompt
      while true
        puts "Search Again? Yes or No"
        re_search = gets.downcase.chomp
        break if search_again(re_search) == false 
      end
    search
    elsif u_start == "2"
      puts average_raiting
      search
    elsif u_start == "3"
      puts average_year
      search
    elsif u_start == "4"
      puts calculate_happiness
      search
    else
      puts "Exiting..."
    end
  end

  def average_raiting
    @movies.map {|movie| movie.score}.reduce(:+).to_f / @movies.size
  end

  def average_year
    avg_year = @movies.map { |movie| movie.year}.reduce(:+).to_f / @movies.size
    avg_year.to_i
  end

  def sort_years(movies)
    movies.map{ |movie| movie.year }.sort
  end

  def average_rating_by_year(movie_hash_by_year,year)
    movies = movie_hash_by_year[year]
    movies.map { |movie| movie.score }.reduce(:+) / movies.length
  end

  def movie_rating_slope(years,movie_hash_by_year)
    years[0] - years[-1] != 0 ? (average_rating_by_year(movie_hash_by_year,years[-1]) - average_rating_by_year(movie_hash_by_year,years[0])).to_f / (years[-1] - years[0]).to_f : 0
  end

  def calculate_happiness
    slope = movie_rating_slope(sort_years(@movies),@movies.group_by {|movie| movie.year})
    if slope == 0
      return "You're neutral"
    elsif slope > 0
      return "You're getting happier!"
    else
      return "You're getting sadder"
    end
  end

end
MovieJson.new.run if __FILE__ == $PROGRAM_NAME
