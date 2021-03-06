module ActsAsApiAuthable
  module RouteSet
    def finalize!
      result = super
      @acts_as_api_authable_finalized ||= begin
        if ActsAsApiAuthable.router_name.nil? && defined?(@acts_as_api_authable_finalized) && self != Rails.application.try(:routes)
          warn "[ActsAsApiAuthable] We have detected that you are using acs_as_api_authable inside engine routes. " \
            "In this case, you probably want to set ActsAsApiAuthable.router_name = MOUNT_POINT, where "   \
            "MOUNT_POINT is a symbol representing where this engine will be mounted at. For "   \
            "now ActsAsApiAuthable will default the mount point to :main_app. You can explicitly set it"   \
            " to :main_app as well in case you want to keep the current behavior."
        end
        true
      end
      result
    end
  end
end

module ActionDispatch::Routing
  class RouteSet #:nodoc:
    # Ensure ActsAsApiAuthable modules are included only after loading routes, because we
    # need acs_as_api_authable mappings already declared to create filters and helpers.
    prepend ActsAsApiAuthable::RouteSet
  end

  class Mapper
    @acts_as_api_authable_finalized = false
    def acts_as_api_auth_for(*resources)
      resources.each do |resource|
        mapping = ActsAsApiAuthable.define_resource(resource, {})

        resource mapping.name, only: [], controller: mapping.controller, path: "", defaults: { class_name: mapping.class_name } do
          get   :list,    path: mapping.path_list
          get   :show,    path: mapping.path_show
          post  :create,  path: mapping.path_create
          match :destroy, path: mapping.path_delete, as: "destroy", via: mapping.sign_out_via
        end
      end
    end

  end
end
