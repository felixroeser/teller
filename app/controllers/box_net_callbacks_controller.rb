class BoxNetCallbacksController < ApplicationController
  protect_from_forgery except: :create

  def create
    ImportMediaFromBoxNet.perform_async(params)

    render status: :accepted, nothing: true
  end
end

# Test callback:
#
# {
#          "box_file_name" => "Screenshot_2013-01-20-15-06-18.png",
#              "box_event" => "uploaded",
#          "box_folder_id" => "967183305",
#            "box_file_id" => "",
#     "box_file_extension" => "png",
#            "box_user_id" => "177948700",
#                 "new_id" => "",
#                 "action" => "create",
#             "controller" => "box_net_callbacks"
# }