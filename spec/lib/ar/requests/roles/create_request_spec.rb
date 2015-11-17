require 'spec_helper'

RSpec.describe "Create Role", type: [:request, :role] do
  let(:finder_role_repo)         { Ar::Repositories::Roles::Finder.new }
  let(:finder_resource_repo)     { Ar::Repositories::Resources::Finder.new }
  let(:creator_resource_service) { Ar::Services::Resources::ResourceManagerCreator.new }
  let(:creator_role_service)     { Ar::Services::Roles::RoleManagerCreator.new }
  let(:success_proc)             { ->(r) {} }
  let(:callback)                 { {success: success_proc, fail: ->(e) {raise e} } }

  context 'when have no created resources or actions' do
    let(:resourceable_001)  { double to_s: 'UsersController', actions_methods: [:index, :show, 'edit'] }
    let(:resourceable_002)  { double to_s: 'ContactsController', actions_methods: [:index, 'edit'] }
    let(:resourceables)     { [resourceable_001, resourceable_002] }
    let(:created_resources) { creator_resource_service.create({resourceables: resourceables}, callback) }

    let(:action_ids) { finder_resource_repo.all.first.actions.ids }

    before do
      created_resources
      role_params = {role: {name: 'role_name', description: 'role_description', action_ids: action_ids}}
      creator_role_service.create(role_params, callback)
    end

    it 'should be recorded one role' do
      expect(finder_role_repo.all.size).to be == 1
    end

    it 'should has 2 actions associated' do
      expect(finder_role_repo.all.first.actions.size).to be == 2
    end

    context 'names of associated actions' do
      it {expect(finder_role_repo.all.first.actions.first.name).to eql 'edit'}
      it {expect(finder_role_repo.all.first.actions.second.name).to eql 'index'}
    end

  end

end