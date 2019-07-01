require 'dish'

module RemoteFactoryBot
  class HashToDot
    def self.convert(json)
      Dish(json)
    end
  end
end
