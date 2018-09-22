require 'fileutils'
require 'money'
require 'money/bank/google_currency'

module TSX
  class UserController < TSX::ApplicationController

    helpers Sinatra::UserAgentHelpers

    get '/spam/delete/:id' do
      redirect to('/not_permitted') if !hb_operator.is_beneficiary?(hb_bot) and !hb_operator.is_admin?(hb_bot) and !hb_operator.is_admin?(hb_bot) and !hb_operator.is_operator?(hb_bot)
      it = Spam[params[:id]]
      it.delete
      flash['info'] = 'Рассылка или пост удален.'
      redirect back
    end

    get '/spam/restore/:id' do
      redirect to('/not_permitted') if !hb_operator.is_beneficiary?(hb_bot) and !hb_operator.is_admin?(hb_bot) and !hb_operator.is_admin?(hb_bot) and !hb_operator.is_operator?(hb_bot)
      it = Spam[params[:id]]
      it.status = Spam::NEW
      it.save
      flash['info'] = 'Рассылка возобновлена.'
      redirect back
    end

    post '/add_group' do
      Group.create(tele: '1', status: Group::ACTIVE, title: params[:group], client: hb_bot.beneficiary.id, )
      redirect back
    end

    get '/spam' do
      haml :'user/spam', layout: hb_layout
    end

    post '/spam' do
      redirect to('/not_permitted') if !hb_operator.is_beneficiary?(hb_bot) and !hb_operator.is_admin?(hb_bot) and !hb_operator.is_operator?(hb_bot)
      Spam.create(bot: hb_bot.id, kind: params[:send_to], label: params[:label] || "название", text: params[:text], status: Spam::NEW)
      redirect back
    end

    post '/ads' do
      redirect to('/not_permitted') if !hb_operator.is_beneficiary?(hb_bot) and !hb_operator.is_admin?(hb_bot) and !hb_operator.is_operator?(hb_bot)
      Spam.create(bot: hb_bot.id, label: params[:label], text: params[:text], status: Spam::AD)
      redirect back
    end

    get '/assign_ad/:ad/:group' do
      redirect to('/not_permitted') if !hb_operator.is_beneficiary?(hb_bot) and !hb_operator.is_admin?(hb_bot) and !hb_operator.is_operator?(hb_bot)
      c = Campaign.find_or_create(spam: params[:ad], group: params[:group], status: Campaign::ACTIVE, counter: 0)
      flash['info'] = "Рекламный пост <b>#{Spam[params[:ad]].label}</b> привязан к чату @#{Group[c.group].tele}."
      redirect url('/advertisement')
    end

    get '/cancel_ad/:ad/:group' do
      redirect to('/not_permitted') if !hb_operator.is_beneficiary?(hb_bot) and !hb_operator.is_admin?(hb_bot) and !hb_operator.is_operator?(hb_bot)
      c = Campaign.find(spam: params[:ad], group: params[:group])
      c.delete
      flash['info'] = "Реклама в чате <b>#{Spam[params[:ad]].label}</b> приостановлена."
      redirect url('/advertisement')
    end

    post'/purchase' do
    end

    get '/choose_ad/:group' do
      @group = params[:group]
      haml :'user/choose_ad', layout: hb_layout
    end

    get '/ad_schedule/:group' do
      @group = params[:group]
      haml :'user/choose_ad', layout: hb_layout
    end

    get '/account' do
      haml :'user/account', layout: hb_layout
    end

    get '/advertisement' do
      @groups = Group.where(status: Group::ACTIVE).paginate(@p.to_i, 20)
      haml :'user/advertisement', layout: hb_layout
    end

    get '/offers' do
      @offers = Item.where(bot: hb_bot.id, status: [Item::ESCROW_ACTIVE, Item::ESCROW_PAUSED]).paginate(@p.to_i, 20)
      haml :'user/offers', layout: hb_layout
    end

    get '/stat' do
      g = Gruff::Line.new
      sets = Product.available_by_bot(hb_bot)
      last_day = Date.new(Date.today.year, Date.today.month, -1).day
      cur_date = 0
      g = Gruff::Line.new(800)
      g.legend_font_size = 18
      g.x_axis_label = 'Дни'
      g.marker_font_size = 25
      g.font = 'Monospace'
      g.line_width = 7
      g.minimum_x_value = 1
      g.maximum_x_value = last_day
      g.has_left_labels = 0
      g.bottom_margin = 20
      g.left_margin = -50
      g.y_axis_increment = 1
      g.no_data_message = "#{icn('warning')} Пустой график"
      g.theme = {
        :colors => LINES,
        :marker_color => '#aea9a9', # Grey
        :font_color => 'black',
        :background_colors => 'white'
      }
      while cur_date < last_day
        cur_date += 1
        current = Date.new(Date.today.year, Date.today.month, cur_date)
        g.labels[cur_date] = current.day.to_s
      end
      sets.each do |prod|
        sales_count = hb_bot.sales_by_product(Product[prod[:prod]])
        puts sales_count.inspect
        g.data(prod.russian, sales_count)
      end
      @cimage = "#{Time.now.to_i.to_s}.png"
      g.write(@cimage)
      # @cimage = 'data:image/png;base64,' + Base64.strict_encode64(g.to_blob)
      send_file open(@cimage),
                type: 'image/png',
                disposition: 'inline'
      # haml :'user/stat', layout: hb_layout
    end

    get '/edit_offer/:id' do
      redirect to('/not_permitted') if !hb_operator.is_beneficiary?(hb_bot) and !hb_operator.is_admin?(hb_bot)
      @item = Item[params[:id]]
      @escrow = Escrow.find(item: @item.id)
      haml :'user/edit_offer', layout: hb_layout
    end

    get '/delete_offer/:id' do
      begin
        it = Item[params[:id]]
        it.delete
        flash['info'] = 'Предложение удалено.'
      rescue
        flash['info'] = 'Невозможно удалить предложение. Возможно кто то уже создал сделку для этого предложения.'
      end
      redirect back
    end

    get '/publish_offer/:id' do
      begin
        it = Item[params[:id]]
        it.update(status: Item::ESCROW_ACTIVE)
        flash['info'] = 'Предложение опубликовано.'
      rescue
        flash['info'] = 'Невозможно опубликовать предложение. '
      end
      redirect back
    end


    post '/edit_offer/:id' do
      begin
        item = Item[params[:id]]
        item.product = params['b22_product']
        item.img = params['b22_picture']
        item.prc = Price[params['b22_prc']].id
        item.escrow = params['b22_escrow']
        item.escrow_paid_by = params['b22_escrow_paid_by']
        item.shipment = params['shipment']
        item.full = params['b22_full']
        item.save
        flash['info'] = 'Оптовое предложение отредактировано.'
        redirect back
      rescue => e
        flash['info'] = 'Ошибка при редактировании предложения.'
        puts e.message
        redirect back
      end
    end

  end

end