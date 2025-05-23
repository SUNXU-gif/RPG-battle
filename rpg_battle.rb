class Constants
    HP_MIN = 0
    ATTACK_VARIANCE = 3

    ACTION_ATTACK = 1
    ACTION_ESCAPE = 2

    ATTACK_TYPE_NORMAL = 1
    ATTACK_TYPE_MAGIC = 2

    MESSAGE_DISPLAY_INTERVAL = 1
end

class Message
    def self.enter_name
       "↓勇者の名前を入力してください↓"
    end 
    
    def self.game_start
        color("magenta","\n◆◆◆ モンスターが現れた！ ◆◆◆")
    end 

    def self.round(round)
        color("cyan", "\n=== ラウンド #{round} ===")
    end

    def self.status(character)
        mark = character.is_alive ? "." : color("red","x")
        name = character.name
        hp = character.hp
        attack_damage = character.attack_damage

        "#{mark}【#{name}】 HP：#{hp} こうげき力：#{attack_damage}"
    end 

    def self.action_choice(hero)
        name = hero.name
        attack = Constants::ACTION_ATTACK
        escape = Constants::ACTION_ESCAPE

        "\n#{name} のターンです。\n↓行動を選択してください↓\n" + color("yellow", "【#{attack}】こうげき\n【#{escape}】逃げる")
    end     

    def self.invalid_choice
        color("blue","無効な選択肢です。再度選んでください。")
    end 

    def self.attack(attacker)
        name = attacker.name
        type = attacker.attack_type
        normal_attack = Constants::ATTACK_TYPE_NORMAL
        magic_attack = Constants::ATTACK_TYPE_MAGIC

        case type
        when normal_attack
            return "#{name}の攻撃！"
        when magic_attack
            return "#{name} は呪文をとなえた！"
        end 
    end 

    def self.damage(target,damage)
        name = target.name

        "→#{name} に #{damage} のダメージ！"
    end 

    def self.death(target)
        name = target.name
        
        color("yellow","→#{name} はたおれた！")
    end 

    def self.escape(character)
        name = character.name

        color("yellow", "#{name} は逃げ出した！\n")
    end 

    def self.judge(hero_alive)
        hero_alive ? color("green", "◆◆◆ 勇者パーティの勝利！ ◆◆◆") : game_over()
    end 

    def self.game_over
        color("red", "◆◆◆ GAME OVER ◆◆◆")
    end

    def self.color(color,text)
        color_codes = {
            "red" => 31,
            "green" => 32,
            "yellow" => 33,
            "blue" => 34,
            "magenta" => 35,
            "cyan" => 36,
        }

        color_code = color_codes[color.downcase]
        color_code ? "\e[#{color_code}m#{text}\e[0m" : text
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

    def calculate_damage 
        variance = Constants::ATTACK_VARIANCE

        rand(@attack_damage - variance..@attack_damage + variance)
    end 

    def receive_damage(damage)
        hp_min = Constants::HP_MIN

        @hp -= damage
        
        if @hp <= hp_min
            @hp = hp_min
            @is_alive = false
        end 
    end
end 


class Game

    def initialize

        @escape_flg = false

        display_message(Message.enter_name())
        hero_name = gets.chomp

        @heroes = create_heroes(hero_name)
        @monsters = create_monsters()

        @all_parties = [@heroes,@monsters]
    end 

    def start
        round = 0

        display_message(Message.game_start())

        loop do
            round += 1
            display_message(Message.round(round))
            display_status(@heroes)
            display_status(@monsters)

            process_heroes_turn()
            break if @all_parties.any? { |party| party_destroyed?(party)} || @escape_flg

            process_monsters_turn()
            break if @all_parties.any? { |party| party_destroyed?(party) }
        end 

        unless @escape_flg
            display_message(Message.judge(party_destroyed?(@monsters)))
        else
            display_message(Message.game_over())
        end 
    end 

    private

    def create_heroes(hero_name)
        normal_attack = Constants::ATTACK_TYPE_NORMAL
        magic_attack = Constants::ATTACK_TYPE_MAGIC

        [
            Character.new(hero_name,30,6,normal_attack,true),
            Character.new("魔法使い",20,8,magic_attack)
        ]
    end 

    def create_monsters
        normal_attack = Constants::ATTACK_TYPE_NORMAL
        [
            Character.new("オーク",30,8,normal_attack),
            Character.new("ゴブリン",25,6,normal_attack)
        ]
    end 

    def display_message(message,wait=false)
        interval = Constants::MESSAGE_DISPLAY_INTERVAL

        puts message
        sleep interval if wait
    end 

    def display_status(party)
        party.each {|character| display_message(Message.status(character))}
    end 

    def process_heroes_turn
        attack_action = Constants::ACTION_ATTACK
        escape_action = Constants::ACTION_ESCAPE

        @heroes.each do |character|
            next unless character.is_alive
            loop do
                if character.is_player
                    display_message(Message.action_choice(character))
                    choice = gets.to_i
                else
                    choice = attack_action
                end 

                case choice
                when attack_action
                    target_monster = @monsters.select(&:is_alive).sample
                    execute_attack(character,target_monster) if target_monster
                    break
                when escape_action
                    execute_escape(character)
                    return 
                else
                    display_message(Message.invalid_choice())
                end
            end
        end 
    end

    def process_monsters_turn
        @monsters.each do |monster|
            next unless monster.is_alive

            attack_target = @heroes.select(&:is_alive).sample
            execute_attack(monster,attack_target) if attack_target
        end 
    end 

    def execute_attack(attacker,target)
        display_message(Message.attack(attacker),true)

        damage = attacker.calculate_damage()
        target.receive_damage(damage)
        display_message(Message.damage(target,damage),true)

        display_message(Message.death(target),true) unless target.is_alive
    end 

    def execute_escape(character)
        @escape_flg = true
        display_message(Message.escape(character),true)
    end 

    def party_destroyed?(party)
        party.none?(&:is_alive)
    end 
end 

game = Game.new
game.start