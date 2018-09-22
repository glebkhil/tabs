Друзья! Уделите минуту времени, пожалуйстя. Скажите, какой из шопов Вы считаете самым авторитетным?
****
buts ||= []
@list = Bot.select_all(:bot).join(:vars, :vars__bot => :bot__id).where(status: Bot::ACTIVE, listed: 1).order(Sequel.desc(:vars__sales))
buts = keyboard(@list, 3) do |rec|
    button("🔸 #{rec.tele}", rec.id)
end
buts
