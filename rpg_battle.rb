class Game
    def initialize
        puts "↓勇者の名前を入力してください↓"
        hero_name = gets.chomp
        
        @heroes = create_heros("BEN")
        @monsters = create_monsters

        display_character_info(@heroes)
        display_character_info(@monsters)

    end 

    private

    def create_heros(hero_name)
        Character.new(hero_name,30,6,Constants::ATTACK_TYPE_NORMAL,true)
    end

    def create_monsters
        Character.new("オーク",30,8,Constants::ATTACK_TYPE_NORMAL)
    end

    def display_character_info(character)
        puts "\nキャラクター名：#{character.name}"
        puts "HP：#{character.hp}"
        puts "こうげき力：#{character.attack_damage}"
        puts "こうげきタイプ：#{character.attack_type}"
        puts "プレイヤーフラグ：#{character.is_player}"
        puts "生存フラグ：#{character.is_alive}"
    end
    
end



class Character
    attr_accessor :name,:hp,:attack_damage,:attack_type,:is_player,:is_alive

    def initialize(name,hp,attack_damage,attack_type,is_player=false)
        @name = name
        @hp = hp
        @attack_damage = attack_damage
        @attack_type = attack_type
        @is_player = is_player
        @is_alive = true
    end 
end

class Constants
    ATTACK_TYPE_NORMAL = 1
    ATTACK_TYPE_MAGIC = 2
end

Game.new