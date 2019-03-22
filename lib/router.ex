defmodule Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  # TODO: handle fully qualified URLs
  get "/generate/:long_url" do
    long_url = Map.get(conn.params, "long_url")
    UrlShortenr.Controller.generate_short_url(conn, long_url)
  end

  get "/stats" do
    UrlShortenr.Controller.stats(conn)
  end

  get "/:short_url" do
    short_url = Map.get(conn.params, "short_url")
    UrlShortenr.Controller.redirect_to_long_url(conn, short_url)
  end

  get _ do
    send_resp(conn, 404, "Not Found")
  end
end
