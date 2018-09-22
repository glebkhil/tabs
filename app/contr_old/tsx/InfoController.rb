module TSX
  module Controllers
    module Search

      def start_info
        hb_client.role = Client::HB_ROLE_SERVICE
        hb_client.save
        reply_simple 'info/welcome', locals: {remove_keyboard: false}
      end

      def ask_token
        handle('save_notify')
        reply_message "Введите Ваш токен авторизации, выданный Вам в админке площадки. Токен должен иметь вид `EM47EL69O20GLM7BMO764268D26522C2KG5M8N31`. Если есть вопросы, обращайтесь в службу поддержки."
      end

      def confirm_escrow(data = nil)
        handle('save_notify')
        reply_message "Введите Ваш токен авторизации, выданный Вам в админке площадки. Токен должен иметь вид `EM47EL69O20GLM7BMO764268D26522C2KG5M8N31`. Если есть вопросы, обращайтесь в службу поддержки."
      end

      def save_notify(data)
        reply_message "#{icon('hourglass_flowing_sand')} Проверяем ваш токен авторизации."
        found_user = Team.find(token: data)
        if found_user.nil?
          update_message("#{icon('no_entry_sign')} Неверный токен.")
        else
          found_user.notify = hb_client.id
          found_user.save
          puts "FOUND USER: #{found_user.client}".colorize(:red)
          hb_client.update(notify: found_user.id)
          update_message("#{icon('white_check_mark')} *Акаунт привязан!* Этот Телеграм акаунт привязан к боту. В этом боте Вы будете получать оповащенеия о событиях площадки.")
        end

      end

    end
  end
end
