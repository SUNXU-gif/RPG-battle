class Game
    def initialize
        puts "↓勇者の名前を入力してください↓"
        hero_name = gets.chomp

        puts "勇者の名前は#{hero_name}です"
    end 
end

Game.new


