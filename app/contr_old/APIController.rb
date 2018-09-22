class APIController < ApplicationController

  get '/api/test_upload' do
    haml :'admin/upload', locals: {layout: hb_layout}
  end

  get '/api/products' do
    content_type :json, charset: 'utf-8'
    lines = Hash.new
    Product::available.each do |p|
      lines[p.id] = p.russian
    end
    lines.to_json
  end

  post '/api/save_item' do
    content_type :json, charset: 'utf-8'
    if params[:image_file] && params[:image_file][:filename]
      filename = params[:image_file][:filename]
      file = params[:image_file][:tempfile]
      path = "#{ROOT}/public/images/uploads/#{filename}"
      IO::File.open(path, 'wb') do |f|
        f.write(file.read)
      end
      u = "http://uploads.im/api?upload=#{url("/images/uploads/#{filename}")}"
      g = Faraday.get(u).body
      # puts g.inspect
      res = JSON.parse(g)
      url = res['data']['img_url']
      # puts res.inspect
      # puts url
      product = params[:product]
      qnt = params[:weight]
      client = params[:client]
      bot = params[:bot]
      begin
        d = Item.create(
          product: product,
          photo: url,
          full: nil,
          qnt: qnt,
          price: 700,
          city: 38,
          district: 34,
          client: client,
          bot: bot,
          status: Item::ACTIVE
        )
        # puts d.inspect
        {'result' => 'saved'}.to_json
      rescue => ex
        # puts ex.message
        {'result' => 'error', 'message' => ex.message}.to_json
      end
    else
      {'result' => 'error', 'message' => 'no file given'}.to_json
    end
  end

end
