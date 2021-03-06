require IEx
defmodule Janitor.AuthController do
  use Janitor.Web, :controller
  use Timex
  import Janitor.DBHelpers
  alias Janitor.User
  alias Janitor.Google

  def connect(conn, _params) do
    redirect conn, external: Google.authorize_url!(scope: "email profile")
  end

  def oauth(conn, %{"code" => code}) do
    params = code |> token |> get_user! |> map_params
    changeset = User.registration_changeset(%User{}, params)
    user = find_or_create_by(User, changeset, :google_id)
    token = user |> sign_jwt_token
    redirect conn, external: client_url(token)
  end

  defp sign_jwt_token({:ok, user}) do
    date =  DateTime.utc_now |> Timex.shift(days: 7)
    JsonWebToken.sign(
      %{user_id: user.id, exp: DateTime.to_unix(date)},
      %{key: System.get_env("JWT_SECRET")})
  end

  defp token(token_string) do
    Google.get_token!(code: token_string)
  end

  defp get_user!(token) do
    user_url = "https://www.googleapis.com/plus/v1/people/me"
    OAuth2.AccessToken.get!(token, user_url)
  end

  defp map_params(data) do

    %{body: %{
        "emails" => [%{"value" => email}],
        "displayName" => name,
        "id" => id,
        "image" => %{"url" => image_url}
      }
    } = data
    [first_name, last_name] = String.split(name)
    %{email: email, google_id: id, first_name: first_name, last_name: last_name, avatar: image_url}
  end

  defp client_url(token) do
    "#{System.get_env("CLIENT_URL")}?token=#{token}"
  end
end
