module TestAssistant
  class FailureReporter
    class SummaryReporter
      attr_accessor :next, :file_extension

      def initialize(request, response, extension = file_extension)
        @request, @response, @extension = request, response, extension
      end

      def write
        File.open(file_path, 'w') do |file|
          file.write(summary)
        end
      end

      def open
        system "open #{file_path}"
      end

      def summary
        @response.body
      end

      protected

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
