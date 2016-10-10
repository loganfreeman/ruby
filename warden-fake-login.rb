include Warden::Test::Helpers

def fake_login_for_each_test(uid='jug2')
  before :each do
    Warden.test_mode!
    identity = Identity.find_by_ldap_uid(uid)
    login_as(identity)
  end

  after :each do
    Warden.test_reset!
  end
end
