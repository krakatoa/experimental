require './main_app'
require './rsa_auth'

use Rask::RsaAuth
run Rask::MainApp.new
