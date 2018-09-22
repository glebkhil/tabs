class Meth < Sequel::Model(:meth)

  METHOD_PUBLIC = 1

  def make_options
  end

  def self.__easypay
    Meth::find(title: 'easypay') || false
  end

  def self.__btce
    Meth::find(title: 'btce') || false
  end

  def self.__livecoin
    Meth::find(title: 'lc') || false
  end

  def self.__exmo
    Meth::find(title: 'exmo') || false
  end

  def self.__tsc
    Meth::find(title: 'tsc_code') || false
  end

  def self.__tokenbar
    Meth::find(title: 'tokenbar') || false
  end

  def self.__cash
    Meth::find(title: 'cash') || false
  end

  def self.__debt
    Meth::find(title: 'debt') || false
  end

  def self.__nix
    Meth::find(title: 'nix') || false
  end

  def self.__wex
    Meth::find(title: 'wex') || false
  end

  def self.__qiwi
    Meth::find(title: 'qiwi') || false
  end

  def self.__bitcoin
    Meth::find(title: 'bitcoin') || false
  end

  def wex?
    self.title == 'wex'
  end

end
