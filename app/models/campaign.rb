class Campaign < Sequel::Model(:campaign)
  ACTIVE = 1
  INACTIVE = 0
  PAUSED = 2
end