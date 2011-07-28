require 'spec_helper'

describe Jangomail::Mailer do
  subject { Jangomail::Mailer.new(:user_name => 'abc', :password => '123', :options => { :OpenTrack => true }) }
  let(:mail) do
    Mail.new("From: \"Some Body\" <sender@example.com>\r\nTo: joe@example.com\r\nSubject: Hello\r\n\r\nHi there!").tap do |mail|
      mail.html_part = Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
        body '<h1>This is HTML</h1>'
      end
    end
  end

  before do
    FakeWeb.register_uri :post, 'http://api.jangomail.com/api.asmx/SendTransactionalEmail', :body => 'Success'
  end

  describe 'settings' do
    it 'requires user name' do
      expect {
        Jangomail::Mailer.new(:password => '123')
      }.to raise_error(ArgumentError, 'User Name needed')
    end

    it 'requires password' do
      expect {
        Jangomail::Mailer.new(:user_name => 'abc')
      }.to raise_error(ArgumentError, 'Password needed')
    end

    context 'when defaults are used' do
      subject { Jangomail::Mailer.new(:user_name => 'abc', :password => '123').settings }
      its([:api_url]) { should == 'http://api.jangomail.com/api.asmx/SendTransactionalEmail' }
      its([:options]) { should == {} }
    end

    context 'when set by user' do
      subject {
        Jangomail::Mailer.new(
          :user_name => 'abc',
          :password => '123',
          :api_url => 'http://www.example.com/foo',
          :options => { :OpenTrack => false }
        ).settings
      }

      its([:user_name]) { should == 'abc' }
      its([:password]) { should == '123' }
      its([:api_url]) { should == 'http://www.example.com/foo' }
      its([:options]) { should == { :OpenTrack => false } }
    end
  end

  describe '#deliver!' do
    let(:mock_http) { mock('http', :body => 'Success') }

    before do
      Net::HTTP.stub!(:new).and_return mock_http
    end

    it 'posts the message to the API with the required parameters' do
      post = "FromEmail=sender%40example.com&Options=OpenTrack%3DTrue&Subject=Hello&Username=abc&FromName=Some+Body&MessagePlain=Hi+there%21&MessageHTML=%3Ch1%3EThis+is+HTML%3C%2Fh1%3E&Password=123&ToEmailAddress=joe%40example.com"
      mock_http.should_receive(:post).with('/api.asmx/SendTransactionalEmail', post).and_return(mock(:body => 'Success'))
      subject.deliver!(mail)
    end
  end

  context 'using Rails' do
    it 'logs response when is available' do
      Object.const_set 'Rails', Module.new
      ::Rails.stub :logger => mock(:logger)

      ::Rails.logger.should_receive(:debug).with('Jangomail: Success')
      subject.deliver!(mail)

      Object.class_eval { remove_const 'Rails' }
    end

    it 'does not raise exception when is not available' do
      expect { subject.deliver!(mail) }.to_not raise_error
    end
  end
end
