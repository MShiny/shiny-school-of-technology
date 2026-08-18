class SettingsController < ApplicationController
  def edit
    @app_setting = AppSetting.instance
  end

  def update
    @app_setting = AppSetting.instance

    if @app_setting.update(setting_params)
      redirect_to edit_settings_path, notice: "Default daily goal updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:app_setting).permit(:default_daily_goal)
  end
end
