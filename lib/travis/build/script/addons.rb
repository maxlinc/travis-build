require 'travis/build/script/addons/code_climate'
require 'travis/build/script/addons/deploy'
require 'travis/build/script/addons/firefox'
require 'travis/build/script/addons/hosts'
require 'travis/build/script/addons/postgresql'
require 'travis/build/script/addons/sauce_connect'

module Travis
  module Build
    class Script
      module Addons
        MAP = {
          code_climate:  CodeClimate,
          deploy:        Deploy,
          firefox:       Firefox,
          hosts:         Hosts,
          postgresql:    Postgresql,
          sauce_connect: SauceConnect,
        }

        def run_addons(stage)
          addons.each do |addon|
            addon.send(stage) if addon.respond_to?(stage)
          end
        end

        def addons
          @addons ||= addons_config.map do |name, addon_config|
            init_addon(name, addon_config)
          end
        end

        def init_addon(name, config)
          MAP[name].new(self, config)
        end

        def addons_config
          @_addons_config ||= begin
                                addons_config = (config[:addons] || {})
                                if addons_config.is_a?(Array)
                                  addons_config = addons_config.each_with_object({}) do |addons, collector|
                                    addons.each do |name, addon_config|
                                      collector[name] = addon_config
                                    end
                                  end
                                end
                                addons_config
                              end
        end
      end
    end
  end
end
