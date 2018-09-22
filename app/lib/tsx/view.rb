module TSX

  class View

    attr_reader :body
    attr_reader :buttons

    def initialize(b, bt)
      @body = b
      @buttons = bt
    end


  end

end