module ActionView #:nodoc:
  class Base
    def initialize(context = nil, assigns = {}, controller = nil, formats = nil) #:nodoc:
      lookup_context = context.is_a?(ActionView::LookupContext) ?
          context : ActionView::LookupContext.new(context)
      @view_renderer = ActionView::Renderer.new(lookup_context)
    end

    ActiveSupport.run_load_hooks(:action_view, self)
  end
end
