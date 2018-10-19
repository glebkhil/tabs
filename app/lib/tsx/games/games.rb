module TSX
  module Games

      def self.included(receiver, mod)
        receiver.send :include, mod
      end

      module Voting

        def approved?
          hb_client.has_vote?
        end

        def progress
          "#{self.conf('counter')} раз проголосовано."
        end

        def winner
          Vote::best_this_month
        end

      end

      module Lottery

        def available_numbers
          nums = []
          rng = eval("#{conf('range')}")
          Bet.where(game: self[:id]).each do |num|
            nums.push(num.number)
          end
          rng - nums
        end

        def approved?
          b = Gameplay[self.id]
          v = !Bet.find(client: client.id, game: b.id).nil?
          puts "Result: #{v}".colorize(:white_on_red)
          !v
        end

        def progress
          counter = Bet.where(game: self.id).count
          puts "#{self.conf('range').inspect}"
          maxi = eval("#{self.conf('range')}").count
          "#{counter} из #{maxi}"
        end

        def winner
          if !self.winner.nil?
            wnner = Client[self.winner]
            "#{icn('id')} <b>#{wnner.id}</b> @#{wnner.username}"
          end
        end

      end

      module Announcement

        def progress
          "#{self.conf('counter')} просмотров."
        end

        def winner
          ""
        end

        def approved?

        end

      end

      module Referals

        def progress
          "#{self.conf('counter')} просмотров."
        end

        def winner
          "нет данных"
        end

        def approved?
        end

        end

  end
end