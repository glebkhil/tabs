class Spam < Sequel::Model(:spam)
  BOT_CLIENTS = 0
  BOT_OPERATORS = 1
  BOT_ADMINS = 3
  BOT_ALL = 4

  NEW = 0
  SENDING = 6
  SENT = 1
  NOT_APPLICABLE = 3
  AD = 4

  def readable_status
    case self.status
      when Spam::NEW
        "#{I18n::t("spam.statuses.#{self.status}")}"
      when Spam::SENT
        "#{I18n::t("spam.statuses.#{self.status}")}"
      when Spam::AD
        "#{I18n::t("spam.statuses.#{self.status}")}"
      when Spam::SENDING
        "#{I18n::t("spam.statuses.#{self.status}")}"
    end
  end

  def sent?
    self.status == Spam::SENT
  end

end