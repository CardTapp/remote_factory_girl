require 'remote_factory_bot/http.rb'

describe RemoteFactoryBot::Http do

  describe '.post' do

    let(:config) { double(:home_url => 'http://somewhere') }
    let(:params) { double(:first_name => 'Sam', :last_name => 'Iam') }
    let(:rest_client) { double('RestClient') }

    it 'should raise no host config errors' do
      expect(config).to receive(:raise_if_host_not_set)
      allow(rest_client).to receive(:post).with(config.home_url, params, content_type: :json, accept: :json).and_return(true)
      RemoteFactoryBot::Http.post(config, params, rest_client)
    end

    it 'should send http request to home_url with params' do
      expect(rest_client).to receive(:post).with(config.home_url, params, content_type: :json, accept: :json)
      allow(config).to receive(:raise_if_host_not_set)
      RemoteFactoryBot::Http.post(config, params, rest_client)
    end
  end
end
