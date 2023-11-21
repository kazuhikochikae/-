class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end


  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  
  def change_leader
    @team = Team.find_by(name: params[:id])
    new_leader = User.find(params[:user_id]) # リクエストから新しいリーダーのユーザーIDを取得する（ここではuser_idとしていますが、実際のパラメーター名に合わせてください）

    if current_user == @team.owner && new_leader != @team.owner

      previous_owner = @team.owner # 前のオーナーを保持する

    @team.update(owner: new_leader)
    
    # 新しいオーナーに通知メールを送信する
    AssignMailer.assign_mail(new_leader.email, 'You have been assigned as the new team leader.').deliver_now


      @team.update(owner: new_leader)
      redirect_to @team, notice: "Team leader changed successfully." # 成功時のリダイレクト先や通知メッセージは適宜変更してください
    else
      redirect_to @team, alert: "Unable to change team leader." # 失敗時のリダイレクト先やアラートメッセージは適宜変更してください
    end
  end


  

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
