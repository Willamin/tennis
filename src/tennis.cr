# A Tennis Match consists of Sets
# A Set consists of Games
# A Game consists of scores (love, fifteen, thirty, forty, etc)

module Tennis
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  class GameState
    macro inherited
      {% pp @type %}
    end
  end

  FOURSCORE = %w(Love Fifteen Thirty Forty)

  {% for right in FOURSCORE %}
    {% for left in FOURSCORE %}
      {% if !(right == "Forty" && left == "Forty") %}
        class {{left.id}}{{right.id}}State < GameState; end
        {{left.id}}{{right.id}} = {{left.id}}{{right.id}}State.new
      {% end %}
    {% end %}
  {% end %}

  {% for state in %w(Deuce AdvDis DisAdv WonLost LostWon) %}
    class {{state.id}}State < GameState; end
    {{state.id}} = {{state.id}}State.new
  {% end %}

  class Side; end

  class LeftSide < Side; end

  Left = LeftSide.new

  class RightSide < Side; end

  Right = RightSide.new

  module Game
    extend self

    def point_left(state : GameState)
      point(Left)
    end

    def point_right(state : GameState)
      point(Right)
    end

    # Game State Pattern Matches

    {% for right, i in FOURSCORE[0..-1] %}
      {% for left, i in FOURSCORE[0..-1] %}
        def point(s : LeftSide, state : {{left.id}}{{right.id}}State)
          {{FOURSCORE[(i + 1) % FOURSCORE.size].id}}{{right.id}}
        end
      {% end %}
    {% end %}

    def point(s : LeftSide, state : FortyLoveState)
      WonLost
    end

    def point(s : RightSide, state : LoveFortyState)
      LostWon
    end

    def point(s : LeftSide, state : WonLostState | LostWonState)
      raise "The game is already over, no more points"
    end

    def point(s : LeftSide, state : FortyThirtyState)
      Deuce
    end

    def point(s : RightSide, state : ThirtyFortyState)
      Deuce
    end

    def point(s : LeftSide, state : Deuce)
      AdvDis
    end

    def point(s : RightSide, state : Deuce)
      DisAdv
    end

    def point(s : LeftSide, state : AdvDis)
      WonLost
    end

    def point(s : RightSide, state : DisAdv)
      LostWon
    end

    def point(s : LeftSide, state : DisAdv)
      Deuce
    end

    def point(s : RightSide, state : AdvDis)
      Deuce
    end
  end
end
