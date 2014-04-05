module Xapi
  class Homework
    attr_reader :key
    def initialize(key)
      @key = key
    end

    def exercises_in(language)
      exercises.select { |exercise| exercise.language == language }
    end

    def exercises
      (current_exercises + upcoming_exercises).reject(&:not_found?).sort_by(&name)
    end

    private

    def current_exercises
      course.lessons.map(&:exercises).flatten
    end

    def upcoming_exercises
      Xapi::Config.languages.map {|language|
        progression = Progression.new(language)
        slugs = data[language]
        if progression.next(slugs)
          Exercise.new(language, progression.next(slugs)).fresh!
        end
      }
    end

    def name
      Proc.new {|exercise|
        [exercise.language, exercise.slug]
      }
    end

    def data
      @data ||= ExercismIO.exercises_for(key)
    end

    def course
      Course.new(data)
    end
  end
end
