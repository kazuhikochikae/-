class AgendasController < ApplicationController
  # before_action :set_agenda, only: %i[show edit update destroy]
  before_action :set_agenda, only: [:destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda') 
    else
      render :new
    end
  end

  def destroy
    @agenda = Agenda.find(params[:id])

    # Agendaを作成したユーザーまたは関連するTeamのオーナーのみが削除できるようにする
    if current_user == @agenda.user || current_user == @agenda.team.owner
      team = @agenda.team

      team.users.each do |user|
        AssignMailer.assign_mail(user.email, 'test').deliver_now
        # 通知メールの送信
      end

      @agenda.destroy
      redirect_to dashboard_url
    
    end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
