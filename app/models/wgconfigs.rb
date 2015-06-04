class Wgconfigs < Settingslogic
  source "#{Rails.root}/config/program_config.yml"
  namespace Rails.env
end