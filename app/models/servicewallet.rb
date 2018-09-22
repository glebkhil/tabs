class Servicewallet < Sequel::Model(:servicewallet)
  ACTIVE = 1
  INACTIVE = 0

  def option(key)
    if !self.params.nil?
      params = JSON.parse(self.params)
      puts params.inspect
      puts params[key]
      params[key]
    else
      false
    end
  end

end