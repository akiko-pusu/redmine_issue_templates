module Concerns
  module TemplateRenderAction
    extend ActiveSupport::Concern
    def render_for_move_with_format
      respond_to do |format|
        format.html { redirect_to action: 'index' }
        format.xml  { head :ok }
      end
    end
  end
end
