module Api
  module V1
    class PaymentsController < Api::V1::ApplicationController

      api :PUT, '/v1/payments/:id', 'Edit Exist Payment'
      param_group :user_token, Api::V1::ApplicationController
      param :id, Integer, desc: 'Payment ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/payments/:id

      # Request Body
      {
        user_token: <USER_TOKEN>,
        id: 10,
        payment: {
          amount: 123
        }
      }

      ########### Response Example ################
      #SUCCESS
      no content

      #FAILURE
      '
      def update
        super
      end

      api :DELETE, '/v1/payments/:id', 'Delete Exist Payment'
      param_group :user_token, Api::V1::ApplicationController
      param :id, Integer, desc: 'Payment ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://api.divecentrehq.com/api/v1/payments/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        id: 1
      }

      ########### Response Example ################
      no content
      '
      def destroy
        super
      end
    end
  end
end
