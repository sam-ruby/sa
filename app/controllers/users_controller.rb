class UsersController < ApplicationController
  skip_before_filter :authenticate, :only => [:ldap_authenticate]
  def login
    
  end
  
  def ldap_authenticate
    flash.keep
    if ldap_login_success(params[:username], params[:password])
      
      @user = User.find_by_user_name(params[:username])
      if @user == nil
        @user =  User.new
        @user.user_name = params[:username]
        @user.logged_in_count = 1;
      else
        @user.logged_in_count = @user.logged_in_count + 1;
      end
      @user.save!
      session[:username] = params[:username]
      session[:authenticated] = true

      redirect_to session[:return_to]

    else
      redirect_to session[:return_to], notice: "Username/Password incorrect."
    end
  end

    def self.ldap params
      result       = nil

      user_name    = params[:name].to_s
      nt_user_name = user_name
      password     = params[:password].to_s
      return ressult if user_name.nil? or user_name.empty? or
        password.nil? or password.empty?
      user = User.get_item_with_name(user_name)
      if user.nil?
        user = User.create(:name=>user_name, :role=>'search_dev')
      end

      stored_password = BaseUtil.instance.decrypt(user.password)
      @match_stored_password = !password.blank? && password == stored_password

      if ldap_login_success(nt_user_name.to_s, password.to_s)
        result = (nt_user_name && !nt_user_name.empty?) ? nt_user_name : nil
      end
      result
    end

    def ldap_login_success(username, password)
        !find_entry(username, password, %w{ldap.sv.walmartlabs.com}).nil?
    end

    def find_entry(username, password, hosts)
      # Initialize an ldap connection
      ldap = initialize_ldap_con("HOMEOFFICE\\#{username}", password, hosts)

      # If fail to bind to the ldap hosts, fail.
      return nil if !ldap

      # Filter out people with different user names
      user_filter = Net::LDAP::Filter.eq("sAMAccountName", username)

      # Filter out non-people
      op_filter = Net::LDAP::Filter.eq("GEC", "Users")
      treebase  = "DC=homeoffice,DC=Wal-Mart,DC=com"

      puts '##### b'

      # ldap.search(:base => treebase, :filter => op_filter & user_filter) do |entry|
      ldap.search(:base => treebase) do |entry|
        puts entry.inspect

        return entry
      end

      puts '##### a'

      nil
    end

    # Takes a list of hosts and finds the first one which
    # successfully connects via active directory
    def initialize_ldap_con(username, password, hosts)
      result = nil

      hosts.each do |host|
        ldap = Net::LDAP.new({
                               :host => host,
                               :port => 389,
                               :auth => {
                                 :method   => :simple,
                                 :username => username,
                                 :password => password
                               }
                             })

        # If the bind succeeded, return the active connection. Else try the next host
        result = ldap if ldap.get_operation_result.code == 0
      end

      return result
    end

    def logout
      session.destroy
      redirect_to :root

    end
end