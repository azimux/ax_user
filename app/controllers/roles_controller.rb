class RolesController < ApplicationController
  include Azimux::RequireLoginController

  require_login
  require_role "admin"

  # GET /roles
  # GET /roles.xml
  def index
    @roles = Role.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    ActiveRecord::Base.transaction do
      @role, hash = fill_role(params[:role])

      respond_to do |format|
        if @role.save
          flash[:notice] = 'Role was successfully created.'
          format.html { redirect_to(@role) }
          format.xml  { render :xml => @role, :status => :created, :location => @role }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    ActiveRecord::Base.transaction do
      @role, hash = fill_role(Role.find(params[:id]), params[:role])

      respond_to do |format|
        if @role.update_attributes(hash) && @role.save
          flash[:notice] = 'Role was successfully updated.'
          format.html { redirect_to(@role) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    ActiveRecord::Base.transaction do
      @role = Role.find(params[:id])
      @role.destroy

      respond_to do |format|
        format.html { redirect_to(roles_url) }
        format.xml  { head :ok }
      end
    end
  end

  protected
  def fill_role(role, hash = nil)
    unless hash
      if role.is_a? Hash
        hash = role
        role = nil
      else
        raise "Expected Hash"
      end
    end

    hash = hash.dup
    children = hash.delete('children')
    raise "no children listed" if children.nil?
    children = children.split("\n").map(&:strip).select {|s|!s.blank?}
    children.map! {|p| Role.find_by_name(p)}
    raise "bad roles" if children.any? {|p|p.blank?}

    role ||= Role.new(hash)
    role.children = children

    return role, hash
  end
end
