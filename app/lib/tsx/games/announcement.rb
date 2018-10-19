module TSX
  module Games


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