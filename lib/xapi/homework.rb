module Xapi
  class Homework
    attr_reader :key, :languages, :path
    def initialize(key, languages=Xapi::Config.languages, path=default_path)
      @key = key
      @languages = languages
      @path = path
    end

    def problems_in(language)
      problems.select { |problem| problem.language == language }
    end

    def problems
      languages.map {|language|
        Array(data[language]).map{|row|
          Problem.new(track_id: language, language: language, slug: row["slug"], path: path)
        }.uniq + [next_in(language)]
      }.flatten.reject(&:not_found?)
    end

    private

    def next_in(language)
      Progression.new(language, Array(data[language]).map{|problem| problem["slug"] }, path).next
    end

    def data
      @data ||= ExercismIO.exercises_for(key)
    end

    def default_path
      '.'
    end
  end
end
