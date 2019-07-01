require 'remote_factory_bot/json_to_active_resource'

describe RemoteFactoryBot::JsonToActiveResource do

  describe 'when configured to return active_resource object' do

    class ActiveResource
      def self.find(id); end;
    end

    class User < ActiveResource; end

    it 'should return an active resource object' do
      expect(ActiveResource).to receive(:find).with(1)
      RemoteFactoryBot::JsonToActiveResource.new({:user => {:id => 1}}).resource(User)
    end
  end
end

