class BackupsController < ApplicationController
  respond_to :json
  include Util

  def index
  end

  def destroy
    snapshot_ids = params[:ids]
    res = []
    snapshot_ids.each do |snapshot_id|
      res << Hijiki::DcmgrResource::BackupObject.delete(snapshot_id)
    end
    render :json => res
  end

  def list
    data = {
      :start => params[:start].to_i - 1,
      :limit => params[:limit]
    }
    snapshots = Hijiki::DcmgrResource::BackupObject.list(data)
    respond_with(snapshots[0], :to => [:json])
  end

  def show
    snapshot_id = params[:id]
    detail = Hijiki::DcmgrResource::BackupObject.show(snapshot_id)
    respond_with(detail,:to => [:json])
  end
  
  def update
    backup_id = params[:id]
    data = {
      :display_name => params[:display_name]
    }
    backup = Hijiki::DcmgrResource::BackupObject.update(backup_id,data)
    render :json => backup
  end

  def total
    all_resource_count = Hijiki::DcmgrResource::BackupObject.total_resource
    all_resources = Hijiki::DcmgrResource::BackupObject.find(:all,:params => {:start => 0, :limit => all_resource_count})
    resources = all_resources[0].results
    deleted_resource_count = Hijiki::DcmgrResource::BackupObject.get_resource_state_count(resources, 'deleted')
    total = all_resource_count - deleted_resource_count
    render :json => total
  end
end
