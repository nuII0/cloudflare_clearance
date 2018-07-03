# CloudflareClearance
A ruby gem to bypass the Cloudflare Anti-Bot protection ("Checking your browser before accessing ...")

## Notes
To access cloudflare protected webpages, the asking HTTP Client needs to solve a challenge.

The most basic variant is checking if the client supports JavaScript by providing a challenge and asking for an answer.
This gem can solve this challenge automatically to allow further web scraping of protected pages.

To correctly solve the challenge, the client needs to wait 5 seconds. Therefore the corresponding methods in this gem are
sleeping some time when creating the clearance.

If you are facing more sophisticated protections, like Captchas, you are out of luck with this gem.

## Dependencies
This library can solve the cloudflare challenge in multiple ways. Each way comes with it owns dependencies and
installation requirements.

### ExecJs
Since Cloudflare sends the challenge as JavaScript code, it can be extracted and solved by executing the challenge in a JavaScript runtime.
The `ExecJs` gem provides support to eval JavaScript code on different runtimes (Node.js, therubyracer, therubyrhino and more).
Pick one runtime on your system and install the `ExecJs` gem. See [ExecJs (Github)](https://github.com/rails/execjs) for more information.

### Selenium-Webdriver
Alternatively, `Selenium` can be used to automate a full browser.
This approach requires [Ruby Bindings for Selenium (Github)](https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings) as gem dependency and a suitable browser like `Firefox` with `geckodriver`.

## Usage
If at least one dependency is installed we are now ready to bypass the challenge.

### Basic Get Request
A basic GET request for the content of a protected page can be done like this
```rb
require 'cloudflare_clearance'

clearance = CloudflareClearance.new(https://example.com)

response = clearance.get("https://example.com/foobar")
=> #<Net::HTTPOK 200 OK readbody=true>

response.body # HTML Content of protected page
```

### Explicit ExecJS Usage
With `ExecJs`, you can pass a custom User-Agent:
```rb
require "cloudflare_clearance"

url = 'https://example.com'
driver = CloudflareClearance::Driver::ExecJs.new(user_agent: "My User-Agent")

clearance = CloudflareClearance::Clearance.new(url, driver: driver)
```

### Explicit Selenium Usage
Alternatively, use the Selenium-Webdriver as driver

```rb
require "cloudflare_clearance"

url = 'https://example.com'
driver = CloudflareClearance::Driver::Selenium.new
clearance = CloudflareClearance::Clearance.new(url, driver: driver)

```

You can use your own selenium instance for the clearance process.
For example Selenium with Firefox and custom options.

```rb
require "selenium-webdriver"
require "cloudflare_clearance"

selenium_options = ::Selenium::WebDriver::Firefox::Options.new(
        args: ['-headless']
      )
selenium_instance = ::Selenium::WebDriver.for :firefox, options: selenium_options)

driver = CloudflareClearance::Selenium.new(selenium_webdriver: selenium_instance)

clearance = CloudflareClearance::Clearance.new(url, driver: driver)
```

### Integration
To use the clearance in your own subsequent HTTP calls, you need to embed the obtained cloudflare Cookies alongside the User-Agent which was used during the challenge.

```rb
clearance.cookieset

=> #<struct CloudflareClearance::CookieSet
 cf_duid=
  #<struct CloudflareClearance::Cookie
   name="__cfduid",
   value="dbf3fcab169fe30cd14e5677de01f51651530618096",
   path="/",
   domain="example.com",
   expires=#<DateTime: 2019-07-03T11:41:35+00:00 ((2458668j,42095s,999999985n),+0s,2299161j)>,
   secure=true>,
 cf_clearance=
  #<struct CloudflareClearance::Cookie
   name="cf_clearance",
   value="5227bcb5f3d82e8d32032b0c58bfaa3c88b3eab2-1130618101-1810",
   path="/",
   domain="example.com",
   expires=#<DateTime: 2018-07-03T13:11:40+00:00 ((2458303j,47500s,999999896n),+0s,2299161j)>

clearance.cookie_string				# for convenience
=> "cf_clearance=5227bcb5f3d82e8d32032b0c58bfaa3c88b3eab2-1130618101-1810;__cfduid=dbf3fcab169fe30cd14e5677de01f51651530618096"

clearance.user_agent
=> "Mozilla/5.0 (X11; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
```

Both cookies, `cf_duid` and `cf_clearance` needs to be passed together with the User-Agent in the HTTP Header for subsequent calls. If other, site-specific, cookies appeared during the challenge process, they will also reside in the cookieset under `other`

```rb
clearance.cookieset                                                                                                    
=> #<struct CloudflareClearance::CookieSet
 cf_duid=
  #<struct CloudflareClearance::Cookie
 cf_clearance=
  #<struct CloudflareClearance::Cookie
 other=
  [#<struct CloudflareClearance::Cookie
    name="whatever_site_specific_cookie",
    value="foobar",
    path="/",
    domain=".example.com",
    expires=nil,
    secure=true>]>
```


An integration example with RestClient would look like:
```rb
require 'rest-client'

headers = { Cookie:     clearance.cookie_string,
            User-Agent: clearance.user_agent }

RestClient.get("https://example.com/", headers)
```




# Similar Projects
For a python based solution of the same problem see [cloudflare-scrape (Github)](https://github.com/Anorov/cloudflare-scrape).

# License
This library is licensed under the MIT License.

