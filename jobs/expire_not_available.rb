require_relative './requires'
l = CronLogger.new

l._say "Flushing escrows without response ... "
ts = Escrow.where(status: Escrow::PENDING)
l.answer(ts.count, :green)
ts.each do |e|
  diff = Time.now - e.created
  if diff.minutes > 60
    l._say "Escrow ##{e.id} ..  "
    e.delete
    l.answer('expired. deleting', :green)
  end
end
DB.disconnect
puts "Finished."
