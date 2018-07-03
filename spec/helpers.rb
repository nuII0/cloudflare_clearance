# frozen_string_literal: true
module Helpers
  def help
    :available
  end

  VALID_CFUID_COOKIE = CloudflareClearance::Cookie.new(
    name: "__cfduid",
    value: "d3a556ffc236de0081560fdad9f09fc0d1524516021",
    path: "/",
    domain: ".foo",
    expires: "bar",
    secure: true)

  VALID_CF_CLEARANCE_COOKIE = CloudflareClearance::Cookie.new(
    name: "cf_clearance",
    value: "8319f2d741cc91a4100055ee346ddd80743e377d-1524516030-1800",
    path: "/",
    domain: ".foo",
    expires: nil,
    secure: false)



  INVALID_COOKIE = CloudflareClearance::Cookie.new(name: "baz", value: "bar")

  OTHER_COOKIE = INVALID_COOKIE

  USER_AGENT = 'rspec-user-agent'

  VALID_CLOUDFLARE_COOKIESET = CloudflareClearance::CookieSet.new(cf_duid: VALID_CFUID_COOKIE, cf_clearance: VALID_CF_CLEARANCE_COOKIE)

  VALID_CLEARANCE_DATA = CloudflareClearance::ClearanceData.new(user_agent: USER_AGENT, cookieset: VALID_CLOUDFLARE_COOKIESET)

  def mock_generic_webdriver
    webdriver = double
    allow(webdriver).to receive(:get_clearance).and_return(
      CloudflareClearance::ClearanceData.new(user_agent: USER_AGENT, cookieset: VALID_CLOUDFLARE_COOKIESET)
    )
    return webdriver
  end

  def mock_selenium_webdriver(cookies)
    manager_mock = double
    allow(manager_mock).to receive(:all_cookies).and_return(
      cookies.map(&:to_h)
    )

    driver_mock = double
    allow(driver_mock).to receive(:manage).and_return(
      manager_mock
    )
    allow(driver_mock).to receive(:get)
    allow(driver_mock).to receive(:execute_script).and_return(
      USER_AGENT
    )
    return driver_mock
  end

  def file_fixture(fixture_name)
    file_fixture_path = File.join(File.dirname(__FILE__), './fixture/files')
    path = Pathname.new(File.join(file_fixture_path, fixture_name))

    if path.exist?
      path
    else
      msg = "the directory '%s' does not contain a file named '%s'"
      raise ArgumentError, msg % [file_fixture_path, fixture_name]
    end
  end

  #def mock_http_adapter(returns: [VALID_INIT_PAGE, VALID_CLEARANCE_PAGE])
  #adapter_mock = double
  #allow(adapter_mock).to receive(:get).and_return(
  #VALID_INIT_PAGE,
  #VALID_CLEARANCE_PAGE
  #)

  #return adapter
  #end
end
