class Chat < Sequel::Model(:chat)
  include TSX::Helpers

  def to_str(bot)
    "#{icon(bot.icon_geo)} #{self[:russian]}"
  end

end