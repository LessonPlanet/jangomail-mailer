require 'net/http'
require 'net/https'
require 'cgi'
require 'mail'

module Jangomail
  class Mailer

    def initialize(values = {})
      self.settings = { :api_url              => 'http://api.jangomail.com/api.asmx/SendTransactionalEmail',
                        :options              => {},
                        :logger               => defined?(Rails) && Rails.logger,
                        :log_level            => :debug,
                        :user_name            => nil,
                        :password             => nil,
                      }.merge!(values)
      raise ArgumentError, 'User Name needed' unless settings[:user_name]
      raise ArgumentError, 'Password needed' unless settings[:password]
    end

    attr_accessor :settings

    def new(*args)
      self
    end

    def deliver!(mail)
      uri = URI.parse(settings[:api_url])
      if uri.scheme == 'https'
        http = Net::HTTP.new(uri.host, 443)
        http.use_ssl = true
      else
        http = Net::HTTP.new(uri.host)
      end

      destinations ||= mail.destinations if mail.respond_to?(:destinations) && mail.destinations
      if destinations.blank?
        raise ArgumentError.new('At least one recipient (To, Cc or Bcc) is required to send a message')
      end

      destinations.each do |destination|
        data = request_data(mail, destination)
        http.post(uri.path, data).body.tap do |response|
          settings[:logger].send(settings[:log_level], "Jangomail: #{response}") if settings[:logger]
        end
      end
    end

    private

    def request_data(mail, destination)
      # Set the envelope from to be either the return-path, the sender or the first from address
      envelope_from = mail.return_path || mail.sender || mail.from_addrs.first
      if envelope_from.blank?
        raise ArgumentError.new('A sender (Return-Path, Sender or From) required to send a message')
      end

      {
        'Username'      => settings[:user_name],
        'Password'      => settings[:password],
        'FromEmail'     => envelope_from,
        'FromName'      => mail[:from].display_names.first,
        'ToEmailAddress'=> destination,
        'Subject'       => mail.subject,
        'MessagePlain'  => mail.multipart? ? mail.text_part.body.to_s : mail.body.to_s,
        'MessageHTML'   => mail.multipart? ? mail.html_part.body.to_s : mail.body.to_s,
        'Options'       => stringified_options,
      }.map{ |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}"}.join('&')

    end

    def stringified_options
      settings[:options].map do |k, v|
        val = case v
                when TrueClass then 'True'
                when FalseClass then 'False'
                else v.to_s
              end
        "#{k.to_s}=#{val}"
      end.join(',')
    end
  end
end
