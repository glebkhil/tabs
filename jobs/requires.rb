require 'bundler/setup'
Bundler.require(:default)
require 'sequel'
require 'colorize'
require 'pg'
require 'logger'
require 'i18n'
require 'open_exchange_rates'
require 'faraday'
require 'mechanize'
require 'require_all'
require 'telegram/bot'
require 'telegram/bot/types'
require 'colorize'
require 'twemoji'
require 'active_support'
require 'active_support/all'
require 'active_support/core_ext'
require 'action_view/helpers'

require_rel '../config/const'
require_rel '../config/config'
require_rel '../app/lib'
require_rel '../app/lib/tsx'
require_rel '../app/models'
require_rel '../app/controllers/tsx'

include TSX::Logman
include TSX::Helpers
include TSX::View_helpers
include TSX::Billing
