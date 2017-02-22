defmodule SparkPost.MockServer do
  @moduledoc false

  def create_json(endpoint\\"transmission") do
    File.read!("test/data/create#{endpoint}.json")
  end

  def create_fail_json(endpoint\\"transmission") do
    File.read!("test/data/create#{endpoint}fail.json")
  end

  def list_json(endpoint\\"transmission") do
    File.read!("test/data/list#{endpoint}.json")
  end

  def get_json(endpoint\\"transmission") do
    File.read!("test/data/#{endpoint}.json")
  end

  def mk_resp do
    SparkPost.MockServer.mk_http_resp(200, create_json())
  end

  def mk_fail do
    SparkPost.MockServer.mk_http_resp(400, create_fail_json())
  end

  def mk_list do
    SparkPost.MockServer.mk_http_resp(200, list_json())
  end

  def mk_get do
    SparkPost.MockServer.mk_http_resp(200, get_json())
  end

  def mk_http_resp(status_code, body) do
    fn (_method, _url, _body, _headers, _opts) -> {:ok, %HTTPoison.Response{status_code: status_code, body: body}} end
  end
end
