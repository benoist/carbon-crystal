require "./base"

module CarbonDispatch
  module Routing
    module HttpRequestRouter
      macro included
        include CarbonDispatch::Routing::Base

        def should_process?(request, pattern, options)
          request.method == options[:via] && should_process_path?(request.path[1..-1], pattern)
        end
      end

      macro route_exec(mapping, request)
        {% receiver_and_message = mapping.split '#' %}
        {% receiver = receiver_and_message[0] %}
        {% message = receiver_and_message[1] %}

        controller = with_context({{receiver.id.capitalize}}Controller.new(request))
        CarbonSupport::Notifier.instance.instrument(CarbonDispatch::RouteEvent.new("{{receiver.id.capitalize}}", "{{message.id}}")) do
          controller.{{message.id}}
        end
        controller.response
      end

      macro create_view(pattern, mapping)
        {% receiver_and_message = mapping.split '#' %}
        {% receiver = receiver_and_message[0] %}
        {% message = receiver_and_message[1] %}

        class ::Views::{{receiver.id.capitalize}}::{{message.id.capitalize}} < CarbonView::Base
          ecr_file "src/views/{{receiver.id}}/{{message.id}}.html.ecr"
        end
      end

      macro get(pattern, mapping)
        append_route({{pattern}}, {{mapping}}, {via: "GET"})
      end

      macro post(pattern, mapping)
        append_route({{pattern}}, {{mapping}}, {via: "POST"})
      end

      macro root(mapping)
        append_route("", {{mapping}}, {via: "GET"})
      end
    end
  end
end
