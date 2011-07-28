# JangoMail Transactional Mailer
Implements [JangoMail Transactional API](http://api.jangomail.com/api.asmx?op=SendTransactionalEmail).

## Features
- Accepts JangoMail options (e.g. OpenTrack, ClickTrack, TransactionalGroupID, etc.)
- Sends both the HTML and plain text parts of the message to the JangoMail API.

## Options
- `user_name` (required): your JangoMail user name
- `password` (required): your JangoMail password
- `options`: hash containing additional JangoMail options (e.g. `{ :OpenTrack => true }`)
- `api_url`: JangoMail API URL

# Rails Examples
Put in `config/initializers/jangomail.rb`:

     ActionMailer::Base.add\_delivery\_method :jangomail, Jangomail::Mailer,
                                              :user_name => 'username',
                                              :password  => 'password',
                                              :options   => { :OpenTrack => true }

And in your ActionMailer class:

    defaults :delivery\_method => :jangomail

or for just a particular message:

    def welcome(user) do
      mail :to => user.email,
           :delivery\_method => :jangomail
    end

# Non-Rails Example
Create a mailer instance and deliver

    mailer = Jangomail::Mailer.new :user_name => "username", :password => "password"
    mail = Mail.new { ... }
    mailer.deliver! mail
    
# Contributors
- Jason Rust
