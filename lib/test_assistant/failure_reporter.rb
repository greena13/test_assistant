module TestAssistant
  # Factory class for generating a failure report summarising the last request and
  # response sent in a particular test and opening it in a browser. Intended to
  # aid in debugging and to be toggled on through the use of RSpec tags and configured
  # using TestAssistant::Configuration#render_failed_responses
  #
  # @see TestAssistant::Configuration#render_failed_responses
  class FailureReporter
    # Base class for generating, saving and opening failure reports. Those classes that
    # inherit from it provide further customisations to better parse and format different
    # request and response bodies, depending on their format.
    class SummaryReporter
      attr_accessor :next, :file_extension

      # Creates a new SummaryReport object
      #
      # @param [ActionDispatch::Request] request the last request made before the test
      #   failed
      # @param [ActionDispatch::TestResponse] response the response to the last request
      #    made before the test failed
      # @param [String] extension what file extension should be used when saving the
      #   failure report
      # @return [SummaryReport] new summary report object
      def initialize(request, response, extension = file_extension)
        @request, @response, @extension = request, response, extension
      end

      # Writes the failure report to the tmp directory in the root of your Rails
      # project so that it may be opened for viewing in an appropriate application
      # depending on the failure report's file extension
      #
      # @return void
      def write
        File.open(file_path, 'w') do |file|
          file.write(summary)
        end
      end

      # Opens the failure report file using an application that depends on the failure
      # report's file extension. Expects that #write has already been called and the
      # file exists.
      #
      # @return void
      def open
        system "open #{file_path}"
      end

      protected

      def summary
        @response.body
      end

      def file_path
        @file_path ||= "#{Rails.root}/tmp/#{DateTime.now.to_i}.#{@extension}"
      end
    end

    class JsonReporter < SummaryReporter
      protected

      def summary
        parsed_json =
          begin
            JSON.parse(@response.body)
          rescue JSON::ParserError
            @response.body
          end

        {
            request: {
                path: @request.path,
                cookies: @request.cookies,
                content_type: @request.content_type,
                format: @request.format,
                referrer: @request.referrer
            },
            response: {
                status: "#{@response.status} #{@response.status_message}",
                cookies: @response.cookies,
                redirect_url: @response.redirect_url
            },
            headers: @response.headers.to_h,
            body: parsed_json
        }.to_json
      end

      def file_extension
        'json'.freeze
      end
    end

    class TextReporter < SummaryReporter
      protected

      def summary
        "<pre>#{@response.body}</pre>"
      end

      def file_extension
        'html'.freeze
      end
    end

    def self.report(request, response)
      extension = file_extension(response.content_type)

      case extension
        when 'txt'
          TextReporter.new(request, response)
        when 'json'
          JsonReporter.new(request, response)
        else
          SummaryReporter.new(request, response, extension)
      end
    end

    def self.file_extension(content_type)
      MIME::Types[content_type].first.extensions.first
    end

  end
end
