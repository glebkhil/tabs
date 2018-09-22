class TBRController < ApplicationController

  get '/tbr' do
    haml :'tbr/index', layout: hb_tbr_layout
  end

  get '/tbr/api_stat' do
    @reqs = Request.where(bot: hb_bot.id).paginate(@p.to_i, 20)
    haml :'tbr/api_stat', layout: hb_tbr_layout
  end

  get '/tbr/register' do
    user = register(Client::HB_ROLE_API)
    login!(user)
    redirect url('/tbr/api_stat')
  end

end
