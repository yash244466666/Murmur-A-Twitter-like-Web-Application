require 'swagger_helper'

RSpec.describe 'Murmurs API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:user) { create(:user) }
  let(:token) { auth_tokens_for_user(user) }
  let!(:murmurs) { create_list(:murmur, 3, user: user) }
  path '/api/murmurs' do
    get 'Retrieves current user\'s murmurs' do
      tags 'Murmurs'
      produces 'application/json'
      security [bearerAuth: []]

      description 'Returns a list of murmurs belonging to the authenticated user'

      response '200', 'murmurs found' do
        schema type: :object,
          properties: {
            murmurs: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  content: { type: :string },
                  created_at: { type: :string, format: 'date-time' },
                  user: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      username: { type: :string },
                      bio: { type: :string }
                    }
                  },
                  likes_count: { type: :integer },
                  liked_by_current_user: { type: :boolean }
                }
              }
            }
          }
        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        run_test!
      end
    end

    post 'Creates a murmur' do
      tags 'Murmurs'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :murmur_params, in: :body, schema: {
        type: :object,
        properties: {
          content: { type: :string, example: 'This is my first murmur!' }
        },
        required: ['content']
      }

      response '201', 'murmur created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            content: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                username: { type: :string },
                bio: { type: :string }
              }
            },
            likes_count: { type: :integer },
            liked_by_current_user: { type: :boolean }
          }
        run_test!
      end

      response '422', 'invalid request' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          }
        run_test!
      end
    end
  end

  path '/api/murmurs/{id}' do
    get 'Get murmur details' do
      tags 'Murmurs'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :id, in: :path, schema: { type: :integer }, required: true, 
                description: 'ID of murmur to retrieve', example: 1

      response '200', 'murmur found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            content: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                username: { type: :string },
                bio: { type: :string }
              }
            },
            likes_count: { type: :integer },
            liked_by_current_user: { type: :boolean }
          }
        run_test!
      end

      response '404', 'murmur not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        run_test!
      end
    end

    delete 'Deletes a murmur' do
      tags 'Murmurs'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, schema: { type: :integer }, required: true, description: 'ID of murmur to delete', example: 1

      response '200', 'murmur deleted' do
        schema type: :object,
          properties: {
            message: { type: :string, example: 'Murmur deleted successfully' }
          }
        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'You are not authorized to perform this action' }
          }
        run_test!
      end

      response '404', 'murmur not found' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'Murmur has already been deleted or does not exist' }
          }
        description 'This error occurs when trying to delete a murmur that has already been deleted or does not exist'
        run_test!
      end
    end
  end

  path '/api/timeline' do
    get 'Retrieves user timeline' do
      tags 'Murmurs'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'timeline retrieved' do
        schema type: :object,
          properties: {
            murmurs: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  content: { type: :string },
                  created_at: { type: :string, format: 'date-time' },
                  user: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      username: { type: :string },
                      bio: { type: :string }
                    }
                  },
                  likes_count: { type: :integer },
                  liked_by_current_user: { type: :boolean }
                }
              }
            }
          }
        run_test!
      end
    end
  end
end
